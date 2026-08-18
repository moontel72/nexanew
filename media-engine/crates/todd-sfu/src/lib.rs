//! T-Odd SFU — the WebRTC media plane.
//!
//! ```text
//! camera --WHIP--> RTCPeerConnection --RTP--> TrackRouter --RTP--> WHEP viewers
//!                                        \                     (simulcast layers)
//!                                         +--> transcode forwarders (rtmp/srt/file)
//! ```
//!
//! Responsibilities:
//! - WHIP ingest with per-interface ICE policy, consent freshness,
//!   takeover reconnects and `Disconnected` grace watchdogs (`engine`).
//! - Simulcast-aware track routing: streams are keyed by
//!   `(room, camera, rid)`; viewers and forwarders subscribe to a layer
//!   (`router`).
//! - PLI forwarding between viewer and publisher legs (`pli`), on top of
//!   the default interceptor set that already provides NACK
//!   retransmission and TWCC congestion control.
//! - Telemetry: Prometheus metrics + WebSocket diagnostics
//!   (`todd-telemetry`).
//! - GStreamer forwarding with the hardware-acceleration matrix and
//!   multichannel audio mixer (`todd-transcode`, `gst` feature).
//!
//! Two usage modes:
//! - **Embedded**: the signaling service (`todd-signaling`) instantiates
//!   `Engine` in-process.
//! - **Standalone**: the `todd-broadcaster` binary (this crate's
//!   `main.rs`) serves its own HTTP API; signaling proxies to it with
//!   `MEDIA_PLANE=remote`.

pub mod engine;
pub mod http_routes;
pub mod net;
pub mod pli;
pub mod router;
pub mod whep_peer;
pub mod whip_peer;

pub use engine::{ice_server_from_string, Engine, EngineConfig, Session, ViewerSession};
pub use router::{RouterStats, TrackRouter};
