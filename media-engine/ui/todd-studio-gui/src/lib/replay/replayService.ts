// Replay director service — thin wrapper around the Phase 3
// `todd-replay` HTTP API.

import { api } from "../api/client";
import type { ReplayEventKind, ReplayInfo } from "../api/types";

export const REPLAY_SPEEDS = [0.25, 0.5, 0.75, 1.0] as const;

export interface ReplayTriggerArgs {
  roomId: string;
  cameraIds: string[];
  event: ReplayEventKind;
  lookbackMs: number;
  speed: number;
  loop?: boolean;
}

export const replayService = {
  trigger(args: ReplayTriggerArgs, token: string): Promise<ReplayInfo> {
    return api.triggerReplay(
      {
        room_id: args.roomId,
        camera_ids: args.cameraIds,
        event: args.event,
        lookback_ms: args.lookbackMs,
        speed: args.speed,
        loop_playback: args.loop,
      },
      token,
    );
  },

  list(token: string): Promise<ReplayInfo[]> {
    return api.listReplays(token);
  },

  close(replayId: string, token: string): Promise<void> {
    return api.closeReplay(replayId, token);
  },
};
