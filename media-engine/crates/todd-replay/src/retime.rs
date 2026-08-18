//! Time-scale RTP retiming — slow/fast motion for replay playback.
//!
//! Operates at the **frame level**: RTP packets sharing a timestamp form
//! one access unit (fragmented video frames stay intact), and each unit
//! is repeated or dropped according to the speed factor:
//!
//! - `speed 0.5` → each frame is emitted twice, every copy advancing the
//!   output timeline by the frame's original duration → half-speed
//!   playback (frame repetition, decoder-safe for H.264/VP8/VP9).
//! - `speed 2.0` → every other frame is dropped → double speed.
//! - `speed 1.0` → passthrough.
//!
//! Output timestamps and sequence numbers are rewritten; SSRC and the
//! payload are untouched (zero-copy `Bytes` payload references).
//!
//! `spacing` on a packet is the real-time pause the pacer should take
//! *after* emitting it — zero within a frame (fragments burst together),
//! one frame duration after the last packet of a frame copy.

use std::sync::Arc;

use bytes::{Bytes, BytesMut};

use crate::ring::Frame;
use todd_transcode::media::MediaCodec;

pub const MIN_SPEED: f32 = 0.1;
pub const MAX_SPEED: f32 = 4.0;

/// Clamps a playback speed to the supported range.
pub fn clamp_speed(speed: f32) -> f32 {
    speed.clamp(MIN_SPEED, MAX_SPEED)
}

/// One retimed output packet.
#[derive(Debug, Clone)]
pub struct RetimedPacket {
    pub bytes: Bytes,
    pub codec: MediaCodec,
    pub rid: Option<String>,
    pub rtp_timestamp: u32,
    pub sequence_number: u16,
    pub clock_rate: u32,
    /// Real-time pause (seconds) after emitting this packet.
    pub spacing: f64,
}

/// One access unit: consecutive packets with an identical RTP timestamp.
#[derive(Debug)]
struct Unit {
    packets: Vec<Arc<Frame>>,
    ts: u32,
    /// Media duration of this unit (clock ticks).
    duration: u32,
}

/// Groups packets into access units by RTP timestamp runs.
fn group_units(frames: &[Arc<Frame>]) -> Vec<Unit> {
    let mut units: Vec<Unit> = Vec::new();
    for frame in frames {
        let same_unit = units.last().map(|u: &Unit| {
            u.packets
                .last()
                .map(|f: &Arc<Frame>| {
                    f.rtp_timestamp == frame.rtp_timestamp && f.chunk.rid == frame.chunk.rid
                })
                .unwrap_or(false)
        });
        match same_unit {
            Some(true) => units
                .last_mut()
                .expect("last exists")
                .packets
                .push(Arc::clone(frame)),
            _ => units.push(Unit {
                packets: vec![Arc::clone(frame)],
                ts: frame.rtp_timestamp,
                duration: 0,
            }),
        }
    }

    // Fill durations: each unit lasts until the next unit's timestamp.
    // The final unit reuses the previous duration (or one frame at 25fps
    // for the degenerate single-unit case).
    for i in 0..units.len() {
        let duration = match units.get(i + 1) {
            Some(next) => next.ts.wrapping_sub(units[i].ts).max(1),
            None => {
                if i > 0 {
                    units[i - 1].duration.max(1)
                } else {
                    1
                }
            }
        };
        units[i].duration = duration;
    }
    units
}

/// Retimes a captured frame sequence at `speed`.
pub fn retime(frames: &[Arc<Frame>], speed: f32) -> Vec<RetimedPacket> {
    let speed = clamp_speed(speed);
    let units = group_units(frames);
    let clock_rate = frames
        .first()
        .map(|f| f.chunk.codec.clock_rate())
        .unwrap_or(90_000);

    let mut out: Vec<RetimedPacket> = Vec::with_capacity(frames.len());
    let mut seq: u16 = 0;
    let mut accumulator: f64 = 0.0;
    let copies_per_unit = 1.0 / f64::from(speed);
    // Running output timestamp: advances by `unit.duration` per emitted
    // copy, so the output timeline is continuous and stretched by 1/speed.
    let mut out_ts: Option<u32> = None;

    for unit in &units {
        accumulator += copies_per_unit;
        while accumulator >= 1.0 {
            let copy_ts = match out_ts {
                Some(ts) => ts.wrapping_add(unit.duration),
                None => unit.ts,
            };
            out_ts = Some(copy_ts);
            for frame in &unit.packets {
                out.push(RetimedPacket {
                    bytes: rewrite_header(&frame.chunk.packet, seq, copy_ts),
                    codec: frame.chunk.codec,
                    rid: frame.chunk.rid.clone(),
                    rtp_timestamp: copy_ts,
                    sequence_number: seq,
                    clock_rate,
                    spacing: 0.0,
                });
                seq = seq.wrapping_add(1);
            }
            // Pace after the last packet of this frame copy.
            if let Some(last) = out.last_mut() {
                last.spacing = f64::from(unit.duration) / f64::from(clock_rate);
            }
            accumulator -= 1.0;
        }
    }
    // The first emission starts immediately.
    if let Some(first) = out.first_mut() {
        first.spacing = 0.0;
    }
    out
}

/// Rewrites the 12-byte RTP header fields (sequence number, timestamp)
/// in place; version/SSRC/payload bytes are shared, not copied.
fn rewrite_header(packet: &Bytes, seq: u16, timestamp: u32) -> Bytes {
    let mut buf = BytesMut::from(packet.clone());
    if buf.len() >= 12 {
        buf[2..4].copy_from_slice(&seq.to_be_bytes());
        buf[4..8].copy_from_slice(&timestamp.to_be_bytes());
    }
    buf.freeze()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ring::Frame;
    use bytes::Bytes;
    use std::time::Instant;
    use todd_transcode::media::RtpChunk;

    fn frame(ts: u32) -> Arc<Frame> {
        let mut payload = vec![0u8; 24];
        payload[0] = 0x80;
        payload[2..4].copy_from_slice(&1u16.to_be_bytes());
        payload[4..8].copy_from_slice(&ts.to_be_bytes());
        Arc::new(Frame::new(
            RtpChunk {
                codec: MediaCodec::Vp8,
                rid: None,
                packet: Bytes::from(payload),
            },
            ts,
            Instant::now(),
        ))
    }

    #[test]
    fn speed_one_is_passthrough() {
        let frames: Vec<Arc<Frame>> = (0..10).map(|i| frame(90_000 * i)).collect();
        let out = retime(&frames, 1.0);
        assert_eq!(out.len(), 10);
        for (i, p) in out.iter().enumerate() {
            assert_eq!(p.rtp_timestamp, 90_000 * i as u32);
            assert_eq!(p.sequence_number, i as u16);
            // Every frame copy ends with one frame-duration pause, except
            // the very first emission which starts immediately.
            if i == 0 {
                assert_eq!(p.spacing, 0.0);
            } else {
                assert_eq!(p.spacing, 1.0);
            }
        }
    }

    #[test]
    fn half_speed_duplicates_frames_with_stretched_timeline() {
        let frames: Vec<Arc<Frame>> = (0..4).map(|i| frame(90_000 * i)).collect();
        let out = retime(&frames, 0.5);
        // 4 frames × 2 copies = 8 packets.
        assert_eq!(out.len(), 8);
        // Timeline stretches: total span doubles.
        let span = out.last().unwrap().rtp_timestamp - out[0].rtp_timestamp;
        assert_eq!(span, 90_000 * 7);
        // Copies of frame 0: ts 0 and 90_000 — both carry frame 0's payload ts (rewritten).
        assert_eq!(out[0].rtp_timestamp, 0);
        assert_eq!(out[1].rtp_timestamp, 90_000);
        // Sequence numbers are sequential.
        for (i, p) in out.iter().enumerate() {
            assert_eq!(p.sequence_number, i as u16);
        }
    }

    #[test]
    fn double_speed_drops_frames() {
        let frames: Vec<Arc<Frame>> = (0..10).map(|i| frame(90_000 * i)).collect();
        let out = retime(&frames, 2.0);
        assert_eq!(out.len(), 5);
        // First emitted frame is frame 0, then every other frame.
        assert_eq!(out[1].rtp_timestamp, 90_000 * 2);
    }

    #[test]
    fn three_quarter_speed_alternates_duplication() {
        let frames: Vec<Arc<Frame>> = (0..4).map(|i| frame(90_000 * i)).collect();
        let out = retime(&frames, 0.75);
        // 4 × 4/3 ≈ 5.33 → 5 or 6 packets depending on accumulation.
        assert!(out.len() >= 5 && out.len() <= 6);
    }

    #[test]
    fn fragmented_frames_stay_intact_per_copy() {
        // Two packets with the same timestamp = one frame.
        let frames: Vec<Arc<Frame>> =
            vec![frame(90_000), frame(90_000), frame(180_000), frame(270_000)];
        let out = retime(&frames, 0.5);
        // Frame 1 (2 packets) → 4 packets; frames 2 and 3 → 2 each: 8 total.
        assert_eq!(out.len(), 8);
        // The two copies of the fragmented frame keep identical timestamps
        // *within* a copy.
        assert_eq!(out[0].rtp_timestamp, out[1].rtp_timestamp);
        assert_eq!(out[2].rtp_timestamp, out[3].rtp_timestamp);
        assert_ne!(out[0].rtp_timestamp, out[2].rtp_timestamp);
    }

    #[test]
    fn speed_is_clamped() {
        assert_eq!(clamp_speed(0.01), MIN_SPEED);
        assert_eq!(clamp_speed(99.0), MAX_SPEED);
        assert_eq!(clamp_speed(0.5), 0.5);
    }

    #[test]
    fn empty_input_produces_nothing() {
        let out = retime(&[], 0.5);
        assert!(out.is_empty());
    }
}
