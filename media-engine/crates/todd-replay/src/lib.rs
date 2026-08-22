//! T-Odd Replay — cricket instant replay engine.
//!
//! The crate is organized around one flow:
//!
//! ```text
//! ingest hot path                       trigger (Run-Out/Wicket/Boundary/Catch)
//! ───────────────                       ──────────────────────────────────────
//! RTP packet ──try_send──▶ per-camera   RingBuffer.snapshot(lookback)
//!                          ring task            │
//!                                               ▼
//!                              retime(frames, speed) ──▶ paced broadcast ──▶ WHEP replay
//!                                               └────▶ unpaced feed ──▶ clip export (gst)
//! ```
//!
//! Modules:
//! - [`ring`] — circular RAM ring buffer (zero-copy retention, lock-free
//!   hot path).
//! - [`retime`] — frame-level time-scale RTP retiming (0.25x–4x).
//! - [`session`] — trigger → replay session with paced playback streams.
//! - [`export`] — clip export engine (absorbs the legacy HLS chunker:
//!   ring replaces directory polling, retimed replay replaces ffmpeg
//!   concat/trim/speed, export status notifications replace the ad-hoc
//!   Laravel callback).

pub mod export;
pub mod retime;
pub mod ring;
pub mod session;

pub use retime::{clamp_speed, retime, RetimedPacket};
pub use ring::{Frame, RingBuffer};
pub use session::{
    CameraStream, ReplayEvent, ReplayInfo, ReplaySession, ReplayStatus, ReplayTrigger,
    ReplayVarState, VarCamera,
};

use std::sync::Arc;
use std::time::Duration;

use dashmap::DashMap;
use serde::Serialize;
use todd_common::error::AppError;

/// Replay notifications broadcast to subscribers (Studio UI, exports).
#[derive(Debug, Clone, Serialize)]
pub struct ReplayNotification {
    pub replay_id: String,
    pub event: String,
    pub status: ReplayStatus,
}

/// The engine-wide replay manager: owns the ring buffer and the live
/// replay sessions.
pub struct ReplayManager {
    pub ring: Arc<RingBuffer>,
    sessions: DashMap<String, Arc<ReplaySession>>,
    /// Broadcast of session lifecycle events.
    pub events: tokio::sync::broadcast::Sender<ReplayNotification>,
    /// Export statuses, keyed by export id.
    pub exports: DashMap<String, export::ExportStatus>,
    /// Cloud callback URL notified on export completion (optional).
    pub export_callback_url: Option<String>,
}

impl ReplayManager {
    pub fn new(buffer_ms: u64, export_callback_url: Option<String>) -> Arc<Self> {
        let (events, _) = tokio::sync::broadcast::channel(64);
        Arc::new(Self {
            ring: RingBuffer::new(buffer_ms),
            sessions: DashMap::new(),
            events,
            exports: DashMap::new(),
            export_callback_url,
        })
    }

    /// Hot path: captures one RTP packet into the ring.
    pub fn capture(&self, room_id: &str, camera_id: &str, frame: Arc<Frame>) {
        self.ring.capture(room_id, camera_id, frame);
    }

    /// Triggers an instant replay: snapshots the lookback window for the
    /// requested cameras and starts paced playback streams.
    pub async fn trigger(&self, req: &ReplayTrigger) -> Result<ReplayInfo, AppError> {
        let lookback = Duration::from_millis(req.lookback_ms.clamp(500, 30_000));
        if lookback > self.ring.retention() {
            return Err(AppError::BadRequest(format!(
                "lookback {}ms exceeds the replay buffer retention {}ms",
                lookback.as_millis(),
                self.ring.retention().as_millis()
            )));
        }

        let cameras: Vec<String> = if req.camera_ids.is_empty() {
            self.ring.cameras_for_room(&req.room_id)
        } else {
            req.camera_ids.clone()
        };
        if cameras.is_empty() {
            return Err(AppError::NotFound(format!(
                "no cameras buffered for room {}",
                req.room_id
            )));
        }

        let session = ReplaySession::create(
            &req.room_id,
            req.event.clone(),
            clamp_speed(req.speed),
            req.loop_playback,
            lookback,
            cameras,
            self.ring.clone(),
        )
        .await?;

        let info = session.info();
        let notification = ReplayNotification {
            replay_id: info.replay_id.clone(),
            event: info.event.clone(),
            status: info.status.clone(),
        };
        let _ = self.events.send(notification);
        self.sessions.insert(info.replay_id.clone(), session);
        Ok(info)
    }

    /// Live replay session by id.
    pub fn session(&self, replay_id: &str) -> Option<Arc<ReplaySession>> {
        self.sessions.get(replay_id).map(|s| Arc::clone(s.value()))
    }

    /// Closes a replay session (stops all producers).
    pub async fn close(&self, replay_id: &str) -> Result<(), AppError> {
        let Some((_, session)) = self.sessions.remove(replay_id) else {
            return Err(AppError::NotFound(format!("unknown replay {replay_id}")));
        };
        session.close();
        let _ = self.events.send(ReplayNotification {
            replay_id: replay_id.to_string(),
            event: session.event.as_str().to_string(),
            status: ReplayStatus::Finished,
        });
        tracing::info!(replay = replay_id, "replay session closed");
        Ok(())
    }

    /// All live replay sessions.
    pub fn list(&self) -> Vec<ReplayInfo> {
        let mut infos: Vec<ReplayInfo> = self
            .sessions
            .iter()
            .map(|entry| entry.value().info())
            .collect();
        infos.sort_by_key(|info| std::cmp::Reverse(info.created_at_ms));
        infos
    }

    /// VAR: frame-accurate review state of one session.
    pub fn var_state(&self, replay_id: &str) -> Result<ReplayVarState, AppError> {
        let session = self
            .session(replay_id)
            .ok_or_else(|| AppError::NotFound(format!("unknown replay {replay_id}")))?;
        Ok(session.var_state())
    }

    /// VAR: restarts the session's synchronized playback at a frame index.
    pub fn seek(&self, replay_id: &str, frame: usize) -> Result<ReplayVarState, AppError> {
        let session = self
            .session(replay_id)
            .ok_or_else(|| AppError::NotFound(format!("unknown replay {replay_id}")))?;
        session.seek(frame);
        Ok(session.var_state())
    }

    /// Starts a clip export job (async; status tracked in `exports`).
    pub async fn export(
        self: &Arc<Self>,
        req: export::ClipExportRequest,
    ) -> Result<export::ExportStatus, AppError> {
        export::run_export(Arc::clone(self), req).await
    }
}

/// Re-exported serde alias used by the signaling layer's request DTOs.
pub use session::ReplayTrigger as TriggerRequest;

/// `ExportStatus` is re-exported for route responses.
pub use export::{ClipExportRequest, ExportState, ExportStatus};
