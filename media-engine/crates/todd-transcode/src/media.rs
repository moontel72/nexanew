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
