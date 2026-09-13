//! T-Odd Transcode — GStreamer output pipelines for the T-Odd media
//! engine.
//!
//! Three concerns, one crate:
//! - [`hw`] — the dynamic hardware acceleration matrix (NVENC / AMF /
//!   QuickSync / x264) and zero-copy passthrough planning. Pure Rust,
//!   unit-testable without GStreamer.
//! - [`audio`] — the multichannel audio bus model (commentary / ambient /
//!   SFX / music) with RID-based routing and mixer configuration.
//! - [`media`] — shared RTP/codec types flowing between the SFU router
//!   and the pipelines.
//! - [`mixer`] — program (PGM) scene planning: layouts, slot rects and
//!   transition easing. Pure Rust, unit-testable without GStreamer.
//!
//! [`forwarder`] and [`mixer_gst`] are the GStreamer pipeline
//! implementations, compiled only with the `gst` feature (requires
//! libgstreamer >= 1.24 on the build host — Ubuntu 24.04 ships it).

pub mod audio;
pub mod hw;
pub mod media;
pub mod mixer;

#[cfg(feature = "gst")]
pub mod forwarder;
#[cfg(feature = "gst")]
pub mod ingest;
#[cfg(feature = "gst")]
pub mod mixer_gst;

/// Initializes GStreamer exactly once for this process.
///
/// Until this runs, every `gst` API call panics with "GStreamer has not been
/// initialized. Call `gst::init` first." — that panic is what took the
/// program transition handler down: the unwinding request task dropped the
/// connection with no response, which nginx surfaced to the director as an
/// opaque 502 and left PGM untouched. Safe to call from any thread and from a
/// hot path; only the first caller does any work.
#[cfg(feature = "gst")]
pub fn ensure_gst_initialized() {
    use std::sync::Once;
    static INIT: Once = Once::new();
    INIT.call_once(|| {
        // `init()` returns `Result` on current gst-rs builds while older ones
        // return `()`; `let _` accepts either shape. A real failure would
        // resurface as the "not initialized" panic at the call site.
        let _ = gstreamer::init();
        tracing::info!("gstreamer initialized");
    });
}

/// No-op without the `gst` feature so callers need no cfg of their own.
#[cfg(not(feature = "gst"))]
pub fn ensure_gst_initialized() {}
