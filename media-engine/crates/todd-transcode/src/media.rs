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
    fn rtp_timestamp_none_for_short_buffer() {
        let chunk = RtpChunk {
            codec: MediaCodec::Opus,
            rid: None,
            packet: Bytes::from_static(&[0u8; 4]),
        };
        assert_eq!(chunk.rtp_timestamp(), None);
    }
}
