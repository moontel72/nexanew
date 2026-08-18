import { useScoreboard } from "../lib/scoreboard/scoreboardService";

export interface ScoreboardProps {
  matchId: string | null;
}

/** Broadcast lower-third: live ball-by-ball score from the manager API. */
export function Scoreboard({ matchId }: ScoreboardProps) {
  const { score, live } = useScoreboard(matchId);

  return (
    <section className="rounded-md border border-border bg-gradient-to-r from-slate-900 to-slate-800 p-3">
      <div className="flex items-center justify-between gap-4">
        <div className="min-w-0">
          <div className="truncate text-xs text-muted-foreground">
            {score.battingTeam} vs {score.bowlingTeam}
          </div>
          <div className="text-2xl font-bold tabular-nums">
            {score.runs}/{score.wickets}
            <span className="ml-2 text-sm font-medium text-muted-foreground">
              {score.overs.toFixed(1)} ov
            </span>
          </div>
        </div>

        <div className="hidden gap-4 text-xs md:flex">
          <div>
            <div className="text-muted-foreground">Striker</div>
            <div className="font-medium">{score.batterOnStrike}</div>
          </div>
          <div>
            <div className="text-muted-foreground">Non-striker</div>
            <div className="font-medium">{score.batterNonStrike}</div>
          </div>
          <div>
            <div className="text-muted-foreground">Bowler</div>
            <div className="font-medium">{score.bowler}</div>
          </div>
          <div>
            <div className="text-muted-foreground">CRR</div>
            <div className="font-medium tabular-nums">
              {score.runRate.toFixed(2)}
            </div>
          </div>
        </div>

        <div className="flex items-center gap-1">
          {score.recentBalls.map((ball, i) => (
            <span
              key={i}
              className={
                ball === "W"
                  ? "rounded bg-destructive px-1.5 py-0.5 text-xs font-semibold"
                  : ball === "4" || ball === "6"
                    ? "rounded bg-accent px-1.5 py-0.5 text-xs font-semibold"
                    : "rounded bg-muted px-1.5 py-0.5 text-xs"
              }
            >
              {ball}
            </span>
          ))}
        </div>
      </div>

      <div className="mt-1 text-right text-[10px] uppercase tracking-wider text-muted-foreground">
        {live ? "live" : "last known score"}
      </div>
    </section>
  );
}
