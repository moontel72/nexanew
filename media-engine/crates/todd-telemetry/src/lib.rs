//! T-Odd telemetry: the media engine's built-in diagnostics system.
//!
//! Two surfaces, one registry:
//! - `GET /metrics` — Prometheus text exposition (scrape target).
//! - `GET /api/v1/telemetry/ws` — WebSocket push feed of a JSON snapshot
//!   (metrics + per-camera stream stats + live ICE state) for dashboards,
//!   the Studio UI, and debugging.
//!
//! The engine writes into [`Telemetry`] from the RTP hot path (atomics +
//! per-camera mutexes); a sampler task periodically reads WebRTC
//! `get_stats()` for RTT. Nothing here blocks or allocates on the media
//! path.

pub mod feed;
pub mod registry;
pub mod stream_stats;

pub use registry::{MetricKind, Registry};
pub use stream_stats::{BitrateMeter, JitterEstimator, StreamSnapshot, StreamStats};

use std::sync::Arc;

use dashmap::DashMap;
use serde::Serialize;

/// Live ICE state of one session, for the diagnostics feed.
#[derive(Debug, Clone, Serialize)]
pub struct IceSessionInfo {
    /// `"whip"` (ingest) or `"whep"` (viewer).
    pub kind: &'static str,
    pub room_id: String,
    pub camera_id: String,
    /// Last observed `RTCPeerConnectionState` (lowercase).
    pub state: String,
}

/// Latest audio level metering of one mixer bus, for the diagnostics
/// feed and the Studio audio mixer UI.
#[derive(Debug, Clone, Serialize)]
pub struct AudioLevelEntry {
    pub room_id: String,
    /// `commentary` / `ambient` / `sfx` / `music` / `master`.
    pub bus: String,
    pub peak_db: f32,
    pub rms_db: f32,
}

/// Latest device health snapshot of one broadcaster (mobile camera),
/// pushed by the device over the telemetry WebSocket.
#[derive(Debug, Clone, Default, Serialize)]
pub struct DeviceTelemetryEntry {
    pub room_id: String,
    pub camera_id: String,
    /// Battery percentage (0–100).
    #[serde(default)]
    pub battery_pct: Option<u8>,
    /// Current capture/encode FPS.
    #[serde(default)]
    pub fps: Option<f32>,
    /// Uplink bitrate in kbps.
    #[serde(default)]
    pub uplink_kbps: Option<f32>,
    /// Cumulative dropped frames.
    #[serde(default)]
    pub dropped_frames: Option<u64>,
    /// Network quality indicator: `good` / `fair` / `poor`.
    #[serde(default)]
    pub quality: Option<String>,
}

/// Serializable snapshot pushed over the diagnostics WebSocket.
#[derive(Debug, Clone, Serialize)]
pub struct TelemetrySnapshot {
    /// Metric name/value pairs from the fixed registry.
    pub metrics: Vec<(String, u64)>,
    /// Per-camera stream statistics.
    pub streams: Vec<StreamFeedEntry>,
    /// Live ICE state per session.
    pub ice_sessions: Vec<IceSessionInfo>,
    /// Audio mixer metering per room/bus.
    pub audio_levels: Vec<AudioLevelEntry>,
    /// Broadcaster device health per room/camera.
    pub devices: Vec<DeviceTelemetryEntry>,
}

#[derive(Debug, Clone, Serialize)]
pub struct StreamFeedEntry {
    pub room_id: String,
    pub camera_id: String,
    #[serde(flatten)]
    pub stats: StreamSnapshot,
}

/// Engine-wide telemetry state. Clonable; every clone shares the same
/// atomics, maps and configuration.
#[derive(Clone)]
pub struct Telemetry {
    pub registry: Arc<Registry>,
    streams: Arc<DashMap<(String, String), Arc<StreamStats>>>,
    ice: Arc<DashMap<String, IceSessionInfo>>,
    /// (room_id, bus) → (peak_db, rms_db).
    audio_levels: Arc<DashMap<(String, String), (f32, f32)>>,
    /// (room_id, camera_id) → device health snapshot.
    devices: Arc<DashMap<(String, String), DeviceTelemetryEntry>>,
    /// Interval (ms) between WebSocket snapshot pushes.
    pub ws_interval_ms: u64,
    /// Interval (ms) between RTT/stats sampling passes.
    pub sample_ms: u64,
}

impl Default for Telemetry {
    fn default() -> Self {
        Self::new(1000, 2000)
    }
}

impl Telemetry {
    pub fn new(ws_interval_ms: u64, sample_ms: u64) -> Self {
        Self {
            registry: Arc::new(Registry::new()),
            streams: Arc::new(DashMap::new()),
            ice: Arc::new(DashMap::new()),
            audio_levels: Arc::new(DashMap::new()),
            devices: Arc::new(DashMap::new()),
            ws_interval_ms: ws_interval_ms.max(100),
            sample_ms: sample_ms.max(500),
        }
    }

    /// Per-camera stream stats, creating the entry on first use. The RTP
    /// clock rate is fixed per stream codec; if the codec is unknown at
    /// first touch, the video-standard 90 kHz is assumed.
    pub fn stream(&self, room_id: &str, camera_id: &str, clock_rate: u32) -> Arc<StreamStats> {
        let key = (room_id.to_string(), camera_id.to_string());
        self.streams
            .entry(key.clone())
            .or_insert_with(|| Arc::new(StreamStats::new(clock_rate.max(1))))
            .value()
            .clone()
    }

    /// Removes a camera's stream stats (camera torn down).
    pub fn remove_stream(&self, room_id: &str, camera_id: &str) {
        self.streams
            .remove(&(room_id.to_string(), camera_id.to_string()));
    }

    /// Aggregated `(ingress_bps, egress_bps, max_jitter_ms)` across all
    /// live camera streams — fed into the global gauges by the engine's
    /// stats sampler.
    pub fn stream_totals(&self) -> (f64, f64, f64) {
        let mut ingress = 0.0f64;
        let mut egress = 0.0f64;
        let mut jitter = 0.0f64;
        for entry in self.streams.iter() {
            let stats = entry.value();
            ingress += stats.ingress_bps();
            egress += stats.egress_bps();
            jitter = jitter.max(stats.jitter_ms());
        }
        (ingress, egress, jitter)
    }

    /// Records (or updates) the ICE state of a session.
    pub fn record_ice(
        &self,
        session_id: &str,
        kind: &'static str,
        room_id: &str,
        camera_id: &str,
        state: &str,
    ) {
        self.ice.insert(
            session_id.to_string(),
            IceSessionInfo {
                kind,
                room_id: room_id.to_string(),
                camera_id: camera_id.to_string(),
                state: state.to_string(),
            },
        );
    }

    /// Removes a session's ICE entry (session closed).
    pub fn remove_ice(&self, session_id: &str) {
        self.ice.remove(session_id);
    }

    /// Records the latest audio level metering of one mixer bus.
    pub fn record_audio_level(&self, room_id: &str, bus: &str, peak_db: f32, rms_db: f32) {
        self.audio_levels
            .insert((room_id.to_string(), bus.to_string()), (peak_db, rms_db));
    }

    /// Records (or replaces) a broadcaster's device health snapshot.
    pub fn record_device(&self, entry: DeviceTelemetryEntry) {
        self.devices
            .insert((entry.room_id.clone(), entry.camera_id.clone()), entry);
    }

    /// Latest audio metering for one room, sorted by bus name.
    pub fn audio_levels_for(&self, room_id: &str) -> Vec<(String, f32, f32)> {
        let mut levels: Vec<(String, f32, f32)> = self
            .audio_levels
            .iter()
            .filter(|entry| entry.key().0 == room_id)
            .map(|entry| (entry.key().1.clone(), entry.value().0, entry.value().1))
            .collect();
        levels.sort_by(|a, b| a.0.cmp(&b.0));
        levels
    }

    /// Builds the JSON snapshot for the WebSocket feed.
    pub fn snapshot(&self) -> TelemetrySnapshot {
        let metrics = self
            .registry
            .values()
            .into_iter()
            .map(|(name, value)| (name.to_string(), value))
            .collect();

        let mut streams: Vec<StreamFeedEntry> = self
            .streams
            .iter()
            .map(|entry| StreamFeedEntry {
                room_id: entry.key().0.clone(),
                camera_id: entry.key().1.clone(),
                stats: entry.value().snapshot(),
            })
            .collect();
        streams.sort_by(|a, b| (&a.room_id, &a.camera_id).cmp(&(&b.room_id, &b.camera_id)));

        let mut ice_sessions: Vec<IceSessionInfo> =
            self.ice.iter().map(|entry| entry.value().clone()).collect();
        ice_sessions.sort_by(|a, b| (&a.room_id, &a.camera_id).cmp(&(&b.room_id, &b.camera_id)));

        let mut audio_levels: Vec<AudioLevelEntry> = self
            .audio_levels
            .iter()
            .map(|entry| AudioLevelEntry {
                room_id: entry.key().0.clone(),
                bus: entry.key().1.clone(),
                peak_db: entry.value().0,
                rms_db: entry.value().1,
            })
            .collect();
        audio_levels.sort_by(|a, b| (&a.room_id, &a.bus).cmp(&(&b.room_id, &b.bus)));

        let mut devices: Vec<DeviceTelemetryEntry> = self
            .devices
            .iter()
            .map(|entry| entry.value().clone())
            .collect();
        devices.sort_by(|a, b| (&a.room_id, &a.camera_id).cmp(&(&b.room_id, &b.camera_id)));

        TelemetrySnapshot {
            metrics,
            streams,
            ice_sessions,
            audio_levels,
            devices,
        }
    }

    /// Renders the Prometheus text format.
    pub fn render_prometheus(&self) -> String {
        self.registry.render()
    }
}
