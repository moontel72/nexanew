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

pub struct GstForwarder {
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

        let detected = crate::hw::detect_encoders();
        let description = build_description(
            target,
            first.codec,
            encoder,
            &spec,
            audio_cfg,
            &detected,
            !audio_rx.is_empty(),
        )?;

        let pipeline = gst::parse::launch(&description)
            .map_err(|e| AppError::Internal(format!("gst pipeline parse failed: {e}")))?
            .downcast::<gst::Pipeline>()
            .map_err(|_| AppError::Internal("expected a GStreamer pipeline".to_string()))?;
        pipeline
            .set_state(gst::State::Playing)
            .map_err(|e| AppError::Internal(format!("pipeline start failed: {e}")))?;

        // One blocking push task per input stream. Each task owns its
        // appsrc element and pushes buffers until its channel closes.
        let mut push_tasks = Vec::new();

        let video_src = pipeline
            .by_name("video_src")
            .and_then(|element| element.downcast::<AppSrc>().ok())
            .ok_or_else(|| AppError::Internal("video appsrc lookup failed".to_string()))?;
        // `replace` moves the receiver out; the caller's slot is left with a
        // closed channel, which is fine because `build_with_callback` owns
        // the receiver for the rest of this call and never reads it again.
        let video_rx = std::mem::replace(video_rx, closed_channel());
        push_tasks.push(spawn_push_task(video_src, video_rx, Some(first)));

        for (bus, rx) in audio_rx {
            let name = format!("audio_{}", bus.as_str());
            match pipeline
                .by_name(&name)
                .and_then(|element| element.downcast::<AppSrc>().ok())
            {
                Some(appsrc) => push_tasks.push(spawn_push_task(appsrc, rx, None)),
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
        let pipeline = gst::parse::launch(&description)
            .map_err(|e| AppError::Internal(format!("gst pipeline parse failed: {e}")))?
            .downcast::<gst::Pipeline>()
            .map_err(|_| AppError::Internal("expected a GStreamer pipeline".to_string()))?;
        pipeline
            .set_state(gst::State::Playing)
            .map_err(|e| AppError::Internal(format!("pipeline start failed: {e}")))?;

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
            pipeline,
            push_tasks,
            _bus_task,
        })
    }
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
                "appsrc name=audio_{} format=time is-live=true do-timestamp=true \
                 caps=\"application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000\" \
                 ! rtpopusdepay ! opusdec ! audioconvert ! audioresample \
                 ! volume name=vol_{} volume={factor:.6} ! mix.",
                bus.as_str(),
                bus.as_str(),
            ));
        }
    }

    // ---- mux + sink ---------------------------------------------------
    let mux_tail = match &target.kind {
        ForwardKind::Rtmp => format!(
            "flvmux streamable=true name=mux ! rtmpsink location=\"{}\" sync=false",
            target.url
        ),
        ForwardKind::Srt => format!(
            "mpegtsmux name=mux ! srtsink uri=\"{}\" sync=false",
            target.url
        ),
        ForwardKind::File => {
            let mux = if target.url.ends_with(".mp4") {
                "mp4mux"
            } else if target.url.ends_with(".webm") {
                "webmmux"
            } else {
                "matroskamux"
            };
            format!(
                "{mux} name=mux ! filesink location=\"{}\" sync=false",
                target.url
            )
        }
        ForwardKind::WebRtcViewer => {
            return Err(AppError::Unsupported(
                "WebRTC viewer output needs a signaling service + gst-plugins-rs webrtcsink; see docs/07-sfu-architecture.md".to_string(),
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
    let mux_tail = match &target.kind {
        ForwardKind::Rtmp => format!(
            "flvmux streamable=true name=mux ! rtmpsink location=\"{}\" sync=false",
            target.url
        ),
        ForwardKind::Srt => format!(
            "mpegtsmux name=mux ! srtsink uri=\"{}\" sync=false",
            target.url
        ),
        ForwardKind::File => {
            let mux = if target.url.ends_with(".mp4") {
                "mp4mux"
            } else if target.url.ends_with(".webm") {
                "webmmux"
            } else {
                "matroskamux"
            };
            format!(
                "{mux} name=mux ! filesink location=\"{}\" sync=false",
                target.url
            )
        }
        ForwardKind::WebRtcViewer => {
            return Err(AppError::Unsupported(
                "WebRTC viewer output needs a signaling service + gst-plugins-rs webrtcsink; see docs/07-sfu-architecture.md".to_string(),
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

    /// The description builder is gst-gated, but the *string* it produces
    /// must be structurally valid — tested here without GStreamer.
    #[test]
    fn description_links_branches_into_mux() {
        let target = ForwardTarget {
            camera_id: "cam-1".to_string(),
            kind: ForwardKind::Rtmp,
            url: "rtmp://example.test/live/key".to_string(),
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
        // Passthrough: no encoder element for H.264 sources.
        assert!(!description.contains("enc"));
    }

    #[test]
    fn passthrough_skips_encoders_vp8_reencodes() {
        let target = ForwardTarget {
            camera_id: "cam-1".to_string(),
            kind: ForwardKind::Srt,
            url: "srt://127.0.0.1:9000".to_string(),
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
            kind: ForwardKind::File,
            url: "/tmp/out.mkv".to_string(),
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
        // Default mixer enables commentary + ambient.
        assert!(description.contains(&format!("name=audio_{}", AudioBus::Commentary.as_str())));
        assert!(description.contains(&format!("name=audio_{}", AudioBus::Ambient.as_str())));
        assert!(description.contains("audiomixer name=mix"));
        assert!(description.contains("aacparse"));
    }

    #[test]
    fn program_description_passthrough_video_and_reencodes_audio() {
        let target = ForwardTarget {
            camera_id: "ignored-for-program".to_string(),
            kind: ForwardKind::Rtmp,
            url: "rtmp://a.rtmp.youtube.com/live2/key".to_string(),
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
