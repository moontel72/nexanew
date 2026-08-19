import { useDirector } from "../lib/director/directorService";

/** PGM/PVW bus display. The switcher actions live in the TransitionBar;
 * every switch is dispatched to the server and confirmed from the
 * control-plane WebSocket. */
export function VisionSwitcher() {
  const { state } = useDirector();

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Vision Switcher
      </header>

      <div className="grid grid-cols-2 gap-2 text-xs">
        <div className="rounded-md border border-border p-2">
          <div className="mb-1 font-mono text-muted-foreground">PGM</div>
          <div className="truncate font-medium">
            {state.pgm ? `${state.pgm.roomId}/${state.pgm.cameraId}` : "—"}
          </div>
        </div>
        <div className="rounded-md border border-accent/50 p-2">
          <div className="mb-1 font-mono text-accent">PVW</div>
          <div className="truncate font-medium">
            {state.pvw ? `${state.pvw.roomId}/${state.pvw.cameraId}` : "—"}
          </div>
        </div>
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
