//! WebRTC PeerConnection lifecycle for a single WHIP ingest.
//!
//! Follows RFC draft-ietf-wish-whip: we are the WHIP server, so we answer
//! the camera's offer with recv-only media, wait for ICE gathering to
//! complete, and return the answer to the caller (which sends it back to
//! the camera over HTTP). Media (SRTP) then flows camera → server over
//! UDP, bypassing nginx entirely.
//!
//! Simulcast: the publisher's `a=simulcast:send` line is parsed and the
//! layer order recorded on the router. Each simulcast layer arrives as
//! its own `on_track` event with a RID (`track.rid()`).

use std::sync::Arc;

use todd_common::error::AppError;
use tokio_util::sync::CancellationToken;
use webrtc::{
    peer_connection::peer_connection_state::RTCPeerConnectionState,
    peer_connection::sdp::session_description::RTCSessionDescription,
    rtp_transceiver::{rtp_receiver::RTCRtpReceiver, RTCRtpTransceiver},
    track::track_remote::TrackRemote,
};
use webrtc_util::Marshal;

use crate::engine::Engine;
use todd_transcode::media::{MediaCodec, RtpChunk};

pub(crate) async fn create(
    engine: &Engine,
    room_id: &str,
    camera_id: &str,
    offer_sdp: &str,
) -> Result<
    (
        Arc<webrtc::peer_connection::RTCPeerConnection>,
        CancellationToken,
        String,
    ),
    AppError,
> {
    let offer = RTCSessionDescription::offer(offer_sdp.to_owned())
        .map_err(|e| AppError::BadRequest(format!("invalid SDP offer: {e}")))?;

    // Record the simulcast layer order before media starts so the router
    // can rank layers (first = lowest) for default viewer selection.
    if let Some(order) = parse_simulcast_order(offer_sdp) {
        engine.router.set_layer_order(room_id, camera_id, order);
    }

    let pc = Arc::new(
        engine
            .api_whip
            .new_peer_connection(webrtc::peer_connection::configuration::RTCConfiguration {
                ice_servers: engine.config.ice_servers.clone(),
                ..Default::default()
            })
            .await
            .map_err(|e| AppError::Internal(format!("peer connection creation failed: {e}")))?,
    );

    // Log gathered candidates so local-dev connectivity problems are
    // visible in the server logs (RUST_LOG=debug).
    pc.on_ice_candidate(Box::new(|candidate| {
        Box::pin(async move {
            if let Some(c) = candidate {
                tracing::debug!(candidate = %c.to_string(), "[whip] local ICE candidate");
            }
        })
    }));

    // Signalled when the session is torn down; cancels the track pumps.
    let shutdown = CancellationToken::new();

    // Incoming media: pump every RTP packet into the track router and
    // the replay ring buffer.
    let (engine_capture, room, camera, pump_shutdown) = (
        engine.clone(),
        room_id.to_owned(),
        camera_id.to_owned(),
        shutdown.clone(),
    );
    pc.on_track(Box::new(
        move |track: Arc<TrackRemote>,
              _receiver: Arc<RTCRtpReceiver>,
              _transceiver: Arc<RTCRtpTransceiver>| {
            let (engine, room, camera, pump_shutdown) = (
                engine_capture.clone(),
                room.clone(),
                camera.clone(),
                pump_shutdown.clone(),
            );
            Box::pin(async move {
                pump_track(track, &engine, &room, &camera, pump_shutdown).await;
            })
        },
    ));

    // Peer state machine:
    // - `Disconnected` is a *warning*, not a death sentence: ICE consent
    //   may re-establish. A grace watchdog closes the session only if
    //   connectivity never returns.
    // - `Failed`/`Closed` prune the session so rooms and the router
    //   never leak state.
    let engine_cb = engine.clone();
    let state_pc = pc.clone();
    pc.on_peer_connection_state_change(Box::new(move |state| {
        let engine = engine_cb.clone();
        let pc = state_pc.clone();
        Box::pin(async move {
            match state {
                RTCPeerConnectionState::Connected => {
                    engine.record_ice_by_pc(&pc, "connected");
                    tracing::info!("[whip] peer connection connected");
                }
                RTCPeerConnectionState::Disconnected => {
                    tracing::warn!("[whip] peer connection disconnected — arming grace watchdog");
                    engine.telemetry.registry.inc("todd_ice_disconnects_total");
                    engine.record_ice_by_pc(&pc, "disconnected");
                    engine.spawn_disconnected_watchdog(pc);
                }
                RTCPeerConnectionState::Failed => {
                    tracing::error!("[whip] peer connection failed");
                    engine.telemetry.registry.inc("todd_ice_failures_total");
                    engine.record_ice_by_pc(&pc, "failed");
                    engine.prune_dead_sessions().await;
                }
                RTCPeerConnectionState::Closed => {
                    engine.record_ice_by_pc(&pc, "closed");
                    engine.prune_dead_sessions().await;
                }
                _ => {}
            }
        })
    }));

    // Standard WHIP answer flow.
    pc.set_remote_description(offer)
        .await
        .map_err(|e| AppError::Internal(format!("set_remote_description failed: {e}")))?;
    let answer = pc
        .create_answer(None)
        .await
        .map_err(|e| AppError::Internal(format!("create_answer failed: {e}")))?;
    pc.set_local_description(answer)
        .await
        .map_err(|e| AppError::Internal(format!("set_local_description failed: {e}")))?;

    // Wait until ICE candidates are collected so the answer the camera
    // receives is complete (trickle ICE is off for WHIP simplicity).
    let _ = pc.gathering_complete_promise().await;

    let local = pc.local_description().await.ok_or_else(|| {
        AppError::Internal("no local description after ICE gathering".to_string())
    })?;

    Ok((pc, shutdown, local.sdp))
}

/// Parses `a=simulcast:send rid=low;mid;high` (and `a=simulcast:send`
/// without an explicit list) from an SDP offer, returning the layer order
/// with the lowest layer first.
fn parse_simulcast_order(sdp: &str) -> Option<Vec<String>> {
    for line in sdp.lines() {
        let line = line.trim();
        if line.starts_with("a=simulcast:send") {
            let rids: Vec<String> = line
                .split_whitespace()
                .find(|token| token.starts_with("rid="))
                .map(|token| {
                    token
                        .trim_start_matches("rid=")
                        .split(';')
                        .filter(|rid| !rid.is_empty())
                        .map(str::to_string)
                        .collect()
                })
                .unwrap_or_default();
            if !rids.is_empty() {
                tracing::info!(?rids, "simulcast layers detected in WHIP offer");
                return Some(rids);
            }
        }
    }
    None
}

/// Reads RTP packets off a remote track and fans them into the router
/// and the replay ring until the track ends or the session is cancelled.
/// Every packet is accounted for in telemetry (ingress bytes +
/// interarrival jitter).
async fn pump_track(
    track: Arc<TrackRemote>,
    engine: &Engine,
    room_id: &str,
    camera_id: &str,
    shutdown: CancellationToken,
) {
    let router = engine.router.clone();
    let codec = MediaCodec::from_mime(&track.codec().capability.mime_type);
    let ssrc = track.ssrc();
    // Simulcast layer id; empty means single-layer.
    let rid = {
        let r = track.rid();
        if r.is_empty() {
            None
        } else {
            Some(r.to_string())
        }
    };
    router.register_track(room_id, camera_id, rid.as_deref(), ssrc, codec);
    tracing::info!(
        room = room_id,
        camera = camera_id,
        ssrc,
        ?rid,
        ?codec,
        "track up"
    );

    loop {
        tokio::select! {
            _ = shutdown.cancelled() => break,
            result = track.read_rtp() => match result {
                Ok((packet, _attributes)) => {
                    let rtp_timestamp = packet.header.timestamp;
                    match packet.marshal() {
                        Ok(bytes) => {
                            router.record_ingress(
                                room_id,
                                camera_id,
                                codec,
                                rtp_timestamp,
                                bytes.len(),
                            );
                            let chunk = RtpChunk { codec, rid: rid.clone(), packet: bytes };
                            router.forward(room_id, camera_id, &chunk);
                            // Zero-copy capture: the ring retains a
                            // reference-counted clone of the payload.
                            engine.replay.capture(
                                room_id,
                                camera_id,
                                Arc::new(todd_replay::Frame::now(
                                    chunk,
                                    rtp_timestamp,
                                )),
                            );
                        }
                        Err(e) => {
                            tracing::warn!(room = room_id, camera = camera_id, error = %e, "rtp marshal failed");
                            break;
                        }
                    }
                }
                Err(e) => {
                    tracing::info!(room = room_id, camera = camera_id, error = %e, "track ended");
                    break;
                }
            },
        }
    }

    router.unregister_track(room_id, camera_id, rid.as_deref(), ssrc);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_simulcast_order() {
        let sdp = "v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\ns=-\r\na=simulcast:send rid=low;mid;high\r\n";
        assert_eq!(
            parse_simulcast_order(sdp),
            Some(vec![
                "low".to_string(),
                "mid".to_string(),
                "high".to_string()
            ])
        );
    }

    #[test]
    fn no_simulcast_line_returns_none() {
        assert_eq!(
            parse_simulcast_order("v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\n"),
            None
        );
    }
}
