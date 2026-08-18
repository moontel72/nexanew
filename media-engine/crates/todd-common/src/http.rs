//! Small HTTP helpers shared by the WHIP handlers of both services.

use axum::{
    http::{header, HeaderMap, HeaderValue, StatusCode},
    response::{IntoResponse, Response},
};

use crate::error::AppError;

/// Builds a WHIP-compliant response (RFC draft-ietf-wish-whip):
/// the POST returns 201 + SDP answer + `Location` of the session resource;
/// the DELETE of that resource returns 200.
pub fn whip_response(
    status: StatusCode,
    session_id: Option<&str>,
    body: String,
) -> Result<Response, AppError> {
    session_response(status, "whip", session_id, body)
}

/// Same as [`whip_response`], but the `Location` points at the WHEP
/// session resource (`/api/v1/whep/session/{id}`) instead of the WHIP one.
pub fn whep_response(
    status: StatusCode,
    session_id: Option<&str>,
    body: String,
) -> Result<Response, AppError> {
    session_response(status, "whep", session_id, body)
}

fn session_response(
    status: StatusCode,
    prefix: &str,
    session_id: Option<&str>,
    body: String,
) -> Result<Response, AppError> {
    let mut response = body.into_response();
    *response.status_mut() = status;
    response.headers_mut().insert(
        header::CONTENT_TYPE,
        HeaderValue::from_static("application/sdp"),
    );
    if let Some(id) = session_id {
        let location = HeaderValue::from_str(&format!("/api/v1/{prefix}/session/{id}"))
            .map_err(|e| AppError::Internal(format!("invalid session id: {e}")))?;
        response.headers_mut().insert(header::LOCATION, location);
    }
    Ok(response)
}

/// Extracts the SDP offer body and enforces the `application/sdp`
/// content type required by the WHIP spec.
pub fn sdp_body(headers: &HeaderMap, body: axum::body::Bytes) -> Result<String, AppError> {
    let content_type = headers
        .get(header::CONTENT_TYPE)
        .and_then(|v| v.to_str().ok())
        .unwrap_or("");
    if !content_type
        .to_ascii_lowercase()
        .contains("application/sdp")
    {
        return Err(AppError::BadRequest(
            "expected Content-Type: application/sdp".to_string(),
        ));
    }
    String::from_utf8(body.to_vec())
        .map_err(|e| AppError::BadRequest(format!("body is not UTF-8: {e}")))
}
