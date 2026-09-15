//! Minimal Pusher-protocol client for Laravel Reverb.
//!
//! The media engine consumes the SAME realtime feed as the Flutter clients
//! (`cricket.match.{id}` channels) instead of polling the manager REST API.
//! Push events act as change signals; the authoritative state is then
//! pulled once from `GET /api/v1/cricket/live/{match_id}` (see
//! `scoreboard::fetch_match`). This keeps the scoreboard mapping identical
//! for both transports and gives us sub-100ms context/score propagation.
//!
//! Protocol subset implemented (protocol 7, no auth):
//!   - `pusher:subscribe`          → subscribe to a public channel
//!   - `pusher:ping` / `pusher:pong` → heartbeat (interval configurable)
//!   - event frames                → `{channel, event, data}` returned
//!
//! Nothing here is hardcoded: connection URL, app key and path all come
//! from the runtime config (resolved from the manager's `realtime-config`
//! endpoint in `scoreboard.rs`).

use std::time::{Duration, Instant};

use futures_util::{SinkExt, StreamExt};
use serde_json::Value;
use tokio_tungstenite::tungstenite::Message;

/// One parsed application event from a subscribed channel.
#[derive(Debug, Clone)]
pub struct ReverbEvent {
    pub channel: String,
    pub event: String,
    pub data: Value,
}

/// Connected Reverb socket. Read and write halves are split so the
/// driver loop can send heartbeats while waiting for events.
pub struct ReverbClient {
    write: futures_util::stream::SplitSink<
        tokio_tungstenite::WebSocketStream<
            tokio_tungstenite::MaybeTlsStream<tokio::net::TcpStream>,
        >,
        Message,
    >,
    read: futures_util::stream::SplitStream<
        tokio_tungstenite::WebSocketStream<
            tokio_tungstenite::MaybeTlsStream<tokio::net::TcpStream>,
        >,
    >,
    ping_interval: Duration,
    last_ping: Instant,
}

impl ReverbClient {
    /// Opens the socket. `url` is the full `ws(s)://host/app/{key}` URL
    /// with Pusher query parameters already attached.
    pub async fn connect(url: &str, ping_interval: Duration) -> Result<Self, String> {
        let (ws, _) = tokio_tungstenite::connect_async(url)
            .await
            .map_err(|e| format!("reverb connect failed: {e}"))?;
        let (write, read) = ws.split();
        Ok(Self {
            write,
            read,
            ping_interval,
            last_ping: Instant::now(),
        })
    }

    /// Sends `pusher:subscribe` for a public channel (idempotent — Reverb
    /// tolerates re-subscribing an already-subscribed channel).
    pub async fn subscribe(&mut self, channel: &str) -> Result<(), String> {
        let frame = serde_json::json!({
            "event": "pusher:subscribe",
            "data": { "channel": channel },
        });
        self.write
            .send(Message::Text(frame.to_string().into()))
            .await
            .map_err(|e| format!("reverb subscribe failed: {e}"))
    }

    /// Sends the Pusher heartbeat frame.
    pub async fn send_ping(&mut self) -> Result<(), String> {
        let frame = serde_json::json!({ "event": "pusher:ping", "data": "{}" });
        self.write
            .send(Message::Text(frame.to_string().into()))
            .await
            .map_err(|e| format!("reverb ping failed: {e}"))
    }

    /// Waits for the next application event.
    ///
    /// Sends a `pusher:ping` whenever the heartbeat interval elapses
    /// (Reverb closes sockets that stay silent past its activity timeout,
    /// typically 30s). Returns `Ok(None)` when the socket closed cleanly.
    pub async fn next_event(&mut self) -> Result<Option<ReverbEvent>, String> {
        loop {
            let remaining = self.ping_interval.saturating_sub(self.last_ping.elapsed());
            if remaining.is_zero() {
                self.send_ping().await?;
                self.last_ping = Instant::now();
                continue;
            }

            let frame = tokio::time::timeout(remaining, self.read.next()).await;
            match frame {
                Ok(Some(Ok(Message::Text(text)))) => {
                    match parse_frame(text.as_str()) {
                        Ok(Some(event)) => return Ok(Some(event)),
                        Ok(None) => continue, // protocol / ack frames
                        Err(e) => {
                            tracing::debug!(error = %e, "reverb: unparsable frame");
                            continue;
                        }
                    }
                }
                Ok(Some(Ok(Message::Ping(payload)))) => {
                    self.write
                        .send(Message::Pong(payload))
                        .await
                        .map_err(|e| format!("reverb pong failed: {e}"))?;
                }
                Ok(Some(Ok(Message::Close(_)))) | Ok(None) => return Ok(None),
                Ok(Some(Err(e))) => return Err(format!("reverb read failed: {e}")),
                Ok(Some(Ok(_))) => {} // binary/other frames — ignore
                Err(_elapsed) => {
                    self.send_ping().await?;
                    self.last_ping = Instant::now();
                }
            }
        }
    }
}

/// Parses one text frame. Protocol frames (`pusher:*`) yield `None`;
/// application events yield `Some(ReverbEvent)`.
fn parse_frame(text: &str) -> Result<Option<ReverbEvent>, String> {
    let value: Value = serde_json::from_str(text).map_err(|e| format!("invalid json: {e}"))?;

    let event = value
        .get("event")
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_string();

    if event.starts_with("pusher:") {
        return Ok(None);
    }

    let channel = value
        .get("channel")
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_string();
    if channel.is_empty() || event.is_empty() {
        return Ok(None);
    }

    // Reverb sends `data` as a JSON string for events; tolerate an
    // already-decoded object (older Pusher SDK variants).
    let data = match value.get("data") {
        Some(Value::String(s)) => serde_json::from_str(s).unwrap_or(Value::Null),
        Some(other) => other.clone(),
        None => Value::Null,
    };

    Ok(Some(ReverbEvent {
        channel,
        event,
        data,
    }))
}
