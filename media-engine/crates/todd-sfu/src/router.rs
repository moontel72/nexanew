//! Multi-camera, multi-layer (simulcast) track router: the
//! publish/subscribe core of the SFU.
//!
//! Streams are keyed by `(room_id, camera_id, rid)` where `rid` is the
//! simulcast layer id (`"f"`/`"h"`/`"q"` …) or empty for single-layer
//! streams. Audio tracks use the RID as their bus tag
//! (`commentary`/`ambient`/`sfx`/`music` — see
//! `todd_common::media::AudioBus::from_rid`), so the same routing table
//! serves both simulcast layer selection and audio bus assignment.
//!
//! Backpressure policy: `try_send` and drop. In a live, sub-second
//! pipeline a dropped packet is always preferable to added latency —
//! retransmission/repair is the encoder's job (NACK), not the router's.
//! Drops are *counted*, never silent: every packet is accounted for in
//! per-camera [`StreamStats`] and the global metrics registry.

use std::sync::Arc;

use dashmap::DashMap;
use todd_telemetry::Telemetry;
use todd_transcode::media::{MediaCodec, RtpChunk};
use tokio::sync::mpsc;

/// Bounded per-subscriber queue; see backpressure policy above.
const SUBSCRIBER_CHANNEL: usize = 64;

pub struct TrackRouter {
    /// (room, camera, rid, ssrc) -> codec. Marks live streams.
    streams: DashMap<(String, String, String, u32), MediaCodec>,
    /// (room, camera) -> ordered RID list from the `a=simulcast` line of
    /// the publisher's offer (first = lowest layer).
    layer_order: DashMap<(String, String), Vec<String>>,
    /// (room, camera, rid) -> subscriber channels.
    subscribers: DashMap<(String, String, String), Vec<mpsc::Sender<RtpChunk>>>,
    telemetry: Arc<Telemetry>,
}

impl TrackRouter {
    pub fn new(telemetry: Arc<Telemetry>) -> Self {
        Self {
            streams: DashMap::new(),
            layer_order: DashMap::new(),
            subscribers: DashMap::new(),
            telemetry,
        }
    }

    pub fn register_track(
        &self,
        room_id: &str,
        camera_id: &str,
        rid: Option<&str>,
        ssrc: u32,
        codec: MediaCodec,
    ) {
        self.streams.insert(
            (
                room_id.to_string(),
                camera_id.to_string(),
                rid.unwrap_or("").to_string(),
                ssrc,
            ),
            codec,
        );
    }

    pub fn unregister_track(&self, room_id: &str, camera_id: &str, rid: Option<&str>, ssrc: u32) {
        self.streams.remove(&(
            room_id.to_string(),
            camera_id.to_string(),
            rid.unwrap_or("").to_string(),
            ssrc,
        ));
    }

    /// Records the simulcast layer order from the publisher's offer.
    /// First entry = lowest (base) layer.
    pub fn set_layer_order(&self, room_id: &str, camera_id: &str, order: Vec<String>) {
        if !order.is_empty() {
            self.layer_order
                .insert((room_id.to_string(), camera_id.to_string()), order);
        }
    }

    /// RIDs of all live layers of a camera, ordered by layer rank
    /// (lowest first). Single-layer cameras return `[""]`.
    pub fn live_rids(&self, room_id: &str, camera_id: &str) -> Vec<String> {
        let mut rids: Vec<String> = self
            .streams
            .iter()
            .filter(|e| e.key().0 == room_id && e.key().1 == camera_id)
            .map(|e| e.key().2.clone())
            .collect();
        rids.sort();
        rids.dedup();
        let order = self
            .layer_order
            .get(&(room_id.to_string(), camera_id.to_string()))
            .map(|o| o.clone())
            .unwrap_or_default();
        rids.sort_by_key(|rid| order.iter().position(|o| o == rid).unwrap_or(usize::MAX));
        rids
    }

    /// The lowest live layer of a camera (`""` for single-layer streams).
    pub fn lowest_rid(&self, room_id: &str, camera_id: &str) -> Option<String> {
        self.live_rids(room_id, camera_id).first().cloned()
    }

    /// True when `rid` is a live layer of the camera (`""` = the
    /// lowest available layer — always resolves).
    pub fn is_rid_active(&self, room_id: &str, camera_id: &str, rid: &str) -> bool {
        if rid.is_empty() {
            self.is_camera_active(room_id, camera_id)
        } else {
            self.streams
                .iter()
                .any(|e| e.key().0 == room_id && e.key().1 == camera_id && e.key().2 == rid)
        }
    }

    /// Records one inbound RTP packet (ingress accounting). Called by the
    /// WHIP track pump before [`forward`](Self::forward).
    pub fn record_ingress(
        &self,
        room_id: &str,
        camera_id: &str,
        codec: MediaCodec,
        rtp_timestamp: u32,
        bytes: usize,
    ) {
        let stats = self
            .telemetry
            .stream(room_id, camera_id, codec.clock_rate());
        stats.record_ingress(rtp_timestamp, bytes);
        self.telemetry.registry.inc("todd_rtp_packets_in_total");
        self.telemetry
            .registry
            .add("todd_rtp_bytes_in_total", bytes as u64);
    }

    /// Subscribes to all RTP traffic of one camera layer. The returned
    /// channel closes when the camera is torn down, which signals
    /// forwarders to end their pipelines cleanly.
    pub fn subscribe(&self, room_id: &str, camera_id: &str, rid: &str) -> mpsc::Receiver<RtpChunk> {
        let (tx, rx) = mpsc::channel(SUBSCRIBER_CHANNEL);
        self.subscribers
            .entry((room_id.to_string(), camera_id.to_string(), rid.to_string()))
            .or_default()
            .push(tx);
        rx
    }

    /// Fans a chunk out to every subscriber of its `(room, camera, rid)`.
    /// Slow subscribers get their backlog dropped (live-first policy);
    /// every delivered or dropped packet is recorded in telemetry.
    pub fn forward(&self, room_id: &str, camera_id: &str, chunk: &RtpChunk) {
        let rid = chunk.rid.as_deref().unwrap_or("");
        let Some(senders) =
            self.subscribers
                .get(&(room_id.to_string(), camera_id.to_string(), rid.to_string()))
        else {
            return;
        };

        let mut delivered = 0usize;
        for sender in senders.iter() {
            // Ignore Full (subscriber too slow) and Closed (subscriber gone).
            if sender.try_send(chunk.clone()).is_ok() {
                delivered += 1;
            }
        }

        let dropped = senders.len() - delivered;
        let stats = self
            .telemetry
            .stream(room_id, camera_id, chunk.codec.clock_rate());
        stats.record_fanout(chunk.packet.len(), delivered, dropped);
        if delivered > 0 {
            self.telemetry
                .registry
                .add("todd_rtp_packets_forwarded_total", delivered as u64);
        }
        if dropped > 0 {
            self.telemetry
                .registry
                .add("todd_rtp_packets_dropped_total", dropped as u64);
        }
    }

    pub fn is_camera_active(&self, room_id: &str, camera_id: &str) -> bool {
        self.streams
            .iter()
            .any(|entry| entry.key().0.as_str() == room_id && entry.key().1.as_str() == camera_id)
    }

    /// First codec seen for a camera layer (used to build pipelines and
    /// viewer tracks).
    pub fn codec_of(&self, room_id: &str, camera_id: &str, rid: &str) -> Option<MediaCodec> {
        self.streams
            .iter()
            .find(|entry| {
                entry.key().0.as_str() == room_id
                    && entry.key().1.as_str() == camera_id
                    && entry.key().2.as_str() == rid
            })
            .map(|entry| *entry.value())
    }

    /// First **video** codec of a camera layer. `codec_of` alone is racy:
    /// audio and video share the same `(room, camera, rid)` key on
    /// single-track phones, and DashMap iteration order is arbitrary — a
    /// viewer built with the Opus entry as its "video codec" gets a
    /// video m-line that can never carry the camera picture (black tile).
    pub fn video_codec_of(&self, room_id: &str, camera_id: &str, rid: &str) -> Option<MediaCodec> {
        self.streams
            .iter()
            .find(|entry| {
                entry.key().0.as_str() == room_id
                    && entry.key().1.as_str() == camera_id
                    && entry.key().2.as_str() == rid
                    && !entry.value().is_audio()
            })
            .map(|entry| *entry.value())
    }

    /// First SSRC of a camera layer (publisher inbound SSRC).
    pub fn ssrc_of(&self, room_id: &str, camera_id: &str, rid: &str) -> Option<u32> {
        self.streams
            .iter()
            .find(|entry| {
                entry.key().0.as_str() == room_id
                    && entry.key().1.as_str() == camera_id
                    && entry.key().2.as_str() == rid
            })
            .map(|entry| entry.key().3)
    }

    /// First **video** SSRC of a camera layer — keyframe requests must
    /// target the video stream, never the Opus audio stream.
    pub fn video_ssrc_of(&self, room_id: &str, camera_id: &str, rid: &str) -> Option<u32> {
        self.streams
            .iter()
            .find(|entry| {
                entry.key().0.as_str() == room_id
                    && entry.key().1.as_str() == camera_id
                    && entry.key().2.as_str() == rid
                    && !entry.value().is_audio()
            })
            .map(|entry| entry.key().3)
    }

    /// All live audio tracks of a camera as `(rid, ssrc, codec)` —
    /// used to wire the transcode audio buses.
    pub fn audio_tracks(&self, room_id: &str, camera_id: &str) -> Vec<(String, u32, MediaCodec)> {
        self.streams
            .iter()
            .filter(|entry| {
                entry.key().0.as_str() == room_id
                    && entry.key().1.as_str() == camera_id
                    && entry.value().is_audio()
            })
            .map(|entry| (entry.key().2.clone(), entry.key().3, *entry.value()))
            .collect()
    }

    /// All live audio feeds of a room as `(camera_id, rid)` pairs — the
    /// inputs of the room's program audio mixer. Sorted and deduped.
    pub fn audio_feeds(&self, room_id: &str) -> Vec<(String, String)> {
        let mut feeds: Vec<(String, String)> = self
            .streams
            .iter()
            .filter(|entry| entry.key().0.as_str() == room_id && entry.value().is_audio())
            .map(|entry| (entry.key().1.clone(), entry.key().2.clone()))
            .collect();
        feeds.sort();
        feeds.dedup();
        feeds
    }

    /// Tears down all state for one camera (streams + subscriber
    /// channels + telemetry stream stats + layer order).
    pub fn remove_camera(&self, room_id: &str, camera_id: &str) {
        self.subscribers
            .retain(|(r, c, _), _| r.as_str() != room_id || c.as_str() != camera_id);
        self.streams
            .retain(|(r, c, _, _), _| r.as_str() != room_id || c.as_str() != camera_id);
        self.layer_order
            .remove(&(room_id.to_string(), camera_id.to_string()));
        self.telemetry.remove_stream(room_id, camera_id);
    }

    pub fn stats(&self) -> RouterStats {
        RouterStats {
            active_streams: self.streams.len(),
            subscribers: self.subscribers.iter().map(|e| e.value().len()).sum(),
        }
    }
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct RouterStats {
    pub active_streams: usize,
    pub subscribers: usize,
}
