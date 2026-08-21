import { useEffect, useState } from "react";
import {
  connectControl,
  type ControlFeed,
  type ControlState,
} from "../lib/ws/control";
import { getToken, onAuthChange } from "../lib/auth/authStore";

const EMPTY_STATE: ControlState = {
  connected: false,
  error: null,
  rooms: [],
  programs: {},
  audioMixes: {},
  overlays: {},
  forwarders: {},
  cricket: null,
  scores: {},
  replays: {},
};

/** One shared control-plane feed per app instance (and per SSO JWT),
 * consumed by every panel that renders live broadcast state. */
let sharedFeed: ControlFeed | undefined;
let sharedToken: string | undefined;
let sharedRefs = 0;

/** Subscribes to the control-plane WebSocket. Returns the latest folded
 * state; `connected` flips false on socket loss (the feed reconnects
 * itself). The token is read from the auth store, so the feed follows
 * login/logout automatically. */
export function useControlState(): ControlState {
  const [token, setToken] = useState<string | null>(() => getToken());
  const [state, setState] = useState<ControlState>(
    () => sharedFeed?.getState() ?? EMPTY_STATE,
  );

  // Keep the token (and therefore the feed) in sync with the auth store.
  useEffect(() => onAuthChange(() => setToken(getToken())), []);

  useEffect(() => {
    if (!token) return;

    if (!sharedFeed || sharedToken !== token) {
      sharedFeed?.close();
      sharedFeed = connectControl();
      sharedToken = token;
    }
    const feed = sharedFeed;
    const unsubscribe = feed.subscribe(setState);
    sharedRefs += 1;
    return () => {
      unsubscribe();
      sharedRefs -= 1;
      // Last consumer unmounts (e.g. sign out) — close the socket.
      if (sharedRefs === 0) {
        sharedFeed?.close();
        sharedFeed = undefined;
        sharedToken = undefined;
      }
    };
  }, [token]);

  return state;
}
