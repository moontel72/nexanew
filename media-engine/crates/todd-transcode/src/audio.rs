//! Multichannel audio bus architecture.
//!
//! The engine routes each incoming audio track to one of four buses
//! (see [`todd_common::media::AudioBus`]): `Commentary`, `Ambient`,
//! `Sfx`, `Music`. Routing convention: the WHIP publisher signals the
//! bus with the track's RID (`commentary`, `ambient`, `sfx`, `music`);
//! tracks without a RID default to commentary.
//!
//! The mixer model and DTOs live in `todd-common` (serialized over the
//! signaling API); this crate contributes the GStreamer `audiomixer`
//! pipeline construction, gated on the `gst` feature.

/// Builds the `audiomixer` branch of a GStreamer pipeline description.
///
/// Every enabled bus contributes
/// `audiotestsrc wave=silence ! audiomixer.sink_N` as a placeholder input
/// so the mixer always has a fixed sink-pad topology; live RTP from the
/// engine is pushed into per-bus `appsrc` elements instead (the engine
/// manages those, this string only defines the mixer skeleton).
#[cfg(feature = "gst")]
pub fn gst_mixer_skeleton(cfg: &todd_common::media::AudioMixerConfig) -> String {
    let mut branches = Vec::new();
    for bus in todd_common::media::AudioBus::ALL {
        if cfg.bus(bus).enabled {
            branches.push(format!(
                "audiotestsrc wave=silence is-live=true name=src_{bus} ! audiomixer name=mix"
            ));
        }
    }
    if branches.is_empty() {
        // No buses: still emit a valid mixer so pipelines don't break.
        "audiomixer name=mix".to_string()
    } else {
        branches.join(" ! ")
    }
}
