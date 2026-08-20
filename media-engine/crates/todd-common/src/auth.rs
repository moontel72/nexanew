//! Bearer-token authentication shared by Studio and Broadcaster.
//!
//! Primary flow: Laravel mints short-lived HS256 JWTs (see
//! `docs/04-laravel-integration.md`, using `firebase/php-jwt`) signed with
//! the same `MEDIA_ENGINE_JWT_SECRET` the Rust engine verifies against.
//! Verification is fully local (HMAC + serde), so a WHIP ingest is
//! authenticated in microseconds with no network hop — critical for the
//! sub-second ingest path.
//!
//! Fallback flow: when `LARAVEL_INTROSPECTION_URL` is configured, tokens
//! that fail JWT verification (e.g. Laravel Sanctum opaque tokens) are
//! validated by Laravel's introspection endpoint instead.

use axum::http::{uri::Uri, HeaderMap};
use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::error::AppError;

/// Audience expected in every token ("aud" claim).
pub const AUDIENCE: &str = "todd-media-engine";

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TokenRole {
    /// Server-to-server callers (Laravel). Can manage rooms and forwarders.
    Admin,
    /// A camera publishing into a room. Scoped to one (room, camera).
    Publisher,
    /// A client authorized to watch a room.
    Viewer,
}

/// Claim set minted by Laravel (PHP) and verified by the Rust engine.
/// Keep this struct in lockstep with `MediaEngineTokenService` in
/// `docs/04-laravel-integration.md`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TokenClaims {
    pub iss: String,
    pub aud: String,
    /// Subject: user id, device id, or "laravel" for server-to-server.
    pub sub: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub room_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub camera_id: Option<String>,
    pub role: TokenRole,
    /// Fine-grained permissions (Phase-1 SSO). Tokens minted before this
    /// field existed deserialize with an empty list — legacy Laravel admin
    /// tokens keep passing `require_perm` via the empty-perms rule.
    #[serde(default)]
    pub perms: Vec<String>,
    pub iat: i64,
    pub exp: i64,
    pub jti: String,
}

impl TokenClaims {
    /// Requires a specific permission. Legacy server-to-server Laravel
    /// admin tokens (minted without a `perms` claim) keep working: an
    /// admin token with an empty perms list passes any permission check.
    /// Non-admin tokens (or admin tokens carrying an explicit perms list)
    /// must list the permission explicitly.
    pub fn require_perm(&self, perm: &str) -> Result<(), AppError> {
        if self.role == TokenRole::Admin && self.perms.is_empty() {
            return Ok(());
        }
        if self.perms.iter().any(|p| p.as_str() == perm) {
            return Ok(());
        }
        Err(AppError::Forbidden(format!(
            "token lacks required permission `{perm}`"
        )))
    }

    /// Requires `role` — admin tokens always pass (they outrank).
    pub fn require_role(&self, role: TokenRole) -> Result<(), AppError> {
        if self.role == role || self.role == TokenRole::Admin {
            Ok(())
        } else {
            Err(AppError::Forbidden(format!(
                "token role {:?} is not allowed here",
                self.role
            )))
        }
    }

    /// Requires `role` and room scope (no camera scope — used by viewer
    /// tokens watching a whole room via WHEP).
    pub fn require_room(&self, room_id: &str, role: TokenRole) -> Result<(), AppError> {
        if self.role == TokenRole::Admin {
            return Ok(());
        }
        self.require_role(role)?;
        if self.room_id.as_deref() != Some(room_id) {
            return Err(AppError::Forbidden(format!(
                "token is scoped to room {:?}, not {room_id}",
                self.room_id
            )));
        }
        Ok(())
    }

    /// Publisher tokens must be scoped to exactly the room/camera they
    /// publish into. Admin tokens bypass scoping (used by the Studio's
    /// internal calls to a remote Broadcaster).
    pub fn require_scope(
        &self,
        room_id: &str,
        camera_id: &str,
        role: TokenRole,
    ) -> Result<(), AppError> {
        if self.role == TokenRole::Admin {
            return Ok(());
        }
        self.require_role(role)?;
        if self.room_id.as_deref() != Some(room_id) {
            return Err(AppError::Forbidden(format!(
                "token is scoped to room {:?}, not {room_id}",
                self.room_id
            )));
        }
        if self.camera_id.as_deref() != Some(camera_id) {
            return Err(AppError::Forbidden(format!(
                "token is scoped to camera {:?}, not {camera_id}",
                self.camera_id
            )));
        }
        Ok(())
    }
}

/// Mints an HS256 token. Used by Studio (internal admin token for the
/// remote Broadcaster, per-camera ingest tokens) and mirrors the PHP
/// implementation 1:1.
pub fn mint_token(
    secret: &str,
    issuer: &str,
    sub: &str,
    role: TokenRole,
    room_id: Option<&str>,
    camera_id: Option<&str>,
    perms: &[&str],
    ttl_secs: i64,
) -> Result<String, AppError> {
    let now = Utc::now();
    let claims = TokenClaims {
        iss: issuer.to_string(),
        aud: AUDIENCE.to_string(),
        sub: sub.to_string(),
        room_id: room_id.map(str::to_string),
        camera_id: camera_id.map(str::to_string),
        role,
        perms: perms.iter().map(|p| p.to_string()).collect(),
        iat: now.timestamp(),
        exp: (now + Duration::seconds(ttl_secs)).timestamp(),
        jti: Uuid::new_v4().to_string(),
    };
    encode(
        &Header::new(Algorithm::HS256),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .map_err(|e| AppError::Internal(format!("token minting failed: {e}")))
}

/// Verifies signature, audience, issuer and expiry.
pub fn verify_token(token: &str, secret: &str, issuer: &str) -> Result<TokenClaims, AppError> {
    let mut validation = Validation::new(Algorithm::HS256);
    validation.set_audience(&[AUDIENCE]);
    validation.set_issuer(&[issuer]);
    let data = decode::<TokenClaims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &validation,
    )
    .map_err(|e| AppError::Unauthorized(format!("token verification failed: {e}")))?;
    Ok(data.claims)
}

/// Extracts the bearer token from the `Authorization` header, falling back
/// to the `?token=` query parameter (some WHIP client SDKs can only send
/// query tokens).
pub fn extract_token(headers: &HeaderMap, uri: &Uri) -> Option<String> {
    bearer_from_headers(headers).or_else(|| query_token(uri))
}

fn bearer_from_headers(headers: &HeaderMap) -> Option<String> {
    let value = headers
        .get(axum::http::header::AUTHORIZATION)?
        .to_str()
        .ok()?;
    let (scheme, token) = value.split_once(' ')?;
    if !scheme.eq_ignore_ascii_case("bearer") {
        return None;
    }
    Some(token.trim().to_string())
}

fn query_token(uri: &Uri) -> Option<String> {
    let query = uri.query()?;
    for (key, value) in url::form_urlencoded::parse(query.as_bytes()) {
        if key == "token" {
            return Some(value.into_owned());
        }
    }
    None
}

/// Settings needed to authenticate a request.
#[derive(Debug, Clone)]
pub struct AuthConfig {
    pub jwt_secret: String,
    pub jwt_issuer: String,
    pub introspection_url: Option<String>,
    pub client: reqwest::Client,
}

/// Full authentication entry point used by every protected handler:
///
/// 1. JWT verification is attempted first (local, sub-millisecond).
/// 2. If it fails and an introspection URL is configured, the token is
///    treated as opaque and validated by Laravel instead.
pub async fn authenticate(
    config: &AuthConfig,
    headers: &HeaderMap,
    uri: &Uri,
) -> Result<TokenClaims, AppError> {
    let Some(token) = extract_token(headers, uri) else {
        return Err(AppError::Unauthorized("missing bearer token".to_string()));
    };

    match verify_token(&token, &config.jwt_secret, &config.jwt_issuer) {
        Ok(claims) => Ok(claims),
        Err(jwt_error) => match &config.introspection_url {
            Some(url) => introspect(config, url, &token).await.map_err(|e| {
                AppError::Unauthorized(format!("{jwt_error}; introspection failed: {e}"))
            }),
            None => Err(jwt_error),
        },
    }
}

#[derive(Debug, Deserialize)]
struct IntrospectionResponse {
    active: bool,
    #[serde(default)]
    sub: Option<String>,
    #[serde(default)]
    role: Option<String>,
    #[serde(default)]
    room_id: Option<String>,
    #[serde(default)]
    camera_id: Option<String>,
    #[serde(default)]
    perms: Option<Vec<String>>,
}

/// POST {token} to Laravel's introspection endpoint and map the response
/// onto our claim set. Opaque tokens carry no verifiable expiry, so the
/// mapped claims are trusted for one minute before re-introspecting.
async fn introspect(config: &AuthConfig, url: &str, token: &str) -> Result<TokenClaims, AppError> {
    let resp = config
        .client
        .post(url)
        .json(&serde_json::json!({ "token": token }))
        .send()
        .await
        .map_err(|e| AppError::Unauthorized(format!("introspection request failed: {e}")))?;

    if resp.status() == axum::http::StatusCode::UNAUTHORIZED
        || resp.status() == axum::http::StatusCode::NOT_FOUND
    {
        return Err(AppError::Unauthorized(
            "token rejected by issuer".to_string(),
        ));
    }

    let body: IntrospectionResponse = resp
        .json()
        .await
        .map_err(|e| AppError::Unauthorized(format!("invalid introspection response: {e}")))?;
    if !body.active {
        return Err(AppError::Unauthorized("token is not active".to_string()));
    }

    let now = Utc::now();
    Ok(TokenClaims {
        iss: config.jwt_issuer.clone(),
        aud: AUDIENCE.to_string(),
        sub: body.sub.unwrap_or_else(|| "introspected".to_string()),
        room_id: body.room_id,
        camera_id: body.camera_id,
        role: match body.role.as_deref() {
            Some("admin") => TokenRole::Admin,
            Some("publisher") => TokenRole::Publisher,
            _ => TokenRole::Viewer,
        },
        perms: body.perms.unwrap_or_default(),
        iat: now.timestamp(),
        exp: (now + Duration::seconds(60)).timestamp(),
        jti: Uuid::new_v4().to_string(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn claims(role: TokenRole, perms: Vec<String>) -> TokenClaims {
        TokenClaims {
            iss: "traceodd".to_string(),
            aud: AUDIENCE.to_string(),
            sub: "test".to_string(),
            room_id: None,
            camera_id: None,
            role,
            perms,
            iat: 0,
            exp: 0,
            jti: "test-jti".to_string(),
        }
    }

    #[test]
    fn require_perm_passes_legacy_admin_with_empty_perms() {
        // Server-to-server Laravel admin tokens minted before the perms
        // claim existed must keep passing every permission check.
        let claims = claims(TokenRole::Admin, vec![]);
        assert!(claims.require_perm("studio_director").is_ok());
    }

    #[test]
    fn require_perm_passes_when_permission_is_present() {
        let claims = claims(TokenRole::Viewer, vec!["studio_director".to_string()]);
        assert!(claims.require_perm("studio_director").is_ok());
    }

    #[test]
    fn require_perm_rejects_when_permission_is_missing() {
        // An admin token carrying an explicit perms list must still list
        // the permission: the legacy bypass only applies to empty perms.
        let claims = claims(TokenRole::Admin, vec!["other_perm".to_string()]);
        let err = claims.require_perm("studio_director").unwrap_err();
        assert!(matches!(err, AppError::Forbidden(_)));
    }

    #[test]
    fn verify_token_accepts_claims_without_perms_field() {
        // Simulates a token minted by the pre-SSO PHP service: no `perms`
        // claim in the payload. `#[serde(default)]` must fill it in.
        let secret = "test-secret";
        let issuer = "traceodd";
        let now = Utc::now().timestamp();
        let payload = serde_json::json!({
            "iss": issuer,
            "aud": AUDIENCE,
            "sub": "legacy-laravel",
            "role": "admin",
            "iat": now,
            "exp": now + 3600,
            "jti": "legacy-jti",
        });
        let token = encode(
            &Header::new(Algorithm::HS256),
            &payload,
            &EncodingKey::from_secret(secret.as_bytes()),
        )
        .expect("legacy token encoding failed");

        let claims = verify_token(&token, secret, issuer).expect("legacy token must verify");
        assert_eq!(claims.role, TokenRole::Admin);
        assert!(claims.perms.is_empty());
        assert!(claims.require_perm("studio_director").is_ok());
    }
}
