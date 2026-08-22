//! Innings highlight playlist API — Phase 5 automated highlight generation.
//!
//! GET /api/v1/highlights — admin — the ordered playlist of auto-tagged
//! clips (newest first) collected by the auto-replay pipeline.

use std::sync::Arc;

use axum::{
    extract::State,
    http::{HeaderMap, Uri},
    Json,
};
use todd_common::{
    auth::{authenticate, TokenRole},
    error::AppError,
};

use crate::{highlights::HighlightEntry, state::AppState};

pub async fn list_highlights(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    uri: Uri,
) -> Result<Json<Vec<HighlightEntry>>, AppError> {
    let claims = authenticate(&state.auth, &headers, &uri).await?;
    claims.require_role(TokenRole::Admin)?;
    claims.require_perm("studio_director")?;

    Ok(Json(state.highlights.list().await))
}
