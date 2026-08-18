//! HTTP API served by the standalone SFU binary.
//!
//! The signaling service proxies to these endpoints when
//! `MEDIA_PLANE=remote`. The routes mirror the signaling-side WHIP/WHEP
//! routes 1:1 and enforce the same auth rules, so the SFU is never
//! exposed without validation.

use std::sync::Arc;

use axum::{
    body::Bytes,
    extract::{Path, Query, State},
    http::{HeaderMap, StatusCode, Uri},
    response::Response,
    routing::get,
    Json, Router,
};
use serde::Deserialize;
use todd_common::{
    auth::{authenticate, AuthConfig, TokenRole},
    error::AppError,
    http::{sdp_body, whep_response, whip_response},
    types::{ForwardTarget, ProgramState, ProgramTransitionRequest},
};
use todd_replay::export::ClipExportRequest;
use todd_replay::session::{ReplayInfo, ReplayTrigger};
use todd_telemetry::feed::HasTelemetry;
use todd_telemetry::Telemetry;

use crate::engine::Engine;

#[derive(Clone)]
struct SfuState {
    engine: Arc<Engine>,
    auth: AuthConfig,
    telemetry: Arc<Telemetry>,
}

impl HasTelemetry for SfuState {
    fn telemetry(&self) -> &Arc<Telemetry> {
        &self.telemetry
    }
}

/// Optional WHEP query parameters.
#[derive(Debug, Default, Deserialize)]
pub struct WatchParams {
    /// Simulcast layer to watch (`f`/`h`/`q` …). Empty = lowest layer.
    pub rid: Option<String>,
}

pub fn routes(engine: Arc<Engine>, auth: AuthConfig, telemetry: Arc<Telemetry>) -> Router {
    let state = SfuState {
        engine,
        auth,
        telemetry,
    };
    Router::new()
        .route("/healthz", get(health))
        .route("/metrics", get(todd_telemetry::feed::metrics::<SfuState>))
        .route(
            "/api/v1/telemetry/ws",
            get(todd_telemetry::feed::ws_feed::<SfuState>),
        )
        .route(
            "/api/v1/whip/ingest/{room_id}/{camera_id}",
            axum::routing::post(ingest),
        )
        .route(
            "/api/v1/whip/session/{session_id}",
            axum::routing::delete(close_session),
        )
        .route(
            "/api/v1/whep/watch/{room_id}/{camera_id}",
            axum::routing::post(watch),
        )
        .route(
            "/api/v1/whep/session/{session_id}",
            axum::routing::delete(close_watch),
        )
        .route(
            "/api/v1/forward/{room_id}/{camera_id}",
            axum::routing::post(add_forward),
        )
        .route("/api/v1/stats", get(stats))
        .route(
            "/api/v1/replay/trigger",
            axum::routing::post(trigger_replay),
        )
        .route("/api/v1/replay/list", get(list_replays))
        .route(
            "/api/v1/replay/{replay_id}",
            axum::routing::delete(close_replay),
        )
        .route(
            "/api/v1/replay/{replay_id}/export",
            axum::routing::post(export_replay),
        )
        .route(
            "/api/v1/replay/watch/{replay_id}/{camera_id}",
            axum::routing::post(watch_replay),
        )
        .route(
            "/api/v1/program/transition",
            axum::routing::post(program_transition),
        )
        .route("/api/v1/program/{room_id}", get(get_program))
        .route(
            "/api/v1/whep/program/{room_id}",
            axum::routing::post(watch_program),
        )
        .with_state(state)
}

async fn health() -> &'static str {
    "ok"
}

async fn ingest(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path((room_id, camera_id)): Path<(String, String)>,
    body: Bytes,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_scope(&room_id, &camera_id, TokenRole::Publisher)?;

    let offer = sdp_body(&headers, body)?;
    let (session_id, answer) = state
        .engine
        .start_session(&room_id, &camera_id, &offer)
        .await?;
    whip_response(StatusCode::CREATED, Some(&session_id), answer)
}

async fn close_session(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path(session_id): Path<String>,
) -> Result<Response, AppError> {
    // Publisher or admin; the signaling service performs the fine-grained
    // camera scoping before proxying here.
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Publisher)?;

    state.engine.stop_session(&session_id).await?;
    whip_response(StatusCode::OK, None, String::new())
}

/// WHEP: browser posts a recvonly offer (+ optional `?rid=` layer
/// selection), we answer with sendonly tracks fed from the camera's live
/// RTP stream of the selected simulcast layer.
async fn watch(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path((room_id, camera_id)): Path<(String, String)>,
    Query(params): Query<WatchParams>,
    body: Bytes,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_room(&room_id, TokenRole::Viewer)?;

    let offer = sdp_body(&headers, body)?;
    let (session_id, answer) = state
        .engine
        .start_viewer_session(&room_id, &camera_id, params.rid, &offer)
        .await?;
    whep_response(StatusCode::CREATED, Some(&session_id), answer)
}

async fn close_watch(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path(session_id): Path<String>,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Viewer)?;

    state.engine.stop_viewer_session(&session_id).await?;
    whep_response(StatusCode::OK, None, String::new())
}

async fn add_forward(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path((room_id, camera_id)): Path<(String, String)>,
    Json(target): Json<ForwardTarget>,
) -> Result<StatusCode, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    state
        .engine
        .add_forwarder(&room_id, &camera_id, &target)
        .await?;
    Ok(StatusCode::ACCEPTED)
}

async fn stats(State(state): State<SfuState>) -> Json<crate::router::RouterStats> {
    Json(state.engine.router().stats())
}

// --------------------------------------------------------------------------
// Instant replay
// --------------------------------------------------------------------------

/// POST /api/v1/replay/trigger — admin.
async fn trigger_replay(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Json(req): Json<ReplayTrigger>,
) -> Result<(StatusCode, Json<ReplayInfo>), AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let info = state.engine.trigger_replay(&req).await?;
    Ok((StatusCode::CREATED, Json(info)))
}

/// GET /api/v1/replay/list — admin.
async fn list_replays(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
) -> Result<Json<Vec<ReplayInfo>>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    Ok(Json(state.engine.list_replays()))
}

/// DELETE /api/v1/replay/{replay_id} — admin.
async fn close_replay(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path(replay_id): Path<String>,
) -> Result<StatusCode, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    state.engine.close_replay(&replay_id).await?;
    Ok(StatusCode::NO_CONTENT)
}

/// POST /api/v1/replay/{replay_id}/export — admin. Starts an async clip
/// export job; the response carries the initial job status.
async fn export_replay(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path(replay_id): Path<String>,
    Json(mut req): Json<ClipExportRequest>,
) -> Result<(StatusCode, Json<todd_replay::export::ExportStatus>), AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    req.replay_id = replay_id;
    let status = state.engine.export_replay(&req).await?;
    Ok((StatusCode::ACCEPTED, Json(status)))
}

/// POST /api/v1/replay/watch/{replay_id}/{camera_id} — viewer. WHEP egress
/// fed from the replay session's paced slow-motion stream (the director's
/// preview monitor).
async fn watch_replay(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path((replay_id, camera_id)): Path<(String, String)>,
    body: Bytes,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Viewer)?;

    let offer = sdp_body(&headers, body)?;
    let (session_id, answer) = state
        .engine
        .start_replay_viewer(&replay_id, &camera_id, &offer)
        .await?;
    whep_response(StatusCode::CREATED, Some(&session_id), answer)
}

// --------------------------------------------------------------------------
// Program (PGM/PVW) control + WHEP program egress
// --------------------------------------------------------------------------

/// POST /api/v1/program/transition — admin.
async fn program_transition(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Json(req): Json<ProgramTransitionRequest>,
) -> Result<(StatusCode, Json<ProgramState>), AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let program = state
        .engine
        .set_program(&req.room_id, &req.camera_id, req.transition);
    Ok((StatusCode::OK, Json(program)))
}

/// GET /api/v1/program/{room_id} — admin.
async fn get_program(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
) -> Result<Json<ProgramState>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let program = state
        .engine
        .get_program(&room_id)
        .ok_or_else(|| AppError::NotFound(format!("no program set for room {room_id}")))?;
    Ok(Json(program))
}

/// POST /api/v1/whep/program/{room_id} — viewer. WHEP egress fed from the
/// room's current program source (resolved at watch time).
async fn watch_program(
    State(state): State<SfuState>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
    body: Bytes,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_room(&room_id, TokenRole::Viewer)?;

    let offer = sdp_body(&headers, body)?;
    let (session_id, answer) = state
        .engine
        .start_program_viewer(&room_id, &offer)
        .await?;
    whep_response(StatusCode::CREATED, Some(&session_id), answer)
}
