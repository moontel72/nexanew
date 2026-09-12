import { useDirector, type FeedRef } from "../lib/director/directorService";
import { useRooms } from "../hooks/useRooms";
import { Button } from "./ui/Button";

/** PGM/PVW bus display. The switcher actions live in the TransitionBar;
 * every switch is dispatched to the server and confirmed from the
 * control-plane WebSocket. */
export function VisionSwitcher() {
  const { state, cut } = useDirector();
  const { rooms } = useRooms();

  // Resolve the human camera label so the director recognises what is on
  // each bus instead of seeing raw room/camera ids.
  const labelFor = (feed: FeedRef | null) => {
    if (!feed) return "—";
    const room = rooms.find((r) => r.id === feed.roomId);
    const camera = room?.cameras.find((c) => c.id === feed.cameraId);
    return camera?.label ?? camera?.id ?? feed.cameraId;
  };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Vision Switcher
      </header>

      <div className="grid grid-cols-2 gap-2 text-xs">
        <div className="rounded-md border border-border p-2">
          <div className="mb-1 flex items-center justify-between gap-1 font-mono text-muted-foreground">
            PGM
            {state.pvw && (
              <Button
                variant="destructive"
                className="px-1.5 py-0.5 text-[10px]"
                disabled={state.transitioning}
                title="Put the preview camera on air (PGM)"
                onClick={() => cut()}
              >
                TAKE
              </Button>
            )}
          </div>
          <div className="truncate font-medium">{labelFor(state.pgm)}</div>
        </div>
        <div className="rounded-md border border-accent/50 p-2">
          <div className="mb-1 font-mono text-accent">PVW</div>
          <div className="truncate font-medium">{labelFor(state.pvw)}</div>
        </div>
      </div>

      <div className="text-[11px] text-muted-foreground">
        Preview: click a camera tile below, then press TAKE to send it on air.
      </div>

      <div className="text-[11px] text-muted-foreground">
        Layout: <span className="font-mono text-foreground">{state.layout.kind}</span>
      </div>

      {state.lastError && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">
          {state.lastError}
        </div>
      )}
    </section>
  );
}
