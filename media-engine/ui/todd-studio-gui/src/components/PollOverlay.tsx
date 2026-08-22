// PollPanel + PollOverlay — Phase 5 fan engagement.
//
// PollPanel: director control for creating/clearing a spectator poll for
// the active room. Vote tallies arrive live over the control plane.
//
// PollOverlay: animated lower-third rendered over the program canvas
// whenever the active room has an active poll — live bars + percentages
// that re-render on every `poll_changed` push.

import { useEffect, useMemo, useRef, useState } from "react";
import { api } from "../lib/api/client";
import { getToken } from "../lib/auth/authStore";
import { useControlState } from "../hooks/useControlState";
import { useDirector } from "../lib/director/directorService";
import { Button } from "./ui/Button";
import type { PollStateDto } from "../lib/api/types";

export function PollPanel() {
  const control = useControlState();
  const director = useDirector();
  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";

  const [question, setQuestion] = useState("");
  const [optionA, setOptionA] = useState("");
  const [optionB, setOptionB] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);

  const poll = activeRoomId ? (control.polls[activeRoomId] ?? null) : null;

  const create = () => {
    const options = [optionA.trim(), optionB.trim()].filter((o) => o.length > 0);
    if (!question.trim() || options.length < 2 || !activeRoomId || !getToken()) return;
    setBusy(true);
    setError(null);
    api
      .createPoll(activeRoomId, { question: question.trim(), options }, getToken())
      .then(() => {
        setNotice("Poll live — votes are streaming in.");
        setQuestion("");
        setOptionA("");
        setOptionB("");
      })
      .catch((createError: Error) => setError(createError.message))
      .finally(() => setBusy(false));
  };

  const clear = () => {
    if (!activeRoomId || !getToken()) return;
    setBusy(true);
    setError(null);
    api
      .clearPoll(activeRoomId, getToken())
      .then(() => setNotice("Poll cleared."))
      .catch((clearError: Error) => setError(clearError.message))
      .finally(() => setBusy(false));
  };

  return (
    <section className="flex flex-col gap-2 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Spectator Poll
        <span className="font-mono text-[10px] normal-case">
          {activeRoomId || "no room"}
        </span>
      </header>

      {poll ? (
        <>
          <div className="text-xs font-medium">{poll.question}</div>
          <div className="flex flex-col gap-1">
            {poll.options.map((option, index) => {
              const total = poll.options.reduce((sum, o) => sum + o.votes, 0);
              const pct = total > 0 ? Math.round((option.votes / total) * 100) : 0;
              return (
                <div key={index} className="flex items-center gap-2 text-[11px]">
                  <span className="w-24 truncate">{option.label}</span>
                  <div className="h-2 min-w-0 flex-1 overflow-hidden rounded bg-muted">
                    <div
                      className="h-full bg-accent transition-all duration-500"
                      style={{ width: `${pct}%` }}
                    />
                  </div>
                  <span className="w-16 text-right font-mono tabular-nums">
                    {pct}% · {option.votes}
                  </span>
                </div>
              );
            })}
          </div>
          <Button variant="destructive" disabled={busy} onClick={clear}>
            Clear Poll
          </Button>
        </>
      ) : (
        <>
          <input
            className="rounded-md border border-input bg-background px-2 py-1 text-xs"
            placeholder="Question, e.g. Player of the Match?"
            value={question}
            onChange={(event) => setQuestion(event.target.value)}
          />
          <div className="grid grid-cols-2 gap-2">
            <input
              className="rounded-md border border-input bg-background px-2 py-1 text-xs"
              placeholder="Option A"
              value={optionA}
              onChange={(event) => setOptionA(event.target.value)}
            />
            <input
              className="rounded-md border border-input bg-background px-2 py-1 text-xs"
              placeholder="Option B"
              value={optionB}
              onChange={(event) => setOptionB(event.target.value)}
            />
          </div>
          <Button onClick={create} disabled={busy || !activeRoomId}>
            {busy ? "Creating…" : "Start Poll"}
          </Button>
          <div className="text-[10px] text-muted-foreground">
            Fans vote at{" "}
            <span className="font-mono">POST /api/v1/poll/{activeRoomId || "{room}"}/vote</span>
          </div>
        </>
      )}

      {notice && <div className="rounded-md bg-accent/10 p-2 text-xs text-accent">{notice}</div>}
      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}

/** Animated lower-third rendered over the program canvas. */
export function PollOverlay() {
  const control = useControlState();
  const director = useDirector();
  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";
  const poll: PollStateDto | null = activeRoomId
    ? (control.polls[activeRoomId] ?? null)
    : null;

  const total = useMemo(
    () => (poll ? poll.options.reduce((sum, o) => sum + o.votes, 0) : 0),
    [poll],
  );

  const containerRef = useRef<HTMLDivElement>(null);

  // Fade the overlay in whenever a poll becomes active.
  useEffect(() => {
    if (!poll || !containerRef.current) return;
    containerRef.current.style.opacity = "0";
    const raf = requestAnimationFrame(() => {
      if (containerRef.current) containerRef.current.style.opacity = "1";
    });
    return () => cancelAnimationFrame(raf);
  }, [poll?.question, poll?.updated_at_ms]);

  if (!poll?.active) return null;

  return (
    <div
      ref={containerRef}
      className="pointer-events-none absolute inset-x-0 bottom-16 z-20 mx-auto max-w-xl transition-opacity duration-500"
    >
      <div className="rounded-md border border-border bg-slate-900/90 px-4 py-3 shadow-2xl">
        <div className="mb-2 text-sm font-semibold text-foreground">{poll.question}</div>
        <div className="flex flex-col gap-1.5">
          {poll.options.map((option, index) => {
            const pct = total > 0 ? Math.round((option.votes / total) * 100) : 0;
            return (
              <div key={index} className="flex items-center gap-2 text-xs text-foreground">
                <span className="w-28 shrink-0 truncate">{option.label}</span>
                <div className="h-3 min-w-0 flex-1 overflow-hidden rounded bg-muted">
                  <div
                    className="h-full bg-accent transition-all duration-700 ease-out"
                    style={{ width: `${pct}%` }}
                  />
                </div>
                <span className="w-12 shrink-0 text-right font-mono tabular-nums">
                  {pct}%
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
