//! Standalone T-Odd SFU binary (deployed as the `todd-broadcaster`
//! service; the signaling service reaches it when `MEDIA_PLANE=remote`).

use std::sync::Arc;

use anyhow::Context;
use todd_common::{auth::AuthConfig, config::Settings};
use todd_sfu::{engine::Engine, http_routes};
use todd_telemetry::Telemetry;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();
    init_tracing();

    let settings = Settings::from_env()?;

    let auth = AuthConfig {
        jwt_secret: settings.jwt_secret.clone(),
        jwt_issuer: settings.jwt_issuer.clone(),
        introspection_url: settings.laravel_introspection_url.clone(),
        client: reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(5))
            .build()?,
    };

    let telemetry = Arc::new(Telemetry::new(
        settings.telemetry_ws_interval_ms,
        settings.telemetry_sample_ms,
    ));
    let engine = Arc::new(Engine::new(
        Engine::config_from_settings(&settings)?,
        telemetry.clone(),
    )?);
    engine.spawn_sampler();
    let app = http_routes::routes(engine, auth, telemetry);

    let listener = tokio::net::TcpListener::bind(settings.broadcaster_listen)
        .await
        .with_context(|| format!("binding {}", settings.broadcaster_listen))?;
    tracing::info!(addr = %settings.broadcaster_listen, "todd-broadcaster (todd-sfu) listening");
    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await?;
    Ok(())
}

fn init_tracing() {
    let filter = tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info"));
    tracing_subscriber::fmt().with_env_filter(filter).init();
}

async fn shutdown_signal() {
    let ctrl_c = async {
        tokio::signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
            .expect("failed to install SIGTERM handler")
            .recv()
            .await;
    };
    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
    tracing::info!("shutdown signal received");
}
