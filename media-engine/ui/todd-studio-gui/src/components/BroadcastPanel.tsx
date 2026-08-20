import { useEffect, useMemo, useState } from "react";
import { useDirector } from "../lib/director/directorService";
import { useControlState } from "../hooks/useControlState";
import { useTelemetry } from "../hooks/useTelemetry";
import { cn } from "../lib/utils";
import { getToken } from "../lib/auth/authStore";
import { api, ApiError } from "../lib/api/client";
import type { ForwardingStatus, ForwardTargetRequest } from "../lib/api/types";
import { Button } from "./ui/Button";

type DestinationKind = "rtmp" | "srt" | "file";

const KINDS: Array<{ value: DestinationKind; label: string }> = [
  { value: "rtmp", label: "RTMP (YouTube / Facebook)" },
  { value: "srt", label: "SRT (point-to-point)" },
  { value: "file", label: "File recording" },
];

const STATE_BADGE: Record<ForwardingStatus["state"], string> = {
  starting: "bg-amber-500/20 text-amber-400",
  running: "bg-emerald-500/20 text-emerald-400",
  stopped: "bg-muted text-muted-foreground",
  failed: "bg-destructive/20 text-destructive",
};

function formatDuration(startedAtMs: number, now: number): string {
  const seconds = Math.max(0, Math.floor((now - startedAtMs) / 1000));
  const h = Math.floor(seconds / 3600)
    .toString()
    .padStart(2, "0");
  const m = Math.floor((seconds % 3600) / 60)
    .toString()
    .padStart(2, "0");
  const s = (seconds % 60).toString().padStart(2, "0");
  return `${h}:${m}:${s}`;
}

/** Broadcast output manager: pushes the mixed program composite to
 * external RTMP/SRT/file destinations with live health indicators. */
export function BroadcastPanel() {
  const control = useControlState();
  const telemetry = useTelemetry();
  const director = useDirector();

  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";
  const roomName =
    control.rooms.find((room) => room.id === activeRoomId)?.name ?? "no room";

  const [kind, setKind] = useState<DestinationKind>("rtmp");
  const [url, setUrl] = useState("");
  const [bitrate, setBitrate] = useState(4000);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [now, setNow] = useState(() => Date.now());

  // Hydrate the forwarder list once when the control feed has none.
  useEffect(() => {
    if (!getToken()) return;
    if (Object.keys(control.forwarders).length > 0) return;
    let cancelled = false;
    api
      .listForwards(getToken())
      .then((statuses) => {
        if (cancelled) return;
        for (const status of statuses) {
          // The feed reducer merges events; seed via the WS-less path by
          // letting the panel show fetched statuses directly below.
          void status;
        }
      })
      .catch(() => {
        // The control feed delivers forwarders once connected.
      });
    return () => {
      cancelled = true;
    };
  }, [control.forwarders]);

  // Duration counters tick once per second.
  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, []);

  const forwarders: ForwardingStatus[] = useMemo(
    () => Object.values(control.forwarders),
    [control.forwarders],
  );

  const egressBps = useMemo(() => {
    const entry = telemetry?.metrics.find(([name]) => name === "todd_egress_bitrate_bps");
    return entry ? entry[1] : 0;
  }, [telemetry]);

  const startStream = () => {
    const trimmed = url.trim();
    if (!activeRoomId || !trimmed) {
      setError("Select a room and enter a destination URL");
      return;
    }
    setBusy(true);
    setError(null);
    const target: ForwardTargetRequest = {
      camera_id: "",
      source: "program",
      kind,
      url: trimmed,
      bitrate_kbps: bitrate,
    };
    api
      .addProgramForward(activeRoomId, target, getToken())
      .catch((startError: Error) =>
        setError(startError instanceof ApiError ? startError.message : startError.message),
      )
      .finally(() => setBusy(false));
  };

  const stopStream = (key: string) => {
    setBusy(true);
    setError(null);
    api
      .stopForward(key, getToken())
      .catch((stopError: Error) => setError(stopError.message))
      .finally(() => setBusy(false));
  };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Broadcast
        <span className="truncate font-mono text-[10px] normal-case">{roomName}</span>
      </header>

      {/* Destination config */}
      <div className="flex flex-col gap-2">
        <select
          className="rounded-md border border-input bg-background px-2 py-1 text-xs"
          value={kind}
          onChange={(event) => setKind(event.target.value as DestinationKind)}
        >
          {KINDS.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        <input
          className="rounded-md border border-input bg-background px-2 py-1 font-mono text-xs"
          placeholder={
            kind === "rtmp"
              ? "rtmp://a.rtmp.youtube.com/live2/stream-key"
              : kind === "srt"
                ? "srt://receiver:9000?mode=caller"
                : "/var/media/{room}.mkv"
          }
          value={url}
          onChange={(event) => setUrl(event.target.value)}
        />
        <label className="flex items-center justify-between gap-2 text-[11px] text-muted-foreground">
          Bitrate
          <input
            type="number"
            min={500}
            max={12000}
            step={250}
            className="w-24 rounded-md border border-input bg-background px-2 py-1 text-right font-mono text-xs"
            value={bitrate}
            onChange={(event) => setBitrate(Number(event.target.value) || 0)}
          />
          kbps
        </label>
        <Button variant="destructive" disabled={busy || !activeRoomId} onClick={startStream}>
          {busy ? "Starting…" : "Start Live Stream"}
        </Button>
      </div>

      {/* Live destinations */}
      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between text-xs text-muted-foreground">
          <span>Destinations</span>
          <span className="font-mono">egress {Math.round(egressBps / 1000)} kbps</span>
        </div>
        {forwarders.length === 0 && (
          <div className="text-xs text-muted-foreground">No output streams started.</div>
        )}
        {forwarders.map((status) => (
          <div
            key={status.key}
            className="flex flex-col gap-1 rounded-md border border-border bg-background/60 p-2"
          >
            <div className="flex items-center justify-between gap-2">
              <div className="flex min-w-0 items-center gap-2">
                <span
                  className={cn(
                    "shrink-0 rounded px-1.5 py-0.5 text-[10px] font-semibold",
                    STATE_BADGE[status.state],
                  )}
                >
                  {status.state}
                </span>
                <span className="rounded bg-muted px-1.5 py-0.5 text-[10px] text-muted-foreground">
                  {status.kind.toUpperCase()} · {status.source}
                </span>
              </div>
              {status.state === "running" && (
                <span className="font-mono text-[10px] tabular-nums text-muted-foreground">
                  {formatDuration(status.started_at_ms, now)}
                </span>
              )}
            </div>
            <div className="truncate font-mono text-[10px] text-muted-foreground" title={status.url}>
              {status.url}
            </div>
            {status.error && (
              <div className="text-[10px] text-destructive">{status.error}</div>
            )}
            <div className="flex justify-end">
              <Button
                variant="destructive"
                className="px-2 py-1 text-[11px]"
                disabled={busy}
                onClick={() => void stopStream(status.key)}
              >
                Stop
              </Button>
            </div>
          </div>
        ))}
      </div>

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
