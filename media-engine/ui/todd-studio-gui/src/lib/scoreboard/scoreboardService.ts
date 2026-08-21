// Ball-by-ball scoreboard data source.
//
// Phase 1 unified realtime: push-first, poll-fallback.
//  - PUSH (primary): the engine delivers `score_updated` events on the
//    control-plane WebSocket (fed by Laravel Reverb → Rust media engine).
//  - POLL (fallback): when the control plane has no score for the match
//    yet (offline feed, engine restart, match not configured), fall back
//    to `GET /api/v1/cricket/live/{match_id}` at a relaxed cadence.

import { useEffect, useState } from "react";
import { env } from "../utils";
import { getToken } from "../auth/authStore";
import { useControlState } from "../../hooks/useControlState";
import type { BallByBallStateDto, BallEventDto } from "../api/types";

export interface BallByBallState {
  matchId: string;
  battingTeam: string;
  bowlingTeam: string;
  runs: number;
  wickets: number;
  overs: number;
  runRate: number;
  batterOnStrike: string;
  batterNonStrike: string;
  bowler: string;
  recentBalls: string[];
  updatedAt: number;
  lastEvent: BallEventDto | null;
}

export function mapBallByBall(raw: BallByBallStateDto): BallByBallState {
  return {
    matchId: raw.match_id,
    battingTeam: raw.batting_team,
    bowlingTeam: raw.bowling_team,
    runs: raw.runs,
    wickets: raw.wickets,
    overs: raw.overs,
    runRate: raw.run_rate,
    batterOnStrike: raw.batter_on_strike,
    batterNonStrike: raw.batter_non_strike,
    bowler: raw.bowler,
    recentBalls: raw.recent_balls,
    updatedAt: raw.updated_at_ms,
    lastEvent: raw.last_event ?? null,
  };
}

/** REST fallback hook — only active while the push feed has no score. */
function useScoreboardPoll(
  matchId: string | null,
  pollMs: number,
  enabled: boolean,
): { score: BallByBallState | null; live: boolean } {
  const [state, setState] = useState<BallByBallState | null>(null);
  const [live, setLive] = useState(false);

  useEffect(() => {
    if (!enabled || !matchId) return;

    let cancelled = false;
    const poll = async () => {
      try {
        const token = getToken();
        const res = await fetch(
          `${env.apiBaseUrl}/api/v1/cricket/live/${encodeURIComponent(matchId)}`,
          {
            headers: {
              Accept: "application/json",
              ...(token ? { Authorization: `Bearer ${token}` } : {}),
            },
          },
        );
        if (!res.ok) throw new Error(`scoreboard ${res.status}`);
        const raw = (await res.json()) as BallByBallStateDto;
        if (!cancelled) {
          setState(mapBallByBall(raw));
          setLive(true);
        }
      } catch {
        // Keep the last known score; do not spam the console.
        setLive(false);
      }
    };

    poll();
    const id = setInterval(poll, pollMs);
    return () => {
      cancelled = true;
      clearInterval(id);
    };
  }, [matchId, pollMs, enabled]);

  return { score: state, live };
}

export function useScoreboard(matchId: string | null, pollMs = 3000) {
  const control = useControlState();
  const pushed = matchId ? (control.scores[matchId] ?? null) : null;

  // Poll only when the push path cannot serve this match.
  const { score: fallback, live: fallbackLive } = useScoreboardPoll(
    matchId,
    pollMs,
    pushed === null,
  );

  if (pushed) {
    return { score: mapBallByBall(pushed), live: true };
  }
  return { score: fallback, live: fallbackLive };
}
