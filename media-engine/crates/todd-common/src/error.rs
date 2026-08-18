//! Unified error type shared by Studio and Broadcaster.
//!
//! Internal details are never leaked to callers: `Internal` variants are
//! logged and replaced with a generic message in the response body.

use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde::Serialize;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("bad request: {0}")]
    BadRequest(String),

    #[error("unauthorized: {0}")]
    Unauthorized(String),

    #[error("forbidden: {0}")]
    Forbidden(String),

    #[error("not found: {0}")]
    NotFound(String),

    #[error("conflict: {0}")]
    Conflict(String),

    #[error("unsupported: {0}")]
    Unsupported(String),

    #[error("internal error: {0}")]
    Internal(String),
}

#[derive(Debug, Serialize)]
struct ErrorBody {
    error: String,
}

impl AppError {
    pub fn status(&self) -> StatusCode {
        match self {
            AppError::BadRequest(_) => StatusCode::BAD_REQUEST,
            AppError::Unauthorized(_) => StatusCode::UNAUTHORIZED,
            AppError::Forbidden(_) => StatusCode::FORBIDDEN,
            AppError::NotFound(_) => StatusCode::NOT_FOUND,
            AppError::Conflict(_) => StatusCode::CONFLICT,
            AppError::Unsupported(_) => StatusCode::NOT_IMPLEMENTED,
            AppError::Internal(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let status = self.status();
        let message = match &self {
            AppError::Internal(_) => "internal error".to_string(),
            other => other.to_string(),
        };
        if matches!(self, AppError::Internal(_)) {
            tracing::error!(error = %self, "internal error");
        }
        (status, Json(ErrorBody { error: message })).into_response()
    }
}

impl From<reqwest::Error> for AppError {
    fn from(e: reqwest::Error) -> Self {
        AppError::Internal(format!("http client error: {e}"))
    }
}
