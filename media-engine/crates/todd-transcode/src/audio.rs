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
///
/// The mixer is declared **once**, and every bus links into it by name
/// (`audiomixer.sink_0`). Each branch used to repeat
/// `audiomixer name=mix` inside its own string and the pieces were then
/// joined with ` ! `, which produced
///
/// ```text
/// audiotestsrc ... ! audiomixer name=mix ! audiotestsrc ... ! audiomixer name=mix
/// ```
///
/// for two enabled buses. GStreamer rejects that outright (a named element
/// may only be created once, and an element cannot precede itself in a
/// filter chain), so the function was a parse failure waiting for its first
/// caller. Declaring the mixer once and linking the branches into it is the
/// same shape the live mixer in `mixer_gst` uses.
#[cfg(feature = "gst")]
pub fn gst_mixer_skeleton(cfg: &todd_common::media::AudioMixerConfig) -> String {
    let mut branches = Vec::new();
    for bus in todd_common::media::AudioBus::ALL {
        if cfg.bus(bus).enabled {
            branches.push(format!(
                "audiotestsrc wave=silence is-live=true name=src_{} \
                 ! audioconvert ! audioresample ! audiomixer.sink_{}",
                bus.as_str(),
                branches.len(),
            ));
        }
    }
    if branches.is_empty() {
        // No buses: still emit a valid mixer so pipelines don't break.
        // Without any sink pad the mixer would never produce a buffer, so a
        // silent keep-alive pad stands in — the same trick `mixer_gst` uses.
        "audiomixer name=amix audiotestsrc wave=silence is-live=true ! audiomixer.sink_0".to_string()
    } else {
        // The mixer is declared last so every reference resolves, and only
        // one declaration exists in the whole description.
        let mut description = branches.join(" ");
        description.push_str(" audiomixer name=amix");
        description
    }
}

#[cfg(test)]
mod tests {
    /// The skeleton is gst-gated, but the *shape* of the string it produces is
    /// what GStreamer parses — testable without GStreamer, and worth testing
    /// because the old join produced an unparseable description for any
    /// configuration with two or more enabled buses.
    #[cfg(feature = "gst")]
    #[test]
    fn skeleton_declares_the_mixer_exactly_once() {
        let cfg = todd_common::media::AudioMixerConfig::default();
        let description = super::gst_mixer_skeleton(&cfg);

        // One declaration, and it is not repeated per branch.
        assert_eq!(
            description.matches("audiomixer name=amix").count(),
            1,
            "{description}"
        );
        // Every enabled bus links into the mixer by name.
        for (index, bus) in todd_common::media::AudioBus::ALL.iter().enumerate() {
            assert!(
                description.contains(&format!("name=src_{}", bus.as_str())),
                "{description}"
            );
            assert!(
                description.contains(&format!("audiomixer.sink_{index}")),
                "{description}"
            );
        }
        // No element may be chained after the mixer: that was the actual bug
        // (`... name=mix ! audiotestsrc ...`).
        let after_mixer = description.split("audiomixer name=amix").nth(1).unwrap_or("");
        assert!(!after_mixer.contains('!'), "{description}");
    }

    #[cfg(feature = "gst")]
    #[test]
    fn skeleton_keeps_a_keep_alive_pad_when_every_bus_is_disabled() {
        let mut cfg = todd_common::media::AudioMixerConfig::default();
        for spec in cfg.buses.iter_mut() {
            spec.enabled = false;
        }
        let description = super::gst_mixer_skeleton(&cfg);
        assert_eq!(description.matches("audiomixer name=amix").count(), 1);
        assert!(description.contains("audiomixer.sink_0"), "{description}");
    }
}
