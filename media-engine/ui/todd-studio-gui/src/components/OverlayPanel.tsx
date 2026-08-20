import { useEffect, useRef, useState } from "react";
import { useDirector } from "../lib/director/directorService";
import { useControlState } from "../hooks/useControlState";
import { getToken } from "../lib/auth/authStore";
import { api } from "../lib/api/client";
import type { OverlayState } from "../lib/api/types";
import { Button } from "./ui/Button";

const POPUP_EVENTS: Array<{ id: string; text: string; subtext?: string }> = [
  { id: "four", text: "FOUR!", subtext: "Boundary" },
  { id: "six", text: "SIX!" },
  { id: "wicket", text: "OUT!" },
  { id: "milestone", text: "MILESTONE" },
];

export interface OverlayPanelProps {
  /** Fired for the director's local 3D preview alongside the server
   * burn-in command. */
  onLocalEvent?(event: string): void;
}

/** Server-side overlay burn-in control: scoreboard lower-third, event
 * popups and the corner watermark. Every toggle/trigger dispatches to
 * `POST /api/v1/program/overlay`; the resulting state arrives back over
 * the control-plane WebSocket. */
export function OverlayPanel({ onLocalEvent }: OverlayPanelProps) {
  const control = useControlState();
  const director = useDirector();
  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";

  const serverState: OverlayState | null = control.overlays[activeRoomId] ?? null;

  const [title, setTitle] = useState("");
  const [subtitle, setSubtitle] = useState("");
  const [scoreboardOn, setScoreboardOn] = useState(false);
  const [watermarkUrl, setWatermarkUrl] = useState("");
  const [watermarkOn, setWatermarkOn] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const hydratedRef = useRef(false);
  const pushTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Hydrate from the control feed (or a one-off GET).
  useEffect(() => {
    if (serverState) {
      if (!hydratedRef.current || serverState.scoreboard?.title !== title) {
        setScoreboardOn(serverState.scoreboard?.enabled ?? false);
        setTitle(serverState.scoreboard?.title ?? "");
        setSubtitle(serverState.scoreboard?.subtitle ?? "");
        setWatermarkOn(!!serverState.watermark);
        setWatermarkUrl(serverState.watermark?.asset_url ?? "");
      }
      hydratedRef.current = true;
      return;
    }
    if (hydratedRef.current || !activeRoomId || !getToken()) return;
    let cancelled = false;
    api
      .getOverlays(activeRoomId, getToken())
      .then((state) => {
        if (cancelled) return;
        setScoreboardOn(state.scoreboard?.enabled ?? false);
        setTitle(state.scoreboard?.title ?? "");
        setSubtitle(state.scoreboard?.subtitle ?? "");
        setWatermarkOn(!!state.watermark);
        setWatermarkUrl(state.watermark?.asset_url ?? "");
        hydratedRef.current = true;
      })
      .catch(() => {
        // The control feed delivers the state once connected.
      });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [serverState, activeRoomId]);

  const send = (command: Parameters<typeof api.applyOverlay>[1]) => {
    if (!activeRoomId || !getToken()) return;
    setBusy(true);
    setError(null);
    api
      .applyOverlay(activeRoomId, command, getToken())
      .catch((sendError: Error) => setError(sendError.message))
      .finally(() => setBusy(false));
  };

  // Debounced scoreboard edits: keep the server lower-third in sync while
  // the director types.
  const scheduleScoreboard = (enabled: boolean, nextTitle: string, nextSubtitle: string) => {
    setScoreboardOn(enabled);
    setTitle(nextTitle);
    setSubtitle(nextSubtitle);
    if (pushTimerRef.current) clearTimeout(pushTimerRef.current);
    pushTimerRef.current = setTimeout(() => {
      void send({
        kind: "scoreboard",
        enabled,
        title: nextTitle,
        subtitle: nextSubtitle,
      });
    }, 400);
  };

  const firePopup = (text: string, subtext?: string, eventId?: string) => {
    void send({ kind: "event_popup", text, subtext, duration_ms: 2500 });
    if (eventId) onLocalEvent?.(eventId.toUpperCase());
  };

  const toggleWatermark = (enabled: boolean) => {
    setWatermarkOn(enabled);
    void send({ kind: "watermark", enabled, asset_url: watermarkUrl, x: 0.965, y: 0.02 });
  };

  const clearAll = () => {
    if (!activeRoomId) return;
    setBusy(true);
    setError(null);
    api
      .clearOverlays(activeRoomId, getToken())
      .then(() => {
        setScoreboardOn(false);
        setWatermarkOn(false);
      })
      .catch((clearError: Error) => setError(clearError.message))
      .finally(() => setBusy(false));
  };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Overlays
        <span className="font-mono text-[10px] normal-case">
          {busy ? "applying…" : activeRoomId || "no room"}
        </span>
      </header>

      {!activeRoomId && (
        <div className="text-[11px] text-muted-foreground">
          Select an active room before toggling overlays.
        </div>
      )}

      {/* Scoreboard lower-third */}
      <div className="flex flex-col gap-2">
        <label className="flex items-center justify-between text-xs">
          Scoreboard lower-third
          <input
            type="checkbox"
            checked={scoreboardOn}
            onChange={(event) => scheduleScoreboard(event.target.checked, title, subtitle)}
          />
        </label>
        {scoreboardOn && (
          <>
            <input
              className="rounded-md border border-input bg-background px-2 py-1 text-xs"
              placeholder="e.g. TIGERS 142/4 — 16.2 ov"
              value={title}
              onChange={(event) => scheduleScoreboard(true, event.target.value, subtitle)}
            />
            <input
              className="rounded-md border border-input bg-background px-2 py-1 text-xs"
              placeholder="e.g. Khan 45* · Patel 2/18"
              value={subtitle}
              onChange={(event) => scheduleScoreboard(true, title, event.target.value)}
            />
          </>
        )}
      </div>

      {/* Event popups */}
      <div className="flex flex-col gap-1">
        <span className="text-xs text-muted-foreground">Event popups (burn-in)</span>
        <div className="grid grid-cols-2 gap-1">
          {POPUP_EVENTS.map((event) => (
            <Button
              key={event.id}
              variant="outline"
              className="px-2 py-1 text-[11px]"
              disabled={!activeRoomId}
              onClick={() => firePopup(event.text, event.subtext, event.id)}
            >
              {event.text}
            </Button>
          ))}
        </div>
      </div>

      {/* Watermark */}
      <div className="flex flex-col gap-2">
        <label className="flex items-center justify-between text-xs">
          Watermark / logo
          <input
            type="checkbox"
            checked={watermarkOn}
            disabled={!activeRoomId}
            onChange={(event) => toggleWatermark(event.target.checked)}
          />
        </label>
        <input
          className="rounded-md border border-input bg-background px-2 py-1 text-xs"
          placeholder="transparent PNG URL"
          value={watermarkUrl}
          disabled={!activeRoomId}
          onChange={(event) => setWatermarkUrl(event.target.value)}
          onBlur={() => watermarkOn && void send({ kind: "watermark", enabled: true, asset_url: watermarkUrl, x: 0.965, y: 0.02 })}
        />
      </div>

      <Button variant="destructive" disabled={busy} onClick={clearAll}>
        Clear All Overlays
      </Button>

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
