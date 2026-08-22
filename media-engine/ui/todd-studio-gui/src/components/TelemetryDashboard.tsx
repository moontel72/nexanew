// TelemetryDashboard — Phase 4 broadcast reliability.
//
// Real-time stream-health strip fed by the engine's diagnostics
// WebSocket: per-camera egress bitrate, broadcaster FPS, dropped
// packets, RTT and jitter, plus a Green/Yellow/Red overall quality
// indicator derived from the live numbers.
//
// Display-only — reads the shared telemetry feed, mutates nothing.

import { useTelemetry } from "../hooks/useTelemetry";
import { useControlState } from "../hooks/useControlState";
import type { StreamFeedEntry, DeviceTelemetryEntryDto } from "../lib/api/types";

type Quality = "good" | "fair" | "poor";

interface Health {
  quality: Quality;
  egressKbps: number;
  dropped: number;
  forwarded: number;
  maxRttMs: number;
  maxJitterMs: number;
}

const QUALITY_BADGE: Record<Quality, { className: string; label: string }> = {
  good: { className: "bg-emerald-500/20 text-emerald-400", label: "GOOD" },
  fair: { className: "bg-amber-500/20 text-amber-400", label: "FAIR" },
  poor: { className: "bg-destructive/20 text-destructive", label: "POOR" },
};

/** Thresholds — conservative for live broadcast. */
function classify(health: Omit<Health, "quality">): Quality {
  if (health.forwarded === 0) return "fair"; // no egress yet — unknown
  const dropRatio = health.forwarded > 0 ? health.dropped / health.forwarded : 0;
  if (dropRatio > 0.05 || health.maxRttMs > 800 || health.maxJitterMs > 60) {
    return "poor";
  }
  if (dropRatio > 0.01 || health.maxRttMs > 200 || health.maxJitterMs > 30) {
    return "fair";
  }
  return "good";
}

function aggregate(
  streams: StreamFeedEntry[],
  devices: DeviceTelemetryEntryDto[],
): Health {
  let egressKbps = 0;
  let dropped = 0;
  let forwarded = 0;
  let maxRttMs = 0;
  let maxJitterMs = 0;

  for (const stream of streams) {
    egressKbps += stream.egress_bps / 1000;
    dropped += stream.packets_dropped;
    forwarded += stream.packets_forwarded;
    maxRttMs = Math.max(maxRttMs, stream.rtt_ms);
    maxJitterMs = Math.max(maxJitterMs, stream.jitter_ms);
  }

  // Device-reported dropped frames add to the health picture.
  for (const device of devices) {
    dropped += device.dropped_frames ?? 0;
  }

  const base = { egressKbps, dropped, forwarded, maxRttMs, maxJitterMs };
  return { ...base, quality: classify(base) };
}

function fpsFor(devices: DeviceTelemetryEntryDto[], roomId: string, cameraId: string): number | null {
  const device = devices.find(
    (d) => d.room_id === roomId && d.camera_id === cameraId,
  );
  return device?.fps ?? null;
}

export function TelemetryDashboard() {
  const telemetry = useTelemetry();
  const control = useControlState();

  if (!telemetry) {
    return (
      <footer className="flex items-center justify-between border-t border-border px-2 py-1.5 text-xs text-muted-foreground">
        <span>connecting telemetry…</span>
      </footer>
    );
  }

  const health = aggregate(telemetry.streams, telemetry.devices);
  const badge = QUALITY_BADGE[health.quality];

  return (
    <footer className="flex flex-col gap-1 border-t border-border px-2 py-1.5 text-xs text-muted-foreground">
      <div className="flex items-center justify-between gap-2">
        <div className="flex items-center gap-2">
          <span
            className={`rounded px-1.5 py-0.5 text-[10px] font-bold ${badge.className}`}
            title={`dropped ${health.dropped} · RTT ${health.maxRttMs}ms · jitter ${health.maxJitterMs}ms`}
          >
            {badge.label}
          </span>
          <span className="tabular-nums">
            {health.egressKbps >= 1000
              ? `${(health.egressKbps / 1000).toFixed(2)} Mbps`
              : `${health.egressKbps.toFixed(0)} kbps`}{" "}
            egress
          </span>
          <span className="tabular-nums">dropped {health.dropped}</span>
          <span className="tabular-nums">RTT {health.maxRttMs}ms</span>
          <span className="tabular-nums">jitter {health.maxJitterMs}ms</span>
        </div>
        <div className="flex items-center gap-2">
          <span>
            {telemetry.streams.length} streams · {telemetry.ice_sessions.length} sessions
          </span>
          <span className={control.connected ? "text-emerald-400" : "text-amber-400"}>
            {control.connected ? "control plane live" : "control plane offline"}
          </span>
        </div>
      </div>

      {/* Per-camera rows (only when there is more than one stream). */}
      {telemetry.streams.length > 0 && (
        <div className="flex flex-wrap gap-x-3 gap-y-0.5 border-t border-border/50 pt-1">
          {telemetry.streams.map((stream) => {
            const fps = fpsFor(telemetry.devices, stream.room_id, stream.camera_id);
            const dropRatio =
              stream.packets_forwarded > 0
                ? stream.packets_dropped / stream.packets_forwarded
                : 0;
            const rowClass =
              dropRatio > 0.05 || stream.rtt_ms > 800
                ? "text-destructive"
                : dropRatio > 0.01 || stream.rtt_ms > 200
                  ? "text-amber-400"
                  : "";
            return (
              <span key={`${stream.room_id}:${stream.camera_id}`} className={`tabular-nums ${rowClass}`}>
                {stream.camera_id} · {(stream.egress_bps / 1000).toFixed(0)}kbps
                {fps !== null ? ` · ${fps.toFixed(0)}fps` : ""} · {stream.packets_dropped}drp ·{" "}
                {stream.rtt_ms}ms
              </span>
            );
          })}
        </div>
      )}
    </footer>
  );
}
