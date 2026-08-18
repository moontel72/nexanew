//! WHEP egress signaling (WebRTC HTTP Egress Protocol).
//!
//! POST   /api/v1/whep/watch/{room_id}/{camera_id}  body: recvonly SDP offer
//! DELETE /api/v1/whep/session/{session_id}          (Location from POST)
//!
//! The browser-side counterpart of WHIP: viewers watch a camera live in
//! a <video> element with sub-second latency — no OBS, no RTMP, no
//! transcoding (pure RTP fan-out from the track router). The optional
//! `?rid=` query parameter selects a simulcast layer (empty = lowest).

use std::sync::Arc;

use axum::{
    body::Bytes,
    extract::{Path, Query, State},
    http::{HeaderMap, StatusCode, Uri},
    response::Response,
};
use serde::Deserialize;
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
    http::{sdp_body, whep_response},
};

use crate::state::AppState;

/// Optional WHEP query parameters.
#[derive(Debug, Default, Deserialize)]
pub struct WatchParams {
    /// Simulcast layer to watch (`f`/`h`/`q` …). Empty = lowest layer.
    pub rid: Option<String>,
}

pub async fn watch(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path((room_id, camera_id)): Path<(String, String)>,
    Query(params): Query<WatchParams>,
    body: Bytes,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_room(&room_id, TokenRole::Viewer)?;

    // The room must exist and contain this camera.
    let Some(room) = state.store.get_room(&room_id).await? else {
        return Err(AppError::NotFound(format!("room {room_id}")));
    };
    if !room.cameras.iter().any(|camera| camera.id == camera_id) {
        return Err(AppError::NotFound(format!(
            "camera {camera_id} is not part of room {room_id}"
        )));
    }

    let offer = sdp_body(&headers, body)?;
    let (session_id, answer) = state
        .plane
        .create_viewer_session(&room_id, &camera_id, params.rid, &offer)
        .await?;

    tracing::info!(room = %room_id, camera = %camera_id, session = %session_id, "whep watch accepted");
    whep_response(StatusCode::CREATED, Some(&session_id), answer)
}

pub async fn close_watch(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(session_id): Path<String>,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Viewer)?;

    state.plane.close_viewer_session(&session_id).await?;
    whep_response(StatusCode::OK, None, String::new())
}
