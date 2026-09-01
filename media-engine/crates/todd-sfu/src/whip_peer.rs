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
    // Diagnostic: how many ICE candidates did the offer carry? Trickle
    // clients (e.g. Larix) send zero and PATCH them in afterward — the
    // log line makes that visible without packet captures.
    let offer_candidates = offer_sdp
        .lines()
        .filter(|line| line.starts_with("a=candidate:"))
        .count();
    tracing::info!(candidates = offer_candidates, "whip offer received");

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

    // Wait until ICE candidates are collected so the answer the camera
    // receives is complete (trickle ICE is off for WHIP simplicity).
    // The gathering-complete receiver MUST be taken before
    // SetLocalDescription and awaited afterwards (canonical webrtc-rs
    // pattern): taking it after races the gather task, the receive is
    // dropped early, and the answer SDP goes out with ZERO candidates —
    // the phone then has no server candidate to reach, ICE times out
    // (~20s) and the broadcaster hangs in "Connecting…" forever.
    let mut gather_complete = pc.gathering_complete_promise().await;
    pc.set_local_description(answer)
        .await
        .map_err(|e| AppError::Internal(format!("set_local_description failed: {e}")))?;
    let _ = gather_complete.recv().await;

    let local = pc.local_description().await.ok_or_else(|| {
        AppError::Internal("no local description after ICE gathering".to_string())
    })?;

    // The answer must carry server candidates or the publisher can never
    // reach us — log the count loudly so a zero is visible immediately.
    // The type mix + IPs make reachability diagnosable at INFO level:
    // host-only answers with private IPs, or missing srflx/relay entries,
    // point straight at STUN/TURN/firewall problems.
    let candidate_count = local.sdp.matches("a=candidate").count();
    if candidate_count == 0 {
        tracing::error!(
            "WHIP answer contains no ICE candidates — server-side gathering failed; publisher will hang in Connecting…"
        );
    } else {
        let (host, srflx, relay) = candidate_counts(&local.sdp);
        tracing::info!(
            candidates = candidate_count,
            host,
            srflx,
            relay,
            ips = %candidate_ips(&local.sdp).join(","),
            "WHIP answer gathered candidates"
        );
    }

    // Trickle-ICE clients (e.g. Larix) send the offer with zero candidates
    // and the answer MUST echo trickle support (WHIP RFC 9745 §4.6):
    // `a=ice-options:trickle` plus `a=end-of-candidates` (every server
    // candidate is already in the answer; none are trickled later via
    // PATCH responses). Without the echo the client aborts the session
    // without ever PATCHing its candidates — the 40s offer-retry loop.
    let mut answer_sdp = local.sdp;
    let offer_trickle = offer_sdp
        .lines()
        .any(|line| line.trim() == "a=ice-options:trickle");
    if offer_candidates == 0 || offer_trickle {
        answer_sdp = add_trickle_signaling(&answer_sdp);
        tracing::info!("trickle ICE signaled in WHIP answer");
    }

    Ok((pc, shutdown, answer_sdp))
}

/// Injects the WHIP trickle-ICE signaling attributes into an answer that
/// already carries every server candidate. Session-level attributes must
/// precede the first `m=` line; `a=end-of-candidates` tells the client no
/// trickled candidates will follow via PATCH responses.
fn add_trickle_signaling(sdp: &str) -> String {
    let mut attrs: Vec<&str> = Vec::new();
    if !sdp.contains("a=ice-options:trickle") {
        attrs.push("a=ice-options:trickle");
    }
    if !sdp.contains("a=end-of-candidates") {
        attrs.push("a=end-of-candidates");
    }
    if attrs.is_empty() {
        return sdp.to_string();
    }
    // Joined without a trailing CRLF: the m= section starts right after
    // the attributes, no blank line in between.
    let extra = attrs.join("\r\n");
    match sdp.find("\r\nm=") {
        Some(pos) => format!("{}\r\n{}{}", &sdp[..pos], extra, &sdp[pos..]),
        None => format!("{sdp}\r\n{extra}"),
    }
}

/// First declared SSRC of the video m-section in an offer, excluding RTX
/// (`a=ssrc-group:FID`) repair streams. Used to PLI a publisher whose
/// video encoder has not started producing RTP yet.
pub(crate) fn first_video_ssrc(sdp: &str) -> Option<u32> {
    let mut in_video = false;
    let mut rtx_ssrcs: Vec<u32> = Vec::new();
    let mut candidates: Vec<u32> = Vec::new();

    for line in sdp.lines() {
        let line = line.trim();
        if line.starts_with("m=") {
            in_video = line.starts_with("m=video");
            continue;
        }
        if !in_video {
            continue;
        }
        if line.starts_with("a=ssrc-group:FID") {
            if let Some(second) = line.split_whitespace().nth(2) {
                rtx_ssrcs.push(second.parse().unwrap_or(0));
            }
        } else if line.starts_with("a=ssrc:") {
            if let Some(rest) = line.strip_prefix("a=ssrc:") {
                if let Some(digits) = rest.split_whitespace().next() {
                    if let Ok(ssrc) = digits.parse::<u32>() {
                        candidates.push(ssrc);
                    }
                }
            }
        }
    }

    candidates
        .into_iter()
        .find(|ssrc| !rtx_ssrcs.contains(ssrc) && *ssrc != 0)
}

/// Counts the ICE candidate types present in an SDP offer as
/// `(host, srflx, relay)`. Offers that carry host candidates only mean
/// the publisher gathered no public address (no STUN/TURN on the phone),
/// which almost always fails ICE behind carrier NAT — surfacing this in
/// the logs turns a silent 20-second ICE timeout into an actionable
/// diagnosis.
pub(crate) fn candidate_counts(sdp: &str) -> (usize, usize, usize) {
    let (mut host, mut srflx, mut relay) = (0usize, 0usize, 0usize);
    for line in sdp.lines() {
        let line = line.trim();
        if !line.starts_with("a=candidate:") {
            continue;
        }
        let mut tokens = line.split_whitespace();
        while let Some(token) = tokens.next() {
            if token == "typ" {
                match tokens.next() {
                    Some("host") => host += 1,
                    Some("srflx") => srflx += 1,
                    Some("relay") => relay += 1,
                    _ => {}
                }
            }
        }
    }
    (host, srflx, relay)
}

/// Unique addresses carried by `a=candidate:` lines, in SDP order. Seeing
/// the actual IPs (public vs private vs link-local) in the answer log makes
/// publisher-side reachability diagnosable without packet captures.
fn candidate_ips(sdp: &str) -> Vec<String> {
    let mut ips: Vec<String> = Vec::new();
    for line in sdp.lines() {
        let line = line.trim();
        let Some(rest) = line.strip_prefix("a=candidate:") else {
            continue;
        };
        // candidate:foundation component protocol priority address port typ …
        if let Some(addr) = rest.split_whitespace().nth(4) {
            if !ips.iter().any(|ip| ip == addr) {
                ips.push(addr.to_string());
            }
        }
    }
    ips
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

    #[test]
    fn counts_candidate_types() {
        let sdp = "v=0\r\n\
a=candidate:1 1 udp 2122260223 192.168.1.5 54321 typ host\r\n\
a=candidate:2 1 udp 1686052607 203.0.113.9 54322 typ srflx raddr 192.168.1.5 rport 54321\r\n\
a=candidate:3 1 udp 41819935 198.51.100.1 3478 typ relay raddr 203.0.113.9 rport 54322\r\n";
        assert_eq!(candidate_counts(sdp), (1, 1, 1));
    }

    #[test]
    fn host_only_offer_has_no_reflexive_candidates() {
        let sdp = "v=0\r\n\
a=candidate:1 1 udp 2122260223 192.168.1.5 54321 typ host\r\n\
a=candidate:2 1 tcp 1518280447 192.168.1.5 9 typ host tcptype active\r\n";
        let (host, srflx, relay) = candidate_counts(sdp);
        assert_eq!(host, 2);
        assert_eq!(srflx, 0);
        assert_eq!(relay, 0);
    }

    #[test]
    fn collects_unique_candidate_addresses() {
        let sdp = "v=0\r\n\
a=candidate:1 1 udp 2122260223 203.0.113.9 54321 typ host\r\n\
a=candidate:2 1 udp 1686052607 203.0.113.9 54322 typ srflx\r\n\
a=candidate:3 1 udp 41819935 10.0.0.4 54323 typ relay\r\n";
        assert_eq!(
            candidate_ips(sdp),
            vec!["203.0.113.9".to_string(), "10.0.0.4".to_string()]
        );
    }

    #[test]
    fn adds_trickle_signaling_before_first_mline() {
        let sdp =
            "v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\ns=-\r\nt=0 0\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\n";
        let out = add_trickle_signaling(sdp);
        let expected = "v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\ns=-\r\nt=0 0\r\n\
a=ice-options:trickle\r\na=end-of-candidates\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\n";
        assert_eq!(out, expected);
    }

    #[test]
    fn trickle_signaling_not_duplicated() {
        // Both attributes already present: the SDP must come back unchanged.
        let sdp = "v=0\r\na=ice-options:trickle\r\na=end-of-candidates\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\n";
        assert_eq!(add_trickle_signaling(sdp), sdp);
    }

    #[test]
    fn adds_only_missing_trickle_attributes() {
        // ice-options present, end-of-candidates missing: only the missing
        // attribute is injected, with no blank line before the m= line.
        let sdp = "v=0\r\na=ice-options:trickle\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\n";
        let out = add_trickle_signaling(sdp);
        assert_eq!(
            out,
            "v=0\r\na=ice-options:trickle\r\na=end-of-candidates\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\n"
        );
    }

    #[test]
    fn finds_video_ssrc_skipping_rtx() {
        let sdp = "v=0\r\n\
m=audio 9 UDP/TLS/RTP/SAVPF 111\r\n\
a=ssrc:1111111111 cname:audio\r\n\
m=video 9 UDP/TLS/RTP/SAVPF 96 97\r\n\
a=ssrc-group:FID 2222222222 3333333333\r\n\
a=ssrc:2222222222 cname:video\r\n\
a=ssrc:3333333333 cname:video\r\n";
        assert_eq!(first_video_ssrc(sdp), Some(2222222222));
    }

    #[test]
    fn video_ssrc_none_without_video_section() {
        let sdp = "v=0\r\nm=audio 9 UDP/TLS/RTP/SAVPF 111\r\na=ssrc:1111111111 cname:audio\r\n";
        assert_eq!(first_video_ssrc(sdp), None);
    }
}
