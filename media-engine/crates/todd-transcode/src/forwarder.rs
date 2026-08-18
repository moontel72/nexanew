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
use gstreamer_app::AppSrc;
use todd_common::{
    error::AppError,
    media::{AudioBus, AudioMixerConfig, EncoderKind, EncoderSpec},
    types::{ForwardKind, ForwardTarget},
};
use tokio::{sync::mpsc, task::JoinHandle};

use crate::hw::{h264_encode_plan, resolve_encoder, EncodePlan};
use crate::media::{MediaCodec, RtpChunk};

pub struct GstForwarder {
    pipeline: gst::Pipeline,
    /// Push tasks; aborted on drop.
    push_tasks: Vec<JoinHandle<()>>,
}

impl Drop for GstForwarder {
    fn drop(&mut self) {
        let _ = self.pipeline.set_state(gst::State::Null);
        for task in &self.push_tasks {
            task.abort();
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
    #[allow(clippy::too_many_arguments)]
    pub async fn build(
        target: &ForwardTarget,
        encoder: EncoderKind,
        spec: EncoderSpec,
        audio_cfg: &AudioMixerConfig,
        mut video_rx: mpsc::Receiver<RtpChunk>,
        audio_rx: Vec<(AudioBus, mpsc::Receiver<RtpChunk>)>,
    ) -> Result<Self, AppError> {
        let first = video_rx.recv().await.ok_or_else(|| {
            AppError::BadRequest("no RTP received; camera is inactive".to_string())
        })?;

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
        Ok(GstForwarder {
            pipeline,
            push_tasks,
        })
    }
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
                map.copy_from_slice(0, &chunk.packet);
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
    let mut audio_branches: Vec<String> = Vec::new();
    if has_audio {
        for bus in AudioBus::ALL {
            let bus_cfg = audio_cfg.bus(bus);
            if !bus_cfg.enabled {
                continue;
            }
            let volume = if bus_cfg.muted {
                -60.0f32
            } else {
                bus_cfg.volume_db
            };
            audio_branches.push(format!(
                "appsrc name=audio_{bus} format=time is-live=true do-timestamp=true \
                 caps=\"application/x-rtp,media=audio,encoding-name=OPUS,clock-rate=48000\" \
                 ! rtpopusdepay ! opusdec ! audioconvert ! audioresample \
                 ! volume name=vol_{bus} volume={volume} ! audiomixer name=mix"
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
        description.push_str(
            " ! audioconvert ! audioresample ! voaacenc bitrate=128000 ! aacparse ! queue name=aq max-size-time=1000000000 ! mux.",
        );
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
}
