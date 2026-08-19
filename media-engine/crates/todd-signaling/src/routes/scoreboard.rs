//! Scoreboard HTTP + WebSocket surfaces for the Studio lower-third.
//!
//! GET /api/v1/cricket/live/{match_id} — latest cached ball-by-ball state
//! GET /api/v1/cricket/ws              — push feed of all cached matches
//! GET /api/v1/cricket/config          — current sync configuration
//! PUT /api/v1/cricket/config          — runtime config update (admin)

use std::sync::Arc;

use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        Path, State,
    },
    http::{HeaderMap, Uri},
    response::Response,
    Json,
};
use futures_util::StreamExt;
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
};

use crate::{
    routes::control_ws::ControlEvent,
    scoreboard::{BallByBallState, CricketConfigUpdate, CricketConfigView},
    state::AppState,
};

/// GET /api/v1/cricket/live/{match_id} — admin (director control room).
pub async fn live(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(match_id): Path<String>,
) -> Result<Json<BallByBallState>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let score = state
        .scoreboard
        .get(&match_id)
        .ok_or_else(|| AppError::NotFound(format!("no score cached for match {match_id}")))?;
    Ok(Json(score))
}

/// GET /api/v1/cricket/config — admin (director control room).
pub async fn get_config(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
) -> Result<Json<CricketConfigView>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    Ok(Json(state.scoreboard.config_view().await))
}

/// PUT /api/v1/cricket/config — admin (director control room).
///
/// Replaces the synced match list and applies optional poll-interval and
/// API-token changes. Directors on the control-plane WebSocket receive
/// the resulting config as a `cricket_config_changed` event.
pub async fn put_config(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Json(update): Json<CricketConfigUpdate>,
) -> Result<Json<CricketConfigView>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let view = state.scoreboard.update_config(update).await?;
    state.control.publish(ControlEvent::CricketConfigChanged {
        config: view.clone(),
    });
    tracing::info!(
        matches = view.match_configs.len(),
        poll_ms = view.poll_ms,
        "cricket sync config updated"
    );
    Ok(Json(view))
}

/// GET /api/v1/cricket/ws — push feed of cached matches. This is an
/// internal director-monitor feed (same trust boundary as the telemetry
/// WS), so it intentionally carries no token.
pub async fn ws(ws: WebSocketUpgrade, State(state): State<Arc<AppState>>) -> Response {
    ws.on_upgrade(move |socket| serve_ws(socket, state.scoreboard.clone()))
}

async fn serve_ws(mut socket: WebSocket, hub: Arc<crate::scoreboard::ScoreboardHub>) {
    if let Err(e) = send_all(&mut socket, &hub).await {
        tracing::debug!(error = %e, "scoreboard ws client disconnected");
        return;
    }

    let mut ticker = tokio::time::interval(std::time::Duration::from_millis(1000));
    loop {
        tokio::select! {
            _ = ticker.tick() => {
                if send_all(&mut socket, &hub).await.is_err() {
                    break;
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

async fn send_all(
    socket: &mut WebSocket,
    hub: &crate::scoreboard::ScoreboardHub,
) -> Result<(), String> {
    let json = serde_json::to_string(&hub.all()).map_err(|e| e.to_string())?;
    socket
        .send(Message::Text(json.into()))
        .await
        .map_err(|e| e.to_string())
}
