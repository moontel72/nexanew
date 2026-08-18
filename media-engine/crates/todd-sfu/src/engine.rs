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
use todd_common::types::{ProgramState, TransitionKind};
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

    /// Records the program (PGM) source for a room. The camera need not
    /// be actively ingesting yet; egress resolution happens at watch time.
    pub fn set_program(
        &self,
        room_id: &str,
        camera_id: &str,
        transition: TransitionKind,
    ) -> ProgramState {
        let rid = self
            .router
            .lowest_rid(room_id, camera_id)
            .unwrap_or_default();
        let state = ProgramState {
            room_id: room_id.to_string(),
            camera_id: camera_id.to_string(),
            rid,
            transition,
            updated_at_ms: chrono::Utc::now().timestamp_millis(),
        };
        self.program.insert(room_id.to_string(), state.clone());
        self.telemetry.registry.inc("todd_program_transitions_total");
        tracing::info!(room = room_id, camera = camera_id, ?transition, "program switched");
        state
    }

    /// Current program source for a room, if the director has set one.
    pub fn get_program(&self, room_id: &str) -> Option<ProgramState> {
        self.program.get(room_id).map(|entry| entry.value().clone())
    }

    /// WHEP egress fed from the room's current program source. The source
    /// is resolved at watch time, so new program watchers always join the
    /// current PGM camera (existing viewers re-subscribe after a switch).
    pub async fn start_program_viewer(
        &self,
        room_id: &str,
        offer_sdp: &str,
    ) -> Result<(String, String), AppError> {
        let state = self
            .get_program(room_id)
            .ok_or_else(|| AppError::NotFound(format!("no program set for room {room_id}")))?;

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
        self.forwarders.insert(key, forwarder);
        Ok(())
    }

    #[cfg(not(feature = "gst"))]
    pub async fn add_forwarder(
        &self,
        _room_id: &str,
        _camera_id: &str,
        _target: &todd_common::types::ForwardTarget,
    ) -> Result<(), AppError> {
        Err(AppError::Unsupported(
            "built without the `gst` feature — rebuild with --features gst on a host with libgstreamer >= 1.24".to_string(),
        ))
    }
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
