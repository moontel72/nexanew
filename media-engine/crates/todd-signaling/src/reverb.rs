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

    // Reverb sends two families of protocol frames that are not
    // application events:
    //   * `pusher:*`            — connection/heartbeat handshakes.
    //   * `pusher_internal:*`   — subscription acks Reverb emits for EVERY
    //                             subscribe (see Reverb's Pusher
    //                             EventHandler, which frames them as
    //                             `'pusher_internal:'.$event`).
    //
    // Only the first family was filtered, so every subscription ack was
    // forwarded to the scoreboard dispatcher. Acks carry no `match_id`,
    // so each one logged "cricket.context event without match_id". That
    // noise masked real discovery failures: the message the engine emitted
    // when it genuinely could not resolve an active match was identical to
    // the one emitted for a harmless subscribe acknowledgement.
    if event.starts_with("pusher:") || event.starts_with("pusher_internal:") {
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

#[cfg(test)]
mod tests {
    use super::*;

    /// Reverb answers every `pusher:subscribe` with
    /// `pusher_internal:subscription_succeeded` (Reverb's Pusher
    /// `EventHandler` frames internal events as `'pusher_internal:'.$event`).
    /// It carries no `match_id`, so before this filter existed the engine
    /// forwarded it to the scoreboard dispatcher and logged
    /// "cricket.context event without match_id - ignored" on every connect.
    #[test]
    fn subscription_ack_is_not_an_application_event() {
        let frame = r#"{
            "event": "pusher_internal:subscription_succeeded",
            "channel": "cricket.context",
            "data": "{}"
        }"#;

        assert!(parse_frame(frame).unwrap().is_none());
    }

    #[test]
    fn presence_events_are_not_application_events() {
        for event in [
            "pusher_internal:member_added",
            "pusher_internal:member_removed",
        ] {
            let frame =
                format!(r#"{{"event":"{event}","channel":"cricket.context","data":"{{}}"}}"#);
            assert!(parse_frame(&frame).unwrap().is_none(), "{event}");
        }
    }

    /// The real payload: Laravel's `broadcastWith()` sits at `data` with
    /// `match_id` at the top level. Nothing wraps it further, which is why
    /// the engine's `data.match_id` lookup is correct as written.
    #[test]
    fn context_selected_payload_resolves_match_id_directly() {
        let frame = r#"{
            "event": "match.context.selected",
            "channel": "cricket.context",
            "data": "{\"match_id\":\"a2c0880f-cc5b-40d9-8d5c-6ffa3916e021\",\"manager_id\":\"mgr-1\",\"selected_at\":\"2026-09-15T22:16:02+00:00\"}"
        }"#;

        let event = parse_frame(frame).unwrap().unwrap();
        assert_eq!(event.channel, "cricket.context");
        assert_eq!(event.event, "match.context.selected");
        assert_eq!(
            event.data.get("match_id").and_then(Value::as_str),
            Some("a2c0880f-cc5b-40d9-8d5c-6ffa3916e021")
        );
    }

    #[test]
    fn protocol_frames_are_not_events() {
        let frame = r#"{"event":"pusher:ping","data":{}}"#;
        assert!(parse_frame(frame).unwrap().is_none());
    }

    #[test]
    fn frames_without_a_channel_are_ignored() {
        let frame = r#"{"event":"some.event","data":"{}"}"#;
        assert!(parse_frame(frame).unwrap().is_none());
    }

    #[test]
    fn object_shaped_data_is_tolerated() {
        let frame = r#"{
            "event": "score.updated",
            "channel": "cricket.match.m-1",
            "data": {"match_id": "m-1"}
        }"#;

        let event = parse_frame(frame).unwrap().unwrap();
        assert_eq!(
            event.data.get("match_id").and_then(Value::as_str),
            Some("m-1")
        );
    }
}
