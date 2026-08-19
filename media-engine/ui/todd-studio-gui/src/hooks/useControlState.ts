import { useEffect, useState } from "react";
import {
  connectControl,
  type ControlFeed,
  type ControlState,
} from "../lib/ws/control";

const EMPTY_STATE: ControlState = {
  connected: false,
  error: null,
  rooms: [],
  programs: {},
  cricket: null,
};

/** One shared control-plane feed per app instance (and per admin token),
 * consumed by every panel that renders live broadcast state. */
let sharedFeed: ControlFeed | undefined;
let sharedToken: string | undefined;

/** Subscribes to the control-plane WebSocket. Returns the latest folded
 * state; `connected` flips false on socket loss (the feed reconnects
 * itself). */
export function useControlState(token: string): ControlState {
  const [state, setState] = useState<ControlState>(
    () => sharedFeed?.getState() ?? EMPTY_STATE,
  );

  useEffect(() => {
    if (!token) return;

    if (!sharedFeed || sharedToken !== token) {
      sharedFeed?.close();
      sharedFeed = connectControl(token);
      sharedToken = token;
    }
    const feed = sharedFeed;
    const unsubscribe = feed.subscribe(setState);
    return () => unsubscribe();
  }, [token]);

  return state;
}
