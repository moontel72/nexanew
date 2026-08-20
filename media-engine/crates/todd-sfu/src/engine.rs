//! SFU engine: session registry + webrtc-rs API + track routing +
//! forwarders + telemetry + PLI forwarding.
//!
//! Two webrtc-rs APIs are built at startup:
//! - `api_whip` — WHIP ingest PCs, carrying the PLI *writer* interceptor
//!   (the SFU injects keyframe requests into publisher-bound RTCP).
//! - `api_whep` — WHEP viewer PCs, carrying the PLI *reader* interceptor
//!   (viewer PLIs are observed and forwarded upstream).
//!
//! Network policy (ICE candidates, timeouts, port binding) is resolved
//! once at startup by [`net::build_policy`] — see `net.rs`.

use std::sync::Arc;
use std::time::Duration;

use dashmap::DashMap;
use todd_common::error::AppError;
use todd_common::media::{AudioMixView, AudioMixerConfig};
#[cfg(feature = "gst")]
use todd_common::types::SourceRef;
use todd_common::types::{
    CameraInfo, ForwardingStatus, OverlayCommand, OverlayState, ProgramState,
    ProgramTransitionRequest, DEFAULT_TRANSITION_DURATION_MS, MAX_TRANSITION_DURATION_MS,
};
use todd_replay::export::ClipExportRequest;
use todd_replay::session::{ReplayInfo, ReplayTrigger};
use todd_replay::ReplayManager;
use todd_telemetry::{StreamStats, Telemetry};
use tokio_util::sync::CancellationToken;
use uuid::Uuid;
use webrtc::{
    api::{
        interceptor_registry::register_default_interceptors, media_engine::MediaEngine,
        setting_engine::SettingEngine, APIBuilder, API,
    },
    ice_transport::{ice_candidate_type::RTCIceCandidateType, ice_server::RTCIceServer},
    interceptor::registry::Registry,
    peer_connection::{peer_connection_state::RTCPeerConnectionState, RTCPeerConnection},
};
use webrtc_ice::mdns::MulticastDnsMode;
use webrtc_ice::udp_network::{EphemeralUDP, UDPNetwork};

use crate::net::{self, IceNetworkPolicy};
use crate::pli::PliBroker;
use crate::{router::TrackRouter, whep_peer, whip_peer};

use todd_transcode::mixer::MixerOutputConfig;
#[cfg(feature = "gst")]
use todd_transcode::mixer::{plan_scene, source_key};
#[cfg(feature = "gst")]
use todd_transcode::mixer_gst::{audio_feed_key, GstProgramMixer};

/// Per-host engine configuration. Clonable: the interface/IP filters are
/// `Arc`d closures.
#[derive(Clone)]
pub struct EngineConfig {
    pub ice_servers: Vec<RTCIceServer>,
    /// ICE network policy resolved from host interfaces + settings.
    pub policy: IceNetworkPolicy,
    /// Server-side grace before a `Disconnected` session that never
    /// recovers is proactively closed.
    pub disconnected_grace: Duration,
    /// Replay ring buffer retention window.
    pub replay_buffer_ms: u64,
    /// Cloud callback URL notified on clip-export completion.
    pub replay_export_callback_url: Option<String>,
    /// Composite program (PGM) output of the GStreamer mixer.
    pub program_output: MixerOutputConfig,
}

/// Parses a TURN entry of the form `user:password@host:port` (as used in
/// `TURN_SERVERS`) into a webrtc-rs ICE server. STUN entries are passed
/// through unchanged.
pub fn ice_server_from_string(entry: &str) -> Result<RTCIceServer, AppError> {
    if entry.starts_with("stun:") {
        return Ok(RTCIceServer {
            urls: vec![entry.to_string()],
            ..Default::default()
        });
    }
    let rest = entry.strip_prefix("turn:").unwrap_or(entry);
    let (creds, host) = rest.rsplit_once('@').ok_or_else(|| {
        AppError::BadRequest(format!(
            "invalid TURN_SERVERS entry '{entry}' (expected user:password@host:port)"
        ))
    })?;
    let (username, credential) = creds.split_once(':').ok_or_else(|| {
        AppError::BadRequest(format!(
            "invalid TURN_SERVERS entry '{entry}' (expected user:password@host:port)"
        ))
    })?;
    Ok(RTCIceServer {
        urls: vec![format!("turn:{host}")],
        username: username.to_string(),
        credential: credential.to_string(),
    })
}

/// One live WHIP session.
pub struct Session {
    pub room_id: String,
    pub camera_id: String,
    pc: Arc<RTCPeerConnection>,
    /// Cancels the track pump tasks on teardown.
    shutdown: CancellationToken,
}

/// One live WHEP viewer session (WebRTC fan-out consumer).
pub struct ViewerSession {
    pub room_id: String,
    pub camera_id: String,
    /// Simulcast layer this viewer watches.
    pub rid: String,
    /// Our outbound video SSRC (for PLI mapping teardown).
    viewer_ssrc: Option<u32>,
    pc: Arc<RTCPeerConnection>,
    shutdown: CancellationToken,
}

/// Cloneable handle to the whole engine. All state is behind Arc/DashMap.
#[derive(Clone)]
pub struct Engine {
    pub(crate) api_whip: Arc<API>,
    pub(crate) api_whep: Arc<API>,
    pub(crate) config: EngineConfig,
    pub(crate) sessions: Arc<DashMap<String, Session>>,
    pub(crate) viewers: Arc<DashMap<String, ViewerSession>>,
    pub(crate) router: Arc<TrackRouter>,
    pub telemetry: Arc<Telemetry>,
    pub(crate) pli: Arc<PliBroker>,
    /// Cricket instant replay engine (ring buffer + replay sessions).
    pub replay: Arc<ReplayManager>,
    /// Per-room program (PGM) source state. Keyed by room id.
    pub(crate) program: Arc<DashMap<String, ProgramState>>,
    /// Per-room audio mixer configuration. Keyed by room id.
    pub(crate) audio: Arc<DashMap<String, AudioMixerConfig>>,
    /// Per-room program overlay state (lower-third / popup / watermark).
    pub(crate) overlays: Arc<DashMap<String, OverlayState>>,
    /// Runtime status of every output forwarder, keyed by forwarder key.
    pub(crate) forwarder_status: Arc<DashMap<String, ForwardingStatus>>,
    /// Running RTSP/RTMP ingest adapters, keyed by "{room}/{camera}".
    #[cfg(feature = "gst")]
    pub(crate) ingests: Arc<DashMap<String, Arc<todd_transcode::ingest::GstIngest>>>,
    /// Per-room GStreamer program mixers (gst builds only; without the
    /// feature the program egress stays a passthrough of the PGM camera).
    #[cfg(feature = "gst")]
    pub(crate) mixers: Arc<DashMap<String, Arc<GstProgramMixer>>>,
    #[cfg(feature = "gst")]
    pub(crate) forwarders: Arc<DashMap<String, todd_transcode::forwarder::GstForwarder>>,
}

impl Engine {
    pub fn new(config: EngineConfig, telemetry: Arc<Telemetry>) -> Result<Self, AppError> {
        let pli = PliBroker::new();
        let api_whip = build_api(&config, Some(pli.writer_builder()))?;
        let api_whep = build_api(&config, Some(pli.reader_builder()))?;
        let replay_buffer_ms = config.replay_buffer_ms;
        let replay_export_callback_url = config.replay_export_callback_url.clone();

        Ok(Engine {
            api_whip: Arc::new(api_whip),
            api_whep: Arc::new(api_whep),
            config,
            sessions: Arc::new(DashMap::new()),
            viewers: Arc::new(DashMap::new()),
            router: Arc::new(TrackRouter::new(telemetry.clone())),
            telemetry,
            pli,
            replay: ReplayManager::new(replay_buffer_ms, replay_export_callback_url),
            program: Arc::new(DashMap::new()),
            audio: Arc::new(DashMap::new()),
            overlays: Arc::new(DashMap::new()),
            forwarder_status: Arc::new(DashMap::new()),
            #[cfg(feature = "gst")]
            ingests: Arc::new(DashMap::new()),
            #[cfg(feature = "gst")]
            mixers: Arc::new(DashMap::new()),
            #[cfg(feature = "gst")]
            forwarders: Arc::new(DashMap::new()),
        })
    }

    /// Builds the engine config from the shared env-driven settings.
    pub fn config_from_settings(
        settings: &todd_common::config::Settings,
    ) -> Result<EngineConfig, AppError> {
        let mut ice_servers = Vec::new();
        for entry in settings
            .stun_servers
            .iter()
            .chain(settings.turn_servers.iter())
        {
            ice_servers.push(ice_server_from_string(entry)?);
        }

        let policy = net::build_policy(settings);
        if policy.interfaces_seen.is_empty() {
            tracing::warn!(
                "no routable host interfaces found — ICE will rely on STUN/TURN candidates only"
            );
        } else {
            for (name, ip) in &policy.interfaces_seen {
                tracing::info!(interface = %name, ip = %ip, "ICE candidate interface");
            }
            tracing::info!(
                ipv6 = %policy.network_types.iter().any(|t| matches!(t, webrtc_ice::network_type::NetworkType::Udp6)),
                "ICE network types resolved from host interfaces"
            );
        }

        Ok(EngineConfig {
            ice_servers,
            policy,
            disconnected_grace: Duration::from_millis(settings.ice_disconnected_grace_ms),
            replay_buffer_ms: settings.replay_buffer_ms,
            replay_export_callback_url: settings.replay_export_callback_url.clone(),
            program_output: MixerOutputConfig {
                width: settings.program_width,
                height: settings.program_height,
                fps: settings.program_fps,
                bitrate_kbps: settings.program_bitrate_kbps,
                encoder: settings.program_encoder,
                stinger_asset_url: settings.stinger_asset_url.clone(),
            },
        })
    }

    /// Accepts a WHIP offer: creates the PeerConnection, waits for ICE
    /// gathering, registers the session and returns `(session_id, answer)`.
    ///
    /// Reconnect semantics: a new offer for an already-live
    /// `(room, camera)` **replaces** the existing session (takeover), so
    /// a camera re-POSTing after a network drop never accumulates zombie
    /// sessions or hits a "camera busy" state.
    pub async fn start_session(
        &self,
        room_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let existing: Vec<String> = self
            .sessions
            .iter()
            .filter(|entry| {
                entry.value().room_id == room_id && entry.value().camera_id == camera_id
            })
            .map(|entry| entry.key().clone())
            .collect();
        for id in existing {
            tracing::warn!(
                session = %id,
                room = room_id,
                camera = camera_id,
                "replacing existing session (takeover reconnect)"
            );
            self.telemetry
                .registry
                .inc("todd_whip_sessions_replaced_total");
            let _ = self.stop_session(&id).await;
        }

        let (pc, shutdown, answer) = whip_peer::create(self, room_id, camera_id, offer_sdp).await?;

        let session_id = Uuid::new_v4().to_string();
        self.sessions.insert(
            session_id.clone(),
            Session {
                room_id: room_id.to_string(),
                camera_id: camera_id.to_string(),
                pc,
                shutdown,
            },
        );
        self.telemetry.registry.inc("todd_whip_ingests_total");
        self.telemetry
            .registry
            .set("todd_sessions_active", self.sessions.len() as u64);
        self.telemetry
            .record_ice(&session_id, "whip", room_id, camera_id, "connecting");
        tracing::info!(session = %session_id, room = room_id, camera = camera_id, "whip session started");
        Ok((session_id, answer))
    }

    /// Closes the PeerConnection, cancels the track pumps and removes the
    /// camera from the router.
    pub async fn stop_session(&self, session_id: &str) -> Result<(), AppError> {
        let Some((_, session)) = self.sessions.remove(session_id) else {
            return Err(AppError::NotFound(format!("unknown session {session_id}")));
        };
        session.shutdown.cancel();
        let _ = session.pc.close().await;
        self.router
            .remove_camera(&session.room_id, &session.camera_id);
        self.telemetry.remove_ice(session_id);
        self.telemetry
            .registry
            .set("todd_sessions_active", self.sessions.len() as u64);
        tracing::info!(session = session_id, "whip session closed");
        Ok(())
    }

    /// Removes sessions whose PeerConnection already died (network loss,
    /// DTLS failure) so rooms and the router don't leak state.
    pub async fn prune_dead_sessions(&self) {
        let is_dead = |state: RTCPeerConnectionState| -> bool {
            matches!(
                state,
                RTCPeerConnectionState::Failed | RTCPeerConnectionState::Closed
            )
        };

        let dead: Vec<String> = self
            .sessions
            .iter()
            .filter(|entry| is_dead(entry.value().pc.connection_state()))
            .map(|entry| entry.key().clone())
            .collect();
        for id in dead {
            let _ = self.stop_session(&id).await;
        }

        let dead_viewers: Vec<String> = self
            .viewers
            .iter()
            .filter(|entry| is_dead(entry.value().pc.connection_state()))
            .map(|entry| entry.key().clone())
            .collect();
        for id in dead_viewers {
            let _ = self.stop_viewer_session(&id).await;
        }
    }

    /// Creates a WHEP viewer session for one simulcast layer of a camera
    /// (`rid` empty = lowest live layer). Returns `(session_id, answer)`.
    ///
    /// A keyframe request is sent to the publisher immediately so the new
    /// viewer receives an IDR without waiting for the keyframe interval.
    pub async fn start_viewer_session(
        &self,
        room_id: &str,
        camera_id: &str,
        rid: Option<String>,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        // Resolve the layer: explicit rid, else the lowest live layer.
        let rid = match rid {
            Some(r) if !r.is_empty() => {
                if !self.router.is_rid_active(room_id, camera_id, &r) {
                    return Err(AppError::BadRequest(format!(
                        "simulcast layer '{r}' is not live on camera {camera_id}"
                    )));
                }
                r
            }
            _ => self
                .router
                .lowest_rid(room_id, camera_id)
                .unwrap_or_default(),
        };

        self.create_live_viewer(room_id, camera_id, &rid, offer_sdp)
            .await
    }

    /// Shared WHEP live-viewer creation path for a resolved camera layer.
    async fn create_live_viewer(
        &self,
        room_id: &str,
        camera_id: &str,
        rid: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let viewer = whep_peer::create_viewer(
            self,
            whep_peer::TrackFeed::Live {
                room: room_id.to_string(),
                camera: camera_id.to_string(),
                rid: rid.to_string(),
            },
            offer_sdp,
        )
        .await?;

        let session_id = Uuid::new_v4().to_string();
        self.viewers.insert(
            session_id.clone(),
            ViewerSession {
                room_id: room_id.to_string(),
                camera_id: camera_id.to_string(),
                rid: rid.to_string(),
                viewer_ssrc: viewer.viewer_ssrc,
                pc: viewer.pc,
                shutdown: viewer.shutdown,
            },
        );
        self.telemetry.registry.inc("todd_whep_watches_total");
        self.telemetry
            .registry
            .set("todd_viewers_active", self.viewers.len() as u64);
        self.telemetry
            .record_ice(&session_id, "whep", room_id, camera_id, "connecting");

        // Fast-start: ask the publisher for a keyframe on this layer.
        if let Some(ssrc) = self.router.ssrc_of(room_id, camera_id, rid) {
            self.pli.request_keyframe(ssrc);
        }

        tracing::info!(session = %session_id, room = room_id, camera = camera_id, rid = %rid, "whep viewer started");
        Ok((session_id, viewer.answer_sdp))
    }

    /// Closes a viewer session. Unlike publisher sessions, this never
    /// tears down the camera stream itself — other viewers may be watching.
    pub async fn stop_viewer_session(&self, session_id: &str) -> Result<(), AppError> {
        let Some((_, viewer)) = self.viewers.remove(session_id) else {
            return Err(AppError::NotFound(format!(
                "unknown viewer session {session_id}"
            )));
        };
        viewer.shutdown.cancel();
        let _ = viewer.pc.close().await;
        if let Some(ssrc) = viewer.viewer_ssrc {
            self.pli.unregister_viewer(ssrc);
        }
        self.telemetry.remove_ice(session_id);
        self.telemetry
            .registry
            .set("todd_viewers_active", self.viewers.len() as u64);
        tracing::info!(session = session_id, "whep viewer closed");
        Ok(())
    }

    /// Records the program (PGM) source for a room and (in gst builds)
    /// applies the scene to the room's GStreamer compositor. The camera
    /// need not be actively ingesting yet; egress resolution happens at
    /// watch time.
    pub fn set_program(&self, req: &ProgramTransitionRequest) -> ProgramState {
        let rid = self
            .router
            .lowest_rid(&req.room_id, &req.camera_id)
            .unwrap_or_default();
        let duration_ms = req
            .duration_ms
            .unwrap_or(DEFAULT_TRANSITION_DURATION_MS)
            .clamp(0, MAX_TRANSITION_DURATION_MS);
        let layout = req.layout.clone().unwrap_or_else(|| {
            self.program
                .get(&req.room_id)
                .map(|entry| entry.value().layout.clone())
                .unwrap_or_default()
        });
        let state = ProgramState {
            room_id: req.room_id.clone(),
            camera_id: req.camera_id.clone(),
            rid,
            transition: req.transition,
            duration_ms,
            layout,
            stinger: req.stinger.clone(),
            updated_at_ms: chrono::Utc::now().timestamp_millis(),
        };
        self.program.insert(req.room_id.clone(), state.clone());

        #[cfg(feature = "gst")]
        self.apply_mixer_scene(&state);

        self.telemetry
            .registry
            .inc("todd_program_transitions_total");
        tracing::info!(
            room = %req.room_id,
            camera = %req.camera_id,
            transition = ?req.transition,
            "program switched"
        );
        state
    }

    /// Current program source for a room, if the director has set one.
    pub fn get_program(&self, room_id: &str) -> Option<ProgramState> {
        self.program.get(room_id).map(|entry| entry.value().clone())
    }

    /// The room's audio mix: active config + the latest metering sampled
    /// by the media plane (empty/floor levels without the gst feature).
    pub fn get_audio_mix(&self, room_id: &str) -> AudioMixView {
        let config = self
            .audio
            .get(room_id)
            .map(|entry| entry.value().clone())
            .unwrap_or_default();
        let metering = self
            .telemetry
            .audio_levels_for(room_id)
            .into_iter()
            .map(|(bus, peak, rms)| todd_common::media::BusMetering {
                bus,
                peak_db: peak,
                rms_db: rms,
            })
            .collect();
        AudioMixView { config, metering }
    }

    /// Applies a new audio mix for a room. In gst builds the running
    /// program mixer applies the faders/gain/delay immediately.
    pub fn set_audio_mix(&self, room_id: &str, config: AudioMixerConfig) -> AudioMixView {
        let config = config.clamped();
        self.audio.insert(room_id.to_string(), config.clone());

        #[cfg(feature = "gst")]
        if let Some(mixer) = self.mixers.get(room_id) {
            mixer.apply_audio_config(&config);
        }

        self.telemetry.registry.inc("todd_audio_mix_updates_total");
        tracing::info!(room = room_id, "audio mix updated");
        self.get_audio_mix(room_id)
    }

    /// Current program overlays of a room.
    pub fn get_overlays(&self, room_id: &str) -> OverlayState {
        self.overlays
            .get(room_id)
            .map(|entry| entry.value().clone())
            .unwrap_or_default()
    }

    /// Applies one overlay command to a room's program bus and returns
    /// the resulting overlay state.
    pub fn apply_overlay(&self, room_id: &str, command: OverlayCommand) -> OverlayState {
        let mut overlays = self.get_overlays(room_id);
        match command {
            OverlayCommand::Scoreboard {
                enabled,
                title,
                subtitle,
            } => {
                overlays.scoreboard = Some(todd_common::types::ScoreboardOverlay {
                    enabled,
                    title,
                    subtitle,
                });
            }
            OverlayCommand::EventPopup {
                text,
                subtext,
                duration_ms,
            } => {
                overlays.popup = Some(todd_common::types::EventPopupSpec {
                    text,
                    subtext,
                    duration_ms: duration_ms.unwrap_or(2500).clamp(500, 10_000),
                });
            }
            OverlayCommand::Watermark {
                enabled,
                asset_url,
                x,
                y,
            } => {
                overlays.watermark = if enabled {
                    asset_url
                        .map(|url| url.trim().to_string())
                        .filter(|url| !url.is_empty())
                        .map(|url| todd_common::types::WatermarkSpec {
                            asset_url: url,
                            x,
                            y,
                        })
                } else {
                    None
                };
            }
        }
        self.overlays.insert(room_id.to_string(), overlays.clone());

        #[cfg(feature = "gst")]
        if let Some(mixer) = self.mixers.get(room_id) {
            mixer.apply_overlays(&overlays);
        }

        self.telemetry.registry.inc("todd_overlay_updates_total");
        tracing::info!(room = room_id, "overlay applied");
        overlays
    }

    /// Clears every program overlay of a room.
    pub fn clear_overlays(&self, room_id: &str) -> OverlayState {
        let cleared = OverlayState::default();
        self.overlays.insert(room_id.to_string(), cleared.clone());

        #[cfg(feature = "gst")]
        if let Some(mixer) = self.mixers.get(room_id) {
            mixer.apply_overlays(&cleared);
        }

        tracing::info!(room = room_id, "overlays cleared");
        cleared
    }

    /// Runtime statuses of every output forwarder.
    pub fn list_forwarders(&self) -> Vec<ForwardingStatus> {
        let mut statuses: Vec<ForwardingStatus> = self
            .forwarder_status
            .iter()
            .map(|entry| entry.value().clone())
            .collect();
        statuses.sort_by(|a, b| a.key.cmp(&b.key));
        statuses
    }

    /// Deterministic synthetic SSRC for an ingest track, so the router
    /// registration can be reversed on stop.
    #[cfg(feature = "gst")]
    fn ingest_ssrc(room_id: &str, camera_id: &str, media: &str) -> u32 {
        use std::collections::hash_map::DefaultHasher;
        use std::hash::{Hash, Hasher};
        let mut hasher = DefaultHasher::new();
        (room_id, camera_id, media).hash(&mut hasher);
        (hasher.finish() & 0xFFFF_FFFE) as u32 | 1
    }

    /// Starts an RTSP/RTMP ingest adapter for a camera and pumps its
    /// re-packetized RTP into the TrackRouter (gst builds only).
    #[cfg(feature = "gst")]
    pub async fn start_ingest(&self, room_id: &str, camera: &CameraInfo) -> Result<(), AppError> {
        use todd_common::types::CameraSourceKind;
        use todd_transcode::ingest::GstIngest;
        use todd_transcode::media::MediaCodec;

        if camera.kind == CameraSourceKind::Whip {
            return Ok(());
        }
        let url = camera.url.as_deref().unwrap_or("").trim().to_string();
        if url.is_empty() {
            return Err(AppError::BadRequest(format!(
                "camera {} requires a source URL for {:?} ingest",
                camera.id, camera.kind
            )));
        }

        let key = format!("{room_id}/{}", camera.id);
        self.stop_ingest(room_id, &camera.id).await;
        let ingest = Arc::new(GstIngest::build(&url, camera.kind)?);
        self.ingests.insert(key, ingest.clone());

        let (engine, room, cam) = (self.clone(), room_id.to_string(), camera.id.clone());
        let video_ssrc = Self::ingest_ssrc(&room, &cam, "video");
        let audio_ssrc = Self::ingest_ssrc(&room, &cam, "audio");
        let video_rx = ingest.subscribe_video();
        let audio_rx = ingest.subscribe_audio();
        tokio::spawn(async move {
            pump_ingest_feed(&engine, &room, &cam, MediaCodec::H264, video_ssrc, video_rx).await;
        });
        tokio::spawn(async move {
            pump_ingest_feed(&engine, &room, &cam, MediaCodec::Opus, audio_ssrc, audio_rx).await;
        });

        tracing::info!(room = room_id, camera = %camera.id, ?camera.kind, "ingest started");
        Ok(())
    }

    /// Starts an ingest adapter in non-gst builds: impossible without the
    /// pipeline, so the attempt is rejected.
    #[cfg(not(feature = "gst"))]
    pub async fn start_ingest(&self, _room_id: &str, camera: &CameraInfo) -> Result<(), AppError> {
        if camera.kind == todd_common::types::CameraSourceKind::Whip {
            return Ok(());
        }
        Err(AppError::Unsupported(
            "built without the `gst` feature — rebuild with --features gst to pull RTSP/RTMP sources"
                .to_string(),
        ))
    }

    /// Stops an ingest adapter and unregisters its router tracks.
    #[cfg(feature = "gst")]
    pub async fn stop_ingest(&self, room_id: &str, camera_id: &str) {
        let key = format!("{room_id}/{camera_id}");
        if self.ingests.remove(&key).is_some() {
            let video_ssrc = Self::ingest_ssrc(room_id, camera_id, "video");
            let audio_ssrc = Self::ingest_ssrc(room_id, camera_id, "audio");
            self.router
                .unregister_track(room_id, camera_id, None, video_ssrc);
            self.router
                .unregister_track(room_id, camera_id, None, audio_ssrc);
            tracing::info!(room = room_id, camera = camera_id, "ingest stopped");
        }
    }

    /// Stops an ingest adapter (no-op without the gst feature).
    #[cfg(not(feature = "gst"))]
    pub async fn stop_ingest(&self, _room_id: &str, _camera_id: &str) {}

    /// Cameras of a room with a running ingest adapter.
    #[cfg(feature = "gst")]
    pub fn active_ingest_cameras(&self, room_id: &str) -> Vec<String> {
        let prefix = format!("{room_id}/");
        let mut cameras: Vec<String> = self
            .ingests
            .iter()
            .filter(|entry| entry.key().starts_with(&prefix))
            .map(|entry| entry.key().trim_start_matches(&prefix).to_string())
            .collect();
        cameras.sort();
        cameras
    }

    /// Cameras of a room with a running ingest adapter (non-gst: none).
    #[cfg(not(feature = "gst"))]
    pub fn active_ingest_cameras(&self, _room_id: &str) -> Vec<String> {
        Vec::new()
    }

    /// Stops an output forwarder by key and marks it stopped.
    #[cfg(feature = "gst")]
    pub async fn stop_forwarder(&self, key: &str) -> Result<ForwardingStatus, AppError> {
        let removed = self.forwarders.remove(key);
        let status = self
            .forwarder_status
            .get(key)
            .map(|entry| entry.value().clone());
        match (removed, status) {
            (Some(_), Some(mut status)) => {
                status.state = todd_common::types::ForwardState::Stopped;
                self.forwarder_status
                    .insert(key.to_string(), status.clone());
                tracing::info!(key, "forwarder stopped");
                Ok(status)
            }
            (None, Some(mut status)) => {
                // Already gone; surface the last known state.
                status.state = todd_common::types::ForwardState::Stopped;
                self.forwarder_status
                    .insert(key.to_string(), status.clone());
                Ok(status)
            }
            _ => Err(AppError::NotFound(format!("unknown forwarder {key}"))),
        }
    }

    /// Stops an output forwarder by key (non-gst builds track only the
    /// camera forwarder attempts, which never started).
    #[cfg(not(feature = "gst"))]
    pub async fn stop_forwarder(&self, key: &str) -> Result<ForwardingStatus, AppError> {
        let status = self
            .forwarder_status
            .get(key)
            .map(|entry| entry.value().clone())
            .ok_or_else(|| AppError::NotFound(format!("unknown forwarder {key}")))?;
        let mut stopped = status.clone();
        stopped.state = todd_common::types::ForwardState::Stopped;
        self.forwarder_status
            .insert(key.to_string(), stopped.clone());
        Ok(stopped)
    }

    /// Starts a forwarder fed from the room's mixed program output
    /// (gst builds). Requires the room's program mixer to exist.
    #[cfg(feature = "gst")]
    pub async fn add_program_forwarder(
        &self,
        room_id: &str,
        target: &todd_common::types::ForwardTarget,
    ) -> Result<ForwardingStatus, AppError> {
        use todd_common::types::ForwardState;

        let key = format!("{room_id}/program/{}", target.url);
        let failed = |message: String| {
            let status = ForwardingStatus {
                key: key.clone(),
                room_id: room_id.to_string(),
                source: todd_common::types::ForwardSource::Program,
                kind: target.kind,
                url: target.url.clone(),
                state: ForwardState::Failed,
                started_at_ms: chrono::Utc::now().timestamp_millis(),
                error: Some(message),
            };
            self.forwarder_status.insert(key.clone(), status.clone());
            Err(AppError::Conflict(status.error.clone().unwrap_or_default()))
        };

        if self.forwarders.contains_key(&key) {
            return failed(format!("program forwarder {key} already exists"));
        }
        let Some(mixer) = self.mixers.get(room_id) else {
            return failed(format!(
                "no program mixer for room {room_id}; set a program source first"
            ));
        };

        let spec = todd_common::media::EncoderSpec {
            bitrate_kbps: target.bitrate_kbps,
            keyframe_interval: target.keyframe_interval,
        };
        let forwarder = todd_transcode::forwarder::GstForwarder::build_program(
            target,
            target.encoder,
            &spec,
            mixer.value().subscribe_video(),
            mixer.value().subscribe_audio(),
        )
        .await
        .map_err(|e| {
            let status = ForwardingStatus {
                key: key.clone(),
                room_id: room_id.to_string(),
                source: todd_common::types::ForwardSource::Program,
                kind: target.kind,
                url: target.url.clone(),
                state: ForwardState::Failed,
                started_at_ms: chrono::Utc::now().timestamp_millis(),
                error: Some(e.to_string()),
            };
            self.forwarder_status.insert(key.clone(), status);
            e
        })?;

        self.forwarders.insert(key.clone(), forwarder);
        let status = ForwardingStatus {
            key,
            room_id: room_id.to_string(),
            source: todd_common::types::ForwardSource::Program,
            kind: target.kind,
            url: target.url.clone(),
            state: ForwardState::Running,
            started_at_ms: chrono::Utc::now().timestamp_millis(),
            error: None,
        };
        self.forwarder_status
            .insert(status.key.clone(), status.clone());
        tracing::info!(key = %status.key, "program forwarder started");
        Ok(status)
    }

    /// Starts a program forwarder in non-gst builds: impossible without
    /// the pipeline, so the attempt is recorded as failed.
    #[cfg(not(feature = "gst"))]
    pub async fn add_program_forwarder(
        &self,
        room_id: &str,
        target: &todd_common::types::ForwardTarget,
    ) -> Result<ForwardingStatus, AppError> {
        let key = format!("{room_id}/program/{}", target.url);
        let message = "built without the `gst` feature — rebuild with --features gst".to_string();
        let status = ForwardingStatus {
            key: key.clone(),
            room_id: room_id.to_string(),
            source: todd_common::types::ForwardSource::Program,
            kind: target.kind,
            url: target.url.clone(),
            state: todd_common::types::ForwardState::Failed,
            started_at_ms: chrono::Utc::now().timestamp_millis(),
            error: Some(message.clone()),
        };
        self.forwarder_status.insert(key, status);
        Err(AppError::Unsupported(message))
    }

    /// WHEP egress fed from the room's current program source. In gst
    /// builds the video comes from the room's composite mixer output
    /// (audio stays a router fan-out of the PGM camera); without gst the
    /// whole egress is a passthrough of the PGM camera. The source is
    /// resolved at watch time, so new program watchers always join the
    /// current PGM.
    pub async fn start_program_viewer(
        &self,
        room_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let state = self
            .get_program(room_id)
            .ok_or_else(|| AppError::NotFound(format!("no program set for room {room_id}")))?;

        #[cfg(feature = "gst")]
        if let Some(mixer) = self.mixers.get(room_id) {
            return self
                .create_program_mix_viewer(&state, mixer.value().clone(), offer_sdp)
                .await;
        }

        let rid = if state.rid.is_empty() {
            self.router
                .lowest_rid(room_id, &state.camera_id)
                .unwrap_or_default()
        } else {
            state.rid.clone()
        };

        if !self.router.is_camera_active(room_id, &state.camera_id) {
            return Err(AppError::Conflict(format!(
                "program camera {} is not live in room {room_id}",
                state.camera_id
            )));
        }

        self.create_live_viewer(room_id, &state.camera_id, &rid, offer_sdp)
            .await
    }

    /// WHEP egress fed from the composite program mixer (gst builds):
    /// video from the mixer's encoded output, audio from the PGM camera's
    /// live router stream.
    #[cfg(feature = "gst")]
    async fn create_program_mix_viewer(
        &self,
        state: &ProgramState,
        mixer: Arc<GstProgramMixer>,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        use todd_transcode::media::MediaCodec;

        let video_rx = mixer.subscribe_video();
        let viewer = whep_peer::create_viewer(
            self,
            whep_peer::TrackFeed::Program {
                video: video_rx,
                audio: Some(mixer.subscribe_audio()),
                codec: MediaCodec::H264,
                audio_room: state.room_id.clone(),
                audio_camera: state.camera_id.clone(),
            },
            offer_sdp,
        )
        .await?;

        let session_id = Uuid::new_v4().to_string();
        self.viewers.insert(
            session_id.clone(),
            ViewerSession {
                room_id: state.room_id.clone(),
                camera_id: state.camera_id.clone(),
                rid: String::new(),
                viewer_ssrc: viewer.viewer_ssrc,
                pc: viewer.pc,
                shutdown: viewer.shutdown,
            },
        );
        self.telemetry.registry.inc("todd_whep_watches_total");
        self.telemetry
            .registry
            .set("todd_viewers_active", self.viewers.len() as u64);
        self.telemetry.record_ice(
            &session_id,
            "whep",
            &state.room_id,
            &state.camera_id,
            "connecting",
        );
        tracing::info!(
            session = %session_id,
            room = %state.room_id,
            "program mix viewer started"
        );
        Ok((session_id, viewer.answer_sdp))
    }

    /// Resolves the scene referenced by a program state and applies it to
    /// the room's mixer, together with the room's audio feeds and audio
    /// mix. Scenes referencing non-H.264 (or not yet live) sources keep
    /// the room on passthrough program egress.
    #[cfg(feature = "gst")]
    fn apply_mixer_scene(&self, state: &ProgramState) {
        use std::collections::HashMap;
        use std::sync::Arc;
        use todd_common::media::AudioBus;
        use todd_transcode::media::MediaCodec;

        let fallback = SourceRef {
            room_id: state.room_id.clone(),
            camera_id: state.camera_id.clone(),
        };
        let plan = plan_scene(&state.layout, &fallback);
        if plan.slots.len() > todd_transcode::mixer::MAX_SLOTS {
            tracing::warn!(
                slots = plan.slots.len(),
                "scene exceeds mixer slots; keeping passthrough program egress"
            );
            return;
        }

        let mut feeds: HashMap<
            String,
            tokio::sync::mpsc::Receiver<todd_transcode::media::RtpChunk>,
        > = HashMap::new();
        for source in plan.sources() {
            let rid = self
                .router
                .lowest_rid(&source.room_id, &source.camera_id)
                .unwrap_or_default();
            let codec = self
                .router
                .codec_of(&source.room_id, &source.camera_id, &rid);
            if !matches!(codec, Some(MediaCodec::H264)) {
                tracing::warn!(
                    room = %source.room_id,
                    camera = %source.camera_id,
                    ?codec,
                    "program mixer requires H.264 sources; keeping passthrough program egress"
                );
                return;
            }
            feeds.insert(
                source_key(&source),
                self.router
                    .subscribe(&source.room_id, &source.camera_id, &rid),
            );
        }

        if !self.mixers.contains_key(&state.room_id) {
            // Level samples from the mixer's `level` elements flow into
            // the engine-wide telemetry feed.
            let telemetry = self.telemetry.clone();
            let metering_room = state.room_id.clone();
            let on_metering: Arc<dyn Fn(String, f32, f32) + Send + Sync> =
                Arc::new(move |bus, peak_db, rms_db| {
                    telemetry.record_audio_level(&metering_room, &bus, peak_db, rms_db);
                });
            match GstProgramMixer::build(&self.config.program_output, on_metering) {
                Ok(mixer) => {
                    self.mixers.insert(state.room_id.clone(), Arc::new(mixer));
                }
                Err(e) => {
                    tracing::error!(room = %state.room_id, error = %e, "program mixer build failed; keeping passthrough program egress");
                    return;
                }
            }
        }
        let mixer = self
            .mixers
            .get(&state.room_id)
            .expect("mixer was just inserted")
            .value()
            .clone();

        let stinger_asset = state
            .stinger
            .as_ref()
            .and_then(|spec| spec.asset_url.clone())
            .or_else(|| self.config.program_output.stinger_asset_url.clone());
        mixer.apply_scene(
            &plan,
            feeds,
            state.transition,
            state.duration_ms,
            stinger_asset,
        );

        // Audio: bind every live Opus track of the room to its bus and
        // apply the current mix.
        let mut audio_feeds: HashMap<
            AudioBus,
            Vec<(
                String,
                tokio::sync::mpsc::Receiver<todd_transcode::media::RtpChunk>,
            )>,
        > = HashMap::new();
        for (camera_id, rid) in self.router.audio_feeds(&state.room_id) {
            let codec = self.router.codec_of(&state.room_id, &camera_id, &rid);
            if !matches!(codec, Some(MediaCodec::Opus)) {
                continue;
            }
            let bus = AudioBus::from_rid(Some(&rid));
            let key = audio_feed_key(&camera_id, &rid);
            audio_feeds
                .entry(bus)
                .or_default()
                .push((key, self.router.subscribe(&state.room_id, &camera_id, &rid)));
        }
        mixer.apply_audio_feeds(audio_feeds);
        let audio_config = self
            .audio
            .get(&state.room_id)
            .map(|entry| entry.value().clone())
            .unwrap_or_default();
        mixer.apply_audio_config(&audio_config);

        // Burn in the room's current overlay state on the fresh mixer.
        let overlays = self.get_overlays(&state.room_id);
        mixer.apply_overlays(&overlays);
    }

    pub fn router(&self) -> Arc<TrackRouter> {
        self.router.clone()
    }

    // ------------------------------------------------------------------
    // Instant replay
    // ------------------------------------------------------------------

    /// Triggers an instant replay from the ring buffer.
    pub async fn trigger_replay(&self, req: &ReplayTrigger) -> Result<ReplayInfo, AppError> {
        self.replay.trigger(req).await
    }

    /// Lists live replay sessions.
    pub fn list_replays(&self) -> Vec<ReplayInfo> {
        self.replay.list()
    }

    /// Closes a replay session.
    pub async fn close_replay(&self, replay_id: &str) -> Result<(), AppError> {
        self.replay.close(replay_id).await
    }

    /// Starts a clip export job for a replay session.
    pub async fn export_replay(
        self: &Arc<Self>,
        req: &ClipExportRequest,
    ) -> Result<todd_replay::export::ExportStatus, AppError> {
        self.replay.export(req.clone()).await
    }

    /// Creates a WHEP viewer fed from a replay session's paced playback
    /// stream — the Studio director's slomo preview monitor.
    pub async fn start_replay_viewer(
        &self,
        replay_id: &str,
        camera_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let Some(session) = self.replay.session(replay_id) else {
            return Err(AppError::NotFound(format!("unknown replay {replay_id}")));
        };
        if session.subscribe(camera_id).is_none() {
            return Err(AppError::NotFound(format!(
                "camera {camera_id} is not part of replay {replay_id}"
            )));
        }

        let viewer = whep_peer::create_viewer(
            self,
            whep_peer::TrackFeed::Replay {
                replay_id: replay_id.to_string(),
                camera_id: camera_id.to_string(),
            },
            offer_sdp,
        )
        .await?;

        let session_id = Uuid::new_v4().to_string();
        self.viewers.insert(
            session_id.clone(),
            ViewerSession {
                room_id: format!("replay:{replay_id}"),
                camera_id: camera_id.to_string(),
                rid: String::new(),
                viewer_ssrc: viewer.viewer_ssrc,
                pc: viewer.pc,
                shutdown: viewer.shutdown,
            },
        );
        self.telemetry.registry.inc("todd_whep_watches_total");
        self.telemetry
            .registry
            .set("todd_viewers_active", self.viewers.len() as u64);
        self.telemetry.record_ice(
            &session_id,
            "whep",
            &format!("replay:{replay_id}"),
            camera_id,
            "connecting",
        );
        tracing::info!(session = %session_id, replay = replay_id, camera = camera_id, "replay viewer started");
        Ok((session_id, viewer.answer_sdp))
    }

    pub fn is_session_active(&self, session_id: &str) -> bool {
        self.sessions.contains_key(session_id)
    }

    // ------------------------------------------------------------------
    // ICE resilience & telemetry
    // ------------------------------------------------------------------

    /// Looks up the WHIP session id owning a PeerConnection (pointer
    /// identity).
    pub fn session_id_for_pc(&self, pc: &Arc<RTCPeerConnection>) -> Option<String> {
        self.sessions
            .iter()
            .find(|entry| Arc::ptr_eq(&entry.value().pc, pc))
            .map(|entry| entry.key().clone())
    }

    /// Looks up the WHEP viewer session id owning a PeerConnection
    /// (pointer identity).
    pub fn viewer_id_for_pc(&self, pc: &Arc<RTCPeerConnection>) -> Option<String> {
        self.viewers
            .iter()
            .find(|entry| Arc::ptr_eq(&entry.value().pc, pc))
            .map(|entry| entry.key().clone())
    }

    /// Records the latest ICE state of the session owning `pc` (if any).
    pub fn record_ice_by_pc(&self, pc: &Arc<RTCPeerConnection>, state: &str) {
        if let Some(id) = self.session_id_for_pc(pc) {
            if let Some(session) = self.sessions.get(&id) {
                self.telemetry
                    .record_ice(&id, "whip", &session.room_id, &session.camera_id, state);
            }
        } else if let Some(id) = self.viewer_id_for_pc(pc) {
            if let Some(viewer) = self.viewers.get(&id) {
                self.telemetry
                    .record_ice(&id, "whep", &viewer.room_id, &viewer.camera_id, state);
            }
        }
    }

    /// Handles the `Disconnected` state: arms a grace-period watchdog that
    /// closes the session only if it never recovers. A transient network
    /// blip (e.g. Wi-Fi roam) typically returns to `Connected` within the
    /// grace window — in that case nothing is torn down.
    pub fn spawn_disconnected_watchdog(&self, pc: Arc<RTCPeerConnection>) {
        let engine = self.clone();
        let grace = self.config.disconnected_grace;
        tokio::spawn(async move {
            tokio::time::sleep(grace).await;
            let state = pc.connection_state();
            if matches!(
                state,
                RTCPeerConnectionState::Disconnected | RTCPeerConnectionState::Failed
            ) {
                if let Some(id) = engine.session_id_for_pc(&pc) {
                    tracing::warn!(
                        session = %id,
                        "closing ingest session after ICE Disconnected grace elapsed"
                    );
                    engine
                        .telemetry
                        .registry
                        .inc("todd_ice_disconnected_closures_total");
                    let _ = engine.stop_session(&id).await;
                } else if let Some(id) = engine.viewer_id_for_pc(&pc) {
                    tracing::warn!(
                        session = %id,
                        "closing viewer session after ICE Disconnected grace elapsed"
                    );
                    engine
                        .telemetry
                        .registry
                        .inc("todd_ice_disconnected_closures_total");
                    let _ = engine.stop_viewer_session(&id).await;
                }
            } else {
                tracing::info!(state = ?state, "peer connection recovered after Disconnected");
            }
        });
    }

    /// Spawns the periodic stats sampler: polls WebRTC `get_stats()` for
    /// nominated candidate pairs and refreshes per-camera RTT + the
    /// global bitrate/jitter gauges.
    pub fn spawn_sampler(&self) {
        let engine = self.clone();
        let interval = Duration::from_millis(self.telemetry.sample_ms.max(500));
        tokio::spawn(async move {
            let mut tick = tokio::time::interval(interval);
            tick.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);
            loop {
                tick.tick().await;
                engine.sample_stats().await;
            }
        });
    }

    async fn sample_stats(&self) {
        use webrtc::stats::StatsReportType;

        let entries: Vec<(String, String, Arc<RTCPeerConnection>)> = self
            .sessions
            .iter()
            .map(|e| {
                (
                    e.value().room_id.clone(),
                    e.value().camera_id.clone(),
                    e.value().pc.clone(),
                )
            })
            .chain(self.viewers.iter().map(|e| {
                (
                    e.value().room_id.clone(),
                    e.value().camera_id.clone(),
                    e.value().pc.clone(),
                )
            }))
            .collect();

        let mut max_rtt_ms = 0.0f64;
        for (room_id, camera_id, pc) in entries {
            let report = pc.get_stats().await;
            let mut rtt_ms: Option<f64> = None;
            for (_id, stats) in report.reports {
                if let StatsReportType::CandidatePair(pair) = stats {
                    if pair.nominated && pair.current_round_trip_time > 0.0 {
                        rtt_ms = Some(pair.current_round_trip_time * 1000.0);
                    }
                }
            }
            if let Some(rtt) = rtt_ms {
                let stream = self.telemetry.stream(&room_id, &camera_id, 90_000);
                stream.set_rtt_ms(rtt);
                max_rtt_ms = max_rtt_ms.max(rtt);
            }
        }

        self.telemetry
            .registry
            .set("todd_rtt_ms", max_rtt_ms.round() as u64);

        let (ingress, egress, jitter) = self.telemetry.stream_totals();
        self.telemetry
            .registry
            .set("todd_ingress_bitrate_bps", ingress.round() as u64);
        self.telemetry
            .registry
            .set("todd_egress_bitrate_bps", egress.round() as u64);
        self.telemetry
            .registry
            .set("todd_jitter_ms", jitter.round() as u64);
    }

    /// Returns the per-camera stream stats handle.
    pub fn stream_stats(&self, room_id: &str, camera_id: &str) -> Arc<StreamStats> {
        self.telemetry.stream(room_id, camera_id, 90_000)
    }

    /// Spawns a GStreamer forwarding pipeline that consumes the camera's
    /// selected layer + audio buses. Only available with the `gst`
    /// feature (needs system GStreamer >= 1.24 at build time).
    #[cfg(feature = "gst")]
    pub async fn add_forwarder(
        &self,
        room_id: &str,
        camera_id: &str,
        target: &todd_common::types::ForwardTarget,
    ) -> Result<(), AppError> {
        use todd_common::media::AudioBus;
        use todd_transcode::forwarder::GstForwarder;
        use todd_transcode::media::MediaCodec;

        let key = format!("{room_id}/{camera_id}/{}", target.url);
        if self.forwarders.contains_key(&key) {
            return Err(AppError::Conflict(format!(
                "forwarder {key} already exists"
            )));
        }

        // Select the simulcast layer to forward (lowest by default).
        let rid = match target.rid.clone() {
            Some(r) if !r.is_empty() => {
                if !self.router.is_rid_active(room_id, camera_id, &r) {
                    return Err(AppError::BadRequest(format!(
                        "simulcast layer '{r}' is not live on camera {camera_id}"
                    )));
                }
                r
            }
            _ => self
                .router
                .lowest_rid(room_id, camera_id)
                .unwrap_or_default(),
        };

        // The forwarder requires a video stream.
        if self
            .router
            .codec_of(room_id, camera_id, &rid)
            .map(|c| c.is_audio())
            .unwrap_or(true)
        {
            return Err(AppError::BadRequest(format!(
                "no video stream on camera {camera_id} layer '{rid}'"
            )));
        }

        // Subscribe the video layer + all live audio tracks, grouped by
        // bus via the RID convention.
        let video_rx = self.router.subscribe(room_id, camera_id, &rid);
        let mut audio_rx: Vec<(AudioBus, tokio::sync::mpsc::Receiver<_>)> = Vec::new();
        for (audio_rid, _ssrc, codec) in self.router.audio_tracks(room_id, camera_id) {
            if !matches!(codec, MediaCodec::Opus) {
                continue;
            }
            let bus = AudioBus::from_rid(Some(&audio_rid));
            if target.audio.bus(bus).enabled {
                audio_rx.push((bus, self.router.subscribe(room_id, camera_id, &audio_rid)));
            }
        }

        let encoder = target.encoder;
        let spec = todd_common::media::EncoderSpec {
            bitrate_kbps: target.bitrate_kbps,
            keyframe_interval: target.keyframe_interval,
        };
        let forwarder =
            GstForwarder::build(target, encoder, spec, &target.audio, video_rx, audio_rx).await?;
        self.forwarders.insert(key.clone(), forwarder);
        let status = ForwardingStatus {
            key: key.clone(),
            room_id: room_id.to_string(),
            source: todd_common::types::ForwardSource::Camera,
            kind: target.kind,
            url: target.url.clone(),
            state: todd_common::types::ForwardState::Running,
            started_at_ms: chrono::Utc::now().timestamp_millis(),
            error: None,
        };
        self.forwarder_status.insert(key, status);
        Ok(())
    }

    #[cfg(not(feature = "gst"))]
    pub async fn add_forwarder(
        &self,
        room_id: &str,
        camera_id: &str,
        target: &todd_common::types::ForwardTarget,
    ) -> Result<(), AppError> {
        let key = format!("{room_id}/{camera_id}/{}", target.url);
        let message =
            "built without the `gst` feature — rebuild with --features gst on a host with libgstreamer >= 1.24".to_string();
        let status = ForwardingStatus {
            key,
            room_id: room_id.to_string(),
            source: todd_common::types::ForwardSource::Camera,
            kind: target.kind,
            url: target.url.clone(),
            state: todd_common::types::ForwardState::Failed,
            started_at_ms: chrono::Utc::now().timestamp_millis(),
            error: Some(message.clone()),
        };
        self.forwarder_status.insert(status.key.clone(), status);
        Err(AppError::Unsupported(message))
    }
}

/// Pumps one ingest feed (video or audio) into the TrackRouter and the
/// replay ring, mirroring the WHIP track pump so RTSP/RTMP cameras
/// behave identically downstream (gst builds only).
#[cfg(feature = "gst")]
async fn pump_ingest_feed(
    engine: &Engine,
    room_id: &str,
    camera_id: &str,
    codec: todd_transcode::media::MediaCodec,
    ssrc: u32,
    mut rx: tokio::sync::broadcast::Receiver<todd_transcode::media::RtpChunk>,
) {
    engine
        .router
        .register_track(room_id, camera_id, None, ssrc, codec);
    tracing::info!(
        room = room_id,
        camera = camera_id,
        ssrc,
        ?codec,
        "ingest track up"
    );
    loop {
        match rx.recv().await {
            Ok(chunk) => {
                engine
                    .router
                    .record_ingress(room_id, camera_id, codec, 0, chunk.packet.len());
                engine.router.forward(room_id, camera_id, &chunk);
                engine.replay.capture(
                    room_id,
                    camera_id,
                    Arc::new(todd_replay::Frame::now(chunk, 0)),
                );
            }
            Err(tokio::sync::broadcast::error::RecvError::Lagged(_)) => continue,
            Err(tokio::sync::broadcast::error::RecvError::Closed) => break,
        }
    }
    engine
        .router
        .unregister_track(room_id, camera_id, None, ssrc);
}

/// Builds a webrtc-rs API with the default interceptor set (NACK
/// generator/responder, RTCP reports, TWCC receiver) plus an optional
/// extra interceptor builder (the PLI writer/reader).
fn build_api(
    config: &EngineConfig,
    extra: Option<impl webrtc::interceptor::InterceptorBuilder + Send + Sync + 'static>,
) -> Result<API, AppError> {
    let mut media_engine = MediaEngine::default();
    media_engine
        .register_default_codecs()
        .map_err(|e| AppError::Internal(format!("codec registration failed: {e}")))?;

    let mut registry = Registry::new();
    registry = register_default_interceptors(registry, &mut media_engine)
        .map_err(|e| AppError::Internal(format!("interceptor registration failed: {e}")))?;
    if let Some(builder) = extra {
        registry.add(Box::new(builder));
    }

    let mut setting_engine = SettingEngine::default();
    apply_ice_policy(&mut setting_engine, config)?;

    Ok(APIBuilder::new()
        .with_setting_engine(setting_engine)
        .with_media_engine(media_engine)
        .with_interceptor_registry(registry)
        .build())
}

/// Applies the resolved ICE policy to a `SettingEngine`.
fn apply_ice_policy(
    setting_engine: &mut SettingEngine,
    config: &EngineConfig,
) -> Result<(), AppError> {
    let policy = &config.policy;

    // Network types adapt to the host: IPv6 candidates are gathered only
    // when the host has a routable IPv6 address on an allowed interface.
    setting_engine.set_network_types(policy.network_types.clone());

    // The policy stores `Arc` filters (so `EngineConfig` stays clonable);
    // webrtc-rs consumes `Box<dyn Fn>` — wrap once per engine.
    if let Some(filter) = &policy.interface_filter {
        let filter = Arc::clone(filter);
        setting_engine.set_interface_filter(Box::new(move |name: &str| filter(name)));
    }
    if let Some(filter) = &policy.ip_filter {
        let filter = Arc::clone(filter);
        setting_engine.set_ip_filter(Box::new(move |ip: std::net::IpAddr| filter(ip)));
    }

    // ICE consent freshness: tuned timeouts make `Disconnected` detection
    // fast and deterministic; the keep-alive interval is the STUN consent
    // heartbeat when no media flows.
    if let Some((disconnected, failed, keep_alive)) = policy.timeouts {
        setting_engine.set_ice_timeouts(Some(disconnected), Some(failed), Some(keep_alive));
    }

    // 1:1 NAT public addresses as host candidates (incl. dev loopback).
    if !policy.nat_1to1_ips.is_empty() {
        setting_engine.set_nat_1to1_ips(policy.nat_1to1_ips.clone(), RTCIceCandidateType::Host);
    }

    // Explicit UDP socket binding: pin the ephemeral port range when
    // configured (deterministic firewall rules).
    if let Some((min, max)) = policy.udp_port_range {
        let udp = EphemeralUDP::new(min, max)
            .map_err(|e| AppError::BadRequest(format!("invalid ICE UDP port range: {e}")))?;
        setting_engine.set_udp_network(UDPNetwork::Ephemeral(udp));
    }

    // Server mode: plain-IP host candidates (no `.local` mDNS
    // obfuscation), which is the reliable mode behind NATs and for
    // browsers that resolve mDNS names unreliably.
    setting_engine.set_ice_multicast_dns_mode(MulticastDnsMode::Disabled);

    Ok(())
}
