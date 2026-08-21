//! Unified control-plane WebSocket for director clients.
//!
//! `GET /api/v1/control/ws` (admin Bearer token, also accepted as
//! `?token=` for browser WebSocket clients) pushes the live state of the
//! broadcast: rooms with their cameras, the PGM program source per room,
//! the per-room audio mix and the cricket sync configuration.
//!
//! Wire protocol:
//! - On connect the server sends one `snapshot` event with the full state.
//! - Every mutation route publishes an incremental event
//!   ([`ControlEvent`]) on the shared [`ControlHub`] bus.
//! - A client that falls behind (bounded broadcast channel) receives a
//!   fresh `snapshot` instead of partial history.
//!
//! This replaces the Studio's room-list polling; the director UI applies
//! events against its local mirror.

use std::sync::Arc;

use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    http::{HeaderMap, Uri},
    response::{IntoResponse, Response},
    Json,
};
use futures_util::StreamExt;
use serde::Serialize;
use todd_common::{
    auth::{authenticate, TokenRole},
    media::{AudioMixView, AudioMixerConfig},
    types::{CameraInfo, ForwardingStatus, OverlayState, ProgramState, Room},
};
use todd_replay::session::ReplayInfo;
use tokio::sync::broadcast;

use crate::{
    routes::rooms,
    scoreboard::{BallByBallState, CricketConfigView},
    state::AppState,
};

/// Full state of one room as seen by the control plane.
#[derive(Debug, Clone, Serialize)]
pub struct ControlRoomSnapshot {
    #[serde(flatten)]
    pub room: Room,
    /// Current program (PGM) source, when a director has set one.
    pub program: Option<ProgramState>,
    /// Per-room audio mix. Phase 1 ships the standard mix; Phase 3 adds
    /// runtime mixer control events on this channel.
    pub mixer: AudioMixerConfig,
}

/// Events broadcast to director clients. Serde tags the payload with
/// `"type"` so the TypeScript client can discriminate the union.
#[derive(Debug, Clone, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum ControlEvent {
    /// Full state, sent once on connect (and after a client lagged).
    Snapshot {
        rooms: Vec<ControlRoomSnapshot>,
        cricket: CricketConfigView,
        /// Cached ball-by-ball states so a (re)connecting director gets
        /// the scores immediately without extra REST round-trips.
        scores: Vec<BallByBallState>,
        /// Live replay sessions (manual + auto-tagged) at connect time.
        replays: Vec<ReplayInfo>,
    },
    RoomCreated {
        room: Room,
    },
    RoomDeleted {
        room_id: String,
    },
    CameraAdded {
        room_id: String,
        camera: CameraInfo,
        ingest_token: String,
        whip_base_url: String,
    },
    CameraUpdated {
        room_id: String,
        camera: CameraInfo,
    },
    CameraRemoved {
        room_id: String,
        camera_id: String,
    },
    ProgramChanged {
        program: ProgramState,
    },
    AudioMixerChanged {
        room_id: String,
        mix: AudioMixView,
    },
    OverlayChanged {
        room_id: String,
        overlays: OverlayState,
    },
    ForwardingChanged {
        status: ForwardingStatus,
    },
    CricketConfigChanged {
        config: CricketConfigView,
    },
    /// Push delivery of a freshly synced ball-by-ball state.
    ScoreUpdated {
        match_id: String,
        score: BallByBallState,
    },
    /// A replay session was created (manual trigger or auto-tag).
    ReplayCreated {
        replay: ReplayInfo,
    },
}

/// Fan-out bus for control events. Mutation routes publish; WebSocket
/// tasks subscribe.
pub struct ControlHub {
    tx: broadcast::Sender<ControlEvent>,
}

impl ControlHub {
    pub fn new() -> Self {
        let (tx, _) = broadcast::channel(256);
        Self { tx }
    }

    pub fn subscribe(&self) -> broadcast::Receiver<ControlEvent> {
        self.tx.subscribe()
    }

    /// Publishes an event to every connected director client. Events are
    /// dropped when nobody is listening — a client that connects later
    /// always receives a fresh snapshot.
    pub fn publish(&self, event: ControlEvent) {
        if self.tx.receiver_count() > 0 {
            let _ = self.tx.send(event);
        }
    }
}

impl Default for ControlHub {
    fn default() -> Self {
        Self::new()
    }
}

/// `GET /api/v1/control/ws` — admin-only director state feed.
pub async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
) -> Response {
    match authenticate(&state.auth, &headers, &uri).await {
        Ok(claims) => {
            if let Err(e) = claims.require_role(TokenRole::Admin) {
                return (
                    e.status(),
                    Json(serde_json::json!({ "error": e.to_string() })),
                )
                    .into_response();
            }
            if let Err(e) = claims.require_perm("studio_director") {
                return (
                    e.status(),
                    Json(serde_json::json!({ "error": e.to_string() })),
                )
                    .into_response();
            }
            ws.on_upgrade(move |socket| serve(socket, state))
        }
        Err(e) => (
            e.status(),
            Json(serde_json::json!({ "error": e.to_string() })),
        )
            .into_response(),
    }
}

async fn serve(mut socket: WebSocket, state: Arc<AppState>) {
    let mut events = state.control.subscribe();

    if send_snapshot(&mut socket, &state).await.is_err() {
        return;
    }

    loop {
        tokio::select! {
            event = events.recv() => {
                match event {
                    Ok(event) => {
                        if send(&mut socket, event).await.is_err() {
                            break;
                        }
                    }
                    Err(broadcast::error::RecvError::Lagged(_)) => {
                        // The client missed events; heal with a fresh
                        // full snapshot instead of partial history.
                        if send_snapshot(&mut socket, &state).await.is_err() {
                            break;
                        }
                    }
                    Err(broadcast::error::RecvError::Closed) => break,
                }
            }
            message = socket.next() => {
                match message {
                    Some(Ok(Message::Close(_))) | None => break,
                    Some(Ok(Message::Ping(payload))) => {
                        if socket.send(Message::Pong(payload)).await.is_err() {
                            break;
                        }
                    }
                    Some(Ok(_)) => {}
                    Some(Err(_)) => break,
                }
            }
        }
    }
}

/// Builds and sends the full-state snapshot event.
async fn send_snapshot(socket: &mut WebSocket, state: &AppState) -> Result<(), String> {
    let rooms = rooms::rooms_with_liveness(state).await.unwrap_or_else(|e| {
        tracing::warn!(error = %e, "control snapshot: room hydration failed");
        Vec::new()
    });

    let mut entries = Vec::with_capacity(rooms.len());
    for room in rooms {
        let program = match state.plane.get_program(&room.id).await {
            Ok(program) => program,
            Err(e) => {
                tracing::warn!(room = %room.id, error = %e, "control snapshot: program lookup failed");
                None
            }
        };
        entries.push(ControlRoomSnapshot {
            room,
            program,
            mixer: AudioMixerConfig::default(),
        });
    }

    send(
        socket,
        ControlEvent::Snapshot {
            rooms: entries,
            cricket: state.scoreboard.config_view().await,
            scores: state.scoreboard.all(),
            replays: state.plane.list_replays().await.unwrap_or_default(),
        },
    )
    .await
}

async fn send(socket: &mut WebSocket, event: ControlEvent) -> Result<(), String> {
    let json = serde_json::to_string(&event).map_err(|e| e.to_string())?;
    socket
        .send(Message::Text(json.into()))
        .await
        .map_err(|e| e.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn events_serialize_with_snake_case_type_tag() {
        // The TypeScript client (`src/lib/ws/control.ts`) discriminates on
        // this exact tag — keep both sides in lockstep.
        let event = ControlEvent::RoomDeleted {
            room_id: "r-1".to_string(),
        };
        assert_eq!(
            serde_json::to_string(&event).unwrap(),
            "{\"type\":\"room_deleted\",\"room_id\":\"r-1\"}"
        );

        let event = ControlEvent::CricketConfigChanged {
            config: crate::scoreboard::CricketConfigView {
                base_url: String::new(),
                match_configs: Vec::new(),
                poll_ms: 3000,
                api_token_set: false,
                sync: Vec::new(),
                active_match_id: Some("m-1".to_string()),
                push_connected: true,
            },
        };
        let json = serde_json::to_string(&event).unwrap();
        assert!(json.starts_with("{\"type\":\"cricket_config_changed\""));
        assert!(json.contains("\"api_token_set\":false"));
        assert!(json.contains("\"active_match_id\":\"m-1\""));
        assert!(json.contains("\"push_connected\":true"));
    }

    #[test]
    fn score_updated_event_serializes_for_ts_client() {
        let event = ControlEvent::ScoreUpdated {
            match_id: "m-1".to_string(),
            score: crate::scoreboard::BallByBallState {
                match_id: "m-1".to_string(),
                batting_team: "Tigers".to_string(),
                bowling_team: "Falcons".to_string(),
                runs: 99,
                wickets: 2,
                overs: 12.0,
                run_rate: 8.25,
                batter_on_strike: "R. Khan".to_string(),
                batter_non_strike: "A. Singh".to_string(),
                bowler: "M. Patel".to_string(),
                recent_balls: vec!["4".to_string()],
                updated_at_ms: 1_700_000_000_000,
                last_event: None,
            },
        };
        let json = serde_json::to_string(&event).unwrap();
        assert!(json.starts_with("{\"type\":\"score_updated\""));
        assert!(json.contains("\"match_id\":\"m-1\""));
        assert!(json.contains("\"runs\":99"));
    }
}
