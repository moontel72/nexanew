//! API DTOs shared by Studio, Broadcaster and (conceptually) Laravel.
//! Field names use snake_case everywhere so the JSON contract matches the
//! PHP payloads in `docs/04-laravel-integration.md` 1:1.

use std::collections::HashMap;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

use crate::media::{AudioMixerConfig, EncoderKind};

/// Default lifetime of a room when the caller does not specify one.
pub const DEFAULT_ROOM_TTL_SECS: u64 = 3600;
/// Hard cap so a misbehaving caller cannot mint near-immortal tokens.
pub const MAX_ROOM_TTL_SECS: u64 = 86_400;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateRoomRequest {
    pub name: String,
    /// Stable camera identifiers for this room, e.g. ["cam-1", "cam-2"].
    /// Defaults to a single camera named "default".
    #[serde(default)]
    pub camera_ids: Vec<String>,
    /// Room lifetime in seconds (clamped to [60, 86400] by the server).
    #[serde(default = "default_room_ttl")]
    pub ttl_secs: u64,
}

fn default_room_ttl() -> u64 {
    DEFAULT_ROOM_TTL_SECS
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CameraInfo {
    pub id: String,
    /// Populated from live session state when rooms are read.
    #[serde(default)]
    pub active: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Room {
    pub id: String,
    pub name: String,
    pub created_at: DateTime<Utc>,
    pub expires_at: DateTime<Utc>,
    pub cameras: Vec<CameraInfo>,
}

#[derive(Debug, Clone, Serialize)]
pub struct CreateRoomResponse {
    pub room: Room,
    /// One short-lived publisher JWT per camera, scoped to that camera.
    pub ingest_tokens: HashMap<String, String>,
    /// Viewer JWT scoped to the room.
    pub viewer_token: String,
    /// Base URL cameras POST their WHIP offers to, e.g.
    /// "https://media.traceodd.com/api/v1/whip/ingest/{room_id}".
    /// Clients append "/{camera_id}".
    pub whip_base_url: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ForwardKind {
    /// Push to an RTMP target (YouTube/Facebook/OBS relay):
    /// url = "rtmp://a.rtmp.youtube.com/live2/xxxx"
    Rtmp,
    /// Push over SRT: url = "srt://host:port"
    Srt,
    /// Record to disk: url = "/var/media/{room}.mkv"
    File,
    /// Reserved: WebRTC viewer fan-out (requires a signaling service and
    /// gst-plugins-rs `webrtcsink` — see docs/01-architecture.md).
    WebRtcViewer,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ForwardTarget {
    pub camera_id: String,
    pub kind: ForwardKind,
    pub url: String,
    /// Hardware encoder preference (default: auto-detect NVENC → QSV →
    /// AMF → x264).
    #[serde(default)]
    pub encoder: EncoderKind,
    /// H.264 re-encode bitrate in kbps.
    #[serde(default = "default_bitrate_kbps")]
    pub bitrate_kbps: u32,
    /// Keyframe interval in frames.
    #[serde(default = "default_keyframe_interval")]
    pub keyframe_interval: u32,
    /// Simulcast layer to forward (`None` = lowest available).
    #[serde(default)]
    pub rid: Option<String>,
    /// Multichannel audio mixer configuration.
    #[serde(default)]
    pub audio: AudioMixerConfig,
}

fn default_bitrate_kbps() -> u32 {
    4000
}

fn default_keyframe_interval() -> u32 {
    60
}

/// Vision-switch transition type. The Studio director drives these through
/// `POST /api/v1/program/transition`. Cut is an instant source swap; Fade
/// and Stinger are recorded and surfaced to the Studio overlay, while the
/// SFU switches the program egress source.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TransitionKind {
    #[default]
    Cut,
    Fade,
    Stinger,
}

/// Request body for the vision switcher control contract.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgramTransitionRequest {
    pub room_id: String,
    /// The camera to move onto Program (the current Preview bus).
    pub camera_id: String,
    pub transition: TransitionKind,
}

/// Current program (PGM) state for one room. Exposed over HTTP and used
/// by the WHEP program egress to resolve the active source.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgramState {
    pub room_id: String,
    pub camera_id: String,
    /// Simulcast layer resolved for the program source (empty = lowest).
    #[serde(default)]
    pub rid: String,
    pub transition: TransitionKind,
    pub updated_at_ms: i64,
}
