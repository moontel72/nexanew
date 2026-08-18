//! Clip exporter — trimmed MP4/WebM segments from the RAM buffer.
//!
//! Absorbs the legacy HLS chunker (`rust/src/bin/video_chunker.rs`,
//! deleted in Phase 0):
//!
//! | Legacy chunker | todd-replay |
//! |---|---|
//! | 10s HLS directory polling | ring buffer (per-packet capture) |
//! | ffmpeg concat of `.ts` segments | retimed replay of the ring snapshot |
//! | ffmpeg trim + `setpts` speed filter | `retime` speed + unpaced feed |
//! | hand-rolled HTTP server + Laravel POST | async export tasks + status registry |
//!
//! The export pipeline reuses the Phase 2 `todd-transcode` GStreamer
//! forwarder: the retimed RTP stream is depayed, decoded, re-encoded and
//! muxed to the target container (the URL extension selects MKV/MP4/WebM).
//! Export runs **unpaced** — as fast as the encoder allows.

use std::sync::Arc;

use serde::{Deserialize, Serialize};
use todd_common::error::AppError;
use todd_common::types::ForwardTarget;

use crate::ReplayManager;

/// Lifecycle state of one export job.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ExportState {
    Pending,
    Running,
    Done,
    Failed,
}

/// Queryable export job status.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExportStatus {
    pub export_id: String,
    pub replay_id: String,
    pub camera_id: String,
    pub state: ExportState,
    pub url: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
}

/// Export request from the signaling/Studio layer.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub struct ClipExportRequest {
    pub replay_id: String,
    pub camera_id: String,
    /// Output target (kind is forced to `file`; the URL's extension
    /// selects MKV/MP4/WebM).
    pub target: ForwardTarget,
    /// Overrides the session speed (default: the session's speed).
    #[serde(default)]
    pub speed: Option<f32>,
}

/// Starts an export job: runs the pipeline asynchronously and updates the
/// tracked status on completion.
///
/// v1 completion semantics: the job is `Done` when the retimed feed has
/// been fully consumed and the pipeline had a short flush window (the
/// transcode forwarder has no EOS handshake yet — Phase 4).
#[cfg(feature = "gst")]
pub async fn run_export(
    manager: Arc<ReplayManager>,
    req: ClipExportRequest,
) -> Result<ExportStatus, AppError> {
    use std::collections::HashMap;
    use std::time::Duration;
    use todd_common::media::{AudioBus, EncoderSpec};
    use todd_transcode::forwarder::GstForwarder;
    use todd_transcode::media::RtpChunk;
    use tokio::sync::mpsc;

    let export_id = uuid::Uuid::new_v4().to_string();
    let mut status = ExportStatus {
        export_id: export_id.clone(),
        replay_id: req.replay_id.clone(),
        camera_id: req.camera_id.clone(),
        state: ExportState::Pending,
        url: req.target.url.clone(),
        error: None,
    };
    manager.exports.insert(export_id.clone(), status.clone());

    let Some(session) = manager.session(&req.replay_id) else {
        status.state = ExportState::Failed;
        status.error = Some(format!("unknown replay {}", req.replay_id));
        return Ok(finalize(&manager, status).await);
    };
    let Some(frames) = session.frames(&req.camera_id) else {
        status.state = ExportState::Failed;
        status.error = Some(format!("camera {} not in replay", req.camera_id));
        return Ok(finalize(&manager, status).await);
    };
    let Some((video_codec, _clock_rate)) = session.camera(&req.camera_id) else {
        status.state = ExportState::Failed;
        status.error = Some(format!("camera {} not in replay", req.camera_id));
        return Ok(finalize(&manager, status).await);
    };
    if video_codec.is_audio() {
        status.state = ExportState::Failed;
        status.error = Some("replay stream has no video".to_string());
        return Ok(finalize(&manager, status).await);
    }

    let speed = req.speed.unwrap_or(session.speed);
    let packets = crate::retime::retime(&frames, speed);

    status.state = ExportState::Running;
    manager.exports.insert(export_id.clone(), status.clone());

    // Split the retimed stream: video into one channel, audio into
    // per-bus channels (RID convention).
    let (video_tx, video_rx) = mpsc::channel::<RtpChunk>(4096);
    let mut audio_channels: Vec<(AudioBus, mpsc::Sender<RtpChunk>, mpsc::Receiver<RtpChunk>)> =
        Vec::new();
    for bus in AudioBus::ALL {
        let (tx, rx) = mpsc::channel::<RtpChunk>(2048);
        audio_channels.push((bus, tx, rx));
    }

    let feeder_txs: HashMap<AudioBus, mpsc::Sender<RtpChunk>> = audio_channels
        .iter()
        .map(|(bus, tx, _)| (*bus, tx.clone()))
        .collect();

    let feeder = tokio::spawn(async move {
        for packet in packets {
            let chunk = RtpChunk {
                codec: packet.codec,
                rid: packet.rid.clone(),
                packet: packet.bytes,
            };
            if packet.codec.is_audio() {
                let bus = AudioBus::from_rid(chunk.rid.as_deref());
                if let Some(tx) = feeder_txs.get(&bus) {
                    let _ = tx.send(chunk).await;
                }
            } else {
                let _ = video_tx.send(chunk).await;
            }
        }
        // Dropping the senders signals end-of-stream to the pipelines.
    });

    let audio_rx: Vec<(AudioBus, mpsc::Receiver<RtpChunk>)> = audio_channels
        .into_iter()
        .map(|(bus, _tx, rx)| (bus, rx))
        .collect();

    let target = ForwardTarget {
        kind: todd_common::types::ForwardKind::File,
        ..req.target.clone()
    };
    let spec = EncoderSpec {
        bitrate_kbps: req.target.bitrate_kbps,
        keyframe_interval: req.target.keyframe_interval,
    };

    let forwarder = GstForwarder::build(
        &target,
        req.target.encoder,
        spec,
        &req.target.audio,
        video_rx,
        audio_rx,
    )
    .await?;

    match feeder.await {
        Ok(()) => {
            // Flush window: let the pipeline drain the remaining buffers
            // before tearing it down (filesink closes on state change).
            tokio::time::sleep(Duration::from_millis(1000)).await;
            drop(forwarder);
            status.state = ExportState::Done;
        }
        Err(e) => {
            drop(forwarder);
            status.state = ExportState::Failed;
            status.error = Some(format!("feeder task failed: {e}"));
        }
    }
    tracing::info!(export = %export_id, state = ?status.state, "clip export finished");
    Ok(finalize(&manager, status).await)
}

/// Records the final status and notifies the cloud callback (if
/// configured) asynchronously — the export caller never waits on the
/// network.
#[cfg(feature = "gst")]
async fn finalize(manager: &Arc<ReplayManager>, status: ExportStatus) -> ExportStatus {
    manager
        .exports
        .insert(status.export_id.clone(), status.clone());
    notify_cloud(manager, status.clone());
    status
}

/// Fire-and-forget POST of the final export status to the TraceOdd cloud
/// (the `REPLAY_EXPORT_CALLBACK_URL` webhook — replacement for the
/// legacy `POST /replay/chunk` Laravel callback).
#[cfg(feature = "gst")]
fn notify_cloud(manager: &Arc<ReplayManager>, status: ExportStatus) {
    let Some(url) = manager.export_callback_url.clone() else {
        return;
    };
    tokio::spawn(async move {
        let client = reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(5))
            .build();
        match client {
            Ok(client) => match client.post(&url).json(&status).send().await {
                Ok(resp) if resp.status().is_success() => {
                    tracing::info!(export = %status.export_id, "cloud notified");
                }
                Ok(resp) => {
                    tracing::warn!(export = %status.export_id, status = %resp.status(), "cloud notification rejected");
                }
                Err(e) => {
                    tracing::warn!(export = %status.export_id, error = %e, "cloud notification failed");
                }
            },
            Err(e) => {
                tracing::warn!(error = %e, "cloud notification client failed");
            }
        }
    });
}

/// Non-gst builds cannot export: the pipeline requires the GStreamer
/// toolchain (CI builds it on ubuntu-24.04 with `--features gst`).
#[cfg(not(feature = "gst"))]
pub async fn run_export(
    _manager: Arc<ReplayManager>,
    req: ClipExportRequest,
) -> Result<ExportStatus, AppError> {
    Err(AppError::Unsupported(format!(
        "clip export for replay {} requires the `gst` feature (libgstreamer >= 1.24)",
        req.replay_id
    )))
}
