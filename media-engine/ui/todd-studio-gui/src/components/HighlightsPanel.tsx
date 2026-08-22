// HighlightsPanel — Phase 5 automated highlight generation.
//
// Read-only playlist of the clips the auto-replay pipeline tagged during
// the innings (boundaries, wickets, catches, milestones). Entries stream
// in live via `highlight_added` control events; the seed list arrives in
// the control snapshot on reconnect.

import { useControlState } from "../hooks/useControlState";

const EVENT_LABEL: Record<string, string> = {
  four: "FOUR",
  six: "SIX",
  wicket: "WICKET",
  catch: "CATCH",
  milestone: "MILESTONE",
};

export function HighlightsPanel() {
  const control = useControlState();
  const highlights = control.highlights;

  return (
    <section className="flex flex-col gap-2 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Innings Highlights
        <span className="font-mono text-[10px] normal-case">
          {highlights.length} clips
        </span>
      </header>

      {highlights.length === 0 ? (
        <div className="text-[11px] text-muted-foreground">
          Auto-tagged boundaries, wickets and milestones appear here as
          the innings progresses.
        </div>
      ) : (
        <div className="flex max-h-48 flex-col gap-1 overflow-y-auto">
          {highlights.map((entry, index) => (
            <div
              key={entry.replay_id}
              className="flex items-center justify-between gap-2 rounded-md border border-border bg-background/60 px-2 py-1 text-[11px]"
            >
              <div className="flex min-w-0 items-center gap-2">
                <span className="w-6 shrink-0 font-mono text-muted-foreground">
                  {index + 1}
                </span>
                <span className="font-medium">
                  {EVENT_LABEL[entry.event] ?? entry.event.toUpperCase()}
                </span>
                {entry.match_id && (
                  <span className="truncate font-mono text-muted-foreground">
                    {entry.match_id.slice(0, 8)}
                  </span>
                )}
              </div>
              <span className="shrink-0 font-mono text-muted-foreground">
                {new Date(entry.created_at_ms).toLocaleTimeString()}
              </span>
            </div>
          ))}
        </div>
      )}
    </section>
  );
}
