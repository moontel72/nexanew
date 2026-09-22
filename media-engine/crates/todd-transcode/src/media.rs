//! Shared media types flowing between the SFU router and the transcode
//! pipelines.

use bytes::Bytes;

/// Codecs recognized from a remote track's MIME type.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MediaCodec {
    H264,
    Vp8,
    Vp9,
    Opus,
    Pcmu,
    Unknown,
}

impl MediaCodec {
    pub fn from_mime(mime: &str) -> Self {
        let mime = mime.to_ascii_lowercase();
        if mime.contains("h264") || mime.contains("avc") {
            MediaCodec::H264
        } else if mime.contains("vp8") {
            MediaCodec::Vp8
        } else if mime.contains("vp9") {
            MediaCodec::Vp9
        } else if mime.contains("opus") {
            MediaCodec::Opus
        } else if mime.contains("pcma") || mime.contains("pcmu") {
            MediaCodec::Pcmu
        } else {
            MediaCodec::Unknown
        }
    }

    /// RTP clock rate in Hz — converts RTP timestamps to seconds for the
    /// interarrival-jitter estimator.
    pub fn clock_rate(&self) -> u32 {
        match self {
            MediaCodec::H264 | MediaCodec::Vp8 | MediaCodec::Vp9 => 90_000,
            MediaCodec::Opus => 48_000,
            MediaCodec::Pcmu => 8_000,
            MediaCodec::Unknown => 90_000,
        }
    }

    pub fn is_audio(&self) -> bool {
        matches!(self, MediaCodec::Opus | MediaCodec::Pcmu)
    }
}

/// RTP payload type an Opus branch advertises when its own packets are not
/// readable yet.
///
/// `rtpopusdepay`'s sink pad template fixes `payload` to `[96, 127]`, and a caps
/// event must carry *fixed* caps, so every `appsrc` that feeds a depayloader has
/// to declare a concrete payload type. Declaring none fails `set_caps`, which
/// leaves the depayloader unnegotiated: the first pushed buffer then comes back
/// as `not-negotiated (-4)`, which the appsrc reports as
/// `streaming stopped, reason not-negotiated (-4)`.
///
/// `rtph264depay`'s template lists no `payload`, so only Opus branches are
/// affected. 96 is the first dynamic payload type, and therefore always inside
/// the range the template accepts.
pub const FALLBACK_OPUS_PAYLOAD_TYPE: u8 = 96;

/// A raw RTP packet plus the codec of its stream and its simulcast RID
/// (empty/`None` for single-layer streams). The RID also carries the
/// audio-bus routing tag (see `audio::AudioBus::from_rid`).
#[derive(Debug, Clone)]
pub struct RtpChunk {
    pub codec: MediaCodec,
    /// Simulcast layer id or audio bus tag.
    pub rid: Option<String>,
    pub packet: Bytes,
}

impl RtpChunk {
    /// Parses the RTP timestamp from the 12-byte packet header
    /// (bytes 4..8, big-endian). Returns `None` for buffers too short
    /// to carry a header.
    pub fn rtp_timestamp(&self) -> Option<u32> {
        let header = self.packet.get(4..8)?;
        Some(u32::from_be_bytes([
            header[0], header[1], header[2], header[3],
        ]))
    }

    /// Parses the RTP payload type from the packet header — the low 7 bits of
    /// byte 1 (the high bit is the marker). Returns `None` for buffers too short
    /// to carry a header.
    pub fn rtp_payload_type(&self) -> Option<u8> {
        self.packet.get(1).map(|byte| byte & 0x7f)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rtp_timestamp_parses_big_endian_header() {
        let mut packet = vec![0u8; 24];
        packet[4..8].copy_from_slice(&123_456u32.to_be_bytes());
        let chunk = RtpChunk {
            codec: MediaCodec::H264,
            rid: None,
            packet: Bytes::from(packet),
        };
        assert_eq!(chunk.rtp_timestamp(), Some(123_456));
    }

    #[test]
    fn rtp_payload_type_masks_the_marker_bit() {
        // byte 1 = 0xEF: marker set, payload type 111.
        let chunk = RtpChunk {
            codec: MediaCodec::Opus,
            rid: None,
            packet: Bytes::from(vec![0x80, 0xef, 0x00, 0x01, 0, 0, 0, 0, 0, 0, 0, 0]),
        };
        assert_eq!(chunk.rtp_payload_type(), Some(111));
    }

    #[test]
    fn rtp_payload_type_none_for_empty_buffer() {
        let chunk = RtpChunk {
            codec: MediaCodec::Opus,
            rid: None,
            packet: Bytes::from_static(&[0x80]),
        };
        assert_eq!(chunk.rtp_payload_type(), None);
    }

    #[test]
    fn rtp_timestamp_none_for_short_buffer() {
        let chunk = RtpChunk {
            codec: MediaCodec::Opus,
            rid: None,
            packet: Bytes::from_static(&[0u8; 4]),
        };
        assert_eq!(chunk.rtp_timestamp(), None);
    }
}
