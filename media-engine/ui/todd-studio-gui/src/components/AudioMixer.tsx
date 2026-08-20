import { useEffect, useRef } from "react";
import { useDirector } from "../lib/director/directorService";
import { useControlState } from "../hooks/useControlState";
import { useTelemetry } from "../hooks/useTelemetry";
import { useAudioMixer } from "../hooks/useAudioMixer";
import { env, cn } from "../lib/utils";
import type { AudioBus, AudioBusSpec } from "../lib/api/types";
import {
  AUDIO_BUSES,
  BUS_LABELS,
  FADER_CEILING_DB,
  FADER_FLOOR_DB,
  GAIN_MAX_DB,
  GAIN_MIN_DB,
  DELAY_MAX_MS,
  METERING_FLOOR_DB,
  dbToMultiplier,
  clampDb,
  clampGainDb,
  clampDelayMs,
  meterColor,
  meterHeight,
} from "../lib/audio/audioMixer";
import type { AudioBusPatch } from "../hooks/useAudioMixer";

interface FaderStripProps {
  label: string;
  meterKey: string;
  spec: AudioBusSpec;
  onBus(patch: AudioBusPatch): void;
  disabled: boolean;
}

/** One console strip: meter, vertical fader, M/S, gain and delay. */
function FaderStrip({ label, meterKey, spec, onBus, disabled }: FaderStripProps) {
  const mutedOut = spec.muted || spec.volume_db <= FADER_FLOOR_DB + 1;

  return (
    <div
      className={cn(
        "flex min-w-0 flex-1 flex-col items-center gap-1.5 rounded-md border border-border bg-background/60 p-2",
        disabled && "pointer-events-none opacity-50",
      )}
    >
      <div className="flex w-full items-center justify-between gap-1">
        <span className="truncate text-[10px] font-semibold" title={label}>
          {label}
        </span>
        <label className="flex items-center gap-1 text-[9px] text-muted-foreground">
          On
          <input
            type="checkbox"
            checked={spec.enabled}
            disabled={disabled}
            onChange={(event) => onBus({ enabled: event.target.checked })}
          />
        </label>
      </div>

      <div className="meter" data-meter={meterKey}>
        <div className="meter-fill" />
      </div>

      <input
        type="range"
        className="fader-vertical"
        min={FADER_FLOOR_DB}
        max={FADER_CEILING_DB}
        step={0.5}
        value={spec.volume_db}
        disabled={disabled}
        onChange={(event) => onBus({ volume_db: clampDb(Number(event.target.value)) })}
        aria-label={`${label} fader`}
      />

      <div className="text-center font-mono text-[9px] tabular-nums leading-tight">
        {mutedOut ? "-∞" : `${spec.volume_db.toFixed(1)} dB`}
        <br />
        {mutedOut ? "muted" : `${dbToMultiplier(spec.volume_db).toFixed(2)}×`}
      </div>

      <div className="flex w-full justify-center gap-1">
        <button
          type="button"
          disabled={disabled}
          className={cn(
            "rounded px-1.5 py-0.5 text-[9px] font-bold",
            spec.muted ? "bg-destructive text-destructive-foreground" : "bg-muted text-muted-foreground",
          )}
          onClick={() => onBus({ muted: !spec.muted })}
          title="Mute"
        >
          M
        </button>
        <button
          type="button"
          disabled={disabled}
          className={cn(
            "rounded px-1.5 py-0.5 text-[9px] font-bold",
            spec.solo ? "bg-accent text-accent-foreground" : "bg-muted text-muted-foreground",
          )}
          onClick={() => onBus({ solo: !spec.solo })}
          title="Solo"
        >
          S
        </button>
      </div>

      <label className="flex w-full items-center justify-between gap-1 text-[9px] text-muted-foreground">
        Gain
        <input
          type="range"
          min={GAIN_MIN_DB}
          max={GAIN_MAX_DB}
          step={1}
          className="min-w-0 flex-1"
          value={spec.gain_db}
          disabled={disabled}
          onChange={(event) => onBus({ gain_db: clampGainDb(Number(event.target.value)) })}
        />
        <span className="w-7 text-right font-mono tabular-nums">
          {spec.gain_db > 0 ? "+" : ""}
          {spec.gain_db.toFixed(0)}
        </span>
      </label>

      <label className="flex w-full items-center justify-between gap-1 text-[9px] text-muted-foreground">
        Delay
        <input
          type="number"
          min={0}
          max={DELAY_MAX_MS}
          step={10}
          className="w-14 rounded border border-input bg-background px-1 py-0.5 text-right font-mono text-[9px]"
          value={spec.delay_ms}
          disabled={disabled}
          onChange={(event) =>
            onBus({ delay_ms: clampDelayMs(Number(event.target.value) || 0) })
          }
        />
        ms
      </label>
    </div>
  );
}

/**
 * OBS-style multichannel audio console: four bus strips (commentary,
 * ambient, sfx/desktop, music/feed) + master, with real-time dB meters
 * driven by the telemetry feed. Meters animate via requestAnimationFrame
 * without re-rendering React per frame.
 */
export function AudioMixer() {
  const control = useControlState(env.adminToken);
  const telemetry = useTelemetry();
  const director = useDirector();

  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";
  const mix = useAudioMixer(activeRoomId, env.adminToken);

  const rootRef = useRef<HTMLDivElement>(null);
  const targetsRef = useRef<Record<string, number>>({});

  // Latest metering targets from the telemetry snapshot (~1 Hz).
  useEffect(() => {
    for (const entry of telemetry?.audio_levels ?? []) {
      if (entry.room_id === activeRoomId) {
        targetsRef.current[entry.bus] = Math.max(entry.peak_db, entry.rms_db);
      }
    }
  }, [telemetry, activeRoomId]);

  // rAF loop: ease meter fills toward their targets and paint via the
  // DOM directly — the React tree is not touched per frame.
  useEffect(() => {
    const meters = [...AUDIO_BUSES, "master" as const];
    const current: Record<string, number> = {};
    let raf = 0;

    const tick = () => {
      const root = rootRef.current;
      if (root) {
        for (const bus of meters) {
          const target = targetsRef.current[bus] ?? METERING_FLOOR_DB;
          const previous = current[bus] ?? METERING_FLOOR_DB;
          const eased = previous + (target - previous) * 0.3;
          current[bus] = eased;
          const fill = root.querySelector<HTMLElement>(
            `[data-meter="${bus}"] .meter-fill`,
          );
          if (fill) {
            fill.style.height = `${meterHeight(eased)}%`;
            fill.dataset.color = meterColor(eased);
          }
        }
      }
      raf = requestAnimationFrame(tick);
    };

    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, []);

  const roomName =
    control.rooms.find((room) => room.id === activeRoomId)?.name ?? "no room";

  const busSpec = (bus: AudioBus): AudioBusSpec =>
    mix.config.buses.find((spec) => spec.bus === bus) ?? {
      bus,
      enabled: false,
      volume_db: 0,
      muted: false,
      solo: false,
      gain_db: 0,
      delay_ms: 0,
    };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Audio Mixer
        <span className="truncate font-mono text-[10px] normal-case">
          {roomName}
          {mix.pending ? " · syncing…" : ""}
        </span>
      </header>

      {!activeRoomId && (
        <div className="text-[11px] text-muted-foreground">
          Select an active room to mix its audio buses.
        </div>
      )}

      <div ref={rootRef} className="flex gap-2">
        {AUDIO_BUSES.map((bus) => (
          <FaderStrip
            key={bus}
            label={BUS_LABELS[bus]}
            meterKey={bus}
            spec={busSpec(bus)}
            onBus={(patch) => mix.setBus(bus, patch)}
            disabled={!activeRoomId}
          />
        ))}

        {/* Master strip */}
        <div
          className={cn(
            "flex min-w-0 flex-1 flex-col items-center gap-1.5 rounded-md border border-accent/40 bg-background/60 p-2",
            !activeRoomId && "pointer-events-none opacity-50",
          )}
        >
          <span className="truncate text-[10px] font-semibold text-accent">Master</span>
          <div className="meter" data-meter="master">
            <div className="meter-fill" />
          </div>
          <input
            type="range"
            className="fader-vertical"
            min={FADER_FLOOR_DB}
            max={FADER_CEILING_DB}
            step={0.5}
            value={mix.config.master_volume_db}
            disabled={!activeRoomId}
            onChange={(event) => mix.setMaster(Number(event.target.value))}
            aria-label="Master fader"
          />
          <div className="text-center font-mono text-[9px] tabular-nums leading-tight">
            {mix.config.master_volume_db <= FADER_FLOOR_DB + 1
              ? "-∞"
              : `${mix.config.master_volume_db.toFixed(1)} dB`}
            <br />
            {dbToMultiplier(mix.config.master_volume_db).toFixed(2)}×
          </div>
        </div>
      </div>

      {mix.error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">
          {mix.error}
        </div>
      )}
    </section>
  );
}
