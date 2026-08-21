import { useEffect, useRef, useState } from "react";
import { useDirector } from "../lib/director/directorService";
import { useControlState } from "../hooks/useControlState";
import { getToken } from "../lib/auth/authStore";
import { api } from "../lib/api/client";
import type { BallEventDto, OverlayState } from "../lib/api/types";
import { Button } from "./ui/Button";

const POPUP_EVENTS: Array<{ id: string; text: string; subtext?: string }> = [
  { id: "four", text: "FOUR!", subtext: "Boundary" },
  { id: "six", text: "SIX!" },
  { id: "wicket", text: "OUT!" },
  { id: "milestone", text: "MILESTONE" },
];

/** Default on-air duration of an auto-triggered popup. */
const DEFAULT_AUTO_DURATION_MS = 4000;

export interface OverlayPanelProps {
  /** Fired for the director's local 3D preview alongside the server
   * burn-in command. */
  onLocalEvent?(event: string): void;
}

/** Popup text for a classified scoring event (Phase 3 auto-graphics). */
export function popupTextFor(event: BallEventDto): string {
  switch (event.kind) {
    case "four":
      return event.zone ? `FOUR — ${event.zone}` : "FOUR!";
    case "six":
      return event.zone ? `SIX — ${event.zone}` : "SIX!";
    case "wicket":
      return "OUT!";
    case "catch":
      return "CAUGHT!";
    case "milestone":
      return event.milestone_runs
        ? `MILESTONE — ${event.milestone_runs}${event.milestone_player ? ` · ${event.milestone_player}` : ""}`
        : "MILESTONE";
    default:
      return "";
  }
}

/** Live overlay control: scoreboard lower-third + event popups (manual
 * and auto-triggered). Every command dispatches to
 * `POST /api/v1/program/overlay`; state arrives back over the control
 * WebSocket. The watermark lives in `WatermarkControl` (config zone). */
export function OverlayPanel({ onLocalEvent }: OverlayPanelProps) {
  const control = useControlState();
  const director = useDirector();
  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";

  const serverState: OverlayState | null = control.overlays[activeRoomId] ?? null;

  const [title, setTitle] = useState("");
  const [subtitle, setSubtitle] = useState("");
  const [scoreboardOn, setScoreboardOn] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Phase 3 auto-graphics: toggle + on-air duration.
  const [autoEnabled, setAutoEnabled] = useState(true);
  const [autoDurationMs, setAutoDurationMs] = useState(DEFAULT_AUTO_DURATION_MS);

  const hydratedRef = useRef(false);
  const pushTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  /** `updated_at_ms` of the last score event already fired on-air. */
  const lastFiredRef = useRef<number | null>(null);

  const activeMatchId =
    control.cricket?.active_match_id ??
    control.cricket?.match_configs[0]?.match_id ??
    null;
  const activeScore = activeMatchId ? (control.scores[activeMatchId] ?? null) : null;

  // Hydrate from the control feed (or a one-off GET).
  useEffect(() => {
    if (serverState) {
      if (!hydratedRef.current || serverState.scoreboard?.title !== title) {
        setScoreboardOn(serverState.scoreboard?.enabled ?? false);
        setTitle(serverState.scoreboard?.title ?? "");
        setSubtitle(serverState.scoreboard?.subtitle ?? "");
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

  const firePopup = (text: string, subtext?: string, eventId?: string, durationMs?: number) => {
    void send({
      kind: "event_popup",
      text,
      subtext,
      duration_ms: durationMs ?? 2500,
    });
    if (eventId) onLocalEvent?.(eventId.toUpperCase());
  };

  // ── Phase 3 auto-graphics: scoring push → popup, no operator action ──
  useEffect(() => {
    if (!autoEnabled || !activeScore) return;
    const event = activeScore.last_event;
    if (!event) return;
    if (lastFiredRef.current === activeScore.updated_at_ms) return;

    const text = popupTextFor(event);
    if (!text) return;
    lastFiredRef.current = activeScore.updated_at_ms;
    firePopup(text, undefined, event.kind, autoDurationMs);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [autoEnabled, activeScore?.updated_at_ms]);

  const clearAll = () => {
    if (!activeRoomId) return;
    setBusy(true);
    setError(null);
    api
      .clearOverlays(activeRoomId, getToken())
      .then(() => setScoreboardOn(false))
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

      {/* Auto-graphics (Phase 3) */}
      <div className="flex flex-col gap-2 rounded-md border border-border bg-background/60 p-2">
        <div className="flex items-center justify-between gap-2">
          <span className="text-xs text-muted-foreground">Auto popups (scoring push)</span>
          <input
            type="checkbox"
            checked={autoEnabled}
            onChange={(event) => setAutoEnabled(event.target.checked)}
          />
        </div>
        <label className="flex items-center justify-between gap-2 text-xs text-muted-foreground">
          Duration (ms)
          <input
            className="w-24 rounded-md border border-input bg-background px-2 py-1 font-mono text-xs text-foreground"
            inputMode="numeric"
            value={autoDurationMs}
            disabled={!autoEnabled}
            onChange={(event) => {
              const value = Number(event.target.value);
              if (Number.isInteger(value) && value >= 500) setAutoDurationMs(value);
            }}
          />
        </label>
        {!activeScore && (
          <div className="text-[10px] text-muted-foreground">
            No live score yet — popups fire automatically once the manager
            records boundary/wicket events.
          </div>
        )}
      </div>

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

      {/* Event popups (manual overrides stay available anytime) */}
      <div className="flex flex-col gap-1">
        <span className="text-xs text-muted-foreground">Event popups (manual override)</span>
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

      <Button variant="destructive" disabled={busy} onClick={clearAll}>
        Clear All Overlays
      </Button>

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
