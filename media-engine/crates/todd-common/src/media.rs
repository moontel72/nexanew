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

impl std::str::FromStr for EncoderKind {
    type Err = crate::error::AppError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.trim().to_ascii_lowercase().as_str() {
            "auto" => Ok(EncoderKind::Auto),
            "nvenc" => Ok(EncoderKind::Nvenc),
            "amf" => Ok(EncoderKind::Amf),
            "qsv" => Ok(EncoderKind::Qsv),
            "x264" => Ok(EncoderKind::X264),
            "passthrough" => Ok(EncoderKind::Passthrough),
            other => Err(crate::error::AppError::BadRequest(format!(
                "invalid encoder '{other}' (expected auto|nvenc|amf|qsv|x264|passthrough)"
            ))),
        }
    }
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
    /// Fader gain in dB (0.0 = unity). The Studio UI presents this as a
    /// 0.0–2.0× multiplier derived from the dB value.
    #[serde(default)]
    pub volume_db: f32,
    #[serde(default)]
    pub muted: bool,
    /// Solo: when any bus is soloed, only soloed buses are audible.
    #[serde(default)]
    pub solo: bool,
    /// Trim gain in dB, clamped to [-24, +24].
    #[serde(default)]
    pub gain_db: f32,
    /// Lip-sync correction delay in milliseconds, clamped to [0, 500].
    #[serde(default)]
    pub delay_ms: u64,
}

fn default_true() -> bool {
    true
}

/// Fader range: faders below this are effectively silence.
pub const FADER_FLOOR_DB: f32 = -60.0;
/// Fader ceiling.
pub const FADER_CEILING_DB: f32 = 12.0;
/// Gain trim range.
pub const GAIN_MIN_DB: f32 = -24.0;
pub const GAIN_MAX_DB: f32 = 24.0;
/// Lip-sync delay range.
pub const DELAY_MAX_MS: u64 = 500;

impl Default for AudioBusSpec {
    fn default() -> Self {
        Self {
            bus: AudioBus::Commentary,
            enabled: true,
            volume_db: 0.0,
            muted: false,
            solo: false,
            gain_db: 0.0,
            delay_ms: 0,
        }
    }
}

impl AudioBusSpec {
    /// Clamps every numeric field into its documented range.
    pub fn clamped(mut self) -> Self {
        self.volume_db = self.volume_db.clamp(FADER_FLOOR_DB, FADER_CEILING_DB);
        self.gain_db = self.gain_db.clamp(GAIN_MIN_DB, GAIN_MAX_DB);
        self.delay_ms = self.delay_ms.min(DELAY_MAX_MS);
        self
    }

    /// True when another bus's solo makes this bus inaudible.
    pub fn audible(&self, any_solo: bool) -> bool {
        self.enabled && !self.muted && (!any_solo || self.solo)
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
            ..AudioBusSpec::default()
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
        let any_solo = self.buses.iter().any(|spec| spec.solo);
        self.buses
            .iter()
            .any(|spec| spec.audible(any_solo) && spec.volume_db > -60.0)
    }

    /// Effective gain (dB) for a bus: -inf when disabled/muted/soloed-out.
    pub fn effective_gain_db(&self, bus: AudioBus) -> f32 {
        let spec = self.bus(bus);
        let any_solo = self.buses.iter().any(|spec| spec.solo);
        if !spec.audible(any_solo) {
            f32::NEG_INFINITY
        } else {
            spec.volume_db
        }
    }

    /// Clamps every bus and the master fader into their documented ranges.
    pub fn clamped(mut self) -> Self {
        self.master_volume_db = self
            .master_volume_db
            .clamp(FADER_FLOOR_DB, FADER_CEILING_DB);
        self.buses = self.buses.into_iter().map(|spec| spec.clamped()).collect();
        self
    }
}

/// Real-time level metering of one bus (peak / RMS in dBFS). Produced by
/// the media plane; `-inf`-like silence is reported as the floor.
pub const METERING_FLOOR_DB: f32 = -60.0;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct BusMetering {
    /// Bus name (`commentary`/`ambient`/`sfx`/`music`/`master`).
    pub bus: String,
    pub peak_db: f32,
    pub rms_db: f32,
}

impl BusMetering {
    pub fn silent(bus: &str) -> Self {
        Self {
            bus: bus.to_string(),
            peak_db: METERING_FLOOR_DB,
            rms_db: METERING_FLOOR_DB,
        }
    }
}

/// Read model of `GET /api/v1/audio/mix/{room_id}`: the active mix plus
/// the latest metering per bus.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AudioMixView {
    pub config: AudioMixerConfig,
    pub metering: Vec<BusMetering>,
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
                solo: false,
                gain_db: 0.0,
                delay_ms: 0,
            }],
            master_volume_db: 0.0,
        };
        assert_eq!(
            cfg.effective_gain_db(AudioBus::Commentary),
            f32::NEG_INFINITY
        );
    }

    #[test]
    fn solo_silences_other_buses() {
        let cfg = AudioMixerConfig {
            buses: vec![
                AudioBusSpec {
                    bus: AudioBus::Commentary,
                    enabled: true,
                    solo: false,
                    ..AudioBusSpec::default()
                },
                AudioBusSpec {
                    bus: AudioBus::Ambient,
                    enabled: true,
                    solo: true,
                    ..AudioBusSpec::default()
                },
            ],
            master_volume_db: 0.0,
        };
        assert_eq!(
            cfg.effective_gain_db(AudioBus::Commentary),
            f32::NEG_INFINITY
        );
        assert_eq!(cfg.effective_gain_db(AudioBus::Ambient), 0.0);
        assert!(cfg.has_audible_input());
    }

    #[test]
    fn clamped_bounds_gain_and_delay() {
        let spec = AudioBusSpec {
            bus: AudioBus::Sfx,
            enabled: true,
            volume_db: 40.0,
            muted: false,
            solo: false,
            gain_db: 99.0,
            delay_ms: 10_000,
        }
        .clamped();
        assert_eq!(spec.volume_db, FADER_CEILING_DB);
        assert_eq!(spec.gain_db, GAIN_MAX_DB);
        assert_eq!(spec.delay_ms, DELAY_MAX_MS);
    }

    #[test]
    fn metering_silence_reports_floor() {
        let meter = BusMetering::silent("master");
        assert_eq!(meter.peak_db, METERING_FLOOR_DB);
        assert_eq!(meter.rms_db, METERING_FLOOR_DB);
    }
}
