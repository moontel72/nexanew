// PGM/PVW vision switcher state machine.
//
// The director UI owns the *program/preview* state and drives the media
// engine through a control contract. Cut swaps instantly, Fade/Stinger
// hold the transition for the configured duration (the Stinger overlay
// renders in the React tree while `transitioning` is true).

import {
  createContext,
  useCallback,
  useContext,
  useRef,
  useState,
  type ReactNode,
} from "react";

import { env } from "../utils";

export interface FeedRef {
  roomId: string;
  cameraId: string;
}

export type TransitionKind = "cut" | "fade" | "stinger";

export interface DirectorState {
  pgm: FeedRef | null;
  pvw: FeedRef | null;
  transitioning: boolean;
  transition: TransitionKind;
}

interface DirectorApi {
  state: DirectorState;
  /** Sets the preview bus. */
  preview(feed: FeedRef): void;
  /** Immediate hard cut (PVW → PGM). */
  cut(): void;
  /** Fade transition (PVW → PGM) over `durationMs`. */
  fade(durationMs?: number): void;
  /** Stinger transition with an animated overlay between sources. */
  stinger(durationMs?: number): void;
}

const DirectorContext = createContext<DirectorApi | null>(null);

/**
 * Future backend control contract. Phase 4 keeps the mix local to the
 * Studio GUI; Phase 5 wires this to `POST /api/v1/program/transition` on
 * `todd-signaling` so the SFU can switch the public program output too.
 */
async function notifyProgramTransition(
  feed: FeedRef,
  transition: TransitionKind,
): Promise<void> {
  try {
    await fetch(`${env.apiBaseUrl}/api/v1/program/transition`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(env.adminToken
          ? { Authorization: `Bearer ${env.adminToken}` }
          : {}),
      },
      body: JSON.stringify({
        room_id: feed.roomId,
        camera_id: feed.cameraId,
        transition,
      }),
    });
  } catch {
    // Control endpoint not deployed yet — the local mix still updates.
  }
}

export function DirectorProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<DirectorState>({
    pgm: null,
    pvw: null,
    transitioning: false,
    transition: "cut",
  });
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  const preview = useCallback((feed: FeedRef) => {
    setState((s) => ({ ...s, pvw: feed }));
  }, []);

  const execute = useCallback(
    (feed: FeedRef, transition: TransitionKind, durationMs: number) => {
      setState((s) => ({
        ...s,
        pvw: feed,
        transitioning: durationMs > 0,
        transition,
      }));
      if (timer.current) clearTimeout(timer.current);
      const apply = () => {
        setState((s) => ({
          ...s,
          pgm: feed,
          pvw: s.pgm,
          transitioning: false,
        }));
        void notifyProgramTransition(feed, transition);
      };
      if (durationMs > 0) {
        timer.current = setTimeout(apply, durationMs);
      } else {
        apply();
      }
    },
    [],
  );

  const cut = useCallback(() => {
    if (!state.pvw) return;
    execute(state.pvw, "cut", 0);
  }, [execute, state.pvw]);

  const fade = useCallback(
    (durationMs = 600) => {
      if (!state.pvw) return;
      execute(state.pvw, "fade", durationMs);
    },
    [execute, state.pvw],
  );

  const stinger = useCallback(
    (durationMs = 1200) => {
      if (!state.pvw) return;
      execute(state.pvw, "stinger", durationMs);
    },
    [execute, state.pvw],
  );

  return (
    <DirectorContext.Provider value={{ state, preview, cut, fade, stinger }}>
      {children}
    </DirectorContext.Provider>
  );
}

export function useDirector(): DirectorApi {
  const ctx = useContext(DirectorContext);
  if (!ctx) throw new Error("useDirector must be used inside DirectorProvider");
  return ctx;
}
