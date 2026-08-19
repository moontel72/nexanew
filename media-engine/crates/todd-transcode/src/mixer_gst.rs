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
//! compositor → videoconvert → encode (h264) → rtph264pay → appsink → fan-out
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
//! Program output is standardized on H.264 (decode → compose → re-encode);
//! scenes referencing non-H.264 sources fall back to passthrough egress at
//! the engine level.

#![cfg(feature = "gst")]

use std::collections::HashMap;
use std::sync::Mutex;
use std::time::Duration;

use bytes::Bytes;
use gst::prelude::*;
use gstreamer as gst;
use gstreamer_app::{AppSink, AppSrc};
use todd_common::error::AppError;
use todd_common::types::{SceneLayout, SourceRef, StingerSpec, TransitionKind};
use tokio::sync::{broadcast, mpsc};
use tokio::task::JoinHandle;

use crate::hw::{h264_encode_plan, resolve_encoder};
use crate::media::{MediaCodec, RtpChunk};
use crate::mixer::{
    ease_progress, plan_scene, MixerOutputConfig, PixelRect, ScenePlan, SlotPlan, MAX_SLOTS,
};

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
    slots: Vec<SlotRuntime>,
    stinger_alpha: gst::Element,
    stinger_src: gst::Element,
    video_tx: broadcast::Sender<RtpChunk>,
    width: u32,
    height: u32,
    /// source key ("room/camera") → slot index bindings.
    bindings: Mutex<HashMap<String, usize>>,
    /// Animation/transition tasks; aborted on drop.
    tasks: Mutex<Vec<JoinHandle<()>>>,
    /// The plan currently being rendered.
    current: Mutex<ScenePlan>,
}

impl Drop for GstProgramMixer {
    fn drop(&mut self) {
        let _ = self.pipeline.set_state(gst::State::Null);
        if let Ok(tasks) = self.tasks.lock() {
            for task in tasks.iter() {
                task.abort();
            }
        }
        for slot in &mut self.slots {
            if let Some(task) = slot.task.take() {
                task.abort();
            }
        }
    }
}

/// Key of a source in the binding table.
pub fn source_key(source: &SourceRef) -> String {
    format!("{}/{}", source.room_id, source.camera_id)
}

impl GstProgramMixer {
    /// Builds the pipeline and starts it.
    pub fn build(config: &MixerOutputConfig) -> Result<Self, AppError> {
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
                .get_static_pad(&format!("sink_{index}"))
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

        let (video_tx, _) = broadcast::channel::<RtpChunk>(256);

        // Fan the encoded program video out to WHEP viewers.
        let out_sink = pipeline
            .by_name("out_sink")
            .and_then(|element| element.downcast::<AppSink>().ok())
            .ok_or_else(|| AppError::Internal("out_sink appsink lookup failed".to_string()))?;
        let sink_tx = video_tx.clone();
        out_sink.set_callbacks(
            gstreamer_app::AppSinkCallbacks::builder()
                .new_sample(move |sink| {
                    let sample = sink.pull_sample()?;
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

        tracing::info!(
            width = config.width,
            height = config.height,
            fps = config.fps,
            "program mixer started"
        );

        Ok(Self {
            pipeline,
            slots,
            stinger_alpha,
            stinger_src,
            video_tx,
            width: config.width,
            height: config.height,
            bindings: Mutex::new(HashMap::new()),
            tasks: Mutex::new(Vec::new()),
            current: Mutex::new(plan_scene(&SceneLayout::Fullscreen, &fallback_source(""))),
        })
    }

    /// Subscribes to the encoded program video (H.264 RTP chunks).
    pub fn subscribe_video(&self) -> broadcast::Receiver<RtpChunk> {
        self.video_tx.subscribe()
    }

    /// The codec carried on the program video feed.
    pub fn output_codec(&self) -> MediaCodec {
        MediaCodec::H264
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
            let mut guard = self.current.lock().expect("mixer state poisoned");
            *guard = plan.clone();
        }

        let mut bindings = self.bindings.lock().expect("mixer bindings poisoned");

        // Rebind slots: same source keeps its running task, everything
        // else is re-pointed.
        let mut new_bindings: HashMap<String, usize> = HashMap::new();
        for (index, slot_plan) in plan.slots.iter().enumerate() {
            let key = source_key(&slot_plan.source);
            new_bindings.insert(key.clone(), index);
            let was_bound = bindings.get(&key) == Some(&index);
            if !was_bound {
                let slot = &mut self.slots[index];
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
                                map.copy_from_slice(0, &chunk.packet);
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
            let slot = &self.slots[index];
            set_slot_rect(slot, slot_plan, self.width, self.height);
        }

        // Slots that are no longer used render nothing.
        for (index, slot) in self.slots.iter().enumerate() {
            if index >= plan.slots.len() {
                let _ = slot.alpha.set_property_from_str("alpha", "0.0");
            }
        }

        // Run the transition.
        let duration = duration_ms.min(10_000);
        match transition {
            TransitionKind::Cut => {
                for (index, slot) in self.slots.iter().enumerate() {
                    let target = if index < plan.slots.len() {
                        format!("{:.4}", plan.slots[index].opacity)
                    } else {
                        "0.0".to_string()
                    };
                    let _ = slot.alpha.set_property_from_str("alpha", &target);
                }
            }
            TransitionKind::Fade => {
                // Crossfade: every slot ramps toward its target opacity;
                // outgoing slots ramp to zero, incoming to their opacity.
                for (index, slot) in self.slots.iter().enumerate() {
                    let target = if index < plan.slots.len() {
                        plan.slots[index].opacity
                    } else {
                        0.0
                    };
                    let _ = slot.alpha.set_property_from_str("alpha", "0.0");
                    let alpha = slot.alpha.clone();
                    let task = animate_alpha(alpha, 0.0, target, duration);
                    self.push_task(task);
                }
            }
            TransitionKind::LumaWipe => {
                // Geometric reveal: the incoming slot's window grows
                // across the frame over the duration.
                for (index, slot_plan) in plan.slots.iter().enumerate() {
                    let slot = &self.slots[index];
                    let _ = slot.alpha.set_property_from_str("alpha", "1.0");
                    let from = PixelRect {
                        x: 0,
                        y: slot_plan.rect.to_pixels(self.width, self.height).y,
                        width: 1,
                        height: slot_plan.rect.to_pixels(self.width, self.height).height,
                    };
                    let to = slot_plan.rect.to_pixels(self.width, self.height);
                    let pad = slot.pad.clone();
                    let task = animate_rect(pad, from, to, duration);
                    self.push_task(task);
                }
            }
            TransitionKind::Stinger => {
                // Swap the program instantly and play the overlay over
                // the swap.
                for (index, slot) in self.slots.iter().enumerate() {
                    let target = if index < plan.slots.len() {
                        format!("{:.4}", plan.slots[index].opacity)
                    } else {
                        "0.0".to_string()
                    };
                    let _ = slot.alpha.set_property_from_str("alpha", &target);
                }
                let asset = stinger_asset.filter(|url| !url.trim().is_empty());
                match asset {
                    Some(url) => {
                        let _ = self.stinger_src.set_property_from_str("uri", &url);
                        let alpha = self.stinger_alpha.clone();
                        let up = animate_alpha(alpha.clone(), 0.0, 1.0, duration / 2);
                        let down = {
                            let alpha = alpha.clone();
                            tokio::spawn(async move {
                                tokio::time::sleep(Duration::from_millis(duration / 2)).await;
                                animate_sync(&alpha, 1.0, 0.0, duration / 2).await;
                            })
                        };
                        self.push_task(up);
                        self.push_task(down);
                    }
                    None => {
                        tracing::warn!("stinger requested without an asset — falling back to cut");
                    }
                }
            }
        }
    }

    fn push_task(&self, task: JoinHandle<()>) {
        let mut tasks = self.tasks.lock().expect("mixer tasks poisoned");
        tasks.retain(|task| !task.is_finished());
        tasks.push(task);
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
    let _ = slot.pad.set_property_from_str("xpos", &rect.x.to_string());
    let _ = slot.pad.set_property_from_str("ypos", &rect.y.to_string());
    let _ = slot
        .pad
        .set_property_from_str("width", &rect.width.to_string());
    let _ = slot
        .pad
        .set_property_from_str("height", &rect.height.to_string());
    let _ = slot
        .pad
        .set_property_from_str("zorder", &plan.zorder.to_string());
}

/// Animates an `alpha` element property over `duration_ms` (spawned task).
fn animate_alpha(alpha: gst::Element, from: f32, to: f32, duration_ms: u64) -> JoinHandle<()> {
    tokio::spawn(async move {
        animate_sync(&alpha, from, to, duration_ms).await;
    })
}

/// Steps an `alpha` element property from `from` to `to` (blocking).
async fn animate_sync(alpha: &gst::Element, from: f32, to: f32, duration_ms: u64) {
    let steps = (duration_ms / 16).clamp(2, 120) as u32;
    let step_ms = (duration_ms / steps as u64).max(1);
    for index in 1..=steps {
        tokio::time::sleep(Duration::from_millis(step_ms)).await;
        let progress = ease_progress(index as f32 / steps as f32);
        let value = from + (to - from) * progress;
        let _ = alpha.set_property_from_str("alpha", &format!("{value:.4}"));
    }
}

/// Animates a compositor pad rect (wipe reveal).
fn animate_rect(pad: gst::Pad, from: PixelRect, to: PixelRect, duration_ms: u64) -> JoinHandle<()> {
    tokio::spawn(async move {
        let steps = (duration_ms / 16).clamp(2, 120) as u32;
        let step_ms = (duration_ms / steps as u64).max(1);
        for index in 1..=steps {
            tokio::time::sleep(Duration::from_millis(step_ms)).await;
            let progress = ease_progress(index as f32 / steps as f32);
            let x = from.x + ((to.x - from.x) as f32 * progress).round() as i32;
            let width = from.width + ((to.width - from.width) as f32 * progress).round() as i32;
            let _ = pad.set_property_from_str("xpos", &x.to_string());
            let _ = pad.set_property_from_str("width", &width.max(1).to_string());
        }
    })
}

/// Builds the pipeline description. Split out (like the forwarder's) so
/// the structure can be inspected without running GStreamer.
fn build_description(config: &MixerOutputConfig, slots: usize) -> Result<String, AppError> {
    let mut branches = Vec::with_capacity(slots);
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
    branches.push(
        "uridecodebin name=stinger_src ! videoconvert ! videoscale \
         ! alpha name=stinger_alpha alpha=0.0 ! comp."
            .to_string(),
    );

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

    let tail = format!(
        "compositor name=comp background=black \
         ! videoconvert ! videoscale ! videorate ! video/x-raw,framerate={fps}/1 \
         ! {encoder_stage} ! video/x-h264,profile=baseline \
         ! rtph264pay pt=96 ! queue max-size-time=1000000000 \
         ! appsink name=out_sink sync=false",
        fps = config.fps,
    );

    Ok(format!("{} {}", branches.join(" "), tail))
}

#[cfg(test)]
mod tests {
    use super::*;
    use todd_common::media::EncoderKind;

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
    fn source_keys_are_stable() {
        let source = SourceRef {
            room_id: "r-1".to_string(),
            camera_id: "cam-2".to_string(),
        };
        assert_eq!(source_key(&source), "r-1/cam-2");
    }

    #[test]
    fn stinger_spec_defaults_to_no_asset() {
        let spec = StingerSpec::default();
        assert!(spec.asset_url.is_none());
    }
}
