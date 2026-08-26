//! Environment-driven configuration shared by both services.
//!
//! Everything is read from env vars so the same binaries run unchanged on
//! the Phase 1 shared VPS or the Phase 2 dedicated media server — the only
//! difference is the values in `.env` / systemd `EnvironmentFile`.

use std::{env, net::IpAddr, str::FromStr};

use crate::error::AppError;
use crate::media::EncoderKind;

fn env_or(key: &str, default: &str) -> String {
    env::var(key).unwrap_or_else(|_| default.to_string())
}

fn env_list(key: &str, default: &str) -> Vec<String> {
    env_or(key, default)
        .split(',')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect()
}

/// Where the Broadcaster engine runs relative to Studio.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum MediaPlaneMode {
    /// Engine inside the Studio process (Phase 1 default — one process,
    /// one port, simplest ops).
    #[default]
    Embedded,
    /// Standalone `todd-broadcaster` service; Studio proxies to it
    /// (Phase 2 / docker-compose).
    Remote,
}

impl FromStr for MediaPlaneMode {
    type Err = AppError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.trim().to_ascii_lowercase().as_str() {
            "embedded" | "local" => Ok(MediaPlaneMode::Embedded),
            "remote" => Ok(MediaPlaneMode::Remote),
            other => Err(AppError::BadRequest(format!(
                "invalid MEDIA_PLANE value '{other}' (expected embedded|remote)"
            ))),
        }
    }
}

/// Where room/session state is stored.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum RoomStoreMode {
    /// In-process DashMaps — Phase 1, single Studio instance.
    #[default]
    Memory,
    /// Redis — shared across Studio replicas / hosts (Phase 2.5).
    Redis,
    /// Try Redis first, fall back to in-memory when it is unreachable at
    /// startup — production default so a missing Redis never bricks the
    /// engine and rooms persist across restarts whenever it is present.
    Auto,
}

impl FromStr for RoomStoreMode {
    type Err = AppError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.trim().to_ascii_lowercase().as_str() {
            "memory" | "inmemory" => Ok(RoomStoreMode::Memory),
            "redis" => Ok(RoomStoreMode::Redis),
            "auto" => Ok(RoomStoreMode::Auto),
            other => Err(AppError::BadRequest(format!(
                "invalid ROOM_STORE value '{other}' (expected memory|redis|auto)"
            ))),
        }
    }
}

#[derive(Debug, Clone)]
pub struct Settings {
    // --- shared ---
    pub jwt_secret: String,
    pub jwt_issuer: String,
    pub cors_allowed_origins: Vec<String>,
    pub log_filter: String,

    // --- studio ---
    pub studio_listen: std::net::SocketAddr,
    pub public_base_url: String,
    pub room_ttl_secs: u64,
    pub ingest_token_ttl_secs: i64,
    pub media_plane: MediaPlaneMode,
    pub broadcaster_url: String,
    pub laravel_introspection_url: Option<String>,
    pub room_store: RoomStoreMode,
    pub redis_url: String,

    // --- broadcaster ---
    pub broadcaster_listen: std::net::SocketAddr,
    pub stun_servers: Vec<String>,
    pub turn_servers: Vec<String>,
    /// Advertise 127.0.0.1 as a host candidate (local dev only).
    pub ice_loopback: bool,

    // --- ICE / network policy ---
    /// Interface allow-list (names), empty = all routable interfaces.
    pub ice_interfaces: Vec<String>,
    /// Interface deny-list (names, prefix-match). Defaults cover known
    /// virtual adapter families (docker/veth/vmware/hyper-v/...).
    pub ice_deny_interfaces: Vec<String>,
    /// Public IPs advertised as 1:1 NAT host candidates (empty = none).
    pub ice_public_ips: Vec<String>,
    /// Pin the ICE ephemeral UDP port range (empty = OS-assigned).
    pub ice_udp_port_min: Option<u16>,
    pub ice_udp_port_max: Option<u16>,
    /// ICE timeouts (ms): disconnected / failed / keep-alive.
    pub ice_disconnected_timeout_ms: u64,
    pub ice_failed_timeout_ms: u64,
    pub ice_keepalive_interval_ms: u64,
    /// Server-side grace (ms) before a `Disconnected` session is
    /// proactively closed when it never recovers.
    pub ice_disconnected_grace_ms: u64,

    // --- telemetry ---
    pub telemetry_sample_ms: u64,
    pub telemetry_ws_interval_ms: u64,

    // --- replay ---
    /// Replay ring buffer retention window (ms).
    pub replay_buffer_ms: u64,
    /// Optional cloud callback URL notified on clip-export completion.
    pub replay_export_callback_url: Option<String>,

    // --- cricket scoreboard sync ---
    /// Base URL of the TraceOdd Cricket Manager panel.
    pub cricket_manager_url: String,
    /// Match ids to continuously sync into the Studio scoreboard hub.
    pub cricket_manager_match_ids: Vec<String>,
    /// Poll interval (ms) for the cricket-manager REST feed.
    pub cricket_manager_poll_ms: u64,
    /// Optional WebSocket feed URL (e.g. `wss://...`) for push updates.
    pub cricket_manager_ws_url: Option<String>,

    // --- program (PGM) mixer output ---
    /// Composite program frame width.
    pub program_width: u32,
    /// Composite program frame height.
    pub program_height: u32,
    /// Composite program frame rate.
    pub program_fps: u32,
    /// Composite program encoder bitrate.
    pub program_bitrate_kbps: u32,
    /// Composite program encoder preference (auto = NVENC → QSV → AMF → x264).
    pub program_encoder: EncoderKind,
    /// Default stinger asset URL used when a transition request does not
    /// carry its own asset (transparent WebM/MP4 or PNG).
    pub stinger_asset_url: Option<String>,
}

impl Settings {
    pub fn from_env() -> Result<Self, AppError> {
        let jwt_secret = env::var("JWT_SECRET").map_err(|_| {
            AppError::BadRequest("JWT_SECRET is required (64+ random chars)".to_string())
        })?;
        if jwt_secret.len() < 32 {
            return Err(AppError::BadRequest(
                "JWT_SECRET must be at least 32 characters".to_string(),
            ));
        }

        let parse_u64 = |key: &str, default: u64| -> Result<u64, AppError> {
            env_or(key, &default.to_string())
                .parse()
                .map_err(|_| AppError::BadRequest(format!("env {key} must be an integer")))
        };

        let parse_u16_opt = |key: &str| -> Result<Option<u16>, AppError> {
            match env::var(key) {
                Ok(raw) if !raw.trim().is_empty() => {
                    raw.trim().parse().map(Some).map_err(|_| {
                        AppError::BadRequest(format!("env {key} must be a port number"))
                    })
                }
                _ => Ok(None),
            }
        };

        let studio_ip = env_or("STUDIO_HOST", "127.0.0.1")
            .parse::<IpAddr>()
            .map_err(|_| AppError::BadRequest("STUDIO_HOST must be an IP address".to_string()))?;
        let studio_port = env_or("STUDIO_PORT", "8080")
            .parse::<u16>()
            .map_err(|_| AppError::BadRequest("STUDIO_PORT must be a port number".to_string()))?;
        let studio_listen = std::net::SocketAddr::new(studio_ip, studio_port);

        let broadcaster_ip = env_or("BROADCASTER_HOST", "127.0.0.1")
            .parse::<IpAddr>()
            .map_err(|_| {
                AppError::BadRequest("BROADCASTER_HOST must be an IP address".to_string())
            })?;
        let broadcaster_port = env_or("BROADCASTER_PORT", "8081")
            .parse::<u16>()
            .map_err(|_| {
                AppError::BadRequest("BROADCASTER_PORT must be a port number".to_string())
            })?;
        let broadcaster_listen = std::net::SocketAddr::new(broadcaster_ip, broadcaster_port);

        let introspection = env::var("LARAVEL_INTROSPECTION_URL")
            .ok()
            .map(|v| v.trim().to_string())
            .filter(|v| !v.is_empty());

        Ok(Settings {
            jwt_secret,
            jwt_issuer: env_or("JWT_ISSUER", "traceodd"),
            cors_allowed_origins: env_list("CORS_ALLOWED_ORIGINS", ""),
            log_filter: env_or("LOG_FILTER", "info"),

            studio_listen,
            public_base_url: env_or("PUBLIC_BASE_URL", &format!("http://{studio_listen}")),
            room_ttl_secs: parse_u64("ROOM_TTL_SECS", 3600)?,
            ingest_token_ttl_secs: parse_u64("INGEST_TOKEN_TTL_SECS", 21600)? as i64,
            media_plane: env_or("MEDIA_PLANE", "embedded")
                .parse()
                .map_err(|e: <MediaPlaneMode as FromStr>::Err| e)?,
            broadcaster_url: env_or("BROADCASTER_URL", "http://127.0.0.1:8081"),
            laravel_introspection_url: introspection,
            room_store: env_or("ROOM_STORE", "memory")
                .parse()
                .map_err(|e: <RoomStoreMode as FromStr>::Err| e)?,
            redis_url: env_or("REDIS_URL", "redis://127.0.0.1:6379/0"),

            broadcaster_listen,
            stun_servers: env_list("STUN_SERVERS", "stun:stun.l.google.com:19302"),
            turn_servers: env_list("TURN_SERVERS", ""),
            ice_loopback: env_or("ICE_LOOPBACK", "0") == "1",

            ice_interfaces: env_list("ICE_INTERFACES", ""),
            ice_deny_interfaces: env_list(
                "ICE_INTERFACE_DENY",
                "docker,veth,br-,virbr,vmnet,vEthernet,VMware,VirtualBox,Hyper-V,wsl,utun",
            ),
            ice_public_ips: env_list("ICE_PUBLIC_IPS", ""),
            ice_udp_port_min: parse_u16_opt("ICE_UDP_PORT_MIN")?,
            ice_udp_port_max: parse_u16_opt("ICE_UDP_PORT_MAX")?,
            ice_disconnected_timeout_ms: parse_u64("ICE_DISCONNECTED_TIMEOUT_MS", 5000)?,
            ice_failed_timeout_ms: parse_u64("ICE_FAILED_TIMEOUT_MS", 15000)?,
            ice_keepalive_interval_ms: parse_u64("ICE_KEEPALIVE_INTERVAL_MS", 2000)?,
            ice_disconnected_grace_ms: parse_u64("ICE_DISCONNECTED_GRACE_MS", 8000)?,

            telemetry_sample_ms: parse_u64("TELEMETRY_SAMPLE_MS", 2000)?,
            telemetry_ws_interval_ms: parse_u64("TELEMETRY_WS_INTERVAL_MS", 1000)?,

            replay_buffer_ms: parse_u64("REPLAY_BUFFER_MS", 15000)?,
            replay_export_callback_url: env::var("REPLAY_EXPORT_CALLBACK_URL")
                .ok()
                .map(|v| v.trim().to_string())
                .filter(|v| !v.is_empty()),

            cricket_manager_url: env_or("CRICKET_MANAGER_URL", ""),
            cricket_manager_match_ids: env_list("CRICKET_MANAGER_MATCH_IDS", ""),
            cricket_manager_poll_ms: parse_u64("CRICKET_MANAGER_POLL_MS", 3000)?,
            cricket_manager_ws_url: env::var("CRICKET_MANAGER_WS_URL")
                .ok()
                .map(|v| v.trim().to_string())
                .filter(|v| !v.is_empty()),

            program_width: parse_u64("PROGRAM_WIDTH", 1280)? as u32,
            program_height: parse_u64("PROGRAM_HEIGHT", 720)? as u32,
            program_fps: parse_u64("PROGRAM_FPS", 30)? as u32,
            program_bitrate_kbps: parse_u64("PROGRAM_BITRATE_KBPS", 2500)? as u32,
            program_encoder: env_or("PROGRAM_ENCODER", "auto")
                .parse()
                .map_err(|e: <crate::media::EncoderKind as std::str::FromStr>::Err| e)?,
            stinger_asset_url: env::var("STINGER_ASSET_URL")
                .ok()
                .map(|v| v.trim().to_string())
                .filter(|v| !v.is_empty()),
        })
    }
}
