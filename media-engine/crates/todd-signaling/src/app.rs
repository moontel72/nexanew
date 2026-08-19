//! Router assembly for the Studio API.

use std::sync::Arc;

use axum::{
    http::{header, HeaderValue, Method},
    routing::{get, post, put},
    Router,
};
use todd_telemetry::feed::HasTelemetry;
use todd_telemetry::Telemetry;
use tower_http::{
    cors::CorsLayer,
    request_id::{MakeRequestUuid, PropagateRequestIdLayer, SetRequestIdLayer},
    trace::TraceLayer,
};

use crate::{routes, state::AppState};

use axum::extract::FromRef;

impl HasTelemetry for AppState {
    fn telemetry(&self) -> &Arc<Telemetry> {
        &self.telemetry
    }
}

/// The studio router carries `Arc<AppState>`; axum's `State` extractor
/// resolves `AppState` from it via `FromRef`, so the telemetry handlers
/// (parameterized on `AppState`) stay host-agnostic.
impl FromRef<Arc<AppState>> for AppState {
    fn from_ref(input: &Arc<AppState>) -> Self {
        input.as_ref().clone()
    }
}

pub fn build(state: Arc<AppState>) -> Router {
    let mut router = Router::new()
        .route("/healthz", get(routes::health::healthz))
        .route("/readyz", get(routes::health::readyz))
        .route("/metrics", get(todd_telemetry::feed::metrics::<AppState>))
        .route(
            "/api/v1/telemetry/ws",
            get(todd_telemetry::feed::ws_feed::<AppState>),
        )
        .nest("/api/v1", api_routes(state.clone()))
        .layer(TraceLayer::new_for_http())
        .layer(SetRequestIdLayer::x_request_id(MakeRequestUuid))
        .layer(PropagateRequestIdLayer::x_request_id())
        .with_state(state.clone());

    // CORS is irrelevant in Phase 1 (same-origin behind nginx). It is only
    // enabled when explicitly configured — required in Phase 2 for browser
    // clients on the app origin calling the media origin directly.
    if let Some(cors) = build_cors(&state.settings.cors_allowed_origins) {
        router = router.layer(cors);
    }
    router
}

fn api_routes(state: Arc<AppState>) -> Router<Arc<AppState>> {
    Router::new()
        .route("/room/create", post(routes::rooms::create_room))
        .route("/room/list", get(routes::rooms::list_rooms))
        .route(
            "/room/{room_id}",
            get(routes::rooms::get_room).delete(routes::rooms::delete_room),
        )
        .route("/room/{room_id}/forward", post(routes::rooms::add_forward))
        .route("/room/{room_id}/camera", post(routes::rooms::add_camera))
        .route(
            "/room/{room_id}/camera/{camera_id}",
            put(routes::rooms::update_camera).delete(routes::rooms::remove_camera),
        )
        .route(
            "/whip/ingest/{room_id}/{camera_id}",
            post(routes::whip::ingest),
        )
        .route(
            "/whip/session/{session_id}",
            axum::routing::delete(routes::whip::close_session),
        )
        .route(
            "/whep/watch/{room_id}/{camera_id}",
            post(routes::whep::watch),
        )
        .route(
            "/whep/session/{session_id}",
            axum::routing::delete(routes::whep::close_watch),
        )
        .route(
            "/replay/trigger",
            axum::routing::post(routes::replay::trigger_replay),
        )
        .route("/replay/list", get(routes::replay::list_replays))
        .route(
            "/replay/{replay_id}",
            axum::routing::delete(routes::replay::close_replay),
        )
        .route(
            "/replay/{replay_id}/export",
            axum::routing::post(routes::replay::export_replay),
        )
        .route(
            "/replay/watch/{replay_id}/{camera_id}",
            axum::routing::post(routes::replay::watch_replay),
        )
        .route(
            "/program/transition",
            axum::routing::post(routes::program::transition),
        )
        .route("/program/{room_id}", get(routes::program::get))
        .route(
            "/whep/program/{room_id}",
            axum::routing::post(routes::program::watch),
        )
        .route("/cricket/live/{match_id}", get(routes::scoreboard::live))
        .route("/cricket/ws", get(routes::scoreboard::ws))
        .route(
            "/cricket/config",
            get(routes::scoreboard::get_config).put(routes::scoreboard::put_config),
        )
        .route("/control/ws", get(routes::control_ws::ws_handler))
        .with_state(state)
}

fn build_cors(origins: &[String]) -> Option<CorsLayer> {
    let parsed: Vec<HeaderValue> = origins
        .iter()
        .filter_map(|o| HeaderValue::from_str(o).ok())
        .collect();
    if parsed.is_empty() {
        return None;
    }
    Some(
        CorsLayer::new()
            .allow_origin(parsed)
            .allow_methods([Method::GET, Method::POST, Method::DELETE, Method::OPTIONS])
            .allow_headers([
                header::AUTHORIZATION,
                header::CONTENT_TYPE,
                header::LOCATION,
            ])
            .expose_headers([header::LOCATION]),
    )
}
