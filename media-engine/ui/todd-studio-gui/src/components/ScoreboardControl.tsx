// ScoreboardControl — lower-third toggle + text fields (5-zone layout).
//
// Extracted from OverlayPanel so the left sidebar can list OVERLAYS
// (popups/auto) and SCOREBOARD LOWER THIRD as separate controls. Same
// state/API contract as before: debounced PUT to
// `POST /api/v1/program/overlay`, control-feed hydration, and Phase 4
// persistence.

import { useEffect, useRef, useState } from "react";
import { useDirector } from "../lib/director/directorService";
import { useControlState } from "../hooks/useControlState";
import { getToken } from "../lib/auth/authStore";
import { api } from "../lib/api/client";
import {
  loadPersistedState,
  savePersistedState,
} from "../lib/persistence/persistState";

export function ScoreboardControl() {
  const control = useControlState();
  const director = useDirector();
  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";

  const serverState = control.overlays[activeRoomId] ?? null;

  const persisted = loadPersistedState();
  const [title, setTitle] = useState(persisted.scoreboard.title);
  const [subtitle, setSubtitle] = useState(persisted.scoreboard.subtitle);
  const [scoreboardOn, setScoreboardOn] = useState(persisted.scoreboard.enabled);
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

  const send = (enabled: boolean, nextTitle: string, nextSubtitle: string) => {
    if (!activeRoomId || !getToken()) return;
    setBusy(true);
    setError(null);
    api
      .applyOverlay(
        activeRoomId,
        { kind: "scoreboard", enabled, title: nextTitle, subtitle: nextSubtitle },
        getToken(),
      )
      .catch((sendError: Error) => setError(sendError.message))
      .finally(() => setBusy(false));
  };

  const scheduleScoreboard = (enabled: boolean, nextTitle: string, nextSubtitle: string) => {
    setScoreboardOn(enabled);
    setTitle(nextTitle);
    setSubtitle(nextSubtitle);
    savePersistedState({
      scoreboard: { enabled, title: nextTitle, subtitle: nextSubtitle },
    });
    if (pushTimerRef.current) clearTimeout(pushTimerRef.current);
    pushTimerRef.current = setTimeout(() => {
      void send(enabled, nextTitle, nextSubtitle);
    }, 400);
  };

  return (
    <section className="flex flex-col gap-2 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Scoreboard Lower Third
        <span className="font-mono text-[10px] normal-case">
          {busy ? "applying…" : activeRoomId || "no room"}
        </span>
      </header>

      <label className="flex items-center justify-between text-xs">
        Enabled
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

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
