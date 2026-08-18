//! Room management API — called by Laravel (server-to-server) with an
//! admin Bearer token.

use std::sync::Arc;

use axum::{
    extract::{Path, State},
    http::{HeaderMap, StatusCode, Uri},
    Json,
};
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
    types::{CreateRoomRequest, CreateRoomResponse, ForwardTarget, Room, MAX_ROOM_TTL_SECS},
};

use crate::state::{build_room, AppState};

/// POST /api/v1/room/create
///
/// Creates a room and mints short-lived, room-scoped tokens:
/// one publisher token per camera (for WHIP ingest) and one viewer token.
pub async fn create_room(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Json(req): Json<CreateRoomRequest>,
) -> Result<(StatusCode, Json<CreateRoomResponse>), AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let name = req.name.trim();
    if name.is_empty() {
        return Err(AppError::BadRequest("room name is required".to_string()));
    }
    let ttl = req.ttl_secs.clamp(60, MAX_ROOM_TTL_SECS);

    let (room, ingest_tokens, viewer_token) =
        build_room(&state, name.to_string(), req.camera_ids, ttl)?;

    let whip_base_url = format!(
        "{}/api/v1/whip/ingest/{}",
        state.settings.public_base_url.trim_end_matches('/'),
        room.id
    );

    let response = CreateRoomResponse {
        room: room.clone(),
        ingest_tokens,
        viewer_token,
        whip_base_url,
    };

    state.store.upsert_room(&room, ttl).await?;
    tracing::info!(room = %response.room.id, name = %name, "room created");
    Ok((StatusCode::CREATED, Json(response)))
}

/// GET /api/v1/room/list — admin only.
pub async fn list_rooms(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
) -> Result<Json<Vec<Room>>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    Ok(Json(state.store.list_rooms().await?))
}

/// GET /api/v1/room/{room_id} — any token scoped to the room, or admin.
/// Active-camera flags are computed from live WHIP session state.
pub async fn get_room(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
) -> Result<Json<Room>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    if claims.role != TokenRole::Admin && claims.room_id.as_deref() != Some(room_id.as_str()) {
        return Err(AppError::Forbidden(
            "token not scoped to this room".to_string(),
        ));
    }

    let Some(mut room) = state.store.get_room(&room_id).await? else {
        return Err(AppError::NotFound(format!("room {room_id}")));
    };

    let sessions = state.store.list_sessions(&room_id).await?;
    for camera in &mut room.cameras {
        camera.active = sessions
            .iter()
            .any(|(_, session_camera)| session_camera == &camera.id);
    }
    Ok(Json(room))
}

/// DELETE /api/v1/room/{room_id} — admin only.
/// Closes every live WHIP session of the room.
pub async fn delete_room(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
) -> Result<StatusCode, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let sessions = state.store.list_sessions(&room_id).await?;
    for (session_id, _) in &sessions {
        let _ = state.plane.close_session(session_id).await;
    }
    state.store.delete_room(&room_id).await?;
    tracing::info!(room = %room_id, "room deleted");
    Ok(StatusCode::NO_CONTENT)
}

/// POST /api/v1/room/{room_id}/forward — admin only.
/// Attaches an output forwarder (RTMP/SRT/file) to one camera of the room.
pub async fn add_forward(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
    Json(target): Json<ForwardTarget>,
) -> Result<StatusCode, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let Some(room) = state.store.get_room(&room_id).await? else {
        return Err(AppError::NotFound(format!("room {room_id}")));
    };
    if !room
        .cameras
        .iter()
        .any(|camera| camera.id == target.camera_id)
    {
        return Err(AppError::NotFound(format!(
            "camera {} is not part of room {room_id}",
            target.camera_id
        )));
    }

    state
        .plane
        .add_forwarder(&room_id, &target.camera_id, &target)
        .await?;
    Ok(StatusCode::ACCEPTED)
}
