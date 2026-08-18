//! Dynamic hardware acceleration matrix.
//!
//! Pure-Rust encode planning (unit-testable without GStreamer): given a
//! preferred encoder and an encode spec, produce the GStreamer element
//! name, properties and caps for the pipeline. The actual *detection*
//! (which encoders exist on this host) is a thin GStreamer wrapper in
//! `detect_encoder` (gated on the `gst` feature).
//!
//! Encoder families:
//! - **NVENC** (NVIDIA): `nvh264enc`
//! - **AMF** (AMD): `amfh264enc`, VA-API fallback `vah264enc`
//! - **QuickSync** (Intel): `qsvh264enc`, VA-API fallback `vah264enc`
//! - **x264** (software): `x264enc` — always available, the safety net
//!
//! Zero-copy passthrough: when the source is already H.264 and the target
//! container accepts it (RTMP/SRT/file all do), no decode/encode stage is
//! built at all — the pipeline is depay → parse → mux.

pub use todd_common::media::{EncoderKind, EncoderSpec};

/// The resolved plan for the encoder stage of a pipeline.
#[derive(Debug, Clone)]
pub struct EncodePlan {
    /// GStreamer element factory name, e.g. `nvh264enc`.
    pub encoder: String,
    /// Element properties applied via `set_property_from_str`.
    pub props: Vec<(String, String)>,
    /// Caps the encoder outputs (empty = accept element defaults).
    pub caps: String,
}

/// Picks the encoder element for a kind. Falls back to x264 when the
/// requested backend is unavailable (checked by the gst-gated detector).
pub fn resolve_encoder(kind: EncoderKind, detected: &[EncoderKind]) -> EncoderKind {
    let mut candidate = kind;
    if candidate == EncoderKind::Auto {
        for backend in [EncoderKind::Nvenc, EncoderKind::Qsv, EncoderKind::Amf] {
            if detected.contains(&backend) {
                candidate = backend;
                break;
            }
        }
    }
    if candidate == EncoderKind::Auto || !detected.contains(&candidate) {
        // x264 is the universal fallback; `detected` always includes it.
        if !detected.contains(&candidate) && candidate != EncoderKind::X264 {
            tracing::warn!(
                ?candidate,
                "requested encoder unavailable — falling back to x264"
            );
        }
        EncoderKind::X264
    } else {
        candidate
    }
}

/// Builds the H.264 encoder stage plan.
pub fn h264_encode_plan(kind: EncoderKind, spec: &EncoderSpec) -> EncodePlan {
    let bitrate_kbps = spec.bitrate_kbps.max(64);
    let gop = spec.keyframe_interval.max(1);
    match kind {
        EncoderKind::Nvenc => EncodePlan {
            encoder: "nvh264enc".to_string(),
            props: vec![
                ("bitrate".to_string(), bitrate_kbps.to_string()),
                ("gop-size".to_string(), gop.to_string()),
                ("rc-mode".to_string(), "cbr".to_string()),
                ("preset".to_string(), "low-latency-high-quality".to_string()),
            ],
            caps: "video/x-h264,profile=baseline".to_string(),
        },
        EncoderKind::Amf => EncodePlan {
            encoder: "amfh264enc".to_string(),
            props: vec![
                ("bitrate".to_string(), bitrate_kbps.to_string()),
                ("gop-size".to_string(), gop.to_string()),
                ("usage".to_string(), "ultra-low-latency".to_string()),
            ],
            caps: "video/x-h264,profile=baseline".to_string(),
        },
        EncoderKind::Qsv => EncodePlan {
            encoder: "qsvh264enc".to_string(),
            props: vec![
                ("bitrate".to_string(), bitrate_kbps.to_string()),
                ("gop-size".to_string(), gop.to_string()),
                ("rate-control".to_string(), "cbr".to_string()),
            ],
            caps: "video/x-h264,profile=baseline".to_string(),
        },
        // X264 and Passthrough-requested-but-unavailable land here.
        EncoderKind::X264 | EncoderKind::Passthrough | EncoderKind::Auto => EncodePlan {
            encoder: "x264enc".to_string(),
            props: vec![
                ("bitrate".to_string(), bitrate_kbps.to_string()),
                ("speed-preset".to_string(), "ultrafast".to_string()),
                ("tune".to_string(), "zerolatency".to_string()),
                ("key-int-max".to_string(), gop.to_string()),
            ],
            caps: "video/x-h264,profile=baseline".to_string(),
        },
    }
}

/// True when a codec can be forwarded to every standard target container
/// (FLV/RTMP, MPEG-TS/SRT, Matroska/file) without re-encoding.
pub fn is_target_compatible(codec: &str) -> bool {
    let codec = codec.to_ascii_lowercase();
    codec.contains("h264") || codec.contains("avc")
}

/// GStreamer-side detection of available encoder factories.
#[cfg(feature = "gst")]
pub fn detect_encoders() -> Vec<EncoderKind> {
    let mut found = Vec::new();
    for (element, kind) in [
        ("nvh264enc", EncoderKind::Nvenc),
        ("qsvh264enc", EncoderKind::Qsv),
        ("amfh264enc", EncoderKind::Amf),
        ("vah264enc", EncoderKind::Amf), // VA-API covers AMD + Intel fallback
        ("x264enc", EncoderKind::X264),
    ] {
        if gstreamer::ElementFactory::find(element).is_some() {
            if !found.contains(&kind) {
                found.push(kind);
            }
            tracing::info!(element, "hardware encoder available");
        }
    }
    if !found.contains(&EncoderKind::X264) {
        found.push(EncoderKind::X264);
    }
    found
}

/// Non-gst builds cannot inspect the host: assume x264 only (the matrix
/// still applies at runtime on hosts built with the feature).
#[cfg(not(feature = "gst"))]
pub fn detect_encoders() -> Vec<EncoderKind> {
    vec![EncoderKind::X264]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn auto_prefers_nvenc_then_qsv_then_amf() {
        assert_eq!(
            resolve_encoder(EncoderKind::Auto, &[EncoderKind::Nvenc, EncoderKind::X264]),
            EncoderKind::Nvenc
        );
        assert_eq!(
            resolve_encoder(EncoderKind::Auto, &[EncoderKind::Qsv, EncoderKind::X264]),
            EncoderKind::Qsv
        );
        assert_eq!(
            resolve_encoder(EncoderKind::Auto, &[EncoderKind::Amf, EncoderKind::X264]),
            EncoderKind::Amf
        );
        assert_eq!(
            resolve_encoder(EncoderKind::Auto, &[EncoderKind::X264]),
            EncoderKind::X264
        );
    }

    #[test]
    fn unavailable_backend_falls_back_to_x264() {
        assert_eq!(
            resolve_encoder(EncoderKind::Nvenc, &[EncoderKind::X264]),
            EncoderKind::X264
        );
        assert_eq!(
            resolve_encoder(EncoderKind::Qsv, &[EncoderKind::Amf, EncoderKind::X264]),
            EncoderKind::X264
        );
    }

    #[test]
    fn encode_plans_carry_encoder_specific_elements() {
        assert_eq!(
            h264_encode_plan(EncoderKind::Nvenc, &EncoderSpec::default()).encoder,
            "nvh264enc"
        );
        assert_eq!(
            h264_encode_plan(EncoderKind::Amf, &EncoderSpec::default()).encoder,
            "amfh264enc"
        );
        assert_eq!(
            h264_encode_plan(EncoderKind::Qsv, &EncoderSpec::default()).encoder,
            "qsvh264enc"
        );
        assert_eq!(
            h264_encode_plan(EncoderKind::X264, &EncoderSpec::default()).encoder,
            "x264enc"
        );
    }

    #[test]
    fn h264_is_target_compatible() {
        assert!(is_target_compatible("video/H264"));
        assert!(is_target_compatible("avc"));
        assert!(!is_target_compatible("video/VP8"));
    }
}
