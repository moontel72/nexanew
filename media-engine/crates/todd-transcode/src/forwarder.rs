//! GStreamer output forwarding ("OBS-like" fan-out) with the hardware
//! acceleration matrix and multichannel audio mixer.
//!
//! Only compiled with the `gst` feature. Pipeline shape (GStreamer
//! delayed-linking syntax):
//!
//! ```text
//! video: appsrc (application/x-rtp) → depay → [decode → scale → encode]
//!        → queue → mux.
//! audio: appsrc (application/x-rtp) → opus depay → decode → volume
//!        → audiomixer → aac → queue → mux.        (one branch per bus)
//! mux:   flvmux / mpegtsmux / matroskamux → sink
//! ```
//!
//! Zero-copy passthrough: H.264 sources reaching RTMP/SRT/file targets
//! skip decode+encode entirely. Otherwise the encoder stage is chosen by
//! the [`crate::hw`] matrix (NVENC / AMF / QuickSync / x264).

#![cfg(feature = "gst")]

use std::collections::HashMap;
use std::sync::{Arc, Mutex, OnceLock};

use gst::prelude::*;
use gstreamer as gst;
use gstreamer_app::AppSrc;
use todd_common::{
    error::AppError,
    media::{AudioBus, AudioMixerConfig, EncoderKind, EncoderSpec},
    types::{ForwardKind, ForwardTarget},
};
use tokio::sync::{broadcast, mpsc};
use tokio::task::JoinHandle;

use crate::hw::{h264_encode_plan, resolve_encoder, EncodePlan};
use crate::media::{MediaCodec, RtpChunk};

/// How long to wait for an audio bus to prove it is carrying frames.
///
/// A track can be negotiated in the offer and still never send a packet — a
/// phone with the mic muted, or a publisher that only captured video. A branch
/// built for that input stalls `flvmux` (it waits for the stream that never
/// arrives), and the failure takes video egress with it. Bounding the wait
/// means a genuinely silent bus is dropped rather than blocking the output.
///
/// 1.5s is well inside one video keyframe interval at the profiles this engine
/// targets, so a working audio bus primes long before the video queue drains.
const AUDIO_PRIME_TIMEOUT: std::time::Duration = std::time::Duration::from_millis(1500);

/// Error text returned for every `ForwardKind::WebRtcViewer` attempt.
///
/// Kept in one place so the API response, the recorded
/// [`ForwardingStatus`](todd_common::types::ForwardingStatus) and the docs
/// cannot drift apart.
pub const WEBRTC_VIEWER_UNAVAILABLE: &str = "WebRTC viewer fan-out is not available in this build: it needs a \
     signaling service plus gst-plugins-rs `webrtcsink` (see docs/07-sfu-architecture.md). \
     Use Rtmp, Srt or File output instead";

/// One camera subscription shared by every consumer that wants it.
///
/// `inputs` holds the router receivers being drained and `track_order` names
/// them (the two are index-aligned), while `consumers` holds one entry per
/// live pipeline — its id plus one sender per track. A pump task per track
/// reads the router and copies each chunk to every consumer, so a second
/// output (or the MJPEG websocket) observes the same media without subscribing
/// to the router again. That is what makes a forwarder rebuildable without
/// tearing the subscription's consumers down with it.
#[derive(Default)]
struct SharedSubscription {
    /// Router receivers being pumped, one per registered track. The position
    /// is the track's channel index, so it stays aligned with `track_order`
    /// and with every consumer's sender vector.
    inputs: Vec<mpsc::Receiver<RtpChunk>>,
    /// Track names in registration order (index-aligned with `inputs`).
    track_order: Vec<String>,
    /// One entry per consumer: its id, and one sender per track.
    consumers: Vec<(ConsumerId, Vec<mpsc::Sender<RtpChunk>>)>,
    /// Next consumer id. Monotonic, so a released id is never handed out
    /// again while the entry lives.
    next_consumer_id: ConsumerId,
}

impl SharedSubscription {
    /// The fan-out senders for one track, skipping consumers that are gone.
    ///
    /// `is_closed` is synchronous and non-blocking: it reports receivers that
    /// have already been dropped, it never waits on one.
    fn consumers_for(&mut self, track_index: usize) -> Vec<mpsc::Sender<RtpChunk>> {
        let mut live = Vec::with_capacity(self.consumers.len());
        for (_, channels) in self.consumers.iter_mut() {
            let Some(sender) = channels.get_mut(track_index) else {
                continue;
            };
            if sender.is_closed() {
                continue;
            }
            live.push(sender.clone());
        }
        live
    }

    /// The channel index of `track`, if it has been registered.
    fn track_index(&self, track: &str) -> Option<usize> {
        self.track_order.iter().position(|name| name == track)
    }
}

/// A consumer's identity, so its channels can be removed on drop.
///
/// `mpsc::Sender` is not `PartialEq`, and pointer identity does not survive a
/// `clone()`: tokio's sender is a thin wrapper around an `Arc`, so two clones
/// are equal only when compared through that `Arc`. A monotonic id is
/// unambiguous and does not depend on those internals.
type ConsumerId = u64;

/// Fans a live camera subscription out to every output that shares the URL.
type Fanout = Arc<Mutex<HashMap<String, SharedSubscription>>>;

fn forwarder_fanouts() -> &'static Fanout {
    static FANOUTS: OnceLock<Fanout> = OnceLock::new();
    FANOUTS.get_or_init(|| Arc::new(Mutex::new(HashMap::new())))
}

/// Locks the fan-out table, re-taking a poisoned lock instead of failing.
///
/// The tables are self-healing (closed receivers are skipped on every pass),
/// so the poisoned payload is safe to reuse. Returning early would instead
/// stall whichever pump hit the poison, permanently.
fn lock_fanouts(fanouts: &Fanout) -> std::sync::MutexGuard<'_, HashMap<String, SharedSubscription>> {
    match fanouts.lock() {
        Ok(guard) => guard,
        Err(poisoned) => {
            tracing::warn!("forwarder fan-out mutex was poisoned; reusing the subscription tables");
            poisoned.into_inner()
        }
    }
}

/// Every output for one target URL shares a subscription: two outputs to the
/// same destination are consumers of the same media, not two independent
/// readers of the router.
fn fanout_key(target: &ForwardTarget) -> String {
    format!("camera:{}", target.url)
}

/// Registers this pipeline as a consumer of `key`'s shared subscription.
///
/// Returns `(consumer_id, video_rx, audio_rx)` where `audio_rx` holds exactly
/// `tracks - 1` receivers — the video channel is the first one and is returned
/// separately, so the caller's per-bus receivers stay aligned with its bus
/// list. Channels are created per consumer *per track* rather than shared: one
/// shared channel would give every output the same capacity and the same lag
/// policy, so the slowest output would drop frames for all of them.
fn register_consumer(
    key: &str,
    tracks: usize,
) -> (
    ConsumerId,
    mpsc::Receiver<RtpChunk>,
    Vec<mpsc::Receiver<RtpChunk>>,
) {
    // Bounded, live-first: a consumer that lags loses frames instead of
    // building latency into the shared subscription.
    const DEPTH: usize = 240;

    let tracks = tracks.max(1);
    let fanouts = forwarder_fanouts();
    let mut map = lock_fanouts(fanouts);
    let shared = map
        .entry(key.to_string())
        .or_insert_with(SharedSubscription::default);

    let id = shared.next_consumer_id;
    shared.next_consumer_id = shared.next_consumer_id.saturating_add(1);

    let mut senders = Vec::with_capacity(tracks);
    let mut receivers = Vec::with_capacity(tracks);
    for _ in 0..tracks {
        let (tx, rx) = mpsc::channel(DEPTH);
        senders.push(tx);
        receivers.push(rx);
    }
    shared.consumers.push((id, senders));

    let mut receivers = receivers.into_iter();
    let video_rx = receivers.next().unwrap_or_else(closed_channel);
    (id, video_rx, receivers.collect())
}

/// Removes a consumer's channels from the shared subscription.
///
/// Dropping them (rather than sending a sentinel) is what ends the consumer's
/// pipeline feed: a closed receiver makes its push task stop and lets the
/// pipeline reach EOS — exactly the behaviour before fan-out existed.
fn release_consumer(key: &str, id: ConsumerId) {
    let fanouts = forwarder_fanouts();
    let mut map = lock_fanouts(fanouts);
    let Some(shared) = map.get_mut(key) else {
        return;
    };
    let before = shared.consumers.len();
    shared.consumers.retain(|(existing, _)| *existing != id);
    if shared.consumers.len() == before {
        return;
    }
    if shared.consumers.is_empty() {
        // No pipeline consumers left, but the *inputs* stay: a detached
        // consumer (the MJPEG websocket) holds raw receivers and never gets a
        // close signal, because `Sender::closed()` only resolves while a
        // sender exists. Dropping the router receivers here would leave that
        // consumer subscribed to a feed nothing ever pumps.
        tracing::debug!(
            key = %key,
            "last pipeline consumer released; shared inputs kept for detached consumers"
        );
    }
}

/// Hands the caller's router receivers to the shared subscription and starts
/// one pump per track. Idempotent for tracks already registered.
fn register_inputs(key: &str, inputs: Vec<(String, mpsc::Receiver<RtpChunk>)>) {
    let fanouts = forwarder_fanouts();
    let mut map = lock_fanouts(fanouts);
    let Some(shared) = map.get_mut(key) else {
        return;
    };
    for (name, rx) in inputs {
        if let Some(existing) = shared.track_index(&name) {
            tracing::debug!(
                key = %key,
                track = %name,
                index = existing,
                "shared input already registered"
            );
            continue;
        }
        let index = shared.track_order.len();
        shared.track_order.push(name.clone());
        shared.inputs.push(rx);
        // Every consumer has one channel per track; a consumer registered
        // before this track existed has no channel for it, so fill the gap
        // with a sender whose receiver is dropped immediately. It reads as
        // `closed()` on the next pass and is skipped — such a consumer simply
        // does not observe a track its pipeline was not built for.
        for (_, channels) in shared.consumers.iter_mut() {
            while channels.len() <= index {
                let (tx, drop_rx) = mpsc::channel(1);
                drop(drop_rx);
                channels.push(tx);
            }
        }
        spawn_input_pump(fanouts.clone(), key.to_string(), index);
    }
}

/// Pumps one track of a shared subscription out to every consumer.
///
/// `std::sync::MutexGuard` is `!Send`, so it must never be alive across an
/// `.await` in a spawned task — that is a compile error, and it would also
/// deadlock every registration path for as long as the source stays quiet.
/// The receiver is therefore *moved out* of the table while it is awaited, so
/// the lock is only ever held for short synchronous sections.
fn spawn_input_pump(fanouts: Fanout, key: String, track_index: usize) {
    tokio::spawn(async move {
        // `closed_channel()` stands in for the receiver while it is owned by
        // this task. Nothing else reads that slot, because a track index is
        // only ever registered once.
        let mut receiver = {
            let mut map = lock_fanouts(&fanouts);
            match map.get_mut(&key) {
                Some(shared) => match shared.inputs.get_mut(track_index) {
                    Some(slot) => std::mem::replace(slot, closed_channel()),
                    None => return,
                },
                None => return,
            }
        };

        loop {
            let Some(chunk) = receiver.recv().await else {
                // The router receiver closed; there is nothing left to pump.
                return;
            };

            let senders = {
                let mut map = lock_fanouts(&fanouts);
                match map.get_mut(&key) {
                    Some(shared) => shared.consumers_for(track_index),
                    // The subscription went away while a chunk was in flight.
                    None => return,
                }
            };
            fan_out(&senders, chunk);
        }
    });
}

/// Copies one chunk to every live consumer, dropping it for any consumer that
/// has fallen behind (`try_send` never waits).
fn fan_out(senders: &[mpsc::Sender<RtpChunk>], chunk: RtpChunk) {
    let mut chunk = chunk;
    let total = senders.len();
    for (index, tx) in senders.iter().enumerate() {
        if index + 1 == total {
            // The last consumer takes the original value, avoiding a clone.
            let _ = tx.try_send(chunk);
            return;
        }
        // Both arms carry the chunk back: a full consumer drops its copy, a
        // closed one is about to be pruned — either way the next consumer
        // still gets its own copy instead of the frame being swallowed here.
        if let Err(returned) = tx.try_send(chunk) {
            chunk = match returned {
                mpsc::error::TrySendError::Full(returned)
                | mpsc::error::TrySendError::Closed(returned) => returned,
            };
        }
    }
}

pub struct GstForwarder {
    /// Key of the shared subscription this pipeline consumes.
    fanout_key: Option<String>,
    /// This pipeline's identity in that subscription, returned on drop so the
    /// remaining consumers keep it alive.
    fanout_consumer: Option<ConsumerId>,
    pipeline: gst::Pipeline,
    /// Push tasks; aborted on drop.
    push_tasks: Vec<JoinHandle<()>>,
    /// Bus watcher; aborted on drop. Keeps the pipeline's error state live
    /// instead of silently discarding it.
    _bus_task: JoinHandle<()>,
}

impl Drop for GstForwarder {
    fn drop(&mut self) {
        let _ = self.pipeline.set_state(gst::State::Null);
        for task in &self.push_tasks {
            task.abort();
        }
        self._bus_task.abort();
        // Drop this consumer's channels: that closes the pipeline's feed, and
        // the subscription itself survives for the remaining consumers.
        if let (Some(key), Some(id)) = (self.fanout_key.take(), self.fanout_consumer.take()) {
            release_consumer(&key, id);
        }
    }
}

impl GstForwarder {
    /// Builds the pipeline after the first video chunk arrives, because
    /// the depayloader and the passthrough decision depend on the codec.
    ///
    /// `video_rx` carries the video stream of one camera (one simulcast
    /// layer); `audio_rx` carries the camera's audio tracks grouped by
    /// target bus (already routed by the SFU via RID convention).
    ///
    /// `on_fail` fires once when the pipeline reports a fatal bus error, so
    /// the caller can clear the forwarder and let a watchdog rebuild it.
    #[allow(clippy::too_many_arguments)]
    pub async fn build(
        target: &ForwardTarget,
        encoder: EncoderKind,
        spec: EncoderSpec,
        audio_cfg: &AudioMixerConfig,
        mut video_rx: mpsc::Receiver<RtpChunk>,
        audio_rx: Vec<(AudioBus, mpsc::Receiver<RtpChunk>)>,
    ) -> Result<Self, AppError> {
        Self::build_with_callback(
            target,
            encoder,
            spec,
            audio_cfg,
            &mut video_rx,
            audio_rx,
            Box::new(|_| {}),
        )
        .await
    }

    /// [`build`](Self::build) with a failure callback.
    ///
    /// The callback runs once, on the bus watcher thread, the first time the
    /// pipeline reports a fatal error (unreachable RTMP server, rejected
    /// publish, encoder failure). Callers that own shared state use it to
    /// mark the forwarder `Failed` instead of leaving a dead pipeline
    /// reported as `Running`.
    #[allow(clippy::too_many_arguments)]
    pub async fn build_with_callback(
        target: &ForwardTarget,
        encoder: EncoderKind,
        spec: EncoderSpec,
        audio_cfg: &AudioMixerConfig,
        video_rx: &mut mpsc::Receiver<RtpChunk>,
        audio_rx: Vec<(AudioBus, mpsc::Receiver<RtpChunk>)>,
        on_fail: Box<dyn FnOnce(String) + Send + 'static>,
    ) -> Result<Self, AppError> {
        crate::ensure_gst_initialized();
        // The router fans every media type of a layer out on one subscription,
        // so the first chunk seen here can be the camera's Opus audio even
        // though this is the video feed. Taking its codec produced
        // "no video forwarder pipeline for codec Opus" (501) and killed the
        // camera forwarder, so wait for the first *video* chunk instead.
        let first = loop {
            let chunk = video_rx.recv().await.ok_or_else(|| {
                AppError::BadRequest("no RTP received; camera is inactive".to_string())
            })?;
            if matches!(
                chunk.codec,
                MediaCodec::H264 | MediaCodec::Vp8 | MediaCodec::Vp9
            ) {
                break chunk;
            }
        };

        // An audio bus counts as present only once it has actually delivered
        // a chunk. A registered track is not enough: the broadcaster
        // negotiates Opus in its offer even when nothing is feeding it, and a
        // branch built for that silent input stalls the mux — `flvmux` waits
        // for the missing stream, so the *video* never reaches SRS either.
        //
        // Measured against the live engine: video-only egress completed and
        // published while video plus a silent audio branch timed out, and
        // neither `ignore-inactive-pads` nor `start-time-selection=first` on
        // the audiomixer changed that. Dropping the branch is the only shape
        // that works, so the wait is bounded and the bus is dropped if it
        // stays quiet.
        let mut live_audio: Vec<(AudioBus, mpsc::Receiver<RtpChunk>, RtpChunk)> = Vec::new();
        for (bus, mut rx) in audio_rx {
            let deadline = tokio::time::Instant::now() + AUDIO_PRIME_TIMEOUT;
            let primed = loop {
                match tokio::time::timeout_at(deadline, rx.recv()).await {
                    Ok(Some(chunk)) => break Some(chunk),
                    // Channel closed — the publisher went away.
                    Ok(None) => break None,
                    Err(_elapsed) => break None,
                }
            };

            match primed {
                Some(chunk) => live_audio.push((bus, rx, chunk)),
                None => tracing::info!(
                    bus = %bus.as_str(),
                    "audio bus produced no frames within the prime window; forwarding without it"
                ),
            }
        }

        let has_audio = !live_audio.is_empty();

        let detected = crate::hw::detect_encoders();
        let description = build_description(
            target,
            first.codec,
            encoder,
            &spec,
            audio_cfg,
            &detected,
            has_audio,
        )?;

        // Share the caller's router receivers instead of consuming them, so a
        // later rebuild (or the MJPEG websocket) can observe the same media.
        // Registration happens before the pipeline is parsed, so every
        // precondition that can fail fails before shared state exists — a
        // registered consumer with no pipeline would hold the subscription and
        // silently swallow the room's media.
        let key = fanout_key(target);
        let tracks = 1 + live_audio.len();
        let (consumer_id, video_rx_out, audio_rx_out) = register_consumer(&key, tracks);
        register_inputs(
            &key,
            std::iter::once((
                "video".to_string(),
                std::mem::replace(video_rx, closed_channel()),
            ))
            .chain(
                audio_rx
                    .into_iter()
                    .map(|(bus, rx)| (bus.as_str().to_string(), rx)),
            )
            .collect(),
        );

        let pipeline = match parse_and_start(&description) {
            Ok(pipeline) => pipeline,
            Err(e) => {
                release_consumer(&key, consumer_id);
                return Err(e);
            }
        };

        // One blocking push task per input stream. Each task owns its
        // appsrc element and pushes buffers until its channel closes.
        let mut push_tasks = Vec::new();

        let Some(video_src) = pipeline
            .by_name("video_src")
            .and_then(|element| element.downcast::<AppSrc>().ok())
        else {
            release_consumer(&key, consumer_id);
            return Err(AppError::Internal("video appsrc lookup failed".to_string()));
        };
        push_tasks.push(spawn_push_task(video_src, video_rx_out, Some(first)));

        // `register_consumer` returns the audio channels with the video one
        // already taken out, so this stays aligned with `live_audio`.
        for ((bus, rx, primed), _) in live_audio.into_iter().zip(audio_rx_out) {
            let name = format!("audio_{}", bus.as_str());
            match pipeline
                .by_name(&name)
                .and_then(|element| element.downcast::<AppSrc>().ok())
            {
                // `Some(primed)` seeds the branch with the chunk already
                // drained while waiting, so the prime is not discarded.
                Some(appsrc) => push_tasks.push(spawn_push_task(appsrc, rx, Some(primed))),
                None => {
                    tracing::warn!(bus = %bus.as_str(), "audio appsrc not in pipeline; dropping bus");
                }
            }
        }

        tracing::info!(kind = ?target.kind, url = %target.url, "forwarder started");

        // Capture output failures instead of discarding them. This is the
        // signal that was missing: without it a dead RTMP connection stayed
        // reported as `Running` while SRS received nothing.
        let fail_label = format!("camera/{}", target.camera_id);
        let _bus_task = watch_bus(&pipeline, fail_label, on_fail);

        Ok(GstForwarder {
            fanout_key: Some(key),
            fanout_consumer: Some(consumer_id),
            pipeline,
            push_tasks,
            _bus_task,
        })
    }

    /// Builds a forwarder fed from the **mixed program output**: the
    /// compositor's encoded H.264 video + mixed Opus audio. Video is a
    /// zero-copy passthrough (the program bus is already H.264 baseline);
    /// audio is decoded to PCM and re-encoded to AAC for the target mux.
    pub async fn build_program(
        target: &ForwardTarget,
        encoder: EncoderKind,
        spec: &EncoderSpec,
        video: broadcast::Receiver<RtpChunk>,
        audio: broadcast::Receiver<RtpChunk>,
    ) -> Result<Self, AppError> {
        Self::build_program_with_callback(target, encoder, spec, video, audio, Box::new(|_| {}))
            .await
    }

    /// [`build_program`](Self::build_program) with a failure callback fired
    /// once when the pipeline reports a fatal bus error.
    pub async fn build_program_with_callback(
        target: &ForwardTarget,
        encoder: EncoderKind,
        spec: &EncoderSpec,
        video: broadcast::Receiver<RtpChunk>,
        audio: broadcast::Receiver<RtpChunk>,
        on_fail: Box<dyn FnOnce(String) + Send + 'static>,
    ) -> Result<Self, AppError> {
        let description = build_program_description(target, encoder, spec)?;
        let pipeline = parse_and_start(&description)?;

        let video_src = pipeline
            .by_name("video_src")
            .and_then(|element| element.downcast::<AppSrc>().ok())
            .ok_or_else(|| AppError::Internal("video appsrc lookup failed".to_string()))?;
        let audio_src = pipeline
            .by_name("audio_src")
            .and_then(|element| element.downcast::<AppSrc>().ok())
            .ok_or_else(|| AppError::Internal("audio appsrc lookup failed".to_string()))?;

        // Bridge the broadcast receivers (async) into blocking push
        // tasks via bounded mpsc channels.
        let video_rx = bridge_broadcast(video);
        let audio_rx = bridge_broadcast(audio);

        let mut push_tasks = Vec::new();
        push_tasks.push(spawn_push_task(video_src, video_rx, None));
        push_tasks.push(spawn_push_task(audio_src, audio_rx, None));

        tracing::info!(kind = ?target.kind, url = %target.url, "program forwarder started");

        let _bus_task = watch_bus(&pipeline, "program".to_string(), on_fail);

        Ok(GstForwarder {
            // Program forwarders own their broadcast receivers directly; the
            // mixer fans the program bus out already.
            fanout_key: None,
            fanout_consumer: None,
            pipeline,
            push_tasks,
            _bus_task,
        })
    }
}

/// Sanitizes a target URL before it is injected into a GStreamer pipeline
/// string.
///
/// `gst_parse_launch` has no escaping rules of its own: anything that closes
/// the surrounding quotes (a key containing `"`), starts a comment (`#`),
/// separates elements (`!`, `,`, `;`) or breaks the property list (`=`) is
/// parsed as pipeline syntax. That turned a perfectly legal RTMP key into a
/// parse failure, and a malformed one into a pipeline that started with the
/// wrong sink.
///
/// Only characters that are structurally safe inside a quoted pipeline value
/// survive. This also closes the injection surface: an operator-supplied URL
/// can no longer terminate the string it lives in.
fn sanitize_url(raw: &str) -> Result<String, AppError> {
    let trimmed = raw.trim();
    if trimmed.is_empty() {
        return Err(AppError::BadRequest("target URL is empty".to_string()));
    }
    let cleaned: String = trimmed
        .chars()
        .filter(|c| {
            !matches!(
                c,
                '"' | '\\' | '#' | '!' | ',' | ';' | '=' | '\r' | '\n'
            ) && !c.is_control()
        })
        .collect();
    if cleaned.is_empty() {
        return Err(AppError::BadRequest(format!(
            "target URL contains no usable characters: {raw:?}"
        )));
    }
    if cleaned != trimmed {
        tracing::warn!(
            original = %trimmed,
            sanitized = %cleaned,
            "target URL contained characters GStreamer would parse as pipeline syntax; they were removed"
        );
    }
    Ok(cleaned)
}

/// Parses a description and puts the pipeline in `Playing`, releasing it again
/// if either step fails.
///
/// `gst::parse::launch` can return a partially built pipeline whose elements
/// already hold resources; dropping it without a `Null` state change leaves
/// them alive, so the failure path resets it explicitly.
fn parse_and_start(description: &str) -> Result<gst::Pipeline, AppError> {
    let element = gst::parse::launch(description)
        .map_err(|e| AppError::Internal(format!("gst pipeline parse failed: {e}")))?;
    let pipeline = element
        .downcast::<gst::Pipeline>()
        .map_err(|_| AppError::Internal("expected a GStreamer pipeline".to_string()))?;
    if let Err(e) = pipeline.set_state(gst::State::Playing) {
        let _ = pipeline.set_state(gst::State::Null);
        return Err(AppError::Internal(format!("pipeline start failed: {e}")));
    }
    Ok(pipeline)
}

/// A receiver whose sender is already dropped — used as the vacated slot
/// when a receiver is moved out of a `&mut` parameter.
fn closed_channel() -> mpsc::Receiver<RtpChunk> {
    let (tx, rx) = mpsc::channel(1);
    drop(tx);
    rx
}

/// Watches a pipeline's bus and reports the first fatal condition.
///
/// GStreamer reports pipeline failures **asynchronously, on the bus**.
/// `set_state(Playing)` returning `Ok` only means the state change was
/// *accepted*, never that playback works — an `rtmpsink` that cannot reach
/// its server fails seconds later with a bus error while the pipeline keeps
/// reporting `Playing`. Nothing in this crate watched the bus, so every
/// output failure was discarded: the forwarder logged "forwarder started",
/// stayed `Running` forever, and the operator saw a healthy forwarder while
/// SRS never received a single byte.
///
/// This task is the missing signal. It logs the error and invokes `on_fail`
/// (which marks the forwarder `Failed` and clears it) so a failure is
/// visible and recoverable instead of silent.
fn watch_bus<F>(pipeline: &gst::Pipeline, label: String, on_fail: F) -> JoinHandle<()>
where
    F: FnOnce(String) + Send + 'static,
{
    let Some(bus) = pipeline.bus() else {
        tracing::warn!(%label, "pipeline has no bus; output errors cannot be observed");
        return tokio::spawn(async {});
    };

    // `spawn_blocking`: `timed_pop_filtered` blocks, and this must not
    // occupy a runtime worker thread.
    tokio::task::spawn_blocking(move || {
        use gst::MessageView;

        let mut on_fail = Some(on_fail);
        loop {
            // Poll in bounded slices so a healthy pipeline does not pin
            // this thread forever; `Drop` on the forwarder aborts the task.
            let Some(message) = bus.timed_pop_filtered(
                gst::ClockTime::from_seconds(1),
                &[
                    gst::MessageType::Error,
                    gst::MessageType::Eos,
                    gst::MessageType::StateChanged,
                ],
            ) else {
                continue;
            };

            match message.view() {
                MessageView::Error(err) => {
                    let src = err
                        .src()
                        .map(|s| s.path_string().to_string())
                        .unwrap_or_else(|| "unknown".to_string());
                    let detail = format!(
                        "{src}: {} (debug: {})",
                        err.error(),
                        err.debug().unwrap_or_default()
                    );
                    tracing::error!(
                        %label,
                        error = %err.error(),
                        debug = err.debug().unwrap_or_default().as_str(),
                        "forwarder pipeline error"
                    );
                    if let Some(cb) = on_fail.take() {
                        cb(detail);
                    }
                    break;
                }
                MessageView::Eos(..) => {
                    tracing::warn!(%label, "forwarder pipeline reached EOS");
                    if let Some(cb) = on_fail.take() {
                        cb("pipeline reached end-of-stream".to_string());
                    }
                    break;
                }
                MessageView::StateChanged(state) => {
                    // A transition away from PLAYING means the sink could
                    // not be (re)configured — bad URL or unreachable host.
                    if state.current() == gst::State::Null {
                        break;
                    }
                }
                _ => {}
            }
        }
    })
}

/// Bridges a broadcast receiver (async) into a bounded mpsc channel that
/// a blocking appsrc push task can consume.
fn bridge_broadcast(mut from: broadcast::Receiver<RtpChunk>) -> mpsc::Receiver<RtpChunk> {
    let (tx, rx) = mpsc::channel(128);
    tokio::spawn(async move {
        loop {
            match from.recv().await {
                Ok(chunk) => {
                    if tx.send(chunk).await.is_err() {
                        break;
                    }
                }
                Err(broadcast::error::RecvError::Lagged(_)) => continue,
                Err(broadcast::error::RecvError::Closed) => break,
            }
        }
    });
    rx
}

/// Spawns a blocking task that pushes chunks into an appsrc until the
/// channel closes or the pipeline errors.
fn spawn_push_task(
    appsrc: AppSrc,
    mut rx: mpsc::Receiver<RtpChunk>,
    first: Option<RtpChunk>,
) -> JoinHandle<()> {
    tokio::task::spawn_blocking(move || {
        let mut first = first;
        loop {
            let chunk = match first.take() {
                Some(c) => Some(c),
                None => rx.blocking_recv(),
            };
            let Some(chunk) = chunk else { break };
            let mut buffer = match gst::Buffer::with_size(chunk.packet.len()) {
                Ok(buffer) => buffer,
                Err(e) => {
                    tracing::warn!(error = %e, "buffer allocation failed; stopping feed");
                    break;
                }
            };
            if let Some(map) = buffer.get_mut() {
                let _ = map.copy_from_slice(0, &chunk.packet);
            }
            if let Err(e) = appsrc.push_buffer(buffer) {
                tracing::warn!(error = %e, "appsrc push failed; stopping feed");
                break;
            }
        }
        let _ = appsrc.end_of_stream();
    })
}

/// Builds the complete pipeline description for one forwarder.
///
/// Branches link into the mux via named-element delayed linking
/// (`! mux.`), the canonical GStreamer syntax for multi-stream muxers.
#[allow(clippy::too_many_arguments)]
fn build_description(
    target: &ForwardTarget,
    codec: MediaCodec,
    encoder: EncoderKind,
    spec: &EncoderSpec,
    audio_cfg: &AudioMixerConfig,
    detected: &[EncoderKind],
    has_audio: bool,
) -> Result<String, AppError> {
    // ---- video stage -------------------------------------------------
    let rtp_caps = match codec {
        MediaCodec::H264 => "application/x-rtp,media=video,encoding-name=H264,clock-rate=90000",
        MediaCodec::Vp8 => "application/x-rtp,media=video,encoding-name=VP8,clock-rate=90000",
        MediaCodec::Vp9 => "application/x-rtp,media=video,encoding-name=VP9,clock-rate=90000",
        other => {
            return Err(AppError::Unsupported(format!(
                "no video forwarder pipeline for codec {other:?}"
            )))
        }
    };

    let depay = match codec {
        MediaCodec::H264 => "rtph264depay ! h264parse",
        MediaCodec::Vp8 => "rtpvp8depay",
        MediaCodec::Vp9 => "rtpvp9depay",
        _ => unreachable!(),
    };

    // Zero-copy passthrough: H.264 sources reaching any standard target
    // container skip the decode/encode pair entirely.
    let passthrough = matches!(codec, MediaCodec::H264);

    let video_stage = if passthrough {
        "queue name=vq max-size-time=1000000000".to_string()
    } else {
        let decode = match codec {
            MediaCodec::H264 => "avdec_h264",
            MediaCodec::Vp8 => "vp8dec",
            MediaCodec::Vp9 => "vp9dec",
            _ => unreachable!(),
        };
        let kind = resolve_encoder(encoder, detected);
        let plan = h264_encode_plan(kind, spec);
        format!(
            "{depay} ! {decode} ! videoconvert ! videoscale ! videorate ! {} ! queue name=vq max-size-time=1000000000",
            render_encode_stage(&plan)
        )
    };

    // ---- audio stage -------------------------------------------------
    // One branch per *live* audio bus. `has_audio` is decided by the caller
    // from the router's registered tracks, never from the mixer config: an
    // enabled bus with no publisher feeding it produced an `appsrc` that never
    // received a buffer, and the un-negotiated depayloader then took the whole
    // pipeline down with `not-negotiated (-4)` — killing the video egress too.
    // Broadcasting video-only is normal (a phone with the mic muted, or a
    // publisher that only sent a video track), and it must not break output.
    //
    // The bus mixer is declared once, with its output chain, and every bus
    // then links into it with `mix.`.
    //
    // Naming `audiomixer name=mix` on *each* branch left the parser with an
    // element that was never added to the pipeline:
    //   gst pipeline parse failed: could not link vol_ambient to mix
    // which the camera forwarder surfaced as a 500 and never reached SRS.
    //
    // `GstVolume::volume` is a linear factor in [0, 10], not decibels, so the
    // bus dB value is converted (and clamped) before it is emitted - a raw
    // 0.0 dB would otherwise be silence.
    let mut audio_branches: Vec<String> = Vec::new();
    if has_audio {
        audio_branches.push(
            "audiomixer name=mix ! audioconvert ! audioresample \
             ! voaacenc bitrate=128000 ! aacparse \
             ! queue name=aq max-size-time=1000000000 ! mux."
                .to_string(),
        );
        for bus in AudioBus::ALL {
            let bus_cfg = audio_cfg.bus(bus);
            if !bus_cfg.enabled {
                continue;
            }
            let db = if bus_cfg.muted {
                -60.0f32
            } else {
                bus_cfg.volume_db
            };
            let factor = 10f32.powf(db / 20.0);
            let factor = if factor.is_finite() {
                factor.clamp(0.0, 10.0)
            } else {
                1.0
            };
            audio_branches.push(format!(
                // `is-live=false` and a `queue` before the depayloader are what
                // let a bus stay silent without killing the pipeline. With
                // `is-live=true` GStreamer expects a buffer immediately, so an
                // input that never produced one failed negotiation with
                // `not-negotiated (-4)` and took the video egress down with it.
                // A queue absorbs that silence instead: the branch simply
                // carries no audio until its publisher sends some.
                "appsrc name=audio_{} format=time do-timestamp=true is-live=false \
                 caps=\"application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000\" \
                 ! queue max-size-time=200000000 leaky=downstream \
                 ! rtpopusdepay ! opusdec ! audioconvert ! audioresample \
                 ! volume name=vol_{} volume={factor:.6} ! mix.",
                bus.as_str(),
                bus.as_str(),
            ));
        }
    }

    // ---- mux + sink ---------------------------------------------------
    //
    // The URL is sanitized first: it is interpolated into a GStreamer
    // description, where a stray quote or `!` would be parsed as pipeline
    // syntax rather than as part of the location.
    let location = sanitize_url(&target.url)?;
    let mux_tail = match &target.kind {
        ForwardKind::Rtmp => format!(
            "flvmux streamable=true name=mux ! rtmpsink location=\"{location}\" sync=false"
        ),
        ForwardKind::Srt => format!(
            "mpegtsmux name=mux ! srtsink uri=\"{location}\" sync=false"
        ),
        ForwardKind::File => {
            let mux = if location.ends_with(".mp4") {
                "mp4mux"
            } else if location.ends_with(".webm") {
                "webmmux"
            } else {
                "matroskamux"
            };
            format!("{mux} name=mux ! filesink location=\"{location}\" sync=false")
        }
        ForwardKind::WebRtcViewer => {
            return Err(AppError::Unsupported(
                WEBRTC_VIEWER_UNAVAILABLE.to_string(),
            ))
        }
    };

    // ---- assemble -----------------------------------------------------
    let mut description = format!(
        "appsrc name=video_src format=time is-live=true do-timestamp=true caps=\"{rtp_caps}\" \
         ! {depay} ! {video_stage} ! mux."
    );
    if !audio_branches.is_empty() {
        description.push_str(" ");
        description.push_str(&audio_branches.join(" "));
    }
    description.push(' ');
    description.push_str(&mux_tail);
    Ok(description)
}

/// Renders the encoder element + properties + caps into pipeline syntax.
fn render_encode_stage(plan: &EncodePlan) -> String {
    let props: Vec<String> = plan
        .props
        .iter()
        .map(|(name, value)| format!("{name}={value}"))
        .collect();
    if props.is_empty() {
        plan.encoder.clone()
    } else {
        format!("{} {}", plan.encoder, props.join(" "))
    }
}

/// Builds the pipeline description for a **program forwarder**: the
/// compositor's H.264 output passes through zero-copy, the mixed Opus
/// output is decoded and re-encoded to AAC for the target mux.
fn build_program_description(
    target: &ForwardTarget,
    _encoder: EncoderKind,
    _spec: &EncoderSpec,
) -> Result<String, AppError> {
    let location = sanitize_url(&target.url)?;
    let mux_tail = match &target.kind {
        ForwardKind::Rtmp => format!(
            "flvmux streamable=true name=mux ! rtmpsink location=\"{location}\" sync=false"
        ),
        ForwardKind::Srt => format!(
            "mpegtsmux name=mux ! srtsink uri=\"{location}\" sync=false"
        ),
        ForwardKind::File => {
            let mux = if location.ends_with(".mp4") {
                "mp4mux"
            } else if location.ends_with(".webm") {
                "webmmux"
            } else {
                "matroskamux"
            };
            format!("{mux} name=mux ! filesink location=\"{location}\" sync=false")
        }
        ForwardKind::WebRtcViewer => {
            return Err(AppError::Unsupported(
                WEBRTC_VIEWER_UNAVAILABLE.to_string(),
            ))
        }
    };

    Ok(format!(
        "appsrc name=video_src format=time is-live=true do-timestamp=true \
         caps=\"application/x-rtp,media=video,encoding-name=H264,clock-rate=90000\" \
         ! rtph264depay ! h264parse ! queue name=vq max-size-time=1000000000 ! mux. \
         appsrc name=audio_src format=time is-live=true do-timestamp=true \
         caps=\"application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000\" \
         ! rtpopusdepay ! opusdec ! audioconvert ! audioresample \
         ! voaacenc bitrate=128000 ! aacparse \
         ! queue name=aq max-size-time=1000000000 ! mux. \
         {mux_tail}"
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    use todd_common::media::AudioBus;

    /// Regression: a video-only publisher must still produce a working
    /// pipeline.
    ///
    /// The audio buses are enabled by default, so the description used to
    /// build an `appsrc ! rtpopusdepay` branch even when nothing fed it. With
    /// `is-live=true` the depayloader negotiated immediately, never received a
    /// buffer, and failed with `not-negotiated (-4)` — which took the video
    /// egress down with it and left the public page dark for a publisher that
    /// simply sent no audio.
    #[test]
    fn audio_branch_survives_a_silent_bus() {
        let target = ForwardTarget {
            camera_id: "cam-1".to_string(),
            source: Default::default(),
            kind: ForwardKind::Rtmp,
            url: "rtmp://example.test/live/key".to_string(),
            encoder: EncoderKind::Auto,
            bitrate_kbps: 4000,
            keyframe_interval: 60,
            rid: None,
            audio: AudioMixerConfig::default(),
        };
        let description = build_description(
            &target,
            MediaCodec::H264,
            EncoderKind::Auto,
            &EncoderSpec::default(),
            &AudioMixerConfig::default(),
            &[EncoderKind::X264],
            true,
        )
        .expect("description builds");

        // A silent bus must not drive its appsrc as a live source: that is
        // what forced negotiation against zero buffers. Only the audio
        // branches are checked — the video appsrc is legitimately live, since
        // the pipeline is only built once a video chunk has arrived.
        for branch in description.split("appsrc name=audio_").skip(1) {
            assert!(!branch.contains("is-live=true"), "{branch}");
            assert!(branch.contains("leaky=downstream"), "{branch}");
        }

        // Sanity: the audio branches really are in the description, so the
        // loop above is not vacuously true.
        assert!(description.contains("appsrc name=audio_"), "{description}");
        assert!(description.contains("audiomixer name=mix"), "{description}");
    }

    /// The description builder is gst-gated, but the *string* it produces
    /// must be structurally valid — tested here without GStreamer.
    #[test]
    fn description_links_branches_into_mux() {
        let target = ForwardTarget {
            camera_id: "cam-1".to_string(),
            source: Default::default(),
            kind: ForwardKind::Rtmp,
            url: "rtmp://example.test/live/key".to_string(),
            encoder: EncoderKind::Auto,
            bitrate_kbps: 4000,
            keyframe_interval: 60,
            rid: None,
            audio: AudioMixerConfig::default(),
        };
        let description = build_description(
            &target,
            MediaCodec::H264,
            EncoderKind::Auto,
            &EncoderSpec::default(),
            &AudioMixerConfig::default(),
            &[EncoderKind::X264],
            true,
        )
        .expect("description builds");

        assert!(description.contains("name=video_src"));
        assert!(description.contains("name=mux"));
        assert!(description.contains("rtmpsink"));
        assert!(description.contains("rtph264depay"));
        // Passthrough: the *video* path skips decode+encode for H.264.
        //
        // Checked on the video stage specifically rather than by rejecting
        // any "enc" substring: the audio chain legitimately contains
        // `voaacenc`, and the old blanket assertion failed on it as soon as
        // this test could finally be compiled (it is gst-gated, so it had
        // never run).
        let video_stage = description
            .split("rtph264depay")
            .nth(1)
            .and_then(|rest| rest.split("audio_").next())
            .unwrap_or("");
        assert!(!video_stage.contains("x264enc"), "{video_stage}");
        assert!(!video_stage.contains("avdec_h264"), "{video_stage}");
    }

    #[test]
    fn passthrough_skips_encoders_vp8_reencodes() {
        let target = ForwardTarget {
            camera_id: "cam-1".to_string(),
            source: Default::default(),
            kind: ForwardKind::Srt,
            url: "srt://127.0.0.1:9000".to_string(),
            encoder: EncoderKind::Auto,
            bitrate_kbps: 4000,
            keyframe_interval: 60,
            rid: None,
            audio: AudioMixerConfig::default(),
        };
        let vp8 = build_description(
            &target,
            MediaCodec::Vp8,
            EncoderKind::X264,
            &EncoderSpec::default(),
            &AudioMixerConfig::default(),
            &[EncoderKind::X264],
            false,
        )
        .expect("vp8 description builds");
        assert!(vp8.contains("x264enc"));
        assert!(vp8.contains("vp8dec"));
    }

    #[test]
    fn audio_buses_appear_in_description() {
        let target = ForwardTarget {
            camera_id: "cam-1".to_string(),
            source: Default::default(),
            kind: ForwardKind::File,
            url: "/tmp/out.mkv".to_string(),
            encoder: EncoderKind::Auto,
            bitrate_kbps: 4000,
            keyframe_interval: 60,
            rid: None,
            audio: AudioMixerConfig::default(),
        };
        let description = build_description(
            &target,
            MediaCodec::H264,
            EncoderKind::Auto,
            &EncoderSpec::default(),
            &AudioMixerConfig::default(),
            &[EncoderKind::X264],
            true,
        )
        .expect("description builds");
        // The default mixer enables every bus, so each one gets a branch.
        for bus in AudioBus::ALL {
            assert!(
                description.contains(&format!("name=audio_{}", bus.as_str())),
                "{description}"
            );
        }
        assert!(description.contains("audiomixer name=mix"));
        assert!(description.contains("aacparse"));
    }

    #[test]
    fn program_description_passthrough_video_and_reencodes_audio() {
        let target = ForwardTarget {
            camera_id: "ignored-for-program".to_string(),
            source: Default::default(),
            kind: ForwardKind::Rtmp,
            url: "rtmp://a.rtmp.youtube.com/live2/key".to_string(),
            encoder: EncoderKind::Auto,
            bitrate_kbps: 4000,
            keyframe_interval: 60,
            rid: None,
            audio: AudioMixerConfig::default(),
        };
        let description =
            build_program_description(&target, EncoderKind::Auto, &EncoderSpec::default())
                .expect("program description builds");
        assert!(description.contains("name=video_src"));
        assert!(description.contains("name=audio_src"));
        assert!(description.contains("rtph264depay"));
        // Video passthrough: no encoder element in the program path.
        assert!(!description.contains("x264enc"));
        assert!(description.contains("opusdec"));
        assert!(description.contains("voaacenc"));
        assert!(description.contains("flvmux"));
        assert!(description.contains("rtmpsink"));
    }
}
