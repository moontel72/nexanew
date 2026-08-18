//! Circular in-memory replay ring buffer.
//!
//! Design goals, and how they are met:
//!
//! - **Zero-copy retention**: frames hold `Bytes` references to the RTP
//!   payloads the SFU router already owns — nothing is copied at ingest.
//! - **Lock-free hot path**: the WHIP pump performs a bounded-channel
//!   `try_send`; ring mutation happens in one dedicated task per camera,
//!   so no lock is ever taken on the packet path. When the channel is
//!   full the packet is dropped (live-first policy — the replay buffer
//!   must never stall ingest).
//! - **Bounded memory**: frames are pruned by age (configurable
//!   retention window) inside the camera task.
//!
//! Snapshot requests (event triggers, exports) are answered by the same
//! per-camera task via a request channel, so readers never contend with
//! the writer.

use std::collections::VecDeque;
use std::sync::Arc;
use std::time::{Duration, Instant};

use dashmap::DashMap;
use todd_transcode::media::RtpChunk;
use tokio::sync::{mpsc, oneshot};

/// One captured RTP packet (or packet of a frame).
#[derive(Debug, Clone)]
pub struct Frame {
    pub chunk: RtpChunk,
    pub rtp_timestamp: u32,
    pub arrived_at: Instant,
}

impl Frame {
    pub fn new(chunk: RtpChunk, rtp_timestamp: u32, arrived_at: Instant) -> Self {
        Self {
            chunk,
            rtp_timestamp,
            arrived_at,
        }
    }

    /// Captures at the current time (the ingest path).
    pub fn now(chunk: RtpChunk, rtp_timestamp: u32) -> Self {
        Self::new(chunk, rtp_timestamp, Instant::now())
    }

    pub fn is_audio(&self) -> bool {
        self.chunk.codec.is_audio()
    }
}

/// A snapshot request handled by the per-camera ring task.
struct SnapshotRequest {
    /// Only frames newer than `now - window` are returned.
    window: Duration,
    reply: oneshot::Sender<Vec<Arc<Frame>>>,
}

/// Hard cap per camera, regardless of the retention window: at ~3k
/// packets/s this is >30s of video. Guards against timestamp anomalies.
const MAX_FRAMES_PER_CAMERA: usize = 100_000;

/// Channels owned by one camera's ring task.
struct CameraRing {
    frames_tx: mpsc::Sender<Arc<Frame>>,
    request_tx: mpsc::Sender<SnapshotRequest>,
}

/// The replay ring: one buffering task per `(room, camera)` pair.
pub struct RingBuffer {
    retention: Duration,
    cameras: DashMap<String, CameraRing>,
}

impl RingBuffer {
    /// `retention_ms` bounds how far back snapshots can reach. Clamped to
    /// the spec'd 5–30 second window.
    pub fn new(retention_ms: u64) -> Arc<Self> {
        let retention = Duration::from_millis(retention_ms.clamp(5_000, 30_000));
        Arc::new(Self {
            retention,
            cameras: DashMap::new(),
        })
    }

    /// The configured retention window.
    pub fn retention(&self) -> Duration {
        self.retention
    }

    /// Hot path: captures one RTP packet. Never blocks; drops when the
    /// camera's ring is saturated.
    pub fn capture(&self, room_id: &str, camera_id: &str, frame: Arc<Frame>) {
        let key = ring_key(room_id, camera_id);
        let entry = self
            .cameras
            .entry(key.clone())
            .or_insert_with(|| self.spawn_camera(key));
        // Live-first: a full replay buffer must never stall ingest.
        let _ = entry.frames_tx.try_send(frame);
    }

    /// Starts the per-camera buffering task.
    fn spawn_camera(&self, key: String) -> CameraRing {
        let (frames_tx, mut frames_rx) = mpsc::channel::<Arc<Frame>>(16_384);
        let (request_tx, mut request_rx) = mpsc::channel::<SnapshotRequest>(16);
        let retention = self.retention;

        tokio::spawn(async move {
            let mut frames: VecDeque<Arc<Frame>> = VecDeque::new();
            loop {
                tokio::select! {
                    frame = frames_rx.recv() => match frame {
                        Some(frame) => {
                            frames.push_back(frame);
                            let cutoff = Instant::now() - retention;
                            while frames
                                .front()
                                .map(|f| f.arrived_at < cutoff)
                                .unwrap_or(false)
                            {
                                frames.pop_front();
                            }
                            while frames.len() > MAX_FRAMES_PER_CAMERA {
                                frames.pop_front();
                            }
                        }
                        None => break,
                    },
                    request = request_rx.recv() => match request {
                        Some(SnapshotRequest { window, reply }) => {
                            let cutoff = Instant::now() - window;
                            let clip: Vec<Arc<Frame>> = frames
                                .iter()
                                .filter(|f| f.arrived_at >= cutoff)
                                .cloned()
                                .collect();
                            let _ = reply.send(clip);
                        }
                        None => break,
                    },
                }
            }
            tracing::debug!(camera = %key, "replay ring task ended");
        });

        CameraRing {
            frames_tx,
            request_tx,
        }
    }

    /// Requests a snapshot of the last `window` of frames. Empty when the
    /// camera has no ring (yet).
    pub async fn snapshot(
        &self,
        room_id: &str,
        camera_id: &str,
        window: Duration,
    ) -> Vec<Arc<Frame>> {
        let Some(camera) = self.cameras.get(&ring_key(room_id, camera_id)) else {
            return Vec::new();
        };
        let (reply_tx, reply_rx) = oneshot::channel();
        if camera
            .request_tx
            .send(SnapshotRequest {
                window,
                reply: reply_tx,
            })
            .await
            .is_err()
        {
            return Vec::new();
        }
        reply_rx.await.unwrap_or_default()
    }

    /// Camera ids of all rings belonging to a room.
    pub fn cameras_for_room(&self, room_id: &str) -> Vec<String> {
        let prefix = format!("{room_id}/");
        let mut ids: Vec<String> = self
            .cameras
            .iter()
            .filter_map(|entry| entry.key().strip_prefix(&prefix).map(str::to_string))
            .collect();
        ids.sort();
        ids
    }

    pub fn camera_count(&self) -> usize {
        self.cameras.len()
    }
}

/// Ring keys are `"{room_id}/{camera_id}"` so camera ids only need to be
/// unique within a room.
fn ring_key(room_id: &str, camera_id: &str) -> String {
    format!("{room_id}/{camera_id}")
}

#[cfg(test)]
mod tests {
    use super::*;
    use bytes::Bytes;
    use todd_transcode::media::MediaCodec;

    fn video_frame(ts: u32, arrived_at: Instant) -> Arc<Frame> {
        let mut payload = vec![0u8; 32];
        // Minimal RTP header for realism (not strictly needed here).
        payload[0] = 0x80;
        Arc::new(Frame::new(
            RtpChunk {
                codec: MediaCodec::Vp8,
                rid: None,
                packet: Bytes::from(payload),
            },
            ts,
            arrived_at,
        ))
    }

    #[tokio::test]
    async fn snapshot_returns_recent_frames_within_window() {
        let ring = RingBuffer::new(5_000);
        let now = Instant::now();
        // Frames arrive every 50ms in the (fabricated) past.
        for i in 0..10u32 {
            ring.capture(
                "room-a",
                "cam-1",
                video_frame(90_000 * i, now - Duration::from_millis(50 * i as u64)),
            );
        }
        // Give the ring task a moment to consume.
        tokio::time::sleep(Duration::from_millis(50)).await;

        // A 300ms window reaches back to ~now-300ms: frames 0..~5. The
        // snapshot round-trip adds a few ms of slack, so assert a bound
        // rather than an exact count.
        let recent = ring
            .snapshot("room-a", "cam-1", Duration::from_millis(300))
            .await;
        assert!(
            (4..=6).contains(&recent.len()),
            "expected ~5 recent frames, got {}",
            recent.len()
        );

        let all = ring
            .snapshot("room-a", "cam-1", Duration::from_millis(5_000))
            .await;
        assert_eq!(all.len(), 10);
    }

    #[tokio::test]
    async fn unknown_camera_returns_empty() {
        let ring = RingBuffer::new(5_000);
        assert!(ring
            .snapshot("room-x", "cam-9", Duration::from_millis(1000))
            .await
            .is_empty());
    }

    #[tokio::test]
    async fn cameras_are_scoped_per_room() {
        let ring = RingBuffer::new(5_000);
        ring.capture("room-a", "cam-1", video_frame(0, Instant::now()));
        ring.capture("room-b", "cam-1", video_frame(0, Instant::now()));
        tokio::time::sleep(Duration::from_millis(50)).await;

        assert_eq!(ring.cameras_for_room("room-a"), vec!["cam-1".to_string()]);
        assert_eq!(ring.cameras_for_room("room-b"), vec!["cam-1".to_string()]);
        assert_eq!(ring.camera_count(), 2);
    }
}
