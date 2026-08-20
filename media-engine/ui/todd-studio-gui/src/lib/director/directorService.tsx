// PGM/PVW vision switcher state machine.
//
// Phase 2 contract: the server (`POST /api/v1/program/transition`) is the
// source of truth for the program bus. Every Cut/Fade/Wipe/Stinger and
// scene apply is dispatched to the media engine; the director state is
// confirmed from the control-plane WebSocket (`program_changed` events)
// instead of optimistic local swaps. When the control feed is offline the
// HTTP response is applied directly so the switcher keeps working in
// degraded mode.

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from "react";

import { getToken } from "../auth/authStore";
import { api } from "../api/client";
import { useControlState } from "../../hooks/useControlState";
import type {
  ProgramState,
  SceneLayout,
  TransitionKind,
} from "../api/types";

export interface FeedRef {
  roomId: string;
  cameraId: string;
}

export interface DirectorState {
  pgm: FeedRef | null;
  pvw: FeedRef | null;
  transitioning: boolean;
  transition: TransitionKind;
  /** Current scene layout of the program room (server state). */
  layout: SceneLayout;
  lastError: string | null;
}

interface PendingTransition {
  roomId: string;
  cameraId: string;
  startedAt: number;
  timer: ReturnType<typeof setTimeout> | null;
}

interface DirectorApi {
  state: DirectorState;
  /** Sets the preview bus. */
  preview(feed: FeedRef): void;
  /** Immediate hard cut (PVW → PGM). */
  cut(): void;
  /** Fade transition (PVW → PGM) over `durationMs`. */
  fade(durationMs?: number): void;
  /** Luma wipe transition (PVW → PGM) over `durationMs`. */
  wipe(durationMs?: number): void;
  /** Stinger transition with an animated overlay between sources. */
  stinger(durationMs?: number): void;
  /** Selects the transition used by the next scene apply. */
  setTransition(transition: TransitionKind): void;
  /** Applies a scene layout to the program bus (server-side composite). */
  applyScene(layout: SceneLayout, durationMs?: number): void;
}

const DirectorContext = createContext<DirectorApi | null>(null);

/** How long a dispatched transition waits for WebSocket confirmation
 * before reconciling via the REST state (the WS may lag or reconnect). */
const CONFIRM_TIMEOUT_MS = 2500;

export function DirectorProvider({ children }: { children: ReactNode }) {
  const control = useControlState();

  const [state, setState] = useState<DirectorState>({
    pgm: null,
    pvw: null,
    transitioning: false,
    transition: "cut",
    layout: { kind: "fullscreen" },
    lastError: null,
  });
  const pendingRef = useRef<PendingTransition | null>(null);

  const confirm = useCallback((program: ProgramState) => {
    setState((s) => ({
      ...s,
      pgm: { roomId: program.room_id, cameraId: program.camera_id },
      pvw: s.pgm,
      transitioning: false,
      layout: program.layout ?? { kind: "fullscreen" },
      lastError: null,
    }));
  }, []);

  // Confirmation path 1: the control-plane WebSocket echoes the server's
  // program_changed event for the room we just switched.
  useEffect(() => {
    const pending = pendingRef.current;
    if (!pending) return;
    const program = control.programs[pending.roomId];
    if (
      program &&
      program.camera_id === pending.cameraId &&
      program.updated_at_ms >= pending.startedAt
    ) {
      pendingRef.current = null;
      if (pending.timer) clearTimeout(pending.timer);
      confirm(program);
    }
  }, [control.programs, confirm]);

  const dispatch = useCallback(
    (target: FeedRef, transition: TransitionKind, durationMs: number, layout?: SceneLayout) => {
      if (state.transitioning && pendingRef.current) return;

      const startedAt = Date.now();
      setState((s) => ({
        ...s,
        transitioning: true,
        transition,
        lastError: null,
      }));

      // Confirmation path 2: the WS did not confirm in time — reconcile
      // via REST so the switcher never deadlocks on a lost socket.
      const timer = setTimeout(() => {
        void (async () => {
          try {
            const program = await api.getProgram(target.roomId, getToken());
            pendingRef.current = null;
            confirm(program);
          } catch {
            // The server may have applied the switch without us hearing
            // about it; settle the state optimistically.
            pendingRef.current = null;
            setState((s) => ({
              ...s,
              transitioning: false,
              pgm: target,
              pvw: s.pgm,
            }));
          }
        })();
      }, CONFIRM_TIMEOUT_MS);

      pendingRef.current = {
        roomId: target.roomId,
        cameraId: target.cameraId,
        startedAt,
        timer,
      };

      api
        .setProgramTransition(
          {
            room_id: target.roomId,
            camera_id: target.cameraId,
            transition,
            ...(durationMs > 0 ? { duration_ms: durationMs } : {}),
            ...(layout ? { layout } : {}),
          },
          getToken(),
        )
        .then((program) => {
          // Degraded mode: without a control feed the HTTP response is
          // the confirmation.
          if (!control.connected) {
            pendingRef.current = null;
            clearTimeout(timer);
            confirm(program);
          }
        })
        .catch((error: Error) => {
          pendingRef.current = null;
          clearTimeout(timer);
          setState((s) => ({
            ...s,
            transitioning: false,
            lastError: error.message,
          }));
        });
    },
    [state.transitioning, control.connected, confirm],
  );

  const execute = useCallback(
    (transition: TransitionKind, durationMs: number) => {
      if (!state.pvw) return;
      dispatch(state.pvw, transition, durationMs);
    },
    [state.pvw, dispatch],
  );

  const preview = useCallback((feed: FeedRef) => {
    setState((s) => ({ ...s, pvw: feed }));
  }, []);

  const cut = useCallback(() => execute("cut", 0), [execute]);
  const fade = useCallback(
    (durationMs = 600) => execute("fade", durationMs),
    [execute],
  );
  const wipe = useCallback(
    (durationMs = 600) => execute("luma_wipe", durationMs),
    [execute],
  );
  const stinger = useCallback(
    (durationMs = 1200) => execute("stinger", durationMs),
    [execute],
  );

  const setTransition = useCallback((transition: TransitionKind) => {
    setState((s) => ({ ...s, transition }));
  }, []);

  const applyScene = useCallback(
    (layout: SceneLayout, durationMs = 600) => {
      if (!state.pvw) return;
      dispatch(state.pvw, state.transition, durationMs, layout);
    },
    [state.pvw, state.transition, dispatch],
  );

  return (
    <DirectorContext.Provider
      value={{
        state,
        preview,
        cut,
        fade,
        wipe,
        stinger,
        setTransition,
        applyScene,
      }}
    >
      {children}
    </DirectorContext.Provider>
  );
}

export function useDirector(): DirectorApi {
  const ctx = useContext(DirectorContext);
  if (!ctx) throw new Error("useDirector must be used inside DirectorProvider");
  return ctx;
}
