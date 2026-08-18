import { Button } from "./ui/Button";
import { useDirector } from "../lib/director/directorService";

/** PGM/PVW vision switcher: Cut / Fade / custom Stinger. */
export function VisionSwitcher() {
  const { state, cut, fade, stinger } = useDirector();

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Vision Switcher
      </header>

      <div className="grid grid-cols-2 gap-2 text-xs">
        <div className="rounded-md border border-border p-2">
          <div className="mb-1 font-mono text-muted-foreground">PGM</div>
          <div className="font-medium">
            {state.pgm ? `${state.pgm.roomId}/${state.pgm.cameraId}` : "—"}
          </div>
        </div>
        <div className="rounded-md border border-accent/50 p-2">
          <div className="mb-1 font-mono text-accent">PVW</div>
          <div className="font-medium">
            {state.pvw ? `${state.pvw.roomId}/${state.pvw.cameraId}` : "—"}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Button variant="destructive" onClick={cut} disabled={!state.pvw}>
          Cut
        </Button>
        <Button variant="secondary" onClick={() => fade(600)} disabled={!state.pvw}>
          Fade
        </Button>
        <Button variant="outline" onClick={() => stinger(1200)} disabled={!state.pvw}>
          Stinger
        </Button>
      </div>

      {state.transitioning && (
        <div className="rounded-md bg-primary/20 p-2 text-center text-xs font-medium text-primary">
          {state.transition.toUpperCase()} transition…
        </div>
      )}
    </section>
  );
}
