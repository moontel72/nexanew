import { useControlState } from "./useControlState";
import type { Room } from "../lib/api/types";

export interface RoomsFeed {
  rooms: Room[];
  error: string | null;
}

/**
 * Live room list driven by the control-plane WebSocket (push), replacing
 * the previous 5s REST polling. The server snapshot arrives on connect
 * and camera/program mutations update the list incrementally.
 */
export function useRooms(token: string): RoomsFeed {
  const state = useControlState(token);

  return {
    rooms: state.rooms,
    error: state.connected ? null : state.error ?? (token ? "connecting…" : null),
  };
}
