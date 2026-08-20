//! HTTP surfaces of the telemetry system.
//!
//! - [`metrics`] — Prometheus text exposition, mounted at `GET /metrics`.
//! - [`ws_feed`] — WebSocket push feed, mounted at
//!   `GET /api/v1/telemetry/ws`. Every `ws_interval_ms` the server sends
//!   one JSON [`TelemetrySnapshot`](crate::TelemetrySnapshot) text frame.
//!
//! Both handlers are generic over the host's application state through
//! [`HasTelemetry`], so the Studio and the standalone Broadcaster mount
//! them without any adapter plumbing.

use std::sync::Arc;

use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        State,
    },
    http::header,
    response::{IntoResponse, Response},
};
use futures_util::StreamExt;
use serde::Deserialize;

use crate::{DeviceTelemetryEntry, Telemetry};

/// Implemented by the host application state (Studio `AppState`,
/// Broadcaster `WhipState`) so the telemetry handlers stay host-agnostic.
pub trait HasTelemetry: Clone + Send + Sync + 'static {
    fn telemetry(&self) -> &Arc<Telemetry>;
}

/// `GET /metrics` — Prometheus text exposition.
pub async fn metrics<S: HasTelemetry>(State(state): State<S>) -> Response {
    let body = state.telemetry().render_prometheus();
    (
        [(
            header::CONTENT_TYPE,
            "text/plain; version=0.0.4; charset=utf-8",
        )],
        body,
    )
        .into_response()
}

/// `GET /api/v1/telemetry/ws` — WebSocket diagnostics feed.
pub async fn ws_feed<S: HasTelemetry>(ws: WebSocketUpgrade, State(state): State<S>) -> Response {
    ws.on_upgrade(move |socket| serve_feed(socket, state))
}

async fn serve_feed<S: HasTelemetry>(mut socket: WebSocket, state: S) {
    let telemetry = Arc::clone(state.telemetry());
    let interval_ms = telemetry.ws_interval_ms;

    // Push an immediate snapshot so new clients see data without waiting
    // a full interval.
    let initial = snapshot_json(&telemetry);
    match initial {
        Some(json) => {
            if socket.send(Message::Text(json.into())).await.is_err() {
                return;
            }
        }
        None => return,
    }

    let mut tick = tokio::time::interval(std::time::Duration::from_millis(interval_ms));
    loop {
        tokio::select! {
            _ = tick.tick() => {
                let Some(json) = snapshot_json(&telemetry) else { continue };
                if socket.send(Message::Text(json.into())).await.is_err() {
                    break;
                }
            }
            message = socket.next() => {
                match message {
                    Some(Ok(Message::Close(_))) | None => break,
                    // Keep the connection alive on client pings.
                    Some(Ok(Message::Ping(payload))) => {
                        if socket.send(Message::Pong(payload)).await.is_err() {
                            break;
                        }
                    }
                    // Broadcasters push device health over this feed:
                    // {"kind":"device_telemetry","room_id":...,"camera_id":...}
                    Some(Ok(Message::Text(text))) => handle_inbound(&telemetry, &text),
                    Some(Ok(_)) => {}
                    Some(Err(_)) => break,
                }
            }
        }
    }
}

/// Serializes a snapshot; logs (once per failure) if serialization ever
/// breaks — the feed must not take the connection down with it.
fn snapshot_json(telemetry: &Telemetry) -> Option<String> {
    match serde_json::to_string(&telemetry.snapshot()) {
        Ok(json) => Some(json),
        Err(e) => {
            tracing::warn!(error = %e, "telemetry snapshot serialization failed");
            None
        }
    }
}

/// Inbound broadcaster device health payload.
#[derive(Debug, Deserialize)]
struct InboundTelemetry {
    kind: String,
    #[serde(default)]
    room_id: String,
    #[serde(default)]
    camera_id: String,
    #[serde(default)]
    battery_pct: Option<u8>,
    #[serde(default)]
    fps: Option<f32>,
    #[serde(default)]
    uplink_kbps: Option<f32>,
    #[serde(default)]
    dropped_frames: Option<u64>,
    #[serde(default)]
    quality: Option<String>,
}

/// Records an inbound device telemetry frame. Unknown payloads are
/// ignored; the feed never errors on client traffic.
fn handle_inbound(telemetry: &Telemetry, text: &str) {
    let Ok(message) = serde_json::from_str::<InboundTelemetry>(text) else {
        return;
    };
    if message.kind != "device_telemetry" {
        return;
    }
    if message.room_id.is_empty() || message.camera_id.is_empty() {
        return;
    }
    telemetry.record_device(DeviceTelemetryEntry {
        room_id: message.room_id,
        camera_id: message.camera_id,
        battery_pct: message.battery_pct,
        fps: message.fps,
        uplink_kbps: message.uplink_kbps,
        dropped_frames: message.dropped_frames,
        quality: message.quality,
    });
}
