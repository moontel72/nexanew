import { useState } from "react";
import { useDirector } from "../lib/director/directorService";
import {
  loadPersistedState,
  savePersistedState,
} from "../lib/persistence/persistState";
import type { TransitionKind } from "../lib/api/types";
import { Button } from "./ui/Button";

const TRANSITIONS: Array<{ value: TransitionKind; label: string }> = [
  { value: "cut", label: "Cut" },
  { value: "fade", label: "Fade" },
  { value: "luma_wipe", label: "Luma Wipe" },
  { value: "stinger", label: "Stinger" },
];

/** Professional transition bar: transition selection, duration slider and
 * the take buttons. Every action dispatches to the server-side mixer. */
export function TransitionBar() {
  const director = useDirector();
  // Phase 4: restore the pre-refresh transition duration synchronously
  // at mount and persist every slider move.
  const [durationMs, setDurationMs] = useState(
    () => loadPersistedState().transitionDurationMs,
  );

  const take = () => {
    switch (director.state.transition) {
      case "cut":
        director.cut();
        break;
      case "fade":
        director.fade(durationMs);
        break;
      case "luma_wipe":
        director.wipe(durationMs);
        break;
      case "stinger":
        director.stinger(durationMs);
        break;
    }
  };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Transition
      </header>

      <div className="grid grid-cols-4 gap-1">
        {TRANSITIONS.map((transition) => (
          <Button
            key={transition.value}
            variant={director.state.transition === transition.value ? "default" : "outline"}
            className="px-1 py-1 text-[11px]"
            onClick={() => director.setTransition(transition.value)}
          >
            {transition.label}
          </Button>
        ))}
      </div>

      <label className="flex items-center justify-between gap-2 text-[11px] text-muted-foreground">
        Duration
        <input
          type="range"
          min={0}
          max={3000}
          step={100}
          className="min-w-0 flex-1"
          value={durationMs}
          onChange={(event) => {
            const value = Number(event.target.value);
            setDurationMs(value);
            savePersistedState({ transitionDurationMs: value });
          }}
        />
        <span className="w-12 text-right font-mono tabular-nums">
          {durationMs} ms
        </span>
      </label>

      <Button
        variant="destructive"
        disabled={!director.state.pvw || director.state.transitioning}
        onClick={take}
      >
        {director.state.transitioning ? "On air…" : "TAKE"}
      </Button>

      {director.state.transitioning && (
        <div className="rounded-md bg-primary/20 p-2 text-center text-xs font-medium text-primary">
          {director.state.transition.toUpperCase()} transition…
        </div>
      )}
    </section>
  );
}
