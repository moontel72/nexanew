//! Audio mixer control plane.
//!
//! GET /api/v1/audio/mix/{room_id} — active bus configuration + metering
//! PUT /api/v1/audio/mix/{room_id} — faders, mute/solo, gain, delay
//!
//! The media plane owns the mix (it must reach the running pipeline);
//! every update is broadcast to director panels as an
//! `audio_mixer_changed` control event.

use std::sync::Arc;

use axum::{
    extract::{Path, State},
    http::{HeaderMap, Uri},
    Json,
};
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
    media::{AudioMixView, AudioMixerConfig},
};

use crate::{routes::control_ws::ControlEvent, state::AppState};

/// GET /api/v1/audio/mix/{room_id} — admin only.
pub async fn get_mix(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
) -> Result<Json<AudioMixView>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    state
        .store
        .get_room(&room_id)
        .await?
        .ok_or_else(|| AppError::NotFound(format!("room {room_id}")))?;

    Ok(Json(state.plane.get_audio_mix(&room_id).await?))
}

/// PUT /api/v1/audio/mix/{room_id} — admin only.
///
/// Replaces the room's mix wholesale: four buses (commentary, ambient,
/// sfx, music) with fader dB, mute, solo, gain trim and lip-sync delay,
/// plus the master fader. Numeric fields are clamped server-side.
pub async fn put_mix(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
    Json(config): Json<AudioMixerConfig>,
) -> Result<Json<AudioMixView>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;

    state
        .store
        .get_room(&room_id)
        .await?
        .ok_or_else(|| AppError::NotFound(format!("room {room_id}")))?;

    let view = state.plane.set_audio_mix(&room_id, config).await?;
    state.control.publish(ControlEvent::AudioMixerChanged {
        room_id: room_id.clone(),
        mix: view.clone(),
    });
    tracing::info!(room = %room_id, "audio mix updated");
    Ok(Json(view))
}
