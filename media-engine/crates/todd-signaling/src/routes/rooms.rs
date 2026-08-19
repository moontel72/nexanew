//! Room management API — called by Laravel (server-to-server) and by the
//! Studio director UI with an admin Bearer token.
//!
//! Dynamic camera management: cameras can be added to, updated in and
//! removed from a live room without tearing the room down. Every mutation
//! publishes a [`ControlEvent`] so director clients stay in sync without
//! polling.

use std::sync::Arc;

use axum::{
    extract::{Path, State},
    http::{HeaderMap, StatusCode, Uri},
    Json,
};
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
    types::{
        AddCameraResponse, CameraInfo, CameraSpec, CreateRoomRequest, CreateRoomResponse,
        ForwardTarget, Room, UpdateCameraRequest, MAX_ROOM_TTL_SECS,
    },
};

use crate::{
    routes::control_ws::ControlEvent,
    state::{build_room, mint_camera_ingest_token, AppState},
};

/// Camera ids appear in URL paths; reject values that would break routing
/// or produce unusable WHIP/WHEP URLs.
fn validate_camera_id(id: &str) -> Result<(), AppError> {
    let id = id.trim();
    if id.is_empty() {
        return Err(AppError::BadRequest("camera id is required".to_string()));
    }
    if id.contains('/') || id.chars().any(char::is_whitespace) {
        return Err(AppError::BadRequest(
            "camera id must not contain '/' or whitespace".to_string(),
        ));
    }
    Ok(())
}

/// Resolves the requested camera list of a create call into specs:
/// `camera_specs` wins over the legacy plain `camera_ids`; an empty
/// request falls back to a single camera named "default" (server-side,
/// matching the documented contract).
fn specs_from_request(req: &CreateRoomRequest) -> Vec<CameraSpec> {
    if !req.camera_specs.is_empty() {
        req.camera_specs.clone()
    } else {
        req.camera_ids
            .iter()
            .map(|id| CameraSpec {
                id: id.clone(),
                label: None,
                kind: todd_common::types::CameraSourceKind::Whip,
                group: None,
            })
            .collect()
    }
}

/// Lists every room with live-camera flags computed from session state.
/// Shared by `GET /room/list` and the control-plane WebSocket snapshot.
pub async fn rooms_with_liveness(state: &AppState) -> Result<Vec<Room>, AppError> {
    let mut rooms = state.store.list_rooms().await?;
    for room in &mut rooms {
        let sessions = state.store.list_sessions(&room.id).await?;
        for camera in &mut room.cameras {
            camera.active = sessions
                .iter()
                .any(|(_, session_camera)| session_camera == &camera.id);
        }
    }
    rooms.sort_by(|a, b| a.name.cmp(&b.name).then_with(|| a.id.cmp(&b.id)));
    Ok(rooms)
}

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
        build_room(&state, name.to_string(), specs_from_request(&req), ttl)?;

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
    state.control.publish(ControlEvent::RoomCreated { room });
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

    Ok(Json(rooms_with_liveness(&state).await?))
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
    state
        .control
        .publish(ControlEvent::RoomDeleted { room_id });
    Ok(StatusCode::NO_CONTENT)
}

/// POST /api/v1/room/{room_id}/camera — admin only.
///
/// Adds a camera to a live room and mints its publisher ingest token.
pub async fn add_camera(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
    Json(spec): Json<CameraSpec>,
) -> Result<(StatusCode, Json<AddCameraResponse>), AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    validate_camera_id(&spec.id)?;
    let camera = spec.into_info();

    let Some(room) = state.store.get_room(&room_id).await? else {
        return Err(AppError::NotFound(format!("room {room_id}")));
    };
    if room.cameras.iter().any(|existing| existing.id == camera.id) {
        return Err(AppError::Conflict(format!(
            "camera {} already exists in room {room_id}",
            camera.id
        )));
    }

    let ingest_token = mint_camera_ingest_token(&state, &room_id, &camera.id)?;
    let whip_base_url = format!(
        "{}/api/v1/whip/ingest/{}",
        state.settings.public_base_url.trim_end_matches('/'),
        room_id
    );

    // Preserve the room's remaining lifetime on the write.
    let ttl = room
        .expires_at
        .signed_duration_since(chrono::Utc::now())
        .num_seconds()
        .max(1) as u64;
    state
        .store
        .upsert_camera(&room_id, &camera, ttl)
        .await?;

    tracing::info!(room = %room_id, camera = %camera.id, "camera added");
    state.control.publish(ControlEvent::CameraAdded {
        room_id: room_id.clone(),
        camera: camera.clone(),
        ingest_token: ingest_token.clone(),
        whip_base_url: whip_base_url.clone(),
    });

    let response = AddCameraResponse {
        camera,
        ingest_token,
        whip_base_url,
    };
    Ok((StatusCode::CREATED, Json(response)))
}

/// PUT /api/v1/room/{room_id}/camera/{camera_id} — admin only.
///
/// Updates camera metadata (label, source kind, group). Omitted fields
/// keep their current value; an explicit empty string clears a text
/// field.
pub async fn update_camera(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path((room_id, camera_id)): Path<(String, String)>,
    Json(update): Json<UpdateCameraRequest>,
) -> Result<Json<CameraInfo>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let Some(mut room) = state.store.get_room(&room_id).await? else {
        return Err(AppError::NotFound(format!("room {room_id}")));
    };
    let Some(existing) = room.cameras.iter_mut().find(|camera| camera.id == camera_id) else {
        return Err(AppError::NotFound(format!(
            "camera {camera_id} is not part of room {room_id}"
        )));
    };

    if let Some(label) = &update.label {
        existing.label = if label.trim().is_empty() {
            None
        } else {
            Some(label.trim().to_string())
        };
    }
    if let Some(kind) = update.kind {
        existing.kind = kind;
    }
    if let Some(group) = &update.group {
        existing.group = if group.trim().is_empty() {
            None
        } else {
            Some(group.trim().to_string())
        };
    }

    let ttl = room
        .expires_at
        .signed_duration_since(chrono::Utc::now())
        .num_seconds()
        .max(1) as u64;
    state
        .store
        .upsert_camera(&room_id, existing, ttl)
        .await?;

    let camera = existing.clone();
    tracing::info!(room = %room_id, camera = %camera_id, "camera updated");
    state.control.publish(ControlEvent::CameraUpdated {
        room_id,
        camera: camera.clone(),
    });
    Ok(Json(camera))
}

/// DELETE /api/v1/room/{room_id}/camera/{camera_id} — admin only.
///
/// Removes a camera from a live room and closes its live WHIP sessions.
pub async fn remove_camera(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path((room_id, camera_id)): Path<(String, String)>,
) -> Result<StatusCode, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let Some(room) = state.store.get_room(&room_id).await? else {
        return Err(AppError::NotFound(format!("room {room_id}")));
    };
    if !room.cameras.iter().any(|camera| camera.id == camera_id) {
        return Err(AppError::NotFound(format!(
            "camera {camera_id} is not part of room {room_id}"
        )));
    }

    // Close every live ingest session of the camera before dropping its
    // registry entries, so the media plane and the store stay consistent.
    let sessions = state.store.list_sessions(&room_id).await?;
    for (session_id, session_camera) in &sessions {
        if session_camera == &camera_id {
            let _ = state.plane.close_session(session_id).await;
            let _ = state.store.remove_session(&room_id, session_id).await;
        }
    }

    state.store.remove_camera(&room_id, &camera_id).await?;
    tracing::info!(room = %room_id, camera = %camera_id, "camera removed");
    state.control.publish(ControlEvent::CameraRemoved {
        room_id,
        camera_id,
    });
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
