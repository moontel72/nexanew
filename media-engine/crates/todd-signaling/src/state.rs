//! Shared application state: room store, auth config and the media plane.

use std::{collections::HashMap, sync::Arc, time::Duration};

use chrono::{Duration as ChronoDuration, Utc};
use todd_common::{
    auth::{mint_token, AuthConfig, TokenRole},
    config::{MediaPlaneMode, Settings},
    error::AppError,
    types::{CameraSpec, Room},
};
use todd_sfu::engine::Engine;
use todd_telemetry::Telemetry;

use crate::{
    media_plane::{EmbeddedMediaPlane, MediaPlane, RemoteMediaPlane},
    routes::control_ws::ControlHub,
    scoreboard::{self, ScoreboardHub, ScoreboardSettings},
    store::{self, RoomStore},
};

/// Shared application state. `Clone`d per-request via `Arc`s — the
/// `Clone` bound is also required by the telemetry handlers
/// (`HasTelemetry`).
#[derive(Clone)]
pub struct AppState {
    pub settings: Settings,
    pub auth: AuthConfig,
    /// Room + session persistence (in-memory or Redis, see `store`).
    pub store: Arc<dyn RoomStore>,
    pub plane: Arc<dyn MediaPlane>,
    /// Engine-wide telemetry (metrics registry + diagnostics feed).
    pub telemetry: Arc<Telemetry>,
    /// Live cricket scoreboard cache + poller.
    pub scoreboard: Arc<ScoreboardHub>,
    /// Control-plane event bus for director WebSocket clients.
    pub control: Arc<ControlHub>,
}

impl AppState {
    pub async fn new(settings: Settings) -> Result<Self, AppError> {
        let client = reqwest::Client::builder()
            .timeout(Duration::from_secs(10))
            .build()
            .map_err(|e| AppError::Internal(format!("http client setup failed: {e}")))?;

        let auth = AuthConfig {
            jwt_secret: settings.jwt_secret.clone(),
            jwt_issuer: settings.jwt_issuer.clone(),
            introspection_url: settings.laravel_introspection_url.clone(),
            client: client.clone(),
        };

        let store = store::build(&settings).await?;

        let telemetry = Arc::new(Telemetry::new(
            settings.telemetry_ws_interval_ms,
            settings.telemetry_sample_ms,
        ));

        // The control hub must exist before the scoreboard sync tasks so
        // they can publish `score_updated` / config changes to director
        // panels (Phase 1 push pipeline).
        let control = Arc::new(ControlHub::new());

        // The media plane must exist BEFORE the scoreboard sync tasks:
        // scoring events trigger auto-tagged replays on it (Phase 3).
        let plane: Arc<dyn MediaPlane> = match settings.media_plane {
            MediaPlaneMode::Embedded => {
                let engine = Arc::new(Engine::new(
                    Engine::config_from_settings(&settings)?,
                    telemetry.clone(),
                )?);
                engine.spawn_sampler();
                Arc::new(EmbeddedMediaPlane { engine })
            }
            MediaPlaneMode::Remote => {
                // Internal admin token used to call the remote Broadcaster's
                // control endpoints (rotated on every Studio restart).
                let internal_token = mint_token(
                    &settings.jwt_secret,
                    &settings.jwt_issuer,
                    "todd-studio",
                    TokenRole::Admin,
                    None,
                    None,
                    &[],
                    3600,
                )?;
                Arc::new(RemoteMediaPlane {
                    base: settings.broadcaster_url.trim_end_matches('/').to_string(),
                    internal_token,
                    client: client.clone(),
                })
            }
        };

        let scoreboard = scoreboard::spawn_sync(
            ScoreboardSettings::new(
                settings.cricket_manager_url.clone(),
                settings.cricket_manager_match_ids.clone(),
                settings.cricket_manager_poll_ms,
                settings.cricket_manager_ws_url.clone(),
            ),
            client.clone(),
            control.clone(),
            plane.clone(),
            store.clone(),
        );

        Ok(Self {
            settings,
            auth,
            store,
            plane,
            telemetry,
            scoreboard,
            control,
        })
    }
}

/// Builds a room with per-camera ingest tokens and a viewer token.
pub fn build_room(
    state: &AppState,
    name: String,
    camera_specs: Vec<CameraSpec>,
    ttl_secs: u64,
) -> Result<(Room, HashMap<String, String>, String), AppError> {
    let cameras: Vec<String> = if camera_specs.is_empty() {
        vec!["default".to_string()]
    } else {
        camera_specs.iter().map(|spec| spec.id.clone()).collect()
    };

    let now = Utc::now();
    let room_id = uuid::Uuid::new_v4().to_string();
    let room = Room {
        id: room_id.clone(),
        name,
        created_at: now,
        expires_at: now + ChronoDuration::seconds(ttl_secs as i64),
        cameras: camera_specs
            .into_iter()
            .map(|spec| spec.into_info())
            .collect(),
    };

    let mut ingest_tokens = HashMap::new();
    for camera in &cameras {
        let token = mint_token(
            &state.settings.jwt_secret,
            &state.settings.jwt_issuer,
            camera,
            TokenRole::Publisher,
            Some(&room_id),
            Some(camera),
            &[],
            state.settings.ingest_token_ttl_secs,
        )?;
        ingest_tokens.insert(camera.clone(), token);
    }

    let viewer_token = mint_token(
        &state.settings.jwt_secret,
        &state.settings.jwt_issuer,
        "viewer",
        TokenRole::Viewer,
        Some(&room_id),
        None,
        &[],
        ttl_secs as i64,
    )?;

    Ok((room, ingest_tokens, viewer_token))
}

/// Mints the room-scoped publisher token for a newly added camera.
pub fn mint_camera_ingest_token(
    state: &AppState,
    room_id: &str,
    camera_id: &str,
) -> Result<String, AppError> {
    mint_token(
        &state.settings.jwt_secret,
        &state.settings.jwt_issuer,
        camera_id,
        TokenRole::Publisher,
        Some(room_id),
        Some(camera_id),
        &[],
        state.settings.ingest_token_ttl_secs,
    )
}
