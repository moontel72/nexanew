//! Scene planning for the program (PGM) mixer.
//!
//! Pure Rust, no GStreamer: converts a [`SceneLayout`] into concrete slot
//! rects and opacities for the compositor. The GStreamer pipeline
//! (`mixer_gst`, `gst` feature) consumes these plans; the passthrough
//! fallback (no `gst`) ignores them and fans the PGM camera through
//! unchanged. Unit-testable everywhere.

use std::collections::HashMap;

use todd_common::types::{
    PiPConfig, SceneLayout, SideBySideConfig, SourceRef, SplitOrientation, SplitRegion,
    SplitScreenConfig,
};

/// Maximum compositor slots of the GStreamer mixer.
pub const MAX_SLOTS: usize = 8;

/// Composite output configuration of the program mixer. Referenced by the
/// SFU engine in both build modes; the GStreamer pipeline consumes it.
#[derive(Debug, Clone)]
pub struct MixerOutputConfig {
    pub width: u32,
    pub height: u32,
    pub fps: u32,
    pub bitrate_kbps: u32,
    pub encoder: todd_common::media::EncoderKind,
    pub stinger_asset_url: Option<String>,
}

/// A compositor slot: which source feeds it and where it renders.
#[derive(Debug, Clone, PartialEq)]
pub struct SlotPlan {
    pub source: SourceRef,
    /// Normalized rect (0.0–1.0 of the program frame).
    pub rect: NormalizedRect,
    /// 0.0 transparent – 1.0 opaque.
    pub opacity: f32,
    /// Stacking order (higher renders on top).
    pub zorder: u32,
}

/// Normalized (0.0–1.0) rectangle on the program frame.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct NormalizedRect {
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
}

impl NormalizedRect {
    pub const FULL: NormalizedRect = NormalizedRect {
        x: 0.0,
        y: 0.0,
        width: 1.0,
        height: 1.0,
    };

    /// Clamps the rect into the unit square so every source is visible.
    pub fn clamped(mut self) -> Self {
        self.x = self.x.clamp(0.0, 1.0);
        self.y = self.y.clamp(0.0, 1.0);
        self.width = self.width.clamp(0.01, 1.0 - self.x);
        self.height = self.height.clamp(0.01, 1.0 - self.y);
        self
    }

    /// Converts to integer pixels for a program frame.
    pub fn to_pixels(self, frame_width: u32, frame_height: u32) -> PixelRect {
        let rect = self.clamped();
        let x = (rect.x * frame_width as f32).round() as i32;
        let y = (rect.y * frame_height as f32).round() as i32;
        let width = (rect.width * frame_width as f32).round() as i32;
        let height = (rect.height * frame_height as f32).round() as i32;
        PixelRect {
            x,
            y,
            width: width.max(1),
            height: height.max(1),
        }
    }
}

/// Integer pixel rect handed to compositor pad properties.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PixelRect {
    pub x: i32,
    pub y: i32,
    pub width: i32,
    pub height: i32,
}

/// The resolved render plan for one scene.
#[derive(Debug, Clone, PartialEq)]
pub struct ScenePlan {
    pub slots: Vec<SlotPlan>,
}

impl ScenePlan {
    /// Every distinct source referenced by the plan.
    pub fn sources(&self) -> Vec<SourceRef> {
        let mut seen = HashMap::new();
        let mut ordered = Vec::new();
        for slot in &self.slots {
            let key = format!("{}/{}", slot.source.room_id, slot.source.camera_id);
            if !seen.contains_key(&key) {
                seen.insert(key, ());
                ordered.push(slot.source.clone());
            }
        }
        ordered
    }
}

/// Resolves a scene layout into compositor slots.
///
/// `fallback` is the camera being moved onto Program; it fills the main
/// position of layouts that do not name every source explicitly.
pub fn plan_scene(layout: &SceneLayout, fallback: &SourceRef) -> ScenePlan {
    match layout {
        SceneLayout::Fullscreen => ScenePlan {
            slots: vec![SlotPlan {
                source: fallback.clone(),
                rect: NormalizedRect::FULL,
                opacity: 1.0,
                zorder: 0,
            }],
        },
        SceneLayout::SideBySide(SideBySideConfig { left, right }) => ScenePlan {
            slots: vec![
                SlotPlan {
                    source: left.clone(),
                    rect: NormalizedRect {
                        x: 0.0,
                        y: 0.0,
                        width: 0.5,
                        height: 1.0,
                    },
                    opacity: 1.0,
                    zorder: 0,
                },
                SlotPlan {
                    source: right.clone(),
                    rect: NormalizedRect {
                        x: 0.5,
                        y: 0.0,
                        width: 0.5,
                        height: 1.0,
                    },
                    opacity: 1.0,
                    zorder: 0,
                },
            ],
        },
        SceneLayout::PictureInPicture(PiPConfig {
            main,
            overlay,
            overlay_x,
            overlay_y,
            overlay_width,
            overlay_height,
            overlay_opacity,
        }) => ScenePlan {
            slots: vec![
                SlotPlan {
                    source: main.clone(),
                    rect: NormalizedRect::FULL,
                    opacity: 1.0,
                    zorder: 0,
                },
                SlotPlan {
                    source: overlay.clone(),
                    rect: NormalizedRect {
                        x: *overlay_x,
                        y: *overlay_y,
                        width: *overlay_width,
                        height: *overlay_height,
                    }
                    .clamped(),
                    opacity: overlay_opacity.clamp(0.0, 1.0),
                    zorder: 1,
                },
            ],
        },
        SceneLayout::SplitScreen(SplitScreenConfig {
            orientation,
            regions,
        }) => plan_split(*orientation, regions),
    }
}

/// Lays split regions out along one axis, normalizing weights.
fn plan_split(orientation: SplitOrientation, regions: &[SplitRegion]) -> ScenePlan {
    if regions.len() < 2 {
        // Degenerate split: render whatever is available fullscreen.
        return ScenePlan {
            slots: regions
                .iter()
                .map(|region| SlotPlan {
                    source: region.source.clone(),
                    rect: NormalizedRect::FULL,
                    opacity: 1.0,
                    zorder: 0,
                })
                .collect(),
        };
    }

    let total: f32 = regions.iter().map(|r| r.weight.max(0.01)).sum();
    let mut cursor = 0.0f32;
    let mut slots = Vec::with_capacity(regions.len());
    for (index, region) in regions.iter().enumerate() {
        let weight = region.weight.max(0.01) / total;
        let rect = match orientation {
            SplitOrientation::Horizontal => NormalizedRect {
                x: 0.0,
                y: cursor,
                width: 1.0,
                height: weight,
            },
            SplitOrientation::Vertical => NormalizedRect {
                x: cursor,
                y: 0.0,
                width: weight,
                height: 1.0,
            },
        };
        cursor += weight;
        slots.push(SlotPlan {
            source: region.source.clone(),
            rect: rect.clamped(),
            opacity: 1.0,
            zorder: index as u32,
        });
    }
    ScenePlan { slots }
}

/// Smoothstep easing for transition property animation.
pub fn ease_progress(t: f32) -> f32 {
    let t = t.clamp(0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

/// Computes `(peak_db, rms_db)` from little-endian interleaved S16LE PCM.
/// Replaces GStreamer `level`-element message parsing: the mixer taps raw
/// PCM with appsinks and meters it here, deterministically.
pub fn compute_levels(pcm: &[u8]) -> (f32, f32) {
    let mut peak = 0.0f32;
    let mut sum_sq = 0.0f64;
    let mut count = 0usize;
    for chunk in pcm.chunks_exact(2) {
        let sample = f32::from(i16::from_le_bytes([chunk[0], chunk[1]])) / 32768.0;
        peak = peak.max(sample.abs());
        sum_sq += f64::from(sample) * f64::from(sample);
        count += 1;
    }
    let rms = if count > 0 {
        ((sum_sq / count as f64).sqrt()) as f32
    } else {
        0.0
    };
    let to_db = |value: f32| 20.0 * value.max(1e-6).log10();
    (to_db(peak), to_db(rms))
}

#[cfg(test)]
mod tests {
    use super::*;
    use todd_common::types::SplitRegion;

    fn source(id: &str) -> SourceRef {
        SourceRef {
            room_id: "room".to_string(),
            camera_id: id.to_string(),
        }
    }

    #[test]
    fn fullscreen_plans_single_full_slot() {
        let plan = plan_scene(&SceneLayout::Fullscreen, &source("cam-1"));
        assert_eq!(plan.slots.len(), 1);
        assert_eq!(plan.slots[0].rect, NormalizedRect::FULL);
        assert_eq!(plan.slots[0].opacity, 1.0);
        assert_eq!(plan.slots[0].source.camera_id, "cam-1");
    }

    #[test]
    fn side_by_side_splits_frame_in_half() {
        let plan = plan_scene(
            &SceneLayout::SideBySide(SideBySideConfig {
                left: source("cam-1"),
                right: source("cam-2"),
            }),
            &source("cam-1"),
        );
        assert_eq!(plan.slots.len(), 2);
        assert_eq!(plan.slots[0].rect.width, 0.5);
        assert_eq!(plan.slots[1].rect.x, 0.5);
    }

    #[test]
    fn pip_stacks_overlay_on_main() {
        let plan = plan_scene(
            &SceneLayout::PictureInPicture(PiPConfig {
                main: source("cam-1"),
                overlay: source("cam-2"),
                overlay_x: 0.7,
                overlay_y: 0.1,
                overlay_width: 0.3,
                overlay_height: 0.3,
                overlay_opacity: 0.9,
            }),
            &source("cam-1"),
        );
        assert_eq!(plan.slots.len(), 2);
        assert_eq!(plan.slots[0].zorder, 0);
        assert_eq!(plan.slots[1].zorder, 1);
        assert_eq!(plan.slots[1].opacity, 0.9);
    }

    #[test]
    fn split_weights_are_normalized_along_orientation() {
        let plan = plan_scene(
            &SceneLayout::SplitScreen(SplitScreenConfig {
                orientation: SplitOrientation::Vertical,
                regions: vec![
                    SplitRegion {
                        source: source("cam-1"),
                        weight: 1.0,
                    },
                    SplitRegion {
                        source: source("cam-2"),
                        weight: 2.0,
                    },
                ],
            }),
            &source("cam-1"),
        );
        assert_eq!(plan.slots.len(), 2);
        assert!((plan.slots[0].rect.width - 1.0 / 3.0).abs() < 0.001);
        assert!((plan.slots[1].rect.width - 2.0 / 3.0).abs() < 0.001);
        assert!((plan.slots[1].rect.x - 1.0 / 3.0).abs() < 0.001);
    }

    #[test]
    fn rects_clamp_into_the_frame_and_convert_to_pixels() {
        let rect = NormalizedRect {
            x: 0.7,
            y: -0.2,
            width: 0.5,
            height: 0.3,
        };
        let pixels = rect.to_pixels(1280, 720);
        assert_eq!(pixels.x, 896);
        assert_eq!(pixels.y, 0);
        assert!(pixels.width <= 384);
        assert!(pixels.height >= 1);
    }

    #[test]
    fn easing_is_smoothstep() {
        assert_eq!(ease_progress(0.0), 0.0);
        assert_eq!(ease_progress(1.0), 1.0);
        assert!((ease_progress(0.5) - 0.5).abs() < 0.001);
    }

    #[test]
    fn plan_sources_are_deduped_in_order() {
        let plan = plan_scene(
            &SceneLayout::PictureInPicture(PiPConfig {
                main: source("cam-1"),
                overlay: source("cam-1"),
                overlay_x: 0.0,
                overlay_y: 0.0,
                overlay_width: 0.2,
                overlay_height: 0.2,
                overlay_opacity: 1.0,
            }),
            &source("cam-1"),
        );
        assert_eq!(plan.sources().len(), 1);
    }

    #[test]
    fn levels_compute_from_s16le_pcm() {
        // Silence: both meters at the floor.
        let (peak, rms) = compute_levels(&[0u8; 64]);
        assert!(peak < -100.0);
        assert!(rms < -100.0);

        // Half-scale constant signal: peak ≈ RMS ≈ -6.02 dB.
        let half = 16384i16.to_le_bytes();
        let buffer: Vec<u8> = half.iter().cycle().take(64).copied().collect();
        let (peak, rms) = compute_levels(&buffer);
        assert!((peak + 6.02).abs() < 0.05);
        assert!((rms + 6.02).abs() < 0.05);

        // Full-scale samples: peak at 0 dB.
        let full = i16::MAX.to_le_bytes();
        let buffer: Vec<u8> = full.iter().cycle().take(64).copied().collect();
        let (peak, _) = compute_levels(&buffer);
        assert!(peak.abs() < 0.01);
    }
}
