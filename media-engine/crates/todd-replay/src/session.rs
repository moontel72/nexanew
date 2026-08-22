//! Replay sessions: trigger → snapshot → paced playback streams.
//!
//! A session owns one [`CameraStream`] per camera. Each stream retimes
//! its snapshot at the session speed and broadcasts paced packets; WHEP
//! replay viewers and (unpaced) exporters consume them independently.

use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, RwLock};
use std::time::Duration;

use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use todd_common::error::AppError;
use todd_transcode::media::{MediaCodec, RtpChunk};
use tokio::sync::{broadcast, watch};
use tokio_util::sync::CancellationToken;
use uuid::Uuid;

use crate::retime::retime;
use crate::ring::{Frame, RingBuffer};

/// Cricket match events that trigger instant replays.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ReplayEvent {
    RunOut,
    Wicket,
    Boundary,
    Catch,
    Custom(String),
}

impl ReplayEvent {
    pub fn as_str(&self) -> &str {
        match self {
            ReplayEvent::RunOut => "run_out",
            ReplayEvent::Wicket => "wicket",
            ReplayEvent::Boundary => "boundary",
            ReplayEvent::Catch => "catch",
            ReplayEvent::Custom(s) => s,
        }
    }
}

/// Trigger request from the signaling/Studio layer.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub struct ReplayTrigger {
    pub room_id: String,
    /// Cameras to capture (empty = every camera buffered for the room).
    #[serde(default)]
    pub camera_ids: Vec<String>,
    pub event: ReplayEvent,
    /// How far back the clip reaches (ms), bounded by the ring retention.
    pub lookback_ms: u64,
    /// Playback speed (0.25 / 0.5 / 0.75 / 1.0 / …).
    pub speed: f32,
    /// Loop playback for continuous director review.
    #[serde(default)]
    pub loop_playback: bool,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ReplayStatus {
    Playing,
    Finished,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReplayCameraInfo {
    pub camera_id: String,
    pub codec: String,
    pub packets: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReplayInfo {
    pub replay_id: String,
    pub room_id: String,
    pub event: String,
    pub speed: f32,
    pub lookback_ms: u64,
    pub created_at_ms: u64,
    pub status: ReplayStatus,
    pub cameras: Vec<ReplayCameraInfo>,
}

/// Frame-accurate VAR review state of one replay session.
#[derive(Debug, Clone, Serialize)]
pub struct VarCamera {
    pub camera_id: String,
    pub frames: usize,
}

#[derive(Debug, Clone, Serialize)]
pub struct ReplayVarState {
    pub replay_id: String,
    pub room_id: String,
    pub current_frame: usize,
    pub total_frames: usize,
    pub cameras: Vec<VarCamera>,
}

/// One camera's playback stream inside a session.
pub struct CameraStream {
    pub camera_id: String,
    pub codec: MediaCodec,
    pub clock_rate: u32,
    /// Captured frames (the export source — unpaced).
    pub frames: Arc<Vec<Arc<Frame>>>,
    /// Paced playback broadcast (the WHEP replay source).
    tx: broadcast::Sender<RtpChunk>,
    /// Swappable completion signal — replaced on every VAR seek so the
    /// session monitor follows the CURRENT producer generation.
    done: RwLock<watch::Sender<bool>>,
    /// Keep-alive receiver for `done` (a closed channel would make the
    /// producer's `send` fail silently). Swapped together with `done`.
    _done_rx: RwLock<watch::Receiver<bool>>,
}

impl CameraStream {
    pub fn subscribe(&self) -> broadcast::Receiver<RtpChunk> {
        self.tx.subscribe()
    }
}

/// One triggered replay session.
pub struct ReplaySession {
    pub id: String,
    pub room_id: String,
    pub event: ReplayEvent,
    pub speed: f32,
    pub lookback_ms: u64,
    pub created_at_ms: u64,
    pub loop_playback: bool,
    streams: DashMap<String, CameraStream>,
    status: watch::Sender<ReplayStatus>,
    /// Current playback generation — replaced on every VAR seek. The
    /// previous generation's token is cancelled before the swap so its
    /// producers wind down instead of interleaving stale packets.
    cancel: RwLock<CancellationToken>,
    /// VAR review cursor (frame index of the current generation).
    current_frame: AtomicUsize,
}

impl ReplaySession {
    /// Snapshots every camera and starts the paced producers.
    pub(crate) async fn create(
        room_id: &str,
        event: ReplayEvent,
        speed: f32,
        loop_playback: bool,
        lookback: Duration,
        camera_ids: Vec<String>,
        ring: Arc<RingBuffer>,
    ) -> Result<Arc<Self>, AppError> {
        let (status_tx, _) = watch::channel(ReplayStatus::Playing);
        let cancel = CancellationToken::new();
        let streams = DashMap::new();

        for camera_id in camera_ids {
            let frames = ring.snapshot(room_id, &camera_id, lookback).await;
            if frames.is_empty() {
                tracing::warn!(camera = %camera_id, "no buffered frames; skipping camera in replay");
                continue;
            }
            let codec = frames
                .iter()
                .find(|f| !f.is_audio())
                .map(|f| f.chunk.codec)
                .unwrap_or(MediaCodec::Vp8);
            let clock_rate = codec.clock_rate();
            let frames: Arc<Vec<Arc<Frame>>> = Arc::new(frames);

            let (tx, _) = broadcast::channel(1024);
            // Keep the receiver alive: a dropped receiver closes the
            // watch channel and the producer's `done` signal would be
            // silently discarded.
            let (done_tx, done_rx) = watch::channel(false);
            let stream = CameraStream {
                camera_id: camera_id.clone(),
                codec,
                clock_rate,
                frames: Arc::clone(&frames),
                tx,
                done: RwLock::new(done_tx.clone()),
                _done_rx: RwLock::new(done_rx),
            };

            // Paced playback producer.
            let producer_tx = stream.tx.clone();
            let producer_frames = Arc::clone(&frames);
            let producer_cancel = cancel.clone();
            tokio::spawn(async move {
                produce(
                    producer_tx,
                    producer_frames,
                    0,
                    codec,
                    speed,
                    loop_playback,
                    done_tx,
                    producer_cancel,
                )
                .await;
            });

            streams.insert(camera_id, stream);
        }

        if streams.is_empty() {
            return Err(AppError::NotFound(format!(
                "no buffered frames for any camera of room {room_id}"
            )));
        }

        let session = Arc::new(Self {
            id: Uuid::new_v4().to_string(),
            room_id: room_id.to_string(),
            event,
            speed,
            lookback_ms: lookback.as_millis() as u64,
            created_at_ms: now_ms(),
            loop_playback,
            streams,
            status: status_tx,
            cancel: RwLock::new(cancel),
            current_frame: AtomicUsize::new(0),
        });

        // Watch all camera producers; finish the session when all are done.
        let monitor = Arc::clone(&session);
        tokio::spawn(async move {
            loop {
                let all_done = monitor
                    .streams
                    .iter()
                    .all(|entry| *entry.value().done.read().expect("done lock").borrow());
                if all_done {
                    let _ = monitor.status.send(ReplayStatus::Finished);
                    break;
                }
                tokio::time::sleep(Duration::from_millis(200)).await;
            }
        });

        Ok(session)
    }

    /// Subscribes to one camera's paced playback stream.
    pub fn subscribe(&self, camera_id: &str) -> Option<broadcast::Receiver<RtpChunk>> {
        self.streams
            .get(camera_id)
            .map(|stream| stream.value().subscribe())
    }

    /// Metadata for one camera.
    pub fn camera(&self, camera_id: &str) -> Option<(MediaCodec, u32)> {
        self.streams
            .get(camera_id)
            .map(|stream| (stream.codec, stream.clock_rate))
    }

    /// Captured frames for one camera (the export source).
    pub fn frames(&self, camera_id: &str) -> Option<Arc<Vec<Arc<Frame>>>> {
        self.streams
            .get(camera_id)
            .map(|stream| Arc::clone(&stream.frames))
    }

    pub fn info(&self) -> ReplayInfo {
        let mut cameras: Vec<ReplayCameraInfo> = self
            .streams
            .iter()
            .map(|entry| ReplayCameraInfo {
                camera_id: entry.key().clone(),
                codec: format!("{:?}", entry.value().codec).to_ascii_lowercase(),
                packets: entry.value().frames.len(),
            })
            .collect();
        cameras.sort_by(|a, b| a.camera_id.cmp(&b.camera_id));
        ReplayInfo {
            replay_id: self.id.clone(),
            room_id: self.room_id.clone(),
            event: self.event.as_str().to_string(),
            speed: self.speed,
            lookback_ms: self.lookback_ms,
            created_at_ms: self.created_at_ms,
            status: self.status.borrow().clone(),
            cameras,
        }
    }

    /// Closes the session (cancels all producers).
    pub fn close(&self) {
        self.cancel.read().expect("cancel lock").cancel();
    }

    /// VAR review: restarts every camera's paced playback from the given
    /// frame index. All streams are re-spawned from the same cursor, so
    /// multi-camera playback stays frame-synchronized. Existing WHEP
    /// subscribers keep their broadcast channels (no reconnect needed).
    pub fn seek(&self, frame_index: usize) {
        let new_cancel = CancellationToken::new();
        // Cancel the previous generation *before* swapping in the new
        // token: its producers observe the cancellation and wind down,
        // otherwise looped auto-replays would accumulate one producer
        // task per seek and keep interleaving stale packets forever.
        {
            let mut cancel = self.cancel.write().expect("cancel lock");
            cancel.cancel();
            *cancel = new_cancel.clone();
        }
        self.current_frame.store(frame_index, Ordering::Relaxed);
        let _ = self.status.send(ReplayStatus::Playing);

        for entry in self.streams.iter() {
            let stream = entry.value();
            let idx = frame_index.min(stream.frames.len().saturating_sub(1));
            let (done_tx, done_rx) = watch::channel(false);
            *stream.done.write().expect("done lock") = done_tx.clone();
            *stream._done_rx.write().expect("done rx lock") = done_rx;

            let tx = stream.tx.clone();
            let frames = Arc::clone(&stream.frames);
            let codec = stream.codec;
            let speed = self.speed;
            let loop_playback = self.loop_playback;
            let cancel = new_cancel.clone();
            tokio::spawn(async move {
                produce(
                    tx,
                    frames,
                    idx,
                    codec,
                    speed,
                    loop_playback,
                    done_tx,
                    cancel,
                )
                .await;
            });
        }
    }

    /// Current VAR cursor (frame index of the active generation).
    pub fn current_frame(&self) -> usize {
        self.current_frame.load(Ordering::Relaxed)
    }

    /// Longest camera frame count — the session's reviewable range.
    pub fn total_frames(&self) -> usize {
        self.streams
            .iter()
            .map(|entry| entry.value().frames.len())
            .max()
            .unwrap_or(0)
    }

    /// Frame-accurate state for the VAR review UI.
    pub fn var_state(&self) -> ReplayVarState {
        let mut cameras: Vec<VarCamera> = self
            .streams
            .iter()
            .map(|entry| VarCamera {
                camera_id: entry.key().clone(),
                frames: entry.value().frames.len(),
            })
            .collect();
        cameras.sort_by(|a, b| a.camera_id.cmp(&b.camera_id));
        ReplayVarState {
            replay_id: self.id.clone(),
            room_id: self.room_id.clone(),
            current_frame: self.current_frame(),
            total_frames: self.total_frames(),
            cameras,
        }
    }
}

/// Milliseconds since the Unix epoch (display only).
fn now_ms() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}

/// The paced producer: retimes the snapshot and broadcasts packets in
/// real time. Loops when `loop_playback` is set.
async fn produce(
    tx: broadcast::Sender<RtpChunk>,
    frames: Arc<Vec<Arc<Frame>>>,
    from: usize,
    codec: MediaCodec,
    speed: f32,
    loop_playback: bool,
    done: watch::Sender<bool>,
    cancel: CancellationToken,
) {
    let start = from.min(frames.len());
    let packets = retime(&frames[start..], speed);
    if packets.is_empty() {
        let _ = done.send(true);
        return;
    }

    loop {
        for packet in &packets {
            if cancel.is_cancelled() {
                let _ = done.send(true);
                return;
            }
            if tx.receiver_count() > 0 {
                let chunk = RtpChunk {
                    codec,
                    rid: packet.rid.clone(),
                    packet: packet.bytes.clone(),
                };
                let _ = tx.send(chunk);
            }
            if packet.spacing > 0.0 {
                // Interruptible pause: a seek cancels this generation's
                // token, so the producer winds down immediately instead
                // of sleeping out the spacing and emitting one more stale
                // packet after the cut.
                tokio::select! {
                    _ = tokio::time::sleep(Duration::from_secs_f64(packet.spacing)) => {}
                    _ = cancel.cancelled() => {
                        let _ = done.send(true);
                        return;
                    }
                }
            }
        }
        if !loop_playback {
            break;
        }
    }
    let _ = done.send(true);
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ring::Frame;
    use crate::ReplayManager;
    use bytes::Bytes;
    use std::time::Instant;

    fn video_frame(ts: u32) -> Arc<Frame> {
        let mut payload = vec![0u8; 24];
        payload[0] = 0x80;
        Arc::new(Frame::new(
            RtpChunk {
                codec: MediaCodec::Vp8,
                rid: None,
                packet: Bytes::from(payload),
            },
            ts,
            Instant::now(),
        ))
    }

    #[tokio::test]
    async fn trigger_creates_playable_session() {
        let manager = ReplayManager::new(10_000, None);
        // 30 video frames at 90k clock, 1 frame per ms of media time
        // (spacing 1ms) — fast enough for a test.
        for i in 0..30u32 {
            manager.capture("room-a", "cam-1", video_frame(90 * i));
        }
        tokio::time::sleep(Duration::from_millis(50)).await;

        let trigger = ReplayTrigger {
            room_id: "room-a".to_string(),
            camera_ids: vec!["cam-1".to_string()],
            event: ReplayEvent::Wicket,
            lookback_ms: 10_000,
            speed: 1.0,
            loop_playback: false,
        };
        let info = manager.trigger(&trigger).await.expect("trigger works");
        assert_eq!(info.event, "wicket");
        assert_eq!(info.cameras.len(), 1);
        assert_eq!(info.cameras[0].packets, 30);

        let session = manager.session(&info.replay_id).expect("session exists");
        let mut rx = session.subscribe("cam-1").expect("stream exists");
        let first = tokio::time::timeout(Duration::from_secs(2), rx.recv())
            .await
            .expect("first packet arrives")
            .expect("broadcast open");
        assert_eq!(first.codec, MediaCodec::Vp8);

        // The session finishes after the (fast) playback completes. The
        // status may already be Finished when we subscribe (watch
        // channels don't replay), so check the current value first.
        let mut status = session.status.subscribe();
        let finished = tokio::time::timeout(Duration::from_secs(5), async {
            loop {
                if *status.borrow() == ReplayStatus::Finished {
                    break;
                }
                if status.changed().await.is_err() {
                    break;
                }
            }
        });
        assert!(finished.await.is_ok(), "session finishes");
        manager.close(&info.replay_id).await.ok();
    }

    #[tokio::test]
    async fn trigger_rejects_lookback_beyond_retention() {
        let manager = ReplayManager::new(5_000, None);
        let trigger = ReplayTrigger {
            room_id: "room-a".to_string(),
            camera_ids: vec![],
            event: ReplayEvent::Boundary,
            lookback_ms: 60_000,
            speed: 0.5,
            loop_playback: false,
        };
        assert!(manager.trigger(&trigger).await.is_err());
    }

    #[tokio::test]
    async fn seek_cancels_previous_generation_token() {
        let manager = ReplayManager::new(10_000, None);
        for i in 0..30u32 {
            manager.capture("room-a", "cam-1", video_frame(90 * i));
        }
        tokio::time::sleep(Duration::from_millis(50)).await;

        let trigger = ReplayTrigger {
            room_id: "room-a".to_string(),
            camera_ids: vec!["cam-1".to_string()],
            event: ReplayEvent::Wicket,
            lookback_ms: 10_000,
            speed: 1.0,
            loop_playback: true,
        };
        let info = manager.trigger(&trigger).await.expect("trigger works");
        let session = manager.session(&info.replay_id).expect("session exists");

        // Hold the current (pre-seek) generation token.
        let old_token = session.cancel.read().expect("cancel lock").clone();

        session.seek(10);
        assert!(
            old_token.is_cancelled(),
            "seeking must cancel the previous generation's token so its producers wind down"
        );
        // The stored token is the fresh live generation.
        assert!(!session.cancel.read().expect("cancel lock").is_cancelled());

        manager.close(&info.replay_id).await.ok();
    }

    #[tokio::test]
    async fn seek_replaces_generation_without_stale_frames() {
        let manager = ReplayManager::new(10_000, None);
        for i in 0..30u32 {
            manager.capture("room-a", "cam-1", video_frame(90 * i));
        }
        tokio::time::sleep(Duration::from_millis(50)).await;

        let trigger = ReplayTrigger {
            room_id: "room-a".to_string(),
            camera_ids: vec!["cam-1".to_string()],
            event: ReplayEvent::Boundary,
            lookback_ms: 10_000,
            speed: 1.0,
            loop_playback: true,
        };
        let info = manager.trigger(&trigger).await.expect("trigger works");
        let session = manager.session(&info.replay_id).expect("session exists");
        let mut rx = session.subscribe("cam-1").expect("stream exists");

        session.seek(10);
        // Drain anything already queued (pre-seek packets plus the new
        // generation's first burst).
        while rx.try_recv().is_ok() {}

        // Every subsequent packet must belong to the new generation
        // (frames 10..29, looping): the previous producer was cancelled,
        // so no frame from 0..9 may ever interleave again.
        let seek_ts = 90u32 * 10;
        let mut seen = 0usize;
        let deadline = Duration::from_secs(3);
        let start = Instant::now();
        while seen < 60 && start.elapsed() < deadline {
            match tokio::time::timeout(Duration::from_millis(500), rx.recv()).await {
                Ok(Ok(chunk)) => {
                    let ts = u32::from_be_bytes([
                        chunk.packet[4],
                        chunk.packet[5],
                        chunk.packet[6],
                        chunk.packet[7],
                    ]);
                    assert!(
                        ts >= seek_ts,
                        "stale packet from pre-seek generation (ts {ts}) after seek"
                    );
                    seen += 1;
                }
                _ => break,
            }
        }
        assert!(seen > 0, "new generation produced packets after seek");
        manager.close(&info.replay_id).await.ok();
    }
}
