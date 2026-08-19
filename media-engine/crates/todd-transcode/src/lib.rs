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
pub mod mixer_gst;
