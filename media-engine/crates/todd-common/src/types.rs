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

/// How a camera's media reaches the engine.
///
/// `whip` is the fully implemented ingest path; `rtsp` (pull) and `rtmp`
/// (push) mark cameras whose sources are attached by external adapters —
/// the metadata flows through the control plane now so directors can
/// configure the source up front.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum CameraSourceKind {
    /// WebRTC HTTP Ingestion Protocol (RFC draft-ietf-wish-whip).
    #[default]
    Whip,
    /// RTSP pull source.
    Rtsp,
    /// RTMP push source.
    Rtmp,
}

/// Camera metadata supplied by a caller when creating or adding a camera.
/// `kind` and `group` are optional so existing plain-id payloads keep
/// working unchanged.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CameraSpec {
    /// Stable identifier, unique within the room (e.g. "cam-1").
    pub id: String,
    /// Director-facing label (e.g. "Cam 1 — Mid Wicket").
    #[serde(default)]
    pub label: Option<String>,
    /// Source transport for this camera.
    #[serde(default)]
    pub kind: CameraSourceKind,
    /// Logical grouping (e.g. "ground", "drone", "studio").
    #[serde(default)]
    pub group: Option<String>,
    /// Source URL for `rtsp`/`rtmp` cameras (required by those kinds;
    /// ignored for WHIP cameras).
    #[serde(default)]
    pub url: Option<String>,
}

impl CameraSpec {
    /// Converts a spec into stored camera metadata. Liveness (`active`) is
    /// never stored — it is computed from live WHIP session state on read.
    pub fn into_info(self) -> CameraInfo {
        CameraInfo {
            id: self.id,
            label: self.label.filter(|label| !label.trim().is_empty()),
            kind: self.kind,
            group: self.group.filter(|group| !group.trim().is_empty()),
            url: self
                .url
                .map(|url| url.trim().to_string())
                .filter(|url| !url.is_empty()),
            active: false,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateRoomRequest {
    pub name: String,
    /// Stable camera identifiers for this room, e.g. ["cam-1", "cam-2"].
    /// Defaults to a single camera named "default".
    #[serde(default)]
    pub camera_ids: Vec<String>,
    /// Full camera metadata. When non-empty it takes precedence over
    /// `camera_ids` (which stays supported for the Laravel caller).
    #[serde(default)]
    pub camera_specs: Vec<CameraSpec>,
    /// Room lifetime in seconds (clamped to [60, 86400] by the server).
    #[serde(default = "default_room_ttl")]
    pub ttl_secs: u64,
}

fn default_room_ttl() -> u64 {
    DEFAULT_ROOM_TTL_SECS
}

/// Metadata of one camera inside a room. `label`, `kind` and `group` are
/// director-facing configuration; `active` is computed from live session
/// state when rooms are read.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CameraInfo {
    pub id: String,
    /// Director-facing label; falls back to `id` in the UI.
    #[serde(default)]
    pub label: Option<String>,
    /// Source transport for this camera.
    #[serde(default)]
    pub kind: CameraSourceKind,
    /// Logical grouping of cameras.
    #[serde(default)]
    pub group: Option<String>,
    /// Source URL for `rtsp`/`rtmp` cameras (ignored for WHIP cameras).
    #[serde(default)]
    pub url: Option<String>,
    /// Populated from live session state when rooms are read.
    #[serde(default)]
    pub active: bool,
}

/// Partial camera metadata update. Every field is optional: omitted
/// fields keep their current value; an explicit empty string clears a
/// text field.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct UpdateCameraRequest {
    #[serde(default)]
    pub label: Option<String>,
    #[serde(default)]
    pub kind: Option<CameraSourceKind>,
    #[serde(default)]
    pub group: Option<String>,
}

/// Response of `POST /api/v1/room/{room_id}/camera`: the stored camera
/// plus the short-lived publisher token the camera operator needs to
/// start WHIP ingest.
#[derive(Debug, Clone, Serialize)]
pub struct AddCameraResponse {
    pub camera: CameraInfo,
    /// Publisher JWT scoped to exactly this (room, camera).
    pub ingest_token: String,
    /// Base URL cameras POST their WHIP offers to; append "/{camera_id}".
    pub whip_base_url: String,
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

/// How a forwarder target is fed: straight from one camera, or from the
/// room's mixed program (PGM) composite.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ForwardSource {
    /// Fan out one camera's live stream (default, backward compatible).
    #[default]
    Camera,
    /// Fan out the mixed program composite (video + mixed audio).
    Program,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ForwardTarget {
    pub camera_id: String,
    /// Which feed the target consumes. `camera_id` is ignored for
    /// `program` sources.
    #[serde(default)]
    pub source: ForwardSource,
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
    /// Multichannel audio mixer configuration (camera sources only; the
    /// program source already carries the mixed audio).
    #[serde(default)]
    pub audio: AudioMixerConfig,
}

/// Lifecycle state of one output forwarder.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ForwardState {
    Starting,
    Running,
    Stopped,
    Failed,
}

/// Runtime status of one output forwarder, exposed to the Studio
/// broadcast panel.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ForwardingStatus {
    /// Stable identifier: `{room}/{source}` or `{room}/{camera}/{url}`.
    pub key: String,
    pub room_id: String,
    pub source: ForwardSource,
    pub kind: ForwardKind,
    pub url: String,
    pub state: ForwardState,
    pub started_at_ms: i64,
    /// Last failure message, when `state == failed`.
    #[serde(default)]
    pub error: Option<String>,
}

fn default_bitrate_kbps() -> u32 {
    4000
}

fn default_keyframe_interval() -> u32 {
    60
}

/// Vision-switch transition type. The Studio director drives these through
/// `POST /api/v1/program/transition`. Cut is an instant source swap; Fade
/// cross-blends opacity; LumaWipe reveals the incoming source with a
/// moving boundary; Stinger plays an animated overlay while the program
/// source swaps behind it. The SFU mixer renders all of them into the
/// program egress.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TransitionKind {
    #[default]
    Cut,
    Fade,
    LumaWipe,
    Stinger,
}

/// Default transition duration when a caller does not specify one.
pub const DEFAULT_TRANSITION_DURATION_MS: u64 = 600;

/// Hard cap so a misbehaving caller cannot stall the program bus.
pub const MAX_TRANSITION_DURATION_MS: u64 = 10_000;

/// Animated overlay asset played during a stinger transition (e.g. the
/// Wicket / Boundary / 6s stingers).
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct StingerSpec {
    /// Asset URL (transparent WebM/MP4 or PNG). When `None`, the mixer
    /// falls back to the server's configured stinger asset.
    #[serde(default)]
    pub asset_url: Option<String>,
}

/// A camera source within a scene. Scenes reference cameras of the same
/// room.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct SourceRef {
    pub room_id: String,
    pub camera_id: String,
}

/// Picture-in-picture placement of an overlay source on top of a main
/// source. Coordinates are normalized (0.0–1.0) to the program frame.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PiPConfig {
    pub main: SourceRef,
    pub overlay: SourceRef,
    /// Left edge of the overlay window.
    #[serde(default = "default_pip_x")]
    pub overlay_x: f32,
    /// Top edge of the overlay window.
    #[serde(default = "default_pip_y")]
    pub overlay_y: f32,
    /// Overlay window width.
    #[serde(default = "default_pip_width")]
    pub overlay_width: f32,
    /// Overlay window height.
    #[serde(default = "default_pip_height")]
    pub overlay_height: f32,
    /// Overlay opacity (0.0 transparent – 1.0 opaque).
    #[serde(default = "default_pip_opacity")]
    pub overlay_opacity: f32,
}

fn default_pip_x() -> f32 {
    0.72
}
fn default_pip_y() -> f32 {
    0.05
}
fn default_pip_width() -> f32 {
    0.26
}
fn default_pip_height() -> f32 {
    0.26
}
fn default_pip_opacity() -> f32 {
    1.0
}

/// How a split scene divides the frame.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum SplitOrientation {
    #[default]
    Horizontal,
    Vertical,
}

/// One region of a split scene.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SplitRegion {
    pub source: SourceRef,
    /// Relative size of the region; weights are normalized across the
    /// split's regions.
    #[serde(default = "default_split_weight")]
    pub weight: f32,
}

fn default_split_weight() -> f32 {
    1.0
}

/// Split scene: two or more regions laid out along one axis.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SplitScreenConfig {
    pub orientation: SplitOrientation,
    #[serde(default)]
    pub regions: Vec<SplitRegion>,
}

/// Side-by-side comparison: two equally sized sources.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SideBySideConfig {
    pub left: SourceRef,
    pub right: SourceRef,
}

/// A program scene layout. Serde-tagged: the `kind` field discriminates
/// the variant (mirrored 1:1 by the TypeScript union in the Studio GUI).
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum SceneLayout {
    Fullscreen,
    PictureInPicture(PiPConfig),
    SplitScreen(SplitScreenConfig),
    SideBySide(SideBySideConfig),
}

impl Default for SceneLayout {
    fn default() -> Self {
        SceneLayout::Fullscreen
    }
}

/// Request body for the vision switcher control contract.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProgramTransitionRequest {
    pub room_id: String,
    /// The camera to move onto Program (the current Preview bus).
    pub camera_id: String,
    #[serde(default)]
    pub transition: TransitionKind,
    /// Transition duration in milliseconds; only meaningful for
    /// Fade / LumaWipe / Stinger (clamped server-side).
    #[serde(default)]
    pub duration_ms: Option<u64>,
    /// Scene layout to render on the program bus. `None` keeps the
    /// room's current layout.
    #[serde(default)]
    pub layout: Option<SceneLayout>,
    /// Stinger asset override (only used for `transition: stinger`).
    #[serde(default)]
    pub stinger: Option<StingerSpec>,
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
    #[serde(default)]
    pub transition: TransitionKind,
    /// Duration the last transition ran (or runs) for.
    #[serde(default = "default_transition_duration")]
    pub duration_ms: u64,
    /// Scene layout currently applied to the program bus.
    #[serde(default)]
    pub layout: SceneLayout,
    /// Stinger asset of the last stinger transition, when one ran.
    #[serde(default)]
    pub stinger: Option<StingerSpec>,
    pub updated_at_ms: i64,
}

fn default_transition_duration() -> u64 {
    DEFAULT_TRANSITION_DURATION_MS
}

// ---------------------------------------------------------------------------
// Program overlays (server-side burn-in)
// ---------------------------------------------------------------------------

/// The scoreboard lower-third burned into the program video.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScoreboardOverlay {
    pub enabled: bool,
    /// Main line, e.g. "TIGERS 142/4 — 16.2 ov".
    #[serde(default)]
    pub title: String,
    /// Second line, e.g. "Khan 45* · Patel 2/18 · CRR 8.7".
    #[serde(default)]
    pub subtitle: String,
}

/// Animated event popup (Boundary / SIX / Wicket / milestone).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventPopupSpec {
    /// Main text, e.g. "SIX!".
    pub text: String,
    /// Optional second line.
    #[serde(default)]
    pub subtext: Option<String>,
    /// How long the popup stays on air.
    #[serde(default = "default_popup_duration_ms")]
    pub duration_ms: u64,
}

fn default_popup_duration_ms() -> u64 {
    2500
}

/// Corner watermark / channel logo burned into the program video.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WatermarkSpec {
    /// Transparent PNG URL or file path.
    pub asset_url: String,
    /// Normalized position (0.0–1.0) of the overlay's top-left corner.
    #[serde(default = "default_watermark_x")]
    pub x: f32,
    #[serde(default = "default_watermark_y")]
    pub y: f32,
}

/// One answer option of a spectator poll, burned into the program video.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PollOptionSpec {
    pub label: String,
    #[serde(default)]
    pub votes: u64,
}

/// Live spectator poll burned into the program composite (WHEP/RTMP
/// viewers see the tally, not just director panels).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PollOverlaySpec {
    pub question: String,
    #[serde(default)]
    pub options: Vec<PollOptionSpec>,
}

fn default_watermark_x() -> f32 {
    0.965
}

fn default_watermark_y() -> f32 {
    0.02
}

/// The live overlay state of one room's program bus.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct OverlayState {
    #[serde(default)]
    pub scoreboard: Option<ScoreboardOverlay>,
    #[serde(default)]
    pub popup: Option<EventPopupSpec>,
    #[serde(default)]
    pub watermark: Option<WatermarkSpec>,
    #[serde(default)]
    pub poll: Option<PollOverlaySpec>,
}

/// A burn-in command for `POST /api/v1/program/overlay`. Serde-tagged:
/// the `kind` field discriminates the variant.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum OverlayCommand {
    /// Enable/disable or restyle the scoreboard lower-third.
    Scoreboard {
        enabled: bool,
        #[serde(default)]
        title: String,
        #[serde(default)]
        subtitle: String,
    },
    /// Fire an event popup (Boundary / SIX / Wicket / milestone).
    EventPopup {
        text: String,
        #[serde(default)]
        subtext: Option<String>,
        #[serde(default)]
        duration_ms: Option<u64>,
    },
    /// Enable/disable or restyle the corner watermark.
    Watermark {
        enabled: bool,
        #[serde(default)]
        asset_url: Option<String>,
        #[serde(default = "default_watermark_x")]
        x: f32,
        #[serde(default = "default_watermark_y")]
        y: f32,
    },
    /// Show/update the live spectator poll burn-in.
    Poll {
        question: String,
        #[serde(default)]
        options: Vec<PollOptionSpec>,
    },
    /// Remove the poll burn-in (other overlays stay on air).
    PollClear,
}

/// Wrapper carrying the room id for overlay commands.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OverlayRequest {
    pub room_id: String,
    pub command: OverlayCommand,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn camera_source_kind_serializes_snake_case() {
        assert_eq!(
            serde_json::to_string(&CameraSourceKind::Whip).unwrap(),
            "\"whip\""
        );
        assert_eq!(
            serde_json::to_string(&CameraSourceKind::Rtsp).unwrap(),
            "\"rtsp\""
        );
        assert_eq!(
            serde_json::to_string(&CameraSourceKind::Rtmp).unwrap(),
            "\"rtmp\""
        );
    }

    #[test]
    fn camera_info_tolerates_legacy_payloads() {
        // Rooms persisted before the metadata fields existed must still
        // deserialize: label/group default to None, kind to Whip.
        let legacy = "{\"id\":\"cam-1\",\"active\":true}";
        let info: CameraInfo = serde_json::from_str(legacy).unwrap();
        assert_eq!(info.id, "cam-1");
        assert!(info.label.is_none());
        assert!(info.group.is_none());
        assert_eq!(info.kind, CameraSourceKind::Whip);
        assert!(info.active);
    }

    #[test]
    fn camera_spec_blank_text_fields_become_none() {
        let spec = CameraSpec {
            id: "cam-2".to_string(),
            label: Some("   ".to_string()),
            kind: CameraSourceKind::Rtsp,
            group: Some("".to_string()),
            url: None,
        };
        let info = spec.into_info();
        assert_eq!(info.id, "cam-2");
        assert!(info.label.is_none());
        assert!(info.group.is_none());
        assert_eq!(info.kind, CameraSourceKind::Rtsp);
        assert!(!info.active);
    }

    #[test]
    fn update_camera_request_defaults_to_all_none() {
        let update: UpdateCameraRequest = serde_json::from_str("{}").unwrap();
        assert!(update.label.is_none());
        assert!(update.kind.is_none());
        assert!(update.group.is_none());
    }

    #[test]
    fn scene_layout_serializes_tagged_kind() {
        let pip = SceneLayout::PictureInPicture(PiPConfig {
            main: SourceRef {
                room_id: "r".to_string(),
                camera_id: "cam-1".to_string(),
            },
            overlay: SourceRef {
                room_id: "r".to_string(),
                camera_id: "cam-2".to_string(),
            },
            overlay_x: 0.7,
            overlay_y: 0.1,
            overlay_width: 0.25,
            overlay_height: 0.25,
            overlay_opacity: 1.0,
        });
        let json = serde_json::to_string(&pip).unwrap();
        assert!(json.contains("\"kind\":\"picture_in_picture\""));
        let roundtrip: SceneLayout = serde_json::from_str(&json).unwrap();
        assert!(matches!(roundtrip, SceneLayout::PictureInPicture(_)));

        assert_eq!(
            serde_json::to_string(&SceneLayout::Fullscreen).unwrap(),
            "{\"kind\":\"fullscreen\"}"
        );
    }

    #[test]
    fn luma_wipe_transition_kind_roundtrips() {
        let json = serde_json::to_string(&TransitionKind::LumaWipe).unwrap();
        assert_eq!(json, "\"luma_wipe\"");
        let back: TransitionKind = serde_json::from_str(&json).unwrap();
        assert_eq!(back, TransitionKind::LumaWipe);
    }

    #[test]
    fn program_transition_request_tolerates_legacy_payloads() {
        // Legacy callers send only room/camera/transition.
        let legacy = "{\"room_id\":\"r\",\"camera_id\":\"cam-1\",\"transition\":\"cut\"}";
        let req: ProgramTransitionRequest = serde_json::from_str(legacy).unwrap();
        assert_eq!(req.transition, TransitionKind::Cut);
        assert!(req.duration_ms.is_none());
        assert!(req.layout.is_none());
        assert!(req.stinger.is_none());
    }

    #[test]
    fn program_state_defaults_layout_to_fullscreen() {
        let legacy = "{\"room_id\":\"r\",\"camera_id\":\"cam-1\",\"updated_at_ms\":1}";
        let state: ProgramState = serde_json::from_str(legacy).unwrap();
        assert!(matches!(state.layout, SceneLayout::Fullscreen));
        assert_eq!(state.duration_ms, DEFAULT_TRANSITION_DURATION_MS);
        assert_eq!(state.transition, TransitionKind::Cut);
    }

    #[test]
    fn overlay_commands_serialize_tagged_kind() {
        let command = OverlayCommand::EventPopup {
            text: "SIX!".to_string(),
            subtext: Some("Khan".to_string()),
            duration_ms: Some(3000),
        };
        let json = serde_json::to_string(&command).unwrap();
        assert!(json.contains("\"kind\":\"event_popup\""));
        let back: OverlayCommand = serde_json::from_str(&json).unwrap();
        assert!(matches!(back, OverlayCommand::EventPopup { .. }));

        let command = OverlayCommand::Scoreboard {
            enabled: true,
            title: "142/4".to_string(),
            subtitle: String::new(),
        };
        let json = serde_json::to_string(&command).unwrap();
        assert!(json.contains("\"kind\":\"scoreboard\""));

        let command = OverlayCommand::Poll {
            question: "Player of the match?".to_string(),
            options: vec![PollOptionSpec {
                label: "Khan".to_string(),
                votes: 12,
            }],
        };
        let json = serde_json::to_string(&command).unwrap();
        assert!(json.contains("\"kind\":\"poll\""));
        let back: OverlayCommand = serde_json::from_str(&json).unwrap();
        assert!(matches!(back, OverlayCommand::Poll { .. }));

        let command = OverlayCommand::PollClear;
        let json = serde_json::to_string(&command).unwrap();
        assert!(json.contains("\"kind\":\"poll_clear\""));
        let back: OverlayCommand = serde_json::from_str(&json).unwrap();
        assert!(matches!(back, OverlayCommand::PollClear));

        // OverlayState gains the poll slot alongside the existing ones.
        let state: OverlayState = serde_json::from_str(
            "{\"scoreboard\":null,\"popup\":null,\"watermark\":null,\"poll\":null}",
        )
        .unwrap();
        assert!(state.poll.is_none());
    }

    #[test]
    fn forward_target_defaults_to_camera_source() {
        let legacy = "{\"camera_id\":\"cam-1\",\"kind\":\"rtmp\",\"url\":\"rtmp://x/live/k\"}";
        let target: ForwardTarget = serde_json::from_str(legacy).unwrap();
        assert_eq!(target.source, ForwardSource::Camera);
    }

    #[test]
    fn forwarding_status_serializes_snake_case() {
        let status = ForwardingStatus {
            key: "r-1/program".to_string(),
            room_id: "r-1".to_string(),
            source: ForwardSource::Program,
            kind: ForwardKind::Rtmp,
            url: "rtmp://x/live/k".to_string(),
            state: ForwardState::Running,
            started_at_ms: 1,
            error: None,
        };
        let json = serde_json::to_string(&status).unwrap();
        assert!(json.contains("\"state\":\"running\""));
        assert!(json.contains("\"source\":\"program\""));
    }
}
