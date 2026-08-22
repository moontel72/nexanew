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
    types::{OverlayCommand, PollOptionSpec},
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
    burn_in(&state, &room_id, &poll).await;
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
    burn_in(&state, &room_id, &poll).await;
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
        .publish(ControlEvent::PollCleared {
            room_id: room_id.clone(),
        });
    // Remove the burn-in without touching the scoreboard/watermark.
    if let Err(error) = state.plane.apply_overlay(&room_id, OverlayCommand::PollClear).await {
        tracing::warn!(room = %room_id, %error, "poll burn-in clear failed");
    }
    Ok(StatusCode::NO_CONTENT)
}

fn publish(state: &AppState, room_id: &str, poll: &PollState) {
    state.control.publish(ControlEvent::PollChanged {
        room_id: room_id.to_string(),
        poll: poll.clone(),
    });
}

/// Maps poll state to the program-composite burn-in command.
pub(crate) fn poll_burn_in_command(poll: &PollState) -> OverlayCommand {
    OverlayCommand::Poll {
        question: poll.question.clone(),
        options: poll
            .options
            .iter()
            .map(|option| PollOptionSpec {
                label: option.label.clone(),
                votes: option.votes,
            })
            .collect(),
    }
}

/// Pushes the poll into the program composite so WHEP/RTMP viewers see
/// the live tally — not just director panels. Failures are non-fatal: the
/// control-plane poll stays live and the next vote retries the burn-in.
async fn burn_in(state: &AppState, room_id: &str, poll: &PollState) {
    let command = poll_burn_in_command(poll);
    if let Err(error) = state.plane.apply_overlay(room_id, command).await {
        tracing::warn!(room = room_id, %error, "poll burn-in failed");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn burn_in_command_carries_question_and_tally() {
        let poll = PollState {
            question: "Who wins?".to_string(),
            options: vec![
                crate::poll::PollOption {
                    label: "A".to_string(),
                    votes: 3,
                },
                crate::poll::PollOption {
                    label: "B".to_string(),
                    votes: 1,
                },
            ],
            active: true,
            updated_at_ms: 1,
        };
        match poll_burn_in_command(&poll) {
            OverlayCommand::Poll { question, options } => {
                assert_eq!(question, "Who wins?");
                assert_eq!(options.len(), 2);
                assert_eq!(options[0].votes, 3);
                assert_eq!(options[1].label, "B");
            }
            other => panic!("expected Poll command, got {other:?}"),
        }
    }
}
