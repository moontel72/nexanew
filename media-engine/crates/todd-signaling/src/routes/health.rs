use std::sync::Arc;

use axum::{extract::State, http::StatusCode};

use crate::state::AppState;

/// Liveness: the process is up.
pub async fn healthz() -> &'static str {
    "ok"
}

/// Readiness: the process is up AND the media plane is reachable.
pub async fn readyz(State(state): State<Arc<AppState>>) -> (StatusCode, &'static str) {
    match state.plane.ping().await {
        Ok(()) => (StatusCode::OK, "ready"),
        Err(_) => (StatusCode::SERVICE_UNAVAILABLE, "media plane unreachable"),
    }
}
