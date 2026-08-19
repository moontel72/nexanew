//! Vision switcher control contract + program (PGM) WHEP egress.
//!
//! POST   /api/v1/program/transition       body: ProgramTransitionRequest
//! GET    /api/v1/program/{room_id}        current program source
//! POST   /api/v1/whep/program/{room_id}   WHEP offer → program egress

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
    types::{ProgramState, ProgramTransitionRequest, SceneLayout, SourceRef},
};

use crate::{routes::control_ws::ControlEvent, state::AppState};

/// POST /api/v1/program/transition — admin only.
///
/// Moves the given camera onto Program (PGM) with a Cut/Fade/Stinger
/// transition. The Studio director's Preview bus is owned by the UI; this
/// endpoint records the resulting Program source and resolves the simulcast
/// layer for WHEP egress.
pub async fn transition(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Json(mut req): Json<ProgramTransitionRequest>,
) -> Result<Json<ProgramState>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    req.room_id = req.room_id.trim().to_string();
    req.camera_id = req.camera_id.trim().to_string();
    if req.room_id.is_empty() || req.camera_id.is_empty() {
        return Err(AppError::BadRequest(
            "room_id and camera_id are required".to_string(),
        ));
    }

    // Validate the camera is part of the room before touching the media plane.
    let Some(room) = state.store.get_room(&req.room_id).await? else {
        return Err(AppError::NotFound(format!("room {}", req.room_id)));
    };
    if !room.cameras.iter().any(|camera| camera.id == req.camera_id) {
        return Err(AppError::NotFound(format!(
            "camera {} is not part of room {}",
            req.camera_id, req.room_id
        )));
    }
    validate_layout(&room, &req)?;

    let program = state.plane.set_program(&req).await?;
    state.control.publish(ControlEvent::ProgramChanged {
        program: program.clone(),
    });
    Ok(Json(program))
}

/// Scene layouts must only reference cameras of the room (Phase 2 scenes
/// do not cross rooms), and split scenes need at least two regions.
fn validate_layout(
    room: &todd_common::types::Room,
    req: &ProgramTransitionRequest,
) -> Result<(), AppError> {
    let Some(layout) = &req.layout else {
        return Ok(());
    };

    let in_room = |source: &SourceRef| {
        source.room_id == room.id
            && room
                .cameras
                .iter()
                .any(|camera| camera.id == source.camera_id)
    };

    match layout {
        SceneLayout::Fullscreen => Ok(()),
        SceneLayout::PictureInPicture(config) => {
            if !in_room(&config.main) || !in_room(&config.overlay) {
                return Err(AppError::BadRequest(
                    "picture-in-picture sources must belong to the room".to_string(),
                ));
            }
            Ok(())
        }
        SceneLayout::SideBySide(config) => {
            if !in_room(&config.left) || !in_room(&config.right) {
                return Err(AppError::BadRequest(
                    "side-by-side sources must belong to the room".to_string(),
                ));
            }
            Ok(())
        }
        SceneLayout::SplitScreen(config) => {
            if config.regions.len() < 2 {
                return Err(AppError::BadRequest(
                    "split scenes require at least two regions".to_string(),
                ));
            }
            for region in &config.regions {
                if !in_room(&region.source) {
                    return Err(AppError::BadRequest(
                        "split regions must reference cameras of the room".to_string(),
                    ));
                }
            }
            Ok(())
        }
    }
}

/// GET /api/v1/program/{room_id} — admin only.
pub async fn get(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
) -> Result<Json<ProgramState>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    let program = state
        .plane
        .get_program(&room_id)
        .await?
        .ok_or_else(|| AppError::NotFound(format!("no program set for room {room_id}")))?;
    Ok(Json(program))
}

/// POST /api/v1/whep/program/{room_id} — viewer token scoped to the room.
///
/// The public/Studio client posts a recvonly SDP offer and receives the
/// current program camera. New program watchers always resolve the current
/// source; re-subscribe after a transition to follow a source switch.
pub async fn watch(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
    body: Bytes,
) -> Result<Response, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_room(&room_id, TokenRole::Viewer)?;

    let offer = sdp_body(&headers, body)?;
    let (session_id, answer) = state.plane.create_program_viewer(&room_id, &offer).await?;

    tracing::info!(room = %room_id, session = %session_id, "program watch accepted");
    whep_response(StatusCode::CREATED, Some(&session_id), answer)
}
