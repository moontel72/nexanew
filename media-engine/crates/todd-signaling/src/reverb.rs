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

    // Laravel broadcasts via `ShouldBroadcastNow` + `broadcastWith()`, and
    // Reverb wraps that payload one level deeper than a bare broadcast:
    // the frame arrives as `{"data": {"data": {"match_id": ...}}}`.
    // Unwrap that inner envelope so consumers see the same flat shape
    // they would get from any other Pusher client. Mirrored events (flat
    // `data`) are left untouched, so both wire shapes work.
    let data = unwrap_broadcast_envelope(&event, data);

    Ok(Some(ReverbEvent {
        channel,
        event,
        data,
    }))
}

/// Flattens Reverb's nested broadcast envelope.
///
/// `{"data": {"match_id": "..."}}` becomes `{"match_id": "..."}`.
///
/// Only the unambiguous shape is unwrapped. A payload is treated as an
/// envelope when it has exactly one key, `data`, holding an object that
/// carries this event's own discriminator (`match_id`, or `config` for
/// the cricket-config events). Everything else — including payloads that
/// merely happen to have a `data` field — is returned unchanged.
///
/// Shape alone cannot decide this: `{"data": {"x": 1}}` and
/// `{"data": {"match_id": "m"}}` are structurally identical before the
/// event name is taken into account.
fn unwrap_broadcast_envelope(event: &str, data: Value) -> Value {
    if !expects_match_id(event) {
        return data;
    }

    let Value::Object(map) = &data else {
        return data;
    };

    if map.len() != 1 {
        return data;
    }

    let Some(Value::Object(inner)) = map.get("data") else {
        return data;
    };

    if inner.contains_key("match_id") {
        return Value::Object(inner.clone());
    }

    data
}

/// Events whose consumer resolves `data.match_id` (see the `run_push_session`
/// dispatch). Their payloads are the only ones that get unwrapped.
fn expects_match_id(event: &str) -> bool {
    matches!(event, "match.context.selected" | "match.context.cleared")
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The exact frame Laravel + Reverb produce for
    /// `CricketMatchContextSelected` (`ShouldBroadcastNow` with
    /// `broadcastWith()`). The payload is nested one level deeper than the
    /// engine's consumer expects, which is what broke active-match
    /// discovery: `data.match_id` was null while the real id sat in
    /// `data.data.match_id`.
    const NESTED_CONTEXT_FRAME: &str = r#"{
        "event": "match.context.selected",
        "channel": "cricket.context",
        "data": "{\"data\":{\"match_id\":\"a2c0880f-cc5b-40d9-8d5c-6ffa3916e021\",\"manager_id\":\"mgr-1\",\"selected_at\":\"2026-09-15T21:21:06+00:00\"}}"
    }"#;

    #[test]
    fn nested_broadcast_envelope_is_unwrapped() {
        let event = parse_frame(NESTED_CONTEXT_FRAME)
            .expect("frame parses")
            .expect("application event");

        assert_eq!(event.channel, "cricket.context");
        assert_eq!(event.event, "match.context.selected");
        // The consumer reads exactly this path.
        assert_eq!(
            event.data.get("match_id").and_then(Value::as_str),
            Some("a2c0880f-cc5b-40d9-8d5c-6ffa3916e021")
        );
        assert_eq!(
            event.data.get("manager_id").and_then(Value::as_str),
            Some("mgr-1")
        );
    }

    #[test]
    fn flat_payload_is_left_untouched() {
        let frame = r#"{
            "event": "score.updated",
            "channel": "cricket.match.m-1",
            "data": "{\"match_id\":\"m-1\",\"innings\":{}}"
        }"#;

        let event = parse_frame(frame).unwrap().unwrap();
        assert_eq!(
            event.data.get("match_id").and_then(Value::as_str),
            Some("m-1")
        );
    }

    #[test]
    fn single_key_data_field_is_not_mistaken_for_an_envelope() {
        // `{"data": {"x": 1}}` must survive intact — unwrapping it would
        // silently destroy a payload that legitimately has a `data` field.
        // Shape alone cannot tell these apart, so the event name decides.
        let data = serde_json::json!({ "data": { "x": 1 } });
        assert_eq!(
            unwrap_broadcast_envelope("score.updated", data.clone()),
            data
        );
    }

    #[test]
    fn envelope_without_a_match_id_is_not_unwrapped() {
        // Right event, wrong inner payload: leave it alone rather than
        // hand the consumer an object with no match_id at all.
        let data = serde_json::json!({ "data": { "x": 1 } });
        assert_eq!(
            unwrap_broadcast_envelope("match.context.selected", data.clone()),
            data
        );
    }

    #[test]
    fn non_object_and_multi_key_payloads_are_untouched() {
        let scalar = serde_json::json!("plain");
        assert_eq!(
            unwrap_broadcast_envelope("match.context.selected", scalar.clone()),
            scalar
        );

        let multi = serde_json::json!({ "data": { "match_id": "m" }, "other": 2 });
        assert_eq!(
            unwrap_broadcast_envelope("match.context.selected", multi.clone()),
            multi
        );
    }

    #[test]
    fn cleared_context_envelope_is_unwrapped_too() {
        let frame = r#"{
            "event": "match.context.cleared",
            "channel": "cricket.context",
            "data": "{\"data\":{\"match_id\":\"m-9\"}}"
        }"#;

        let event = parse_frame(frame).unwrap().unwrap();
        assert_eq!(
            event.data.get("match_id").and_then(Value::as_str),
            Some("m-9")
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
}
