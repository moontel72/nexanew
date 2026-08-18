//! Media DTOs shared across signaling, SFU and transcode:
//! hardware-encoder selection and the multichannel audio mixer config.

use serde::{Deserialize, Serialize};

/// Preferred encoder for a transcode pipeline.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum EncoderKind {
    /// Detect at runtime: NVENC → QuickSync → AMF → x264.
    #[default]
    Auto,
    Nvenc,
    Amf,
    Qsv,
    X264,
    /// Never re-encode; fail if the source codec is not target-compatible.
    Passthrough,
}

/// Encode parameters shared by every encoder backend.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub struct EncoderSpec {
    pub bitrate_kbps: u32,
    /// Keyframe (IDR) interval in frames.
    pub keyframe_interval: u32,
}

impl Default for EncoderSpec {
    fn default() -> Self {
        Self {
            bitrate_kbps: 4000,
            keyframe_interval: 60,
        }
    }
}

/// The four audio buses of the broadcast mix.
///
/// Routing convention: WHIP publishers signal the bus with the track's
/// RID — `commentary`, `ambient`, `sfx`, `music`. Tracks without a RID
/// default to commentary.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AudioBus {
    Commentary,
    Ambient,
    Sfx,
    Music,
}

impl AudioBus {
    pub const ALL: [AudioBus; 4] = [
        AudioBus::Commentary,
        AudioBus::Ambient,
        AudioBus::Sfx,
        AudioBus::Music,
    ];

    pub fn as_str(self) -> &'static str {
        match self {
            AudioBus::Commentary => "commentary",
            AudioBus::Ambient => "ambient",
            AudioBus::Sfx => "sfx",
            AudioBus::Music => "music",
        }
    }

    /// Maps a track RID to its bus; unknown/empty RIDs are commentary.
    pub fn from_rid(rid: Option<&str>) -> Self {
        match rid.map(str::to_ascii_lowercase).as_deref() {
            Some("ambient") => AudioBus::Ambient,
            Some("sfx") => AudioBus::Sfx,
            Some("music") => AudioBus::Music,
            _ => AudioBus::Commentary,
        }
    }
}

/// Per-bus mixer settings.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AudioBusSpec {
    pub bus: AudioBus,
    #[serde(default = "default_true")]
    pub enabled: bool,
    /// Bus gain in dB (0.0 = unity).
    #[serde(default)]
    pub volume_db: f32,
    #[serde(default)]
    pub muted: bool,
}

fn default_true() -> bool {
    true
}

impl Default for AudioBusSpec {
    fn default() -> Self {
        Self {
            bus: AudioBus::Commentary,
            enabled: true,
            volume_db: 0.0,
            muted: false,
        }
    }
}

/// The whole mix: four buses + master gain.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AudioMixerConfig {
    #[serde(default = "default_buses")]
    pub buses: Vec<AudioBusSpec>,
    /// Master gain in dB (0.0 = unity).
    #[serde(default)]
    pub master_volume_db: f32,
}

fn default_buses() -> Vec<AudioBusSpec> {
    AudioBus::ALL
        .iter()
        .map(|bus| AudioBusSpec {
            bus: *bus,
            enabled: *bus == AudioBus::Commentary || *bus == AudioBus::Ambient,
            volume_db: 0.0,
            muted: false,
        })
        .collect()
}

impl Default for AudioMixerConfig {
    fn default() -> Self {
        Self {
            buses: default_buses(),
            master_volume_db: 0.0,
        }
    }
}

impl AudioMixerConfig {
    /// Settings for one bus (defaults apply for missing buses).
    pub fn bus(&self, bus: AudioBus) -> AudioBusSpec {
        self.buses
            .iter()
            .find(|spec| spec.bus == bus)
            .cloned()
            .unwrap_or(AudioBusSpec {
                bus,
                ..AudioBusSpec::default()
            })
    }

    /// True when at least one bus is unmuted and enabled.
    pub fn has_audible_input(&self) -> bool {
        self.buses
            .iter()
            .any(|spec| spec.enabled && !spec.muted && spec.volume_db > -60.0)
    }

    /// Effective gain (dB) for a bus: -inf when disabled/muted.
    pub fn effective_gain_db(&self, bus: AudioBus) -> f32 {
        let spec = self.bus(bus);
        if !spec.enabled || spec.muted {
            f32::NEG_INFINITY
        } else {
            spec.volume_db
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rid_routing_convention() {
        assert_eq!(AudioBus::from_rid(Some("commentary")), AudioBus::Commentary);
        assert_eq!(AudioBus::from_rid(Some("ambient")), AudioBus::Ambient);
        assert_eq!(AudioBus::from_rid(Some("sfx")), AudioBus::Sfx);
        assert_eq!(AudioBus::from_rid(Some("music")), AudioBus::Music);
        assert_eq!(AudioBus::from_rid(None), AudioBus::Commentary);
        assert_eq!(AudioBus::from_rid(Some("unknown")), AudioBus::Commentary);
    }

    #[test]
    fn default_mixer_enables_commentary_and_ambient() {
        let cfg = AudioMixerConfig::default();
        assert!(cfg.bus(AudioBus::Commentary).enabled);
        assert!(cfg.bus(AudioBus::Ambient).enabled);
        assert!(!cfg.bus(AudioBus::Sfx).enabled);
        assert!(!cfg.bus(AudioBus::Music).enabled);
        assert!(cfg.has_audible_input());
    }

    #[test]
    fn muted_bus_has_negative_infinity_gain() {
        let cfg = AudioMixerConfig {
            buses: vec![AudioBusSpec {
                bus: AudioBus::Commentary,
                enabled: true,
                volume_db: 3.0,
                muted: true,
            }],
            master_volume_db: 0.0,
        };
        assert_eq!(
            cfg.effective_gain_db(AudioBus::Commentary),
            f32::NEG_INFINITY
        );
    }
}
