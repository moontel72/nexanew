//! WHEP (WebRTC HTTP Egress Protocol) viewer sessions.
//!
//! The egress counterpart of WHIP: a browser (or any WHEP client) POSTs a
//! recvonly SDP offer, and we answer with a sendonly PeerConnection whose
//! tracks are fed from either:
//!
//! - **Live** ([`TrackFeed::Live`]): the TrackRouter's RTP stream of one
//!   simulcast layer of a camera — sub-second live watch.
//! - **Replay** ([`TrackFeed::Replay`]): a replay session's paced
//!   slow-motion playback stream — the Studio director's preview monitor.
//!
//! Layer selection: `rid` selects the simulcast layer; the viewer's
//! answer carries the layer's RID (via `TrackLocalStaticRTP::new_with_rid`)
//! so simulcast-aware clients can request layer switches later.
//!
//! PLI forwarding (live only): the viewer-facing outbound SSRC (parsed
//! from our own answer) is registered in the [`crate::pli::PliBroker`]
//! against the publisher's inbound SSRC, so viewer keyframe requests
//! propagate upstream. Replay streams have no publisher to PLI.

use std::sync::Arc;

use todd_common::error::AppError;
use tokio_util::sync::CancellationToken;
use uuid::Uuid;
use webrtc::{
    peer_connection::{
        configuration::RTCConfiguration, peer_connection_state::RTCPeerConnectionState,
        sdp::session_description::RTCSessionDescription, RTCPeerConnection,
    },
    rtp::packet::Packet,
    rtp_transceiver::rtp_codec::{RTCRtpCodecCapability, RTPCodecType},
    track::track_local::track_local_static_rtp::TrackLocalStaticRTP,
};
use webrtc_util::Unmarshal;

use crate::{engine::Engine, router::TrackRouter};
use todd_transcode::media::{MediaCodec, RtpChunk};

/// Which source feeds a viewer's tracks.
pub(crate) enum TrackFeed {
    Live {
        room: String,
        camera: String,
        rid: String,
    },
    Replay {
        replay_id: String,
        camera_id: String,
    },
    /// Composite program egress: video from the GStreamer mixer's encoded
    /// output, audio from the mixer's mixed Opus output (falling back to
    /// the PGM camera's live router stream when no mix exists). Constructed
    /// only in gst builds (without the feature the program egress stays a
    /// passthrough of the PGM camera).
    #[cfg_attr(not(feature = "gst"), allow(dead_code))]
    Program {
        video: tokio::sync::broadcast::Receiver<RtpChunk>,
        audio: Option<tokio::sync::broadcast::Receiver<RtpChunk>>,
        codec: MediaCodec,
        audio_room: String,
        audio_camera: String,
    },
}

pub(crate) struct ViewerPeer {
    pub pc: Arc<RTCPeerConnection>,
    pub shutdown: CancellationToken,
    pub answer_sdp: String,
    /// Our outbound video SSRC (the SSRC the viewer PLIs).
    pub viewer_ssrc: Option<u32>,
}

pub(crate) async fn create_viewer(
    engine: &Engine,
    feed: TrackFeed,
    offer_sdp: &str,
) -> Result<ViewerPeer, AppError> {
    let offer = RTCSessionDescription::offer(offer_sdp.to_owned())
        .map_err(|e| AppError::BadRequest(format!("invalid SDP offer: {e}")))?;

    let pc = Arc::new(
        engine
            .api_whep
            .new_peer_connection(RTCConfiguration {
                ice_servers: engine.config.ice_servers.clone(),
                ..Default::default()
            })
            .await
            .map_err(|e| AppError::Internal(format!("peer connection creation failed: {e}")))?,
    );

    let shutdown = CancellationToken::new();

    // Log gathered candidates so local-dev connectivity problems are
    // visible in the server logs (RUST_LOG=debug).
    pc.on_ice_candidate(Box::new(|candidate| {
        Box::pin(async move {
            if let Some(c) = candidate {
                tracing::debug!(candidate = %c.to_string(), "[whep] local ICE candidate");
            }
        })
    }));

    // The remote offer's media sections create the transceivers.
    pc.set_remote_description(offer)
        .await
        .map_err(|e| AppError::Internal(format!("set_remote_description failed: {e}")))?;

    // Preferred video codec: whatever the source is actually sending
    // right now (the router tracks it for live cameras; replay sessions
    // carry it from the captured frames), so the fan-out is a pure RTP
    // pass-through with no re-encode. VP8 is the fallback — Chrome's
    // default for camera and screen-share tracks.
    let video_codec = match &feed {
        TrackFeed::Live { room, camera, rid } => engine
            .router
            .codec_of(room, camera, rid)
            .unwrap_or(MediaCodec::Vp8),
        TrackFeed::Replay {
            replay_id,
            camera_id,
        } => engine
            .replay
            .session(replay_id)
            .and_then(|session| session.camera(camera_id))
            .map(|(codec, _)| codec)
            .unwrap_or(MediaCodec::Vp8),
        TrackFeed::Program { codec, .. } => *codec,
    };

    // Replay sessions may carry audio (commentary etc.); only create the
    // audio track when the feed actually has audio.
    let replay_has_audio = matches!(&feed, TrackFeed::Replay { replay_id, camera_id }
        if engine
            .replay
            .session(replay_id)
            .and_then(|session| session.frames(camera_id))
            .map(|frames| frames.iter().any(|f| f.is_audio()))
            .unwrap_or(false));

    for transceiver in pc.get_transceivers().await {
        let chosen = match transceiver.kind() {
            RTPCodecType::Video => video_codec,
            RTPCodecType::Audio
                if matches!(feed, TrackFeed::Live { .. } | TrackFeed::Program { .. }) =>
            {
                MediaCodec::Opus
            }
            RTPCodecType::Audio if replay_has_audio => MediaCodec::Opus,
            _ => continue,
        };

        let track = match &feed {
            TrackFeed::Live { rid, .. } if !rid.is_empty() => {
                Arc::new(TrackLocalStaticRTP::new_with_rid(
                    codec_capability(chosen),
                    format!("todd-{}", Uuid::new_v4()),
                    "todd".to_string(),
                    rid.to_string(),
                ))
            }
            _ => Arc::new(TrackLocalStaticRTP::new(
                codec_capability(chosen),
                format!("todd-{}", Uuid::new_v4()),
                "todd".to_string(),
            )),
        };
        pc.add_track(track.clone())
            .await
            .map_err(|e| AppError::Internal(format!("add_track failed: {e}")))?;

        // Pump the source into this viewer track until shutdown.
        let pump_shutdown = shutdown.clone();
        match &feed {
            TrackFeed::Live { room, camera, rid } => {
                let (router, room, camera, layer) = (
                    engine.router.clone(),
                    room.clone(),
                    camera.clone(),
                    rid.clone(),
                );
                tokio::spawn(async move {
                    pump_live_track(track, router, room, camera, layer, chosen, pump_shutdown)
                        .await;
                });
            }
            TrackFeed::Replay {
                replay_id,
                camera_id,
            } => {
                let Some(session) = engine.replay.session(replay_id) else {
                    continue;
                };
                let Some(rx) = session.subscribe(camera_id) else {
                    continue;
                };
                tokio::spawn(async move {
                    pump_replay_track(track, rx, chosen, pump_shutdown).await;
                });
            }
            TrackFeed::Program {
                video,
                audio,
                audio_room,
                audio_camera,
                ..
            } => {
                if transceiver.kind() == RTPCodecType::Video {
                    // tokio's broadcast::Receiver has no Clone impl;
                    // resubscribe() hands out a fresh tail reader.
                    let mut rx = video.resubscribe();
                    tokio::spawn(async move {
                        loop {
                            tokio::select! {
                                _ = pump_shutdown.cancelled() => break,
                                chunk = rx.recv() => {
                                    let Ok(chunk) = chunk else { break };
                                    if chunk.codec != chosen {
                                        continue;
                                    }
                                    if !write_chunk(&track, &chunk).await {
                                        break;
                                    }
                                }
                            }
                        }
                    });
                } else if let Some(audio) = audio {
                    // Mixed program audio from the mixer's Opus output.
                    let mut rx = audio.resubscribe();
                    tokio::spawn(async move {
                        loop {
                            tokio::select! {
                                _ = pump_shutdown.cancelled() => break,
                                chunk = rx.recv() => {
                                    let Ok(chunk) = chunk else { break };
                                    if chunk.codec != chosen {
                                        continue;
                                    }
                                    if !write_chunk(&track, &chunk).await {
                                        break;
                                    }
                                }
                            }
                        }
                    });
                } else {
                    // Fallback: the PGM camera's live router audio.
                    let (router, room, camera) = (
                        engine.router.clone(),
                        audio_room.to_string(),
                        audio_camera.to_string(),
                    );
                    tokio::spawn(async move {
                        pump_live_track(
                            track,
                            router,
                            room,
                            camera,
                            String::new(),
                            chosen,
                            pump_shutdown,
                        )
                        .await;
                    });
                }
            }
        }
    }

    // Peer state machine — mirror of the WHIP side: `Disconnected` arms
    // a grace watchdog, `Failed`/`Closed` prune the viewer session.
    let engine_cb = engine.clone();
    let state_pc = pc.clone();
    pc.on_peer_connection_state_change(Box::new(move |state| {
        let engine = engine_cb.clone();
        let pc = state_pc.clone();
        Box::pin(async move {
            match state {
                RTCPeerConnectionState::Connected => {
                    engine.record_ice_by_pc(&pc, "connected");
                    tracing::info!("[whep] peer connection connected");
                }
                RTCPeerConnectionState::Disconnected => {
                    tracing::warn!("[whep] peer connection disconnected — arming grace watchdog");
                    engine.telemetry.registry.inc("todd_ice_disconnects_total");
                    engine.record_ice_by_pc(&pc, "disconnected");
                    engine.spawn_disconnected_watchdog(pc);
                }
                RTCPeerConnectionState::Failed => {
                    tracing::error!("[whep] peer connection failed");
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

    // Standard WHEP answer flow. Same gathering-complete ordering as the
    // WHIP side: take the receiver BEFORE SetLocalDescription and await it
    // afterwards, or the viewer answer can go out with zero candidates
    // and the Studio tile never renders media.
    let answer = pc
        .create_answer(None)
        .await
        .map_err(|e| AppError::Internal(format!("create_answer failed: {e}")))?;
    let mut gather_complete = pc.gathering_complete_promise().await;
    pc.set_local_description(answer)
        .await
        .map_err(|e| AppError::Internal(format!("set_local_description failed: {e}")))?;
    let _ = gather_complete.recv().await;

    let local = pc.local_description().await.ok_or_else(|| {
        AppError::Internal("no local description after ICE gathering".to_string())
    })?;

    let candidate_count = local.sdp.matches("a=candidate").count();
    if candidate_count == 0 {
        tracing::error!("WHEP answer contains no ICE candidates — viewer will never receive media");
    }

    // Our outbound SSRCs are assigned during binding; parse the first one
    // from the answer (video m-section is listed first in practice). The
    // broker maps it to the publisher's inbound SSRC for PLI forwarding
    // (live feeds only — replays have no publisher).
    let outbound_video_ssrc = first_ssrc_in_sdp(&local.sdp);
    if let TrackFeed::Live { room, camera, rid } = &feed {
        if let (Some(viewer_ssrc), Some(publisher_ssrc)) = (
            outbound_video_ssrc,
            engine.router.ssrc_of(room, camera, rid),
        ) {
            engine.pli.register_viewer(viewer_ssrc, publisher_ssrc);
        }
    }

    Ok(ViewerPeer {
        pc,
        shutdown,
        answer_sdp: local.sdp,
        viewer_ssrc: outbound_video_ssrc,
    })
}

/// Extracts the first `a=ssrc:<n>` value from an SDP description.
fn first_ssrc_in_sdp(sdp: &str) -> Option<u32> {
    sdp.lines()
        .map(str::trim)
        .find_map(|line| line.strip_prefix("a=ssrc:"))
        .and_then(|rest| rest.split_whitespace().next())
        .and_then(|digits| digits.parse().ok())
}

/// Streams a live camera's RTP chunks of one layer into one viewer track.
async fn pump_live_track(
    track: Arc<TrackLocalStaticRTP>,
    router: Arc<TrackRouter>,
    room_id: String,
    camera_id: String,
    rid: String,
    codec: MediaCodec,
    shutdown: CancellationToken,
) {
    let mut rx = router.subscribe(&room_id, &camera_id, &rid);
    loop {
        tokio::select! {
            _ = shutdown.cancelled() => break,
            chunk = rx.recv() => {
                let Some(chunk) = chunk else { break };
                if chunk.codec != codec {
                    continue;
                }
                if !write_chunk(&track, &chunk).await {
                    break;
                }
            }
        }
    }
}

/// Streams a replay session's paced playback into one viewer track,
/// demuxing by media kind (video/audio arrive interleaved on the
/// session broadcast).
async fn pump_replay_track(
    track: Arc<TrackLocalStaticRTP>,
    mut rx: tokio::sync::broadcast::Receiver<todd_transcode::media::RtpChunk>,
    codec: MediaCodec,
    shutdown: CancellationToken,
) {
    loop {
        tokio::select! {
            _ = shutdown.cancelled() => break,
            chunk = rx.recv() => {
                let Ok(chunk) = chunk else { break };
                if chunk.codec != codec {
                    continue;
                }
                if !write_chunk(&track, &chunk).await {
                    break;
                }
            }
        }
    }
}

/// Unmarshals and writes one chunk into a viewer track.
async fn write_chunk(track: &TrackLocalStaticRTP, chunk: &todd_transcode::media::RtpChunk) -> bool {
    // webrtc-util's Unmarshal drains the buffer: takes &mut Bytes.
    let mut buf = chunk.packet.clone();
    let packet = match Packet::unmarshal(&mut buf) {
        Ok(p) => p,
        Err(e) => {
            tracing::warn!(error = %e, "rtp unmarshal failed");
            return true;
        }
    };
    if let Err(e) = track.write_rtp_with_extensions(&packet, &[]).await {
        tracing::warn!(error = %e, "write_rtp failed; stopping viewer pump");
        return false;
    }
    true
}

fn codec_capability(codec: MediaCodec) -> RTCRtpCodecCapability {
    let (mime, clock_rate, channels) = match codec {
        MediaCodec::H264 => ("video/H264", 90_000, 0),
        MediaCodec::Vp8 => ("video/VP8", 90_000, 0),
        MediaCodec::Vp9 => ("video/VP9", 90_000, 0),
        MediaCodec::Opus => ("audio/opus", 48_000, 2),
        MediaCodec::Pcmu => ("audio/PCMU", 8_000, 1),
        MediaCodec::Unknown => ("video/VP8", 90_000, 0),
    };
    RTCRtpCodecCapability {
        mime_type: mime.to_string(),
        clock_rate,
        channels,
        sdp_fmtp_line: String::new(),
        rtcp_feedback: vec![],
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extracts_first_ssrc_from_sdp() {
        let sdp = "v=0\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\na=ssrc:123456 cname:todd\r\na=ssrc:123456 msid:todd cam\r\nm=audio 9 UDP/TLS/RTP/SAVPF 111\r\na=ssrc:789012 cname:todd\r\n";
        assert_eq!(first_ssrc_in_sdp(sdp), Some(123456));
    }

    #[test]
    fn no_ssrc_returns_none() {
        assert_eq!(
            first_ssrc_in_sdp("v=0\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\n"),
            None
        );
    }
}
