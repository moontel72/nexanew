// Ball-by-ball scoreboard data source.
//
// The Studio GUI reads the media engine's cached scoreboard feed
// (`GET /api/v1/cricket/live/{match_id}`) rather than reaching the
// cricket-manager origin directly. The `todd-signaling` process owns the
// external sync/polling and applies the lower-third mapping server-side,
// so every Studio panel sees one consistent state.

import { useEffect, useState } from "react";
import { env } from "../utils";
import { getToken } from "../auth/authStore";

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
}

/** Wire shape returned by `todd-signaling` (snake_case). */
interface BallByBallStateDto {
  match_id: string;
  batting_team: string;
  bowling_team: string;
  runs: number;
  wickets: number;
  overs: number;
  run_rate: number;
  batter_on_strike: string;
  batter_non_strike: string;
  bowler: string;
  recent_balls: string[];
  updated_at_ms: number;
}

function mapBallByBall(raw: BallByBallStateDto): BallByBallState {
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
  };
}

export function useScoreboard(matchId: string | null, pollMs = 3000) {
  const [state, setState] = useState<BallByBallState | null>(null);
  const [live, setLive] = useState(false);

  useEffect(() => {
    if (!matchId) return;

    let cancelled = false;
    const poll = async () => {
      try {
        const token = getToken();
        const res = await fetch(
          `${env.apiBaseUrl}/api/v1/cricket/live/${encodeURIComponent(matchId)}`,
          {
            headers: {
              Accept: "application/json",
              ...(token
                ? { Authorization: `Bearer ${token}` }
                : {}),
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
  }, [matchId, pollMs]);

  return { score: state, live };
}
