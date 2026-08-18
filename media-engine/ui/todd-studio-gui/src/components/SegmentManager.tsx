import { Button } from "./ui/Button";
import {
  formatClock,
  SEGMENT_PRESETS,
  useSegmentManager,
} from "../lib/segments/segmentManager";

/** Automated ad / break segment manager (3 min / 5 min timers). */
export function SegmentManager({ onFire }: { onFire?: () => void }) {
  const seg = useSegmentManager(onFire);

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Segment / Ad Timer
      </header>

      <div className="text-center font-mono text-3xl tabular-nums">
        {formatClock(seg.remainingSeconds)}
      </div>

      <div className="grid grid-cols-2 gap-2">
        {(Object.keys(SEGMENT_PRESETS) as Array<keyof typeof SEGMENT_PRESETS>).map(
          (key) => (
            <Button
              key={key}
              variant={
                seg.presetSeconds === SEGMENT_PRESETS[key] ? "default" : "outline"
              }
              onClick={() => seg.setPreset(SEGMENT_PRESETS[key])}
            >
              {key}
            </Button>
          ),
        )}
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Button onClick={seg.start} disabled={seg.running}>
          Start
        </Button>
        <Button onClick={seg.pause} disabled={!seg.running}>
          Pause
        </Button>
      </div>
    </section>
  );
}
