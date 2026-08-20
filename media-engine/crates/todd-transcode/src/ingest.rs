//! RTSP/RTMP ingest adapters — legacy camera sources pulled into the SFU.
//!
//! Only compiled with the `gst` feature. Pipeline shapes:
//!
//! ```text
//! RTSP: rtspsrc → rtph264depay → h264parse → rtph264pay → appsink (video)
//!       rtspsrc → decodebin → opusenc → rtpopuspay → appsink (audio)
//! RTMP: rtmpsrc → flvdemux → h264parse → rtph264pay → appsink (video)
//!       rtmpsrc → flvdemux → aacparse → avdec_aac → opusenc → rtpopuspay
//!              → appsink (audio)
//! ```
//!
//! Incoming streams are re-packetized into WebRTC-compatible RTP (H.264
//! payload type 96, Opus 111) and broadcast on channels the SFU engine
//! pumps into the TrackRouter — so RTSP/RTMP cameras behave identically
//! to WHIP camera feeds downstream.

#![cfg(feature = "gst")]

use bytes::Bytes;
use gst::prelude::*;
use gstreamer as gst;
use gstreamer_app::AppSink;
use todd_common::error::AppError;
use todd_common::types::CameraSourceKind;
use tokio::sync::broadcast;

use crate::media::{MediaCodec, RtpChunk};

/// A running RTSP/RTMP ingest pipeline for one camera.
pub struct GstIngest {
    pipeline: gst::Pipeline,
    video_tx: broadcast::Sender<RtpChunk>,
    audio_tx: broadcast::Sender<RtpChunk>,
}

impl Drop for GstIngest {
    fn drop(&mut self) {
        let _ = self.pipeline.set_state(gst::State::Null);
    }
}

impl GstIngest {
    /// Builds and starts the pipeline for `url` of the given source kind.
    pub fn build(url: &str, kind: CameraSourceKind) -> Result<Self, AppError> {
        let description = build_description(url, kind)?;
        let pipeline = gst::parse::launch(&description)
            .map_err(|e| AppError::Internal(format!("gst ingest parse failed: {e}")))?
            .downcast::<gst::Pipeline>()
            .map_err(|_| AppError::Internal("expected a GStreamer pipeline".to_string()))?;
        pipeline
            .set_state(gst::State::Playing)
            .map_err(|e| AppError::Internal(format!("ingest pipeline start failed: {e}")))?;

        let (video_tx, _) = broadcast::channel::<RtpChunk>(128);
        let (audio_tx, _) = broadcast::channel::<RtpChunk>(128);

        let video_out = pipeline
            .by_name("video_out")
            .and_then(|element| element.downcast::<AppSink>().ok())
            .ok_or_else(|| AppError::Internal("video_out appsink lookup failed".to_string()))?;
        let video_fan = video_tx.clone();
        video_out.set_callbacks(
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
                    let _ = video_fan.send(chunk);
                    Ok(gst::FlowSuccess::Ok)
                })
                .build(),
        );

        let audio_out = pipeline
            .by_name("audio_out")
            .and_then(|element| element.downcast::<AppSink>().ok())
            .ok_or_else(|| AppError::Internal("audio_out appsink lookup failed".to_string()))?;
        let audio_fan = audio_tx.clone();
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
                    let _ = audio_fan.send(chunk);
                    Ok(gst::FlowSuccess::Ok)
                })
                .build(),
        );

        tracing::info!(?kind, url, "ingest started");
        Ok(Self {
            pipeline,
            video_tx,
            audio_tx,
        })
    }

    /// Subscribes to the re-packetized H.264 video.
    pub fn subscribe_video(&self) -> broadcast::Receiver<RtpChunk> {
        self.video_tx.subscribe()
    }

    /// Subscribes to the transcoded Opus audio.
    pub fn subscribe_audio(&self) -> broadcast::Receiver<RtpChunk> {
        self.audio_tx.subscribe()
    }
}

/// Builds the pipeline description for a source kind. Split out so the
/// structure can be inspected without running GStreamer.
fn build_description(url: &str, kind: CameraSourceKind) -> Result<String, AppError> {
    let url = url.trim();
    if url.is_empty() {
        return Err(AppError::BadRequest(
            "ingest source URL is required".to_string(),
        ));
    }

    match kind {
        CameraSourceKind::Rtsp => Ok(format!(
            "rtspsrc name=src location=\"{url}\" latency=200 \
             src. ! queue ! rtph264depay ! h264parse ! rtph264pay pt=96 \
             ! queue max-size-time=1000000000 ! appsink name=video_out sync=false \
             src. ! queue ! decodebin ! audioconvert ! audioresample \
             ! opusenc ! rtpopuspay pt=111 \
             ! queue max-size-time=1000000000 ! appsink name=audio_out sync=false"
        )),
        CameraSourceKind::Rtmp => Ok(format!(
            "rtmpsrc location=\"{url}\" ! flvdemux name=demux \
             demux. ! queue ! h264parse ! rtph264pay pt=96 \
             ! queue max-size-time=1000000000 ! appsink name=video_out sync=false \
             demux. ! queue ! aacparse ! avdec_aac ! audioconvert ! audioresample \
             ! opusenc ! rtpopuspay pt=111 \
             ! queue max-size-time=1000000000 ! appsink name=audio_out sync=false"
        )),
        CameraSourceKind::Whip => Err(AppError::BadRequest(
            "WHIP cameras ingest over HTTP — no GStreamer adapter needed".to_string(),
        )),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rtsp_description_repacketizes_to_webrtc_rtp() {
        let description = build_description("rtsp://cam.local/live", CameraSourceKind::Rtsp)
            .expect("rtsp description builds");
        assert!(description.contains("rtspsrc"));
        assert!(description.contains("rtph264depay"));
        assert!(description.contains("rtph264pay pt=96"));
        assert!(description.contains("name=video_out"));
        assert!(description.contains("opusenc"));
        assert!(description.contains("rtpopuspay pt=111"));
        assert!(description.contains("name=audio_out"));
    }

    #[test]
    fn rtmp_description_repacketizes_to_webrtc_rtp() {
        let description = build_description("rtmp://ingest.local/live/key", CameraSourceKind::Rtmp)
            .expect("rtmp description builds");
        assert!(description.contains("rtmpsrc"));
        assert!(description.contains("flvdemux"));
        assert!(description.contains("rtph264pay pt=96"));
        assert!(description.contains("avdec_aac"));
        assert!(description.contains("rtpopuspay pt=111"));
    }

    #[test]
    fn whip_sources_have_no_adapter() {
        assert!(build_description("http://x", CameraSourceKind::Whip).is_err());
        assert!(build_description("", CameraSourceKind::Rtsp).is_err());
    }
}
