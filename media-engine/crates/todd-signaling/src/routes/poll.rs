//! Spectator poll REST surface — Phase 5 fan engagement.
//!
//! POST   /api/v1/poll/{room_id}           admin   create/replace a poll
//! POST   /api/v1/poll/{room_id}/vote      public  register one vote
//! GET    /api/v1/poll/{room_id}           public  current poll + tally
//! DELETE /api/v1/poll/{room_id}           admin   clear the poll
//!
//! Every mutation publishes `poll_changed` on the control plane so the
//! animated lower-third overlay updates in real time.

use std::sync::Arc;

use axum::{
    extract::{Path, State},
    http::{HeaderMap, StatusCode, Uri},
    Json,
};
use serde::Deserialize;
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
};

use crate::{
    poll::PollState,
    routes::control_ws::ControlEvent,
    state::AppState,
};

#[derive(Debug, Deserialize)]
pub struct CreatePollRequest {
    pub question: String,
    pub options: Vec<String>,
}

#[derive(Debug, Deserialize)]
pub struct VoteRequest {
    pub option: usize,
}

pub async fn create_poll(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
    Json(req): Json<CreatePollRequest>,
) -> Result<Json<PollState>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;
    claims.require_perm("studio_director")?;

    if req.question.trim().is_empty() || req.options.len() < 2 {
        return Err(AppError::BadRequest(
            "poll requires a question and at least two options".to_string(),
        ));
    }

    let poll = state.polls.set(&room_id, req.question, req.options);
    publish(&state, &room_id, &poll);
    Ok(Json(poll))
}

pub async fn vote(
    State(state): State<Arc<AppState>>,
    Path(room_id): Path<String>,
    Json(req): Json<VoteRequest>,
) -> Result<Json<PollState>, AppError> {
    let Some(poll) = state.polls.vote(&room_id, req.option) else {
        return Err(AppError::NotFound("no active poll for this room".to_string()));
    };
    publish(&state, &room_id, &poll);
    Ok(Json(poll))
}

pub async fn get_poll(
    State(state): State<Arc<AppState>>,
    Path(room_id): Path<String>,
) -> Result<Json<PollState>, AppError> {
    let poll = state
        .polls
        .get(&room_id)
        .ok_or_else(|| AppError::NotFound("no active poll for this room".to_string()))?;
    Ok(Json(poll))
}

pub async fn clear_poll(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
    Path(room_id): Path<String>,
) -> Result<StatusCode, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;
    claims.require_perm("studio_director")?;

    state.polls.clear(&room_id);
    state
        .control
        .publish(ControlEvent::PollCleared { room_id });
    Ok(StatusCode::NO_CONTENT)
}

fn publish(state: &AppState, room_id: &str, poll: &PollState) {
    state.control.publish(ControlEvent::PollChanged {
        room_id: room_id.to_string(),
        poll: poll.clone(),
    });
}
