//! Instant replay signaling — delegates to the media plane (embedded SFU
//! or remote broadcaster).
//!
//! POST   /api/v1/replay/trigger                        admin   { ReplayTrigger }
//! GET    /api/v1/replay/list                           admin
//! DELETE /api/v1/replay/{replay_id}                    admin
//! POST   /api/v1/replay/{replay_id}/export             admin   { ClipExportRequest }
//! POST   /api/v1/replay/watch/{replay_id}/{camera_id}  viewer  body: recvonly SDP offer

use std::sync::Arc;

use axum::{
    body::Bytes,
    extract::{Path, State},
    http::{HeaderMap, StatusCode, Uri},
    response::Response,
    Json,
};
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
    http::{sdp_body, whep_response},
};
use todd_replay::export::{ClipExportRequest, ExportStatus};
use todd_replay::session::{ReplayInfo, ReplayTrigger};

use crate::routes::control_ws::ControlEvent;
use crate::state::AppState;

pub async fn trigger_replay(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Json(req): Json<ReplayTrigger>,
) -> Result<(StatusCode, Json<ReplayInfo>), AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;
    claims.require_perm("studio_director")?;

    let info = state.plane.trigger_replay(&req).await?;
    // Fan out to every director panel so ReplayDirector lists the new
    // session immediately (same event used by the auto-tag pipeline).
    state.control.publish(ControlEvent::ReplayCreated {
        replay: info.clone(),
    });
    Ok((StatusCode::CREATED, Json(info)))
}

pub async fn list_replays(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
) -> Result<Json<Vec<ReplayInfo>>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;
    claims.require_perm("studio_director")?;

    Ok(Json(state.plane.list_replays().await?))
}

pub async fn close_replay(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(replay_id): Path<String>,
) -> Result<StatusCode, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;
    claims.require_perm("studio_director")?;

    state.plane.close_replay(&replay_id).await?;
    Ok(StatusCode::NO_CONTENT)
}

pub async fn export_replay(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(replay_id): Path<String>,
    Json(mut req): Json<ClipExportRequest>,
) -> Result<(StatusCode, Json<ExportStatus>), AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;
    claims.require_perm("studio_director")?;

    req.replay_id = replay_id;
    let status = state.plane.export_replay(&req).await?;
    Ok((StatusCode::ACCEPTED, Json(status)))
}

pub async fn watch_replay(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path((replay_id, camera_id)): Path<(String, String)>,
    body: Bytes,
) -> Result<Response, AppError> {
    // Replay preview is a production-surface: any valid viewer token may
    // watch (room scoping is enforced at trigger time by the caller).
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Viewer)?;

    let offer = sdp_body(&headers, body)?;
    let (session_id, answer) = state
        .plane
        .create_replay_viewer(&replay_id, &camera_id, &offer)
        .await?;

    tracing::info!(replay = %replay_id, camera = %camera_id, session = %session_id, "replay watch accepted");
    whep_response(StatusCode::CREATED, Some(&session_id), answer)
}
