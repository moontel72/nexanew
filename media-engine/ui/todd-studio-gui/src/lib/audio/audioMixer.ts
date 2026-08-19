// Audio mixer helpers: fader math, meter mapping and the client-side
// default mix (mirror of the server default — commentary + ambient
// enabled, everything at unity).

import type {
  AudioBus,
  AudioMixerConfig,
  AudioBusSpec,
} from "../api/types";

export const AUDIO_BUSES: AudioBus[] = ["commentary", "ambient", "sfx", "music"];

/** Director-facing channel labels. The four engine buses carry desktop
 * audio, commentary mics, ground ambient mics and camera ingestion
 * audio — the bus names are the routing contract, the labels are the
 * console names. */
export const BUS_LABELS: Record<AudioBus, string> = {
  commentary: "Commentary Mic",
  ambient: "Ground Ambient",
  sfx: "SFX / Desktop",
  music: "Music / Feed",
};

export const FADER_FLOOR_DB = -60;
export const FADER_CEILING_DB = 12;
export const GAIN_MIN_DB = -24;
export const GAIN_MAX_DB = 24;
export const DELAY_MAX_MS = 500;
export const METERING_FLOOR_DB = -60;

/** dB → linear multiplier (the OBS-style 0–2× readout). */
export function dbToMultiplier(db: number): number {
  return Math.pow(10, db / 20);
}

/** Linear multiplier → dB. */
export function multiplierToDb(multiplier: number): number {
  return multiplier > 0 ? 20 * Math.log10(multiplier) : FADER_FLOOR_DB;
}

export function clampDb(db: number): number {
  return Math.min(FADER_CEILING_DB, Math.max(FADER_FLOOR_DB, db));
}

export function clampGainDb(db: number): number {
  return Math.min(GAIN_MAX_DB, Math.max(GAIN_MIN_DB, db));
}

export function clampDelayMs(ms: number): number {
  return Math.min(DELAY_MAX_MS, Math.max(0, Math.round(ms)));
}

/** Meter fill height (0–100%) for a dBFS level. */
export function meterHeight(db: number): number {
  const span = FADER_CEILING_DB - METERING_FLOOR_DB;
  const clamped = Math.min(FADER_CEILING_DB, Math.max(METERING_FLOOR_DB, db));
  return ((clamped - METERING_FLOOR_DB) / span) * 100;
}

/** OBS-style meter color class from a level in dBFS. */
export function meterColor(db: number): "green" | "yellow" | "red" {
  if (db >= -6) return "red";
  if (db >= -18) return "yellow";
  return "green";
}

/** Client-side mirror of the server's standard mix — used only until the
 * server state arrives (the server default is authoritative). */
export function defaultMix(): AudioMixerConfig {
  return {
    buses: AUDIO_BUSES.map((bus) => ({
      bus,
      enabled: bus === "commentary" || bus === "ambient",
      volume_db: 0,
      muted: false,
      solo: false,
      gain_db: 0,
      delay_ms: 0,
    })),
    master_volume_db: 0,
  };
}

/** Clones a mix with one bus patched. */
export function withBus(
  config: AudioMixerConfig,
  bus: AudioBus,
  patch: Partial<AudioBusSpec>,
): AudioMixerConfig {
  return {
    ...config,
    buses: config.buses.map((spec) => (spec.bus === bus ? { ...spec, ...patch } : spec)),
  };
}
