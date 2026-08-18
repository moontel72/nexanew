//! WHIP ingest signaling (RFC draft-ietf-wish-whip).
//!
//! POST   /api/v1/whip/ingest/{room_id}/{camera_id}   body: SDP offer
//! DELETE /api/v1/whip/session/{session_id}           (Location from POST)
//!
//! The POST validates the publisher token (Authorization header or
//! ?token= query parameter), hands the offer to the media plane, and
//! returns the SDP answer with a `Location` header pointing at the
//! session resource. WebRTC media then flows camera → engine directly
//! over UDP — HTTP is signaling only.

use std::sync::Arc;

use axum::{
    body::Bytes,
    extract::{Path, State},
    http::{HeaderMap, StatusCode, Uri},
    response::Response,
};
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
    http::{sdp_body, whip_response},
};

use crate::state::AppState;

pub async fn ingest(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path((room_id, camera_id)): Path<(String, String)>,
    body: Bytes,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_scope(&room_id, &camera_id, TokenRole::Publisher)?;

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
        .create_whip_session(&room_id, &camera_id, &offer)
        .await?;

    // Session state must outlive the ingest token so a camera can close
    // its session after a token renewal (reconnect window).
    let session_ttl = (state.settings.ingest_token_ttl_secs as u64) * 2 + 60;
    state
        .store
        .add_session(&room_id, &session_id, &camera_id, session_ttl)
        .await?;

    tracing::info!(room = %room_id, camera = %camera_id, session = %session_id, "whip ingest accepted");
    whip_response(StatusCode::CREATED, Some(&session_id), answer)
}

pub async fn close_session(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(session_id): Path<String>,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;

    // An admin may close anything. A publisher may only close sessions of
    // its own camera. (WHIP clients may also send an ICE-restart offer in
    // the DELETE body per spec; we accept and close regardless.)
    let Some((room_id, camera_id)) = state.store.find_session(&session_id).await? else {
        return Err(AppError::NotFound(format!("unknown session {session_id}")));
    };
    if claims.role != TokenRole::Admin
        && !(claims.role == TokenRole::Publisher
            && claims.camera_id.as_deref() == Some(camera_id.as_str()))
    {
        return Err(AppError::Forbidden(
            "token not allowed to close this session".to_string(),
        ));
    }

    // Remove from the store first so state never references a session the
    // engine has already forgotten.
    state.store.remove_session(&room_id, &session_id).await?;
    state.plane.close_session(&session_id).await?;
    whip_response(StatusCode::OK, None, String::new())
}
