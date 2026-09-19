//! GStreamer program (PGM) mixer — the real server-side compositor.
//!
//! Only compiled with the `gst` feature (libgstreamer >= 1.24). Pipeline
//! shape:
//!
//! ```text
//! per slot i: appsrc (H264 RTP) → rtph264depay → avdec_h264 → videoconvert
//!             → videoscale → videorate → queue → alpha(alpha_i) → compositor.sink_i
//! stinger:    uridecodebin (uri set at runtime) → videoconvert → videoscale
//!             → alpha(stinger_alpha) → compositor.sink_stinger
//! overlays:   gdkpixbufoverlay (watermark) / textoverlay (lower-third,
//!             popup, spectator poll) → alpha gates → compositor
//! compositor → videoconvert → encode (h264) → rtph264pay → appsink → fan-out
//!
//! per bus b:  appsrc (Opus RTP) → rtpopusdepay → opusdec → audioconvert
//!             → volume (fader) → audioamplify (gain) → audiodelay (delay)
//!             → tee: → amix + → S16LE appsink (metering tap)
//! audiomixer ← audiotestsrc silence (keeps a live pad)
//! audiomixer → tee: → S16LE appsink (master metering) + → opusenc →
//!             rtpopuspay → appsink (fan-out)
//! ```
//!
//! Transitions are rendered server-side by animating per-slot `alpha`
//! element properties (fade / stinger) and compositor pad rects (wipe):
//! - Cut: instant alpha swap.
//! - Fade: opacity blend over `duration_ms`.
//! - LumaWipe: geometric reveal (moving window) over `duration_ms`.
//! - Stinger: animated overlay asset ramps 0→1→0 while the program source
//!   swaps behind it.
//!
//! Audio metering taps raw S16LE PCM via appsinks and computes peak/RMS
//! in Rust ([`crate::mixer::compute_levels`]) — no fragile `level`-element
//! message parsing.
//!
//! Program output is standardized on H.264 video + Opus audio (decode →
//! compose → re-encode); scenes referencing non-H.264 sources fall back
//! to passthrough egress at the engine level.

#![cfg(feature = "gst")]

use std::collections::{HashMap, HashSet};
use std::sync::{Arc, Mutex};
use std::time::Duration;

use bytes::Bytes;
use gst::prelude::*;
use gstreamer as gst;
use gstreamer_app::{AppSink, AppSrc};
use todd_common::error::AppError;
use todd_common::media::{AudioBus, AudioMixerConfig, FADER_FLOOR_DB};
use todd_common::types::{OverlayState, SceneLayout, SourceRef, TransitionKind};
use tokio::sync::{broadcast, mpsc};
use tokio::task::JoinHandle;

use crate::hw::{h264_encode_plan, resolve_encoder};
use crate::media::{MediaCodec, RtpChunk};
use crate::mixer::{
    compute_levels, ease_progress, format_poll_text, plan_scene, MixerOutputConfig, PixelRect,
    ScenePlan, SlotPlan, MAX_SLOTS,
};

/// Called with `(bus, peak_db, rms_db)` whenever a metering tap samples
/// PCM. `bus` is `commentary`/`ambient`/`sfx`/`music` or `master`.
pub type MeteringCallback = Arc<dyn Fn(String, f32, f32) + Send + Sync>;

/// Runtime state of one compositor slot.
struct SlotRuntime {
    appsrc: AppSrc,
    alpha: gst::Element,
    pad: gst::Pad,
    task: Option<JoinHandle<()>>,
}

/// The live program compositor for one room.
pub struct GstProgramMixer {
    pipeline: gst::Pipeline,
    slots: Mutex<Vec<SlotRuntime>>,
    stinger_alpha: gst::Element,
    stinger_src: gst::Element,
    /// Corner watermark overlay (gdkpixbufoverlay).
    watermark: gst::Element,
    /// Tournament brand logo overlay (gdkpixbufoverlay, left side).
    brand_logo: gst::Element,
    /// Tournament brand name (textoverlay).
    brand_text: gst::Element,
    /// Alpha gate for the brand name text.
    brand_text_alpha: gst::Element,
    /// Scoreboard lower-third (textoverlay).
    lowerthird: gst::Element,
    /// Animated event popup (textoverlay).
    popup: gst::Element,
    /// Live spectator poll burn-in (textoverlay, persistent while active).
    poll: gst::Element,
    /// Alpha gates of the lower-third / popup / poll branches.
    lt_alpha: gst::Element,
    pop_alpha: gst::Element,
    poll_alpha: gst::Element,
    video_tx: broadcast::Sender<RtpChunk>,
    audio_tx: broadcast::Sender<RtpChunk>,
    width: u32,
    height: u32,
    /// Target output frame rate, used to size animation steps.
    fps: u32,
    /// source key ("room/camera") → slot index bindings.
    bindings: Mutex<HashMap<String, usize>>,
    /// bus name → bound audio feed keys (camera/rid).
    audio_bindings: Mutex<HashMap<String, HashSet<String>>>,
    /// bus name → (feed key, push task); aborted tasks are dropped.
    audio_tasks: Mutex<HashMap<String, Vec<(String, JoinHandle<()>)>>>,
    /// Animation/transition tasks; aborted on drop.
    tasks: Mutex<Vec<JoinHandle<()>>>,
    /// The plan currently being rendered.
    current: Mutex<ScenePlan>,
}

impl Drop for GstProgramMixer {
    fn drop(&mut self) {
        let _ = self.pipeline.set_state(gst::State::Null);
        // Poisoned locks are not trusted, but on drop there is nothing left
        // to rebuild them for: the tasks they guarded are being aborted here,
        // and the whole mixer is going away with them.
        poison::clear_poison(&self.tasks);
        poison::clear_poison(&self.audio_tasks);
        poison::clear_poison(&self.slots);
        if let Ok(tasks) = self.tasks.lock() {
            for task in tasks.iter() {
                task.abort();
            }
        }
        if let Ok(buses) = self.audio_tasks.lock() {
            for (_, tasks) in buses.iter() {
                for (_, task) in tasks {
                    task.abort();
                }
            }
        }
        if let Ok(mut slots) = self.slots.lock() {
            for slot in slots.iter_mut() {
                if let Some(task) = slot.task.take() {
                    task.abort();
                }
            }
        }
    }
}

/// Key of a source in the binding table.
pub fn source_key(source: &SourceRef) -> String {
    format!("{}/{}", source.room_id, source.camera_id)
}

/// Sanitizes a stinger / overlay URI before it is interpolated into a
/// pipeline description.
///
/// Same problem as forwarder target URLs: `gst_parse_launch` has no escaping
/// of its own, so an asset URL containing a quote would terminate the string
/// it lives in and the rest would be parsed as pipeline syntax. Only the
/// characters that are structurally safe inside a quoted value are kept.
fn sanitize_uri(raw: &str) -> String {
    let cleaned: String = raw
        .trim()
        .chars()
        .filter(|c| {
            !matches!(
                c,
                '"' | '\\' | '#' | '!' | ',' | ';' | '=' | '\r' | '\n'
            ) && !c.is_control()
        })
        .collect();
    if cleaned != raw.trim() {
        tracing::warn!(
            original = %raw.trim(),
            sanitized = %cleaned,
            "URI contained characters GStreamer would parse as pipeline syntax; they were removed"
        );
    }
    cleaned
}

/// Audio feed key: "camera/rid" — identifies one live audio track.
pub fn audio_feed_key(camera_id: &str, rid: &str) -> String {
    if rid.is_empty() {
        camera_id.to_string()
    } else {
        format!("{camera_id}/{rid}")
    }
}

/// Installs an S16LE metering tap on an appsink: every PCM buffer is
/// measured and forwarded to `on_metering`.
fn attach_meter_sink(sink: &AppSink, bus_name: &'static str, on_metering: MeteringCallback) {
    let callback = on_metering.clone();
    sink.set_callbacks(
        gstreamer_app::AppSinkCallbacks::builder()
            .new_sample(move |sink| {
                let sample = sink.pull_sample().map_err(|_| gst::FlowError::Error)?;
                let buffer = sample.buffer().ok_or_else(|| gst::FlowError::Error)?;
                let map = buffer.map_readable().map_err(|_| gst::FlowError::Error)?;
                let (peak_db, rms_db) = compute_levels(&map);
                callback(bus_name.to_string(), peak_db, rms_db);
                Ok(gst::FlowSuccess::Ok)
            })
            .build(),
    );
}

impl GstProgramMixer {
    /// Builds the pipeline and starts it. `on_metering` receives level
    /// samples from the per-bus and master metering taps.
    pub fn build(
        config: &MixerOutputConfig,
        on_metering: MeteringCallback,
    ) -> Result<Self, AppError> {
        crate::ensure_gst_initialized();
        let description = build_description(config, MAX_SLOTS)?;
        let pipeline = gst::parse::launch(&description)
            .map_err(|e| AppError::Internal(format!("gst mixer parse failed: {e}")))?
            .downcast::<gst::Pipeline>()
            .map_err(|_| AppError::Internal("expected a GStreamer pipeline".to_string()))?;
        pipeline
            .set_state(gst::State::Playing)
            .map_err(|e| AppError::Internal(format!("mixer pipeline start failed: {e}")))?;

        let compositor = pipeline
            .by_name("comp")
            .ok_or_else(|| AppError::Internal("compositor lookup failed".to_string()))?;

        // Slots are linked in branch order during parsing: src0..srcN map
        // to sink_0..sink_N of the compositor.
        let mut slots = Vec::with_capacity(MAX_SLOTS);
        for index in 0..MAX_SLOTS {
            let appsrc = pipeline
                .by_name(&format!("src{index}"))
                .and_then(|element| element.downcast::<AppSrc>().ok())
                .ok_or_else(|| AppError::Internal(format!("src{index} appsrc lookup failed")))?;
            let alpha = pipeline
                .by_name(&format!("alpha{index}"))
                .ok_or_else(|| AppError::Internal(format!("alpha{index} lookup failed")))?;
            let pad = compositor
                .static_pad(&format!("sink_{index}"))
                .ok_or_else(|| {
                    AppError::Internal(format!("compositor sink_{index} lookup failed"))
                })?;
            slots.push(SlotRuntime {
                appsrc,
                alpha,
                pad,
                task: None,
            });
        }

        let stinger_alpha = pipeline
            .by_name("stinger_alpha")
            .ok_or_else(|| AppError::Internal("stinger_alpha lookup failed".to_string()))?;
        let stinger_src = pipeline
            .by_name("stinger_src")
            .ok_or_else(|| AppError::Internal("stinger_src lookup failed".to_string()))?;
        let watermark = pipeline
            .by_name("watermark")
            .ok_or_else(|| AppError::Internal("watermark lookup failed".to_string()))?;
        let brand_logo = pipeline
            .by_name("brand_logo")
            .ok_or_else(|| AppError::Internal("brand_logo lookup failed".to_string()))?;
        let brand_text = pipeline
            .by_name("brand_text")
            .ok_or_else(|| AppError::Internal("brand_text lookup failed".to_string()))?;
        let brand_text_alpha = pipeline
            .by_name("brand_text_alpha")
            .ok_or_else(|| AppError::Internal("brand_text_alpha lookup failed".to_string()))?;
        let lowerthird = pipeline
            .by_name("lowerthird")
            .ok_or_else(|| AppError::Internal("lowerthird lookup failed".to_string()))?;
        let popup = pipeline
            .by_name("popup")
            .ok_or_else(|| AppError::Internal("popup lookup failed".to_string()))?;
        let lt_alpha = pipeline
            .by_name("lt_alpha")
            .ok_or_else(|| AppError::Internal("lt_alpha lookup failed".to_string()))?;
        let pop_alpha = pipeline
            .by_name("pop_alpha")
            .ok_or_else(|| AppError::Internal("pop_alpha lookup failed".to_string()))?;
        let poll = pipeline
            .by_name("poll")
            .ok_or_else(|| AppError::Internal("poll lookup failed".to_string()))?;
        let poll_alpha = pipeline
            .by_name("poll_alpha")
            .ok_or_else(|| AppError::Internal("poll_alpha lookup failed".to_string()))?;

        let (video_tx, _) = broadcast::channel::<RtpChunk>(256);
        let (audio_tx, _) = broadcast::channel::<RtpChunk>(256);

        // Fan the encoded program video out to WHEP viewers.
        let out_sink = pipeline
            .by_name("out_sink")
            .and_then(|element| element.downcast::<AppSink>().ok())
            .ok_or_else(|| AppError::Internal("out_sink appsink lookup failed".to_string()))?;
        let sink_tx = video_tx.clone();
        out_sink.set_callbacks(
            gstreamer_app::AppSinkCallbacks::builder()
                .new_sample(move |sink| {
                    let sample = sink.pull_sample().map_err(|_| gst::FlowError::Error)?;
                    let buffer = sample.buffer().ok_or_else(|| gst::FlowError::Error)?;
                    let map = buffer.map_readable().map_err(|_| gst::FlowError::Error)?;
                    let chunk = RtpChunk {
                        codec: MediaCodec::H264,
                        rid: None,
                        packet: Bytes::copy_from_slice(&map),
                    };
                    // Live-first: drop when viewers lag rather than
                    // building latency into the program bus.
                    let _ = sink_tx.send(chunk);
                    Ok(gst::FlowSuccess::Ok)
                })
                .build(),
        );

        // Fan the mixed program audio out to WHEP viewers.
        let audio_out = pipeline
            .by_name("audio_out")
            .and_then(|element| element.downcast::<AppSink>().ok())
            .ok_or_else(|| AppError::Internal("audio_out appsink lookup failed".to_string()))?;
        let audio_sink_tx = audio_tx.clone();
        audio_out.set_callbacks(
            gstreamer_app::AppSinkCallbacks::builder()
                .new_sample(move |sink| {
                    let sample = sink.pull_sample().map_err(|_| gst::FlowError::Error)?;
                    let buffer = sample.buffer().ok_or_else(|| gst::FlowError::Error)?;
                    let map = buffer.map_readable().map_err(|_| gst::FlowError::Error)?;
                    let chunk = RtpChunk {
                        codec: MediaCodec::Opus,
                        rid: None,
                        packet: Bytes::copy_from_slice(&map),
                    };
                    let _ = audio_sink_tx.send(chunk);
                    Ok(gst::FlowSuccess::Ok)
                })
                .build(),
        );

        // Per-bus + master metering taps (S16LE PCM → Rust levels).
        for bus in AudioBus::ALL {
            if let Some(sink) = pipeline
                .by_name(&format!("meter_{}", bus.as_str()))
                .and_then(|element| element.downcast::<AppSink>().ok())
            {
                attach_meter_sink(&sink, bus.as_str(), on_metering.clone());
            }
        }
        if let Some(sink) = pipeline
            .by_name("meter_master")
            .and_then(|element| element.downcast::<AppSink>().ok())
        {
            attach_meter_sink(&sink, "master", on_metering.clone());
        }

        tracing::info!(
            width = config.width,
            height = config.height,
            fps = config.fps,
            "program mixer started"
        );

        Ok(Self {
            pipeline,
            slots: Mutex::new(slots),
            stinger_alpha,
            stinger_src,
            watermark,
            brand_logo,
            brand_text,
            brand_text_alpha,
            lowerthird,
            popup,
            poll,
            lt_alpha,
            pop_alpha,
            poll_alpha,
            video_tx,
            audio_tx,
            width: config.width,
            height: config.height,
            fps: config.fps,
            bindings: Mutex::new(HashMap::new()),
            audio_bindings: Mutex::new(HashMap::new()),
            audio_tasks: Mutex::new(HashMap::new()),
            tasks: Mutex::new(Vec::new()),
            current: Mutex::new(plan_scene(&SceneLayout::Fullscreen, &fallback_source(""))),
        })
    }

    /// Subscribes to the encoded program video (H.264 RTP chunks).
    pub fn subscribe_video(&self) -> broadcast::Receiver<RtpChunk> {
        self.video_tx.subscribe()
    }

    /// Subscribes to the mixed program audio (Opus RTP chunks).
    pub fn subscribe_audio(&self) -> broadcast::Receiver<RtpChunk> {
        self.audio_tx.subscribe()
    }

    /// The codec carried on the program video feed.
    pub fn output_codec(&self) -> MediaCodec {
        MediaCodec::H264
    }

    /// Applies the room's overlay state to the compositor: lower-third
    /// scoreboard, animated event popup (fade in/out) and the corner
    /// watermark.
    pub fn apply_overlays(&self, overlays: &OverlayState) {
        // Scoreboard lower-third.
        let lowerthird_on = overlays
            .scoreboard
            .as_ref()
            .map(|scoreboard| scoreboard.enabled)
            .unwrap_or(false);
        if lowerthird_on {
            if let Some(scoreboard) = &overlays.scoreboard {
                let text = if scoreboard.subtitle.trim().is_empty() {
                    scoreboard.title.clone()
                } else {
                    format!("{}\n{}", scoreboard.title, scoreboard.subtitle)
                };
                set_props(&self.lowerthird, &[("text", text)]);
            }
        }
        set_props(
            &self.lt_alpha,
            &[(
                "alpha",
                if lowerthird_on { "1.0" } else { "0.0" }.to_string(),
            )],
        );

        // Event popup: fade in, hold, fade out.
        if let Some(popup) = &overlays.popup {
            let text = match &popup.subtext {
                Some(subtext) if !subtext.trim().is_empty() => {
                    format!("{}\n{}", popup.text, subtext)
                }
                _ => popup.text.clone(),
            };
            set_props(&self.popup, &[("text", text)]);
            let duration = popup.duration_ms.clamp(500, 10_000);
            let fade = (duration / 5).clamp(100, 1000);
            let hold = duration.saturating_sub(2 * fade);
            let alpha = self.pop_alpha.clone();
            // Fall back to the nominal rate if the mixer was built with an
            // unvalidated `fps` of 0.
            let fps = if self.fps == 0 { ANIMATION_FPS } else { self.fps };
            let task = tokio::spawn(async move {
                animate_sync(&alpha, 0.0, 1.0, fade, fps).await;
                tokio::time::sleep(Duration::from_millis(hold)).await;
                animate_sync(&alpha, 1.0, 0.0, fade, fps).await;
            });
            self.push_task(task);
        }

        // Corner watermark / channel logo.
        match &overlays.watermark {
            Some(watermark) => {
                set_props(
                    &self.watermark,
                    &[
                        ("location", watermark.asset_url.clone()),
                        ("relative-x", watermark.x.to_string()),
                        ("relative-y", watermark.y.to_string()),
                        ("alpha", "1.0".to_string()),
                    ],
                );
            }
            None => {
                set_props(&self.watermark, &[("alpha", "0.0".to_string())]);
            }
        }

        // Tournament brand (left side): the manager's own logo + name,
        // opposite the Trace Odd watermark.
        match &overlays.brand {
            Some(brand) => {
                match brand
                    .asset_url
                    .as_deref()
                    .filter(|url| !url.trim().is_empty())
                {
                    Some(url) => {
                        set_props(
                            &self.brand_logo,
                            &[
                                ("location", url.to_string()),
                                ("relative-x", brand.x.to_string()),
                                ("relative-y", brand.y.to_string()),
                                ("alpha", "1.0".to_string()),
                            ],
                        );
                    }
                    None => {
                        set_props(&self.brand_logo, &[("alpha", "0.0".to_string())]);
                    }
                }
                match brand.text.as_deref().filter(|t| !t.trim().is_empty()) {
                    Some(text) => {
                        set_props(
                            &self.brand_text,
                            &[("text", text.to_string())],
                        );
                        set_props(
                            &self.brand_text_alpha,
                            &[("alpha", "1.0".to_string())],
                        );
                    }
                    None => {
                        set_props(
                            &self.brand_text_alpha,
                            &[("alpha", "0.0".to_string())],
                        );
                    }
                }
            }
            None => {
                set_props(&self.brand_logo, &[("alpha", "0.0".to_string())]);
                set_props(
                    &self.brand_text_alpha,
                    &[("alpha", "0.0".to_string())],
                );
            }
        }

        // Live spectator poll: persistent while a poll is active, updated
        // on every vote so WHEP/RTMP viewers follow the tally.
        match &overlays.poll {
            Some(poll) => {
                set_props(
                    &self.poll,
                    &[("text", format_poll_text(poll))],
                );
                set_props(&self.poll_alpha, &[("alpha", "1.0".to_string())]);
            }
            None => {
                set_props(&self.poll_alpha, &[("alpha", "0.0".to_string())]);
            }
        }
    }

    /// Applies the room's audio mix live: faders (`volume`), gain trims
    /// (`audioamplify`), lip-sync delays (`audiodelay`) and solo/mute
    /// semantics per bus.
    pub fn apply_audio_config(&self, config: &AudioMixerConfig) {
        let any_solo = config.buses.iter().any(|spec| spec.solo);
        for bus in AudioBus::ALL {
            let spec = config.bus(bus);
            let audible = spec.audible(any_solo);

            if let Some(volume) = self.pipeline.by_name(&format!("avol_{}", bus.as_str())) {
                let db = if audible {
                    spec.volume_db
                } else {
                    FADER_FLOOR_DB
                };
                // `GstVolume::volume` is a linear factor in [0, 10] (the
                // unbounded knob is `volume-full-range`), not decibels.
                // Handing it a dB value such as "-6.00" makes gst-rs panic
                // with "can't be set from given value, it is invalid or out of
                // range", which unwound the whole transition request (a 502
                // for the director) the moment the mixer finally built.
                let factor = 10f32.powf(db / 20.0);
                let factor = if factor.is_finite() {
                    factor.clamp(0.0, 10.0)
                } else {
                    1.0
                };
                set_props(
                    &volume,
                    &[("volume", format!("{factor:.6}"))],
                );
            }
            if let Some(amplify) = self.pipeline.by_name(&format!("again_{}", bus.as_str())) {
                let linear = 10f32.powf(spec.gain_db / 20.0);
                set_props(
                    &amplify,
                    &[("amplification", format!("{linear:.4}"))],
                );
            }
            if let Some(delay) = self.pipeline.by_name(&format!("adelay_{}", bus.as_str())) {
                // `adelay_{bus}` is a `queue` held at zero latency by default
                // (see `build_description`); `min-threshold-time` is its delay
                // in nanoseconds. The property is checked first because a
                // host shipping a different element build (or the old
                // `identity` pass-through) would otherwise reject the write.
                if delay.find_property("min-threshold-time").is_some() {
                    let nanos = spec.delay_ms.saturating_mul(1_000_000);
                    set_props(
                        &delay,
                        &[("min-threshold-time", nanos.to_string())],
                    );
                }
            }
        }
    }

    /// (Re)binds audio feeds to their bus branches. Feeds whose key set
    /// changed are re-pointed; unchanged bindings keep running.
    ///
    /// `feeds` maps bus → (feed key, live Opus RTP receiver). One bus
    /// appsrc accepts pushes from multiple tasks, so several camera mics
    /// can share a bus.
    pub fn apply_audio_feeds(
        &self,
        mut feeds: HashMap<AudioBus, Vec<(String, mpsc::Receiver<RtpChunk>)>>,
    ) {
        // Poison-tolerant: a panic while a mixer lock was held poisons it for
        // the rest of the process lifetime, and panicking on the poison turns
        // every later vision switch into a dropped connection (nginx 502).
        // The guarded state is a cache of what the pipeline holds, so a
        // poisoned table is *discarded* and rebuilt rather than trusted —
        // `bindings_for` treats an empty table as "nothing is bound yet" and
        // the loop below re-derives every entry from `feeds`.
        let mut bindings = poison::lock_resetting(&self.audio_bindings, "audio_bindings", HashMap::new);
        let mut tasks = poison::lock_resetting(&self.audio_tasks, "audio_tasks", HashMap::new);

        for bus in AudioBus::ALL {
            let bus_name = bus.as_str().to_string();
            let appsrc = match self
                .pipeline
                .by_name(&format!("abus_{bus_name}"))
                .and_then(|element| element.downcast::<AppSrc>().ok())
            {
                Some(appsrc) => appsrc,
                None => {
                    tracing::warn!(bus = %bus_name, "audio bus appsrc missing; skipping feeds");
                    continue;
                }
            };

            // Take ownership of this bus's incoming feeds (receivers are
            // not Clone).
            let incoming: Vec<(String, mpsc::Receiver<RtpChunk>)> =
                feeds.remove(&bus).unwrap_or_default();
            let bound = bindings.entry(bus_name.clone()).or_default();
            let existing = tasks.entry(bus_name.clone()).or_default();

            // Drop tasks for feeds that are no longer present.
            existing.retain(|(key, task)| {
                let keep = incoming.iter().any(|(incoming_key, _)| incoming_key == key);
                if !keep {
                    task.abort();
                }
                keep
            });
            bound.retain(|key| incoming.iter().any(|(incoming_key, _)| incoming_key == key));

            // Spawn push tasks for newly arrived feeds.
            for (key, mut rx) in incoming {
                if bound.contains(&key) {
                    continue;
                }
                let appsrc = appsrc.clone();
                let task = tokio::task::spawn_blocking(move || {
                    while let Some(chunk) = rx.blocking_recv() {
                        let mut buffer = match gst::Buffer::with_size(chunk.packet.len()) {
                            Ok(buffer) => buffer,
                            Err(e) => {
                                tracing::warn!(error = %e, "audio buffer allocation failed");
                                break;
                            }
                        };
                        if let Some(map) = buffer.get_mut() {
                            let _ = map.copy_from_slice(0, &chunk.packet);
                        }
                        if appsrc.push_buffer(buffer).is_err() {
                            break;
                        }
                    }
                    let _ = appsrc.end_of_stream();
                });
                bound.insert(key.clone());
                existing.push((key, task));
            }
        }
    }

    /// Applies a scene: (re)binds slots to sources, sets slot rects and
    /// runs the transition.
    ///
    /// `feeds` maps source key → live H.264 RTP of the camera's lowest
    /// layer. Sources without a feed render as black slots.
    pub fn apply_scene(
        &self,
        plan: &ScenePlan,
        mut feeds: HashMap<String, mpsc::Receiver<RtpChunk>>,
        transition: TransitionKind,
        duration_ms: u64,
        stinger_asset: Option<String>,
    ) {
        if plan.slots.len() > MAX_SLOTS {
            tracing::warn!(
                slots = plan.slots.len(),
                max = MAX_SLOTS,
                "scene exceeds mixer slots; ignoring"
            );
            return;
        }
        {
            // Resetting is the conservative choice here too: the guarded plan
            // is immediately overwritten below anyway, so trusting a
            // half-written value would only risk reading a mangled one.
            let mut guard = poison::lock_resetting(&self.current, "current", ScenePlan::default);
            *guard = plan.clone();
        }

        let mut bindings = poison::lock_resetting(&self.bindings, "bindings", HashMap::new);
        let mut slots = poison::lock_resetting(&self.slots, "slots", Vec::new);

        // Rebind slots: same source keeps its running task, everything
        // else is re-pointed.
        let mut new_bindings: HashMap<String, usize> = HashMap::new();
        for (index, slot_plan) in plan.slots.iter().enumerate() {
            let key = source_key(&slot_plan.source);
            new_bindings.insert(key.clone(), index);
            let was_bound = bindings.get(&key) == Some(&index);
            if !was_bound {
                let slot = &mut slots[index];
                if let Some(task) = slot.task.take() {
                    task.abort();
                }
                // Each source key feeds exactly one slot; take ownership
                // of the receiver (tokio mpsc receivers are not Clone).
                slot.task = feeds.remove(&key).map(|mut rx| {
                    let appsrc = slot.appsrc.clone();
                    tokio::task::spawn_blocking(move || {
                        while let Some(chunk) = rx.blocking_recv() {
                            let mut buffer = match gst::Buffer::with_size(chunk.packet.len()) {
                                Ok(buffer) => buffer,
                                Err(e) => {
                                    tracing::warn!(error = %e, "mixer buffer allocation failed");
                                    break;
                                }
                            };
                            if let Some(map) = buffer.get_mut() {
                                let _ = map.copy_from_slice(0, &chunk.packet);
                            }
                            if appsrc.push_buffer(buffer).is_err() {
                                break;
                            }
                        }
                        let _ = appsrc.end_of_stream();
                    })
                });
            }
        }
        *bindings = new_bindings;

        // Slot rects: apply target geometry immediately; alpha changes
        // follow the transition.
        for (index, slot_plan) in plan.slots.iter().enumerate() {
            let slot = &slots[index];
            set_slot_rect(slot, slot_plan, self.width, self.height);
        }

        // Slots that are no longer used render nothing.
        for (index, slot) in slots.iter().enumerate() {
            if index >= plan.slots.len() {
                set_props(&slot.alpha, &[("alpha", "0.0".to_string())]);
            }
        }

        // Run the transition.
        let duration = duration_ms.min(10_000);
        match transition {
            TransitionKind::Cut => {
                for (index, slot) in slots.iter().enumerate() {
                    let target = if index < plan.slots.len() {
                        format!("{:.4}", plan.slots[index].opacity)
                    } else {
                        "0.0".to_string()
                    };
                    set_props(&slot.alpha, &[("alpha", target)]);
                }
            }
            TransitionKind::Fade => {
                // Crossfade: every slot ramps toward its target opacity;
                // outgoing slots ramp to zero, incoming to their opacity.
                for (index, slot) in slots.iter().enumerate() {
                    let target = if index < plan.slots.len() {
                        plan.slots[index].opacity
                    } else {
                        0.0
                    };
                    set_props(&slot.alpha, &[("alpha", "0.0".to_string())]);
                    let alpha = slot.alpha.clone();
                    let task = animate_alpha(alpha, 0.0, target, duration, self.animation_fps());
                    self.push_task(task);
                }
            }
            TransitionKind::LumaWipe => {
                // Geometric reveal: the incoming slot's window grows
                // across the frame over the duration.
                for (index, slot_plan) in plan.slots.iter().enumerate() {
                    let slot = &slots[index];
                    set_props(&slot.alpha, &[("alpha", "1.0".to_string())]);
                    let pixels = slot_plan.rect.to_pixels(self.width, self.height);
                    let from = PixelRect {
                        x: 0,
                        y: pixels.y,
                        width: 1,
                        height: pixels.height,
                    };
                    let pad = slot.pad.clone();
                    let task = animate_rect(pad, from, pixels, duration, self.animation_fps());
                    self.push_task(task);
                }
            }
            TransitionKind::Stinger => {
                // Swap the program instantly and play the overlay over
                // the swap.
                for (index, slot) in slots.iter().enumerate() {
                    let target = if index < plan.slots.len() {
                        format!("{:.4}", plan.slots[index].opacity)
                    } else {
                        "0.0".to_string()
                    };
                    set_props(&slot.alpha, &[("alpha", target)]);
                }
                let asset = stinger_asset.filter(|url| !url.trim().is_empty());
                match asset {
                    Some(url) if self.stinger_src.find_property("uri").is_some() => {
                        // `stinger_asset` is `Option<String>`, so `url` is a
                        // `&String`; `sanitize_uri` takes `&str`. Deref-coercion
                        // does not apply through the `filter` closure binding.
                        set_props(&self.stinger_src, &[("uri", sanitize_uri(url.as_str()))]);
                        let alpha = self.stinger_alpha.clone();
                        let up = animate_alpha(
                            alpha.clone(),
                            0.0,
                            1.0,
                            duration / 2,
                            self.animation_fps(),
                        );
                        let down = {
                            let alpha = alpha.clone();
                            let fps = self.animation_fps();
                            tokio::spawn(async move {
                                tokio::time::sleep(Duration::from_millis(duration / 2)).await;
                                animate_sync(&alpha, 1.0, 0.0, duration / 2, fps).await;
                            })
                        };
                        self.push_task(up);
                        self.push_task(down);
                    }
                    Some(_) => {
                        tracing::warn!(
                            "stinger asset ignored: this mixer has no file source (no stinger asset configured at build time) — cutting instead"
                        );
                    }
                    None => {
                        tracing::warn!("stinger requested without an asset — falling back to cut");
                    }
                }
            }
        }
    }

    fn push_task(&self, task: JoinHandle<()>) {
        // An empty list here loses nothing but the abort-on-drop guarantee:
        // the tasks still end on their own when their alpha/pad disappears.
        let mut tasks = poison::lock_resetting(&self.tasks, "tasks", Vec::new);
        tasks.retain(|task| !task.is_finished());
        tasks.push(task);
    }

    /// The output frame rate animations should step at, falling back to the
    /// nominal rate when the mixer was built with an unvalidated `fps` of 0.
    fn animation_fps(&self) -> u32 {
        if self.fps == 0 {
            ANIMATION_FPS
        } else {
            self.fps
        }
    }
}

/// Helper for poisoned-mutex recovery: resets the guarded state instead of
/// trusting whatever was half-written when the panic unwound.
mod poison {
    use std::sync::{Mutex, MutexGuard};

    /// Locks `mutex`, replacing a poisoned payload with `fresh()`.
    ///
    /// `poisoned.into_inner()` hands back the *stale* value, and the guarded
    /// structures here are not crash-safe: a panic between "rebind slot 2" and
    /// "rebind slot 3" leaves a table that references tasks which were already
    /// aborted. Trusting that produced transitions that pointed at dead
    /// bindings. Resetting is safe precisely because every one of these
    /// structures is a *cache* of what the pipeline already holds — the
    /// rebuild path re-derives it from the live scene plan.
    /// Two lifetimes are needed because the guard borrows only `mutex`, while
    /// `label` is borrowed independently — a single elided lifetime would make
    /// the guard's lifetime depend on the label string too.
    pub(super) fn lock_resetting<'a, T>(
        mutex: &'a Mutex<T>,
        label: &str,
        fresh: impl FnOnce() -> T,
    ) -> MutexGuard<'a, T> {
        match mutex.lock() {
            Ok(guard) => guard,
            Err(poisoned) => {
                tracing::warn!(
                    state = label,
                    "mutex was poisoned by a panic; discarding the half-written state and rebuilding it"
                );
                drop(poisoned);
                let mut guard = mutex
                    .lock()
                    .unwrap_or_else(|poisoned| poisoned.into_inner());
                *guard = fresh();
                guard
            }
        }
    }

    /// Drops a poisoned payload without reading it (used by `Drop`).
    pub(super) fn clear_poison<T>(mutex: &Mutex<T>) {
        let _ = mutex.clear_poison();
    }
}

fn fallback_source(room: &str) -> SourceRef {
    SourceRef {
        room_id: room.to_string(),
        camera_id: String::new(),
    }
}

/// Applies a slot's target geometry to its compositor pad.
fn set_slot_rect(slot: &SlotRuntime, plan: &SlotPlan, width: u32, height: u32) {
    let rect = plan.rect.to_pixels(width, height);
    set_pad_geometry(
        &slot.pad,
        &[
            ("xpos", rect.x.to_string()),
            ("ypos", rect.y.to_string()),
            ("width", rect.width.to_string()),
            ("height", rect.height.to_string()),
            ("zorder", plan.zorder.to_string()),
        ],
    );
}

/// Writes several string properties on one element, reporting each failure.
///
/// `gst::prelude::GObjectExtManualGst::set_property_from_str` **panics** on an
/// unknown property or an unparsable value — it has no `Result` to inspect. A
/// panic here unwinds the request task, which the operator sees as an opaque
/// 502 with the picture left on its previous value. Deserializing the value
/// first turns that into a logged, skipped update.
fn set_props(element: &gst::Element, props: &[(&str, String)]) {
    for (name, value) in props {
        if let Err(e) = set_prop_checked(element, name, value) {
            tracing::warn!(
                element = %element.name(),
                property = name,
                value = %value,
                error = %e,
                "gst property update failed; element keeps its previous value"
            );
        }
    }
}

/// Writes the compositor pad geometry (a distinct type from `gst::Element`).
fn set_pad_geometry(pad: &gst::Pad, props: &[(&str, String)]) {
    for (name, value) in props {
        if let Err(e) = set_prop_checked(pad, name, value) {
            tracing::warn!(
                pad = %pad.name(),
                property = name,
                value = %value,
                error = %e,
                "gst pad property update failed; pad keeps its previous value"
            );
        }
    }
}

/// The fallible half of a string property write, shared by elements and pads.
///
/// `GObjectExtManualGst::set_property_from_str` **panics** on an unknown
/// property or an unparsable value — it has no `Result` to inspect. A panic
/// here unwinds the request task, which the operator sees as an opaque 502 with
/// the picture left on its previous value. `GstValueExt::deserialize_with_pspec`
/// is what that method uses internally; going through it directly keeps the
/// same semantics but reports the failure instead of aborting.
///
/// `glib` is reached through `gst::glib` because the crate depends on
/// `gstreamer`, not on `glib` itself.
#[cfg(feature = "gst")]
fn set_prop_checked(
    target: &impl IsA<gst::glib::Object>,
    name: &str,
    value: &str,
) -> Result<(), String> {
    use gst::prelude::GstValueExt;

    let pspec = target
        .find_property(name)
        .ok_or_else(|| format!("no property '{name}' on '{}'", target.type_()))?;
    let deserialized = gst::glib::Value::deserialize_with_pspec(value, &pspec)
        .map_err(|e| format!("'{value}' is not valid for {name}: {e}"))?;
    target.set_property_from_value(name, &deserialized);
    Ok(())
}

/// Animates an `alpha` element property over `duration_ms` (spawned task).
fn animate_alpha(
    alpha: gst::Element,
    from: f32,
    to: f32,
    duration_ms: u64,
    fps: u32,
) -> JoinHandle<()> {
    tokio::spawn(async move {
        animate_sync(&alpha, from, to, duration_ms, fps).await;
    })
}

/// Frames per second the animation stepper falls back to when the caller does
/// not know the output rate.
///
/// The step interval is derived from `1000 / fps` rather than hardcoded at
/// 16 ms: at 24 fps output a 16 ms step animates almost three times faster
/// than the frame rate can show, burning CPU on values that are overwritten
/// before they are ever rendered.
pub(crate) const ANIMATION_FPS: u32 = 30;
/// Upper bound on animation steps, so a long fade cannot spawn thousands of
/// property writes (each one crosses into the GStreamer object lock).
const MAX_ANIMATION_STEPS: u64 = 120;

/// Derives the `(step_count, step_ms)` pair for an animation of
/// `duration_ms` at `fps`.
fn animation_steps(duration_ms: u64, fps: u32) -> (u64, u64) {
    // `min_fps` keeps the arithmetic honest for a caller that passes 0 (a
    // config that was never validated): one step per second, never a
    // division by zero.
    let interval_ms = (1000 / fps.max(1) as u64).max(1);
    let steps = (duration_ms / interval_ms).clamp(2, MAX_ANIMATION_STEPS);
    (steps, (duration_ms / steps).max(1))
}

/// Steps an `alpha` element property from `from` to `to` (blocking).
async fn animate_sync(alpha: &gst::Element, from: f32, to: f32, duration_ms: u64, fps: u32) {
    let (steps, step_ms) = animation_steps(duration_ms, fps);
    for index in 1..=steps {
        tokio::time::sleep(Duration::from_millis(step_ms)).await;
        let progress = ease_progress(index as f32 / steps as f32);
        let value = from + (to - from) * progress;
        set_props(alpha, &[("alpha", format!("{value:.4}"))]);
    }
}

/// Animates a compositor pad rect (wipe reveal).
fn animate_rect(
    pad: gst::Pad,
    from: PixelRect,
    to: PixelRect,
    duration_ms: u64,
    fps: u32,
) -> JoinHandle<()> {
    tokio::spawn(async move {
        let (steps, step_ms) = animation_steps(duration_ms, fps);
        for index in 1..=steps {
            tokio::time::sleep(Duration::from_millis(step_ms)).await;
            let progress = ease_progress(index as f32 / steps as f32);
            let x = from.x + ((to.x - from.x) as f32 * progress).round() as i32;
            let width = from.width + ((to.width - from.width) as f32 * progress).round() as i32;
            set_pad_geometry(
                &pad,
                &[
                    ("xpos", x.to_string()),
                    ("width", width.max(1).to_string()),
                ],
            );
        }
    })
}

/// Builds the pipeline description. Split out (like the forwarder's) so
/// the structure can be inspected without running GStreamer.
fn build_description(config: &MixerOutputConfig, slots: usize) -> Result<String, AppError> {
    let mut branches = Vec::with_capacity(slots + AudioBus::ALL.len() * 2 + 6);
    for index in 0..slots {
        branches.push(format!(
            "appsrc name=src{index} format=time is-live=true do-timestamp=true \
             caps=\"application/x-rtp,media=video,encoding-name=H264,clock-rate=90000\" \
             ! rtph264depay ! avdec_h264 ! videoconvert ! videoscale ! videorate \
             ! queue max-size-time=1000000000 \
             ! alpha name=alpha{index} alpha=1.0 ! comp."
        ));
    }
    // Stinger overlay branch: inert until a stinger URI is set at runtime.
    //
    // `uridecodebin` *without* a URI posts "No URI specified to play from."
    // and fails the whole pipeline's state change, so it is only used when an
    // asset is actually configured. Otherwise a black live pattern holds the
    // slot (same element name, so the runtime uri swap and the build-time
    // lookup still resolve).
    //
    // `uridecodebin` is a multi-stream source: its `pad-added` signal can hand
    // back the asset's *audio* pad first. Linking that into `videoconvert` is
    // a caps mismatch, and because the link is created inside the signal
    // handler it took the compositor down with it (`not-negotiated`), not just
    // the stinger. `decodebin` + an explicit `video/x-raw` selector forces the
    // only stream that reaches the compositor to be raw video — any audio pad
    // is simply left unlinked.
    match config
        .stinger_asset_url
        .as_deref()
        .filter(|url| !url.trim().is_empty())
    {
        Some(url) => branches.push(format!(
            "uridecodebin name=stinger_src uri=\"{}\" ! \
             video/x-raw ! videoconvert ! videoscale \
             ! alpha name=stinger_alpha alpha=0.0 ! comp.",
            sanitize_uri(url)
        )),
        None => branches.push(
            "videotestsrc name=stinger_src pattern=black is-live=true \
             ! videoconvert ! videoscale \
             ! alpha name=stinger_alpha alpha=0.0 ! comp."
                .to_string(),
        ),
    }

    // ---- program overlay burn-in branches (stack above the video) -----
    //
    // Every overlay is its own compositor layer, so each branch needs its own
    // source: `gdkpixbufoverlay`/`textoverlay` are filters, and a branch whose
    // sink pad is unlinked never delivers a buffer — the compositor then waits
    // for that pad forever and the *whole* mixer produces nothing (no PGM
    // egress, no program-forwarder data, no metering). A fully transparent live
    // pattern is the layer base; the overlay draws onto it and the alpha gate
    // (or the overlay's own `alpha`) keeps it invisible until enabled.
    branches.push(format!(
        "videotestsrc name=ov_base pattern=solid-color foreground-color=0x00000000 \
         is-live=true \
         ! video/x-raw,format=AYUV,width={w},height={h},framerate={fps}/1 \
         ! tee name=ov_tee",
        w = config.width,
        h = config.height,
        fps = config.fps,
    ));
    // Corner watermark / channel logo (transparent PNG).
    branches.push(
        "ov_tee. ! queue ! gdkpixbufoverlay name=watermark relative-x=0.965 relative-y=0.02 alpha=0.0 ! comp."
            .to_string(),
    );
    // Tournament brand (left side): the manager's own logo + name.
    branches.push(
        "ov_tee. ! queue ! gdkpixbufoverlay name=brand_logo relative-x=0.02 relative-y=0.02 alpha=0.0 ! comp."
            .to_string(),
    );
    branches.push(
        "ov_tee. ! queue ! textoverlay name=brand_text text=\"\" valignment=top halignment=left xpos=70 ypos=6 \
         line-alignment=left shaded-background=true font-desc=\"Sans Bold 20\" \
         ! alpha name=brand_text_alpha alpha=0.0 ! comp."
            .to_string(),
    );
    // Scoreboard lower-third.
    branches.push(
        "ov_tee. ! queue ! textoverlay name=lowerthird text=\"\" valignment=bottom halignment=center ypos=70 \
         line-alignment=center shaded-background=true font-desc=\"Sans Bold 26\" \
         ! alpha name=lt_alpha alpha=0.0 ! comp."
            .to_string(),
    );
    // Animated event popup (SIX / FOUR / WICKET / milestone).
    branches.push(
        "ov_tee. ! queue ! textoverlay name=popup text=\"\" valignment=center halignment=center \
         line-alignment=center shaded-background=true font-desc=\"Sans Bold 64\" \
         ! alpha name=pop_alpha alpha=0.0 ! comp."
            .to_string(),
    );
    // Live spectator poll (persistent while a poll is active).
    branches.push(
        "ov_tee. ! queue ! textoverlay name=poll text=\"\" valignment=top halignment=center ypos=28 \
         line-alignment=center shaded-background=true font-desc=\"Sans Bold 22\" \
         ! alpha name=poll_alpha alpha=0.0 ! comp."
            .to_string(),
    );

    // ---- audio stage: one branch per bus + silence keep-alive pad -----
    //
    // Lip-sync correction uses a named `queue` with `min-threshold-time`
    // instead of `audiodelay`: that element is no longer shipped by
    // GStreamer (nothing in the 1.24 plugin set registers it), and
    // referencing it made `gst_parse_launch` reject the *whole* mixer
    // description with `no element "audiodelay"`. That single missing element
    // silently downgraded PGM to passthrough and blocked add_program_forwarder
    // with 409, so the public HLS stream never started.
    //
    // A `queue` always exists in coreelements, and its `min-threshold-time`
    // (nanoseconds) holds every buffer back by exactly that much before it is
    // pushed downstream — the same effect `audiodelay` had, so
    // `apply_audio_config()` can really honour `delay_ms` now instead of
    // writing to a pass-through that ignored it.
    //
    // Each bus also has to reach the mixer through `audioconvert`: linking a
    // `tee` src pad straight into `audiomixer` fails at parse time with
    // `could not link btee_{bus} to amix`.
    for bus in AudioBus::ALL {
        branches.push(format!(
            "appsrc name=abus_{bus} format=time is-live=true do-timestamp=true \
             caps=\"application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000\" \
             ! rtpopusdepay ! opusdec ! audioconvert ! audioresample \
             ! volume name=avol_{bus} \
             ! audioamplify name=again_{bus} amplification=1.0 \
             ! queue name=adelay_{bus} min-threshold-time=0 max-size-time=1000000000 \
             ! tee name=btee_{bus} \
             btee_{bus}. ! queue ! audioconvert ! audioresample \
             ! audio/x-raw,format=S16LE,rate=48000,channels=2 \
             ! appsink name=meter_{bus} sync=false \
             btee_{bus}. ! audioconvert ! amix.",
            bus = bus.as_str(),
        ));
    }
    // A silence pad keeps the audiomixer live when every bus is idle.
    branches.push("audiotestsrc wave=silence is-live=true ! amix.".to_string());

    let detected = crate::hw::detect_encoders();
    let kind = resolve_encoder(config.encoder, &detected);
    let plan = h264_encode_plan(
        kind,
        &todd_common::media::EncoderSpec {
            bitrate_kbps: config.bitrate_kbps,
            keyframe_interval: (config.fps * 2).max(1),
        },
    );
    let props: Vec<String> = plan
        .props
        .iter()
        .map(|(name, value)| format!("{name}={value}"))
        .collect();
    let encoder_stage = if props.is_empty() {
        plan.encoder.clone()
    } else {
        format!("{} {}", plan.encoder, props.join(" "))
    };

    let video_tail = format!(
        "compositor name=comp background=black \
         ! videoconvert ! videoscale ! videorate ! video/x-raw,framerate={fps}/1 \
         ! {encoder_stage} ! video/x-h264,profile=baseline \
         ! rtph264pay pt=96 ! queue max-size-time=1000000000 \
         ! appsink name=out_sink sync=false",
        fps = config.fps,
    );
    let audio_tail = "audiomixer name=amix \
         ! tee name=audio_tee \
         audio_tee. ! queue ! audioconvert ! audioresample \
         ! audio/x-raw,format=S16LE,rate=48000,channels=2 \
         ! appsink name=meter_master sync=false \
         audio_tee. ! audioconvert ! audioresample \
         ! opusenc ! rtpopuspay pt=111 \
         ! queue max-size-time=1000000000 \
         ! appsink name=audio_out sync=false"
        .to_string();

    Ok(format!(
        "{} {} {}",
        branches.join(" "),
        video_tail,
        audio_tail
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    use todd_common::media::EncoderKind;
    use todd_common::types::StingerSpec;

    #[test]
    fn description_contains_slots_compositor_and_encoder() {
        let config = MixerOutputConfig {
            width: 1280,
            height: 720,
            fps: 30,
            bitrate_kbps: 2500,
            encoder: EncoderKind::X264,
            stinger_asset_url: None,
        };
        let description = build_description(&config, 4).expect("description builds");
        assert!(description.contains("name=comp"));
        assert!(description.contains("name=src0"));
        assert!(description.contains("name=alpha3"));
        assert!(description.contains("x264enc"));
        assert!(description.contains("rtph264pay"));
        assert!(description.contains("name=stinger_src"));
        assert!(description.contains("name=out_sink"));
        // H.264 slots: depay + software decode.
        assert!(description.contains("rtph264depay"));
        assert!(description.contains("avdec_h264"));
    }

    #[test]
    fn description_contains_audio_buses_and_metering_taps() {
        let config = MixerOutputConfig {
            width: 1280,
            height: 720,
            fps: 30,
            bitrate_kbps: 2500,
            encoder: EncoderKind::X264,
            stinger_asset_url: None,
        };
        let description = build_description(&config, 2).expect("description builds");
        for bus in AudioBus::ALL {
            assert!(description.contains(&format!("name=avol_{}", bus.as_str())));
            assert!(description.contains(&format!("name=again_{}", bus.as_str())));
            assert!(description.contains(&format!("name=adelay_{}", bus.as_str())));
            assert!(description.contains(&format!("name=meter_{}", bus.as_str())));
        }
        assert!(description.contains("audiomixer name=amix"));
        assert!(description.contains("name=meter_master"));
        assert!(description.contains("audio/x-raw,format=S16LE"));
        assert!(description.contains("audiotestsrc wave=silence"));
        assert!(description.contains("rtpopuspay"));
        assert!(description.contains("name=audio_out"));
    }

    #[test]
    fn description_contains_overlay_branches() {
        let config = MixerOutputConfig {
            width: 1280,
            height: 720,
            fps: 30,
            bitrate_kbps: 2500,
            encoder: EncoderKind::X264,
            stinger_asset_url: None,
        };
        let description = build_description(&config, 2).expect("description builds");
        assert!(description.contains("name=watermark"));
        assert!(description.contains("name=brand_logo"));
        assert!(description.contains("name=brand_text"));
        assert!(description.contains("name=lowerthird"));
        assert!(description.contains("name=lt_alpha"));
        assert!(description.contains("name=popup"));
        assert!(description.contains("name=pop_alpha"));
        assert!(description.contains("name=poll"));
        assert!(description.contains("name=poll_alpha"));
    }

    #[test]
    fn source_keys_are_stable() {
        let source = SourceRef {
            room_id: "r-1".to_string(),
            camera_id: "cam-2".to_string(),
        };
        assert_eq!(source_key(&source), "r-1/cam-2");
    }

    #[test]
    fn audio_feed_keys_encode_rid() {
        assert_eq!(audio_feed_key("cam-1", ""), "cam-1");
        assert_eq!(audio_feed_key("cam-1", "commentary"), "cam-1/commentary");
    }

    #[test]
    fn stinger_spec_defaults_to_no_asset() {
        let spec = StingerSpec::default();
        assert!(spec.asset_url.is_none());
    }
}
