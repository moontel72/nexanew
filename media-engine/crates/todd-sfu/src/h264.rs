//! H.264 RTP payload helpers — keyframe visibility for the SFU.
//!
//! The RTP payload of an H.264 stream carries NAL units without their
//! Annex-B start codes. The NAL type lives in the low 5 bits of each
//! unit's first byte:
//!
//! - type 5 = IDR slice — the decoder-starting keyframe every viewer
//!   needs before it can present a picture,
//! - type 24 = STAP-A (one RTP packet aggregates several NAL units),
//! - type 28 = FU-A (one NAL unit split across several RTP packets; the
//!   real type is in the second byte, and only the *start* fragment of
//!   an IDR marks the beginning of a keyframe).
//!
//! Counting IDRs at the ingest and egress legs is how a black Studio
//! tile is localized: IDRs arriving from the publisher but never
//! forwarded to a viewer points inside the SFU; IDRs reaching the
//! viewer while the tile stays black points at the SDP negotiation or
//! decoder on the viewer side.

/// True when an RTP payload contains an H.264 IDR slice (NAL type 5),
/// either as a single NAL unit, the start fragment of an FU-A, or inside
/// a STAP-A aggregate.
pub(crate) fn payload_has_idr(payload: &[u8]) -> bool {
    let Some(&first) = payload.first() else {
        return false;
    };
    match first & 0x1f {
        // Single NAL unit.
        5 => true,
        // FU-A: type 28 lives in the indicator (first byte); the start
        // bit (0x80) and the real NAL type are in the FU header (second
        // byte) — only the *start* fragment of an IDR begins a keyframe.
        28 => payload.len() >= 2 && payload[1] & 0x80 != 0 && payload[1] & 0x1f == 5,
        // STAP-A: 16-bit NAL-unit sizes follow the aggregate header.
        24 => stap_a_contains_idr(&payload[1..]),
        _ => false,
    }
}

/// Scans a STAP-A body (after the aggregate header) for an IDR NAL unit.
/// Stops at a truncated unit instead of misreading payload bytes.
fn stap_a_contains_idr(mut body: &[u8]) -> bool {
    while body.len() >= 2 {
        let size = u16::from_be_bytes([body[0], body[1]]) as usize;
        body = &body[2..];
        if body.len() < size {
            return false;
        }
        if body[0] & 0x1f == 5 {
            return true;
        }
        body = &body[size..];
    }
    false
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn single_nal_idr() {
        // NAL header byte 0x65 = type 5 (IDR), forbidden-zero + nal_ref_idc set.
        assert!(payload_has_idr(&[0x65, 0x88, 0x84]));
    }

    #[test]
    fn single_nal_non_idr_is_not_a_keyframe() {
        // 0x41 = type 1 (non-IDR slice), 0x61 = type 3, 0x67 = type 7 (SPS),
        // 0x68 = type 8 (PPS) — parameter sets alone cannot start a picture.
        for nal in [0x41u8, 0x61, 0x67, 0x68] {
            assert!(!payload_has_idr(&[nal, 0x88, 0x84]));
        }
    }

    #[test]
    fn fu_a_start_fragment_of_idr() {
        // FU indicator 0x7c (type 28); FU header 0x85 = start bit (0x80)
        // set + NAL type 5 (IDR) in the low bits.
        assert!(payload_has_idr(&[0x7c, 0x85, 0x01, 0x02]));
        // A *continuation* fragment of the same IDR is not a keyframe
        // boundary of its own.
        assert!(!payload_has_idr(&[0x7c, 0x05, 0x03, 0x04]));
    }

    #[test]
    fn stap_a_aggregate_containing_idr() {
        // STAP-A header 0x78 (type 24), one 3-byte IDR NAL unit, then a
        // 2-byte non-IDR unit.
        let payload = [0x78, 0x00, 0x03, 0x65, 0xaa, 0xbb, 0x00, 0x02, 0x41, 0xcc];
        assert!(payload_has_idr(&payload));
    }

    #[test]
    fn stap_a_without_idr_is_not_a_keyframe() {
        let payload = [0x78, 0x00, 0x02, 0x41, 0xcc, 0x00, 0x02, 0x67, 0xee];
        assert!(!payload_has_idr(&payload));
    }

    #[test]
    fn truncated_aggregate_and_empty_payloads_are_safe() {
        assert!(!payload_has_idr(&[]));
        // Size field promises more bytes than the aggregate carries.
        assert!(!payload_has_idr(&[0x78, 0x00, 0x99]));
        // FU-A with only one byte has no FU header.
        assert!(!payload_has_idr(&[0x7c]));
    }
}
