//! T-Odd Studio — Axum control plane for the T-Odd media engine.
//!
//! Phase 1 (shared VPS): the Broadcaster engine runs embedded in this
//! process (`MEDIA_PLANE=embedded`) behind nginx on 127.0.0.1:8080.
//! Phase 2 (dedicated media server): flip `MEDIA_PLANE=remote` and this
//! binary proxies WHIP/forwarding to the standalone Broadcaster.

mod app;
mod media_plane;
mod routes;
mod scoreboard;
mod state;
mod store;

use std::sync::Arc;

use anyhow::Context;
use todd_common::config::Settings;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv().ok();
    init_tracing();

    let settings = Settings::from_env()?;
    let listen = settings.studio_listen;

    let state = Arc::new(state::AppState::new(settings).await?);
    let app = app::build(state);

    let listener = tokio::net::TcpListener::bind(listen)
        .await
        .with_context(|| format!("binding {listen}"))?;
    tracing::info!(addr = %listen, "todd-studio listening");
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
