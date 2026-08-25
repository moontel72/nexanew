// StreamStats + SessionStatus — header telemetry chips (5-zone layout).
//
// StreamStats: live quality badge (GOOD/FAIR/POOR) + egress bitrate,
// dropped frames, RTT and jitter — rendered center-left in the top
// header. Hovering shows per-camera detail.
//
// SessionStatus: "N streams · N sessions" + control-plane connectivity —
// rendered center-right in the top header.

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
  for (const device of devices) {
    dropped += device.dropped_frames ?? 0;
  }

  const base = { egressKbps, dropped, forwarded, maxRttMs, maxJitterMs };
  return { ...base, quality: classify(base) };
}

/** Center-left header chip: live stream health. */
export function StreamStats() {
  const telemetry = useTelemetry();

  if (!telemetry) {
    return <span className="text-xs text-muted-foreground">connecting telemetry…</span>;
  }

  const health = aggregate(telemetry.streams, telemetry.devices);
  const badge = QUALITY_BADGE[health.quality];
  const perCamera = telemetry.streams
    .map(
      (stream) =>
        `${stream.camera_id}: ${(stream.egress_bps / 1000).toFixed(0)}kbps, ${stream.packets_dropped}drp, ${stream.rtt_ms}ms`,
    )
    .join(" · ");

  return (
    <div
      className="flex items-center gap-2 text-xs text-muted-foreground"
      title={perCamera || undefined}
    >
      <span className={`rounded px-1.5 py-0.5 text-[10px] font-bold ${badge.className}`}>
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
  );
}

/** Center-right header chip: sessions + control-plane state. */
export function SessionStatus() {
  const telemetry = useTelemetry();
  const control = useControlState();

  return (
    <div className="flex items-center gap-2 text-xs text-muted-foreground">
      <span className="tabular-nums">
        {telemetry
          ? `${telemetry.streams.length} streams · ${telemetry.ice_sessions.length} sessions`
          : "connecting telemetry…"}
      </span>
      <span className={control.connected ? "text-emerald-400" : "text-amber-400"}>
        {control.connected ? "control plane live" : "control plane offline"}
      </span>
    </div>
  );
}
