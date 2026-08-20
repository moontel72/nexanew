import { useState } from "react";
import { Button } from "./ui/Button";
import {
  REPLAY_SPEEDS,
  replayService,
} from "../lib/replay/replayService";
import { getToken } from "../lib/auth/authStore";
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
}

/** Director replay panel: event triggers + speed selection toggles. */
export function ReplayDirector({
  roomId,
  cameraIds,
}: ReplayDirectorProps) {
  const [speed, setSpeed] = useState<number>(0.5);
  const [event, setEvent] = useState<ReplayEventKind>("wicket");
  const [triggering, setTriggering] = useState(false);
  const [closing, setClosing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastReplayId, setLastReplayId] = useState<string | null>(null);

  const trigger = async () => {
    setTriggering(true);
    setError(null);
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
        getToken(),
      );
      setLastReplayId(info.replay_id);
    } catch (triggerError) {
      setError(
        triggerError instanceof Error ? triggerError.message : String(triggerError),
      );
    } finally {
      setTriggering(false);
    }
  };

  const stop = async () => {
    if (!lastReplayId) return;
    setClosing(true);
    setError(null);
    try {
      await replayService.close(lastReplayId, getToken());
      setLastReplayId(null);
    } catch (closeError) {
      setError(closeError instanceof Error ? closeError.message : String(closeError));
    } finally {
      setClosing(false);
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

      <div className="flex gap-2">
        <Button
          variant="destructive"
          className="flex-1"
          onClick={trigger}
          disabled={triggering || closing || !roomId}
        >
          {triggering ? "Triggering…" : "Trigger Replay"}
        </Button>
        <Button variant="outline" onClick={stop} disabled={triggering || closing || !lastReplayId}>
          {closing ? "Closing…" : "Stop / Close"}
        </Button>
      </div>

      {!roomId && (
        <div className="text-[11px] text-muted-foreground">
          Create or select a room to replay.
        </div>
      )}

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}

      {lastReplayId && (
        <div className="truncate font-mono text-xs text-muted-foreground">
          {lastReplayId}
        </div>
      )}
    </section>
  );
}
