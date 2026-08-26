import { useEffect, useRef, useState, type RefObject } from "react";
import {
  startWhepWatch,
  isRetryableWatchError,
  type WhepSession,
} from "../lib/webrtc/whep";

export interface WhepPlayerState {
  ref: RefObject<HTMLVideoElement>;
  connected: boolean;
  error: string | null;
}

/** Retry interval for retryable watch failures (camera not live yet,
 * transient engine/network errors). The tile stays in the "waiting" state
 * and connects automatically the moment the camera starts ingesting. */
const RETRY_DELAY_MS = 2000;

/**
 * Manages one WHEP viewer stream bound to a <video> element.
 *
 * `live` gates the watch: when it is false no WHEP POST is sent at all —
 * the session (if any) is closed and the tile returns to the waiting
 * state. Liveness is driven by the telemetry feed (the camera's WHIP ICE
 * state), so a camera that connects, drops and reconnects (WHIP takeover)
 * is watched deterministically without 409 polling. While `live` is true,
 * retryable failures (409 not-live-yet, 5xx, network) are retried until
 * the watch succeeds; permanent failures (401/403/404) surface as an
 * error.
 */
export function useWhepPlayer(
  watchUrl: string | null,
  live = true,
): WhepPlayerState {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const sessionRef = useRef<WhepSession | null>(null);

  useEffect(() => {
    let cancelled = false;
    let retryTimer: ReturnType<typeof setTimeout> | undefined;

    // Not live (or no surface): drop any active session and idle.
    if (!watchUrl || !videoRef.current || !live) {
      sessionRef.current?.close();
      sessionRef.current = null;
      setConnected(false);
      setError(null);
      return () => {
        cancelled = true;
      };
    }

    const attempt = async () => {
      if (cancelled) return;
      try {
        const session = await startWhepWatch({
          watchUrl,
          videoEl: videoRef.current!,
        });
        if (cancelled) {
          session.close();
          return;
        }
        sessionRef.current = session;
        setConnected(true);
        setError(null);
      } catch (e) {
        if (cancelled) return;
        sessionRef.current = null;
        setConnected(false);
        if (isRetryableWatchError(e)) {
          // Camera not live yet (409) or a transient failure — keep the
          // tile in the "waiting" state and retry shortly.
          retryTimer = setTimeout(attempt, RETRY_DELAY_MS);
        } else {
          setError(e instanceof Error ? e.message : String(e));
        }
      }
    };
    void attempt();

    return () => {
      cancelled = true;
      if (retryTimer) clearTimeout(retryTimer);
      sessionRef.current?.close();
      sessionRef.current = null;
      setConnected(false);
    };
  }, [watchUrl, live]);

  return { ref: videoRef, connected, error };
}
