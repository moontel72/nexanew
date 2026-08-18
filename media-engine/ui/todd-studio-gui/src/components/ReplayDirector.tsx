import { useState } from "react";
import { Button } from "./ui/Button";
import {
  REPLAY_SPEEDS,
  replayService,
} from "../lib/replay/replayService";
import type { ReplayEventKind } from "../lib/api/types";

const EVENTS: Array<{ id: ReplayEventKind; label: string }> = [
  { id: "run_out", label: "Run Out" },
  { id: "wicket", label: "Wicket" },
  { id: "boundary", label: "Boundary" },
  { id: "catch", label: "Catch" },
];

export interface ReplayDirectorProps {
  roomId: string;
  cameraIds: string[];
  adminToken: string;
}

/** Director replay panel: event triggers + speed selection toggles. */
export function ReplayDirector({
  roomId,
  cameraIds,
  adminToken,
}: ReplayDirectorProps) {
  const [speed, setSpeed] = useState<number>(0.5);
  const [event, setEvent] = useState<ReplayEventKind>("wicket");
  const [busy, setBusy] = useState(false);
  const [lastReplayId, setLastReplayId] = useState<string | null>(null);

  const trigger = async () => {
    setBusy(true);
    try {
      const info = await replayService.trigger(
        {
          roomId,
          cameraIds,
          event,
          lookbackMs: 10_000,
          speed,
          loop: false,
        },
        adminToken,
      );
      setLastReplayId(info.replay_id);
    } finally {
      setBusy(false);
    }
  };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Replay Director
      </header>

      <div className="grid grid-cols-2 gap-2">
        {EVENTS.map((e) => (
          <Button
            key={e.id}
            variant={event === e.id ? "default" : "outline"}
            onClick={() => setEvent(e.id)}
          >
            {e.label}
          </Button>
        ))}
      </div>

      <div className="flex items-center gap-2">
        <span className="text-xs text-muted-foreground">Speed</span>
        {REPLAY_SPEEDS.map((s) => (
          <Button
            key={s}
            variant={speed === s ? "default" : "outline"}
            onClick={() => setSpeed(s)}
            className="px-2 py-1 text-xs"
          >
            {s}x
          </Button>
        ))}
      </div>

      <Button variant="destructive" onClick={trigger} disabled={busy || !roomId}>
        {busy ? "Triggering…" : "Trigger Replay"}
      </Button>

      {lastReplayId && (
        <div className="truncate font-mono text-xs text-muted-foreground">
          {lastReplayId}
        </div>
      )}
    </section>
  );
}
