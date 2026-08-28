import { useCallback, useEffect, useRef, useState, type RefObject } from "react";
import {
  startWhepWatch,
  isRetryableWatchError,
  type WhepSession,
} from "../lib/webrtc/whep";

export interface WhepPlayerState {
  ref: RefObject<HTMLVideoElement>;
  connected: boolean;
  /** True when decoded frames are actually being presented on the
   * element (`videoWidth > 0` and playback is not stalled). This is the
   * real render signal — `connected` alone only proves the WHEP session
   * and RTP path are up. */
  rendering: boolean;
  error: string | null;
}

/** Retry interval for retryable watch failures (camera not live yet,
 * transient engine/network errors). The tile stays in the "waiting" state
 * and connects automatically the moment the camera starts ingesting. */
const RETRY_DELAY_MS = 2000;

/** When a session is up but no frame has been decoded for this long, the
 * hook force-restarts the watch (fresh WHEP POST → fresh keyframe PLI
 * from the SFU). Heals the "LIVE badge but black tile" state. */
const BLACK_FRAME_RESTART_MS = 4000;

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
  const [rendering, setRendering] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const sessionRef = useRef<WhepSession | null>(null);
  const [generation, setGeneration] = useState(0);

  const restart = useCallback(() => setGeneration((g) => g + 1), []);

  useEffect(() => {
    let cancelled = false;
    let retryTimer: ReturnType<typeof setTimeout> | undefined;
    let frameWatchdog: ReturnType<typeof setInterval> | undefined;

    // Not live (or no surface): drop any active session and idle.
    if (!watchUrl || !videoRef.current || !live) {
      sessionRef.current?.close();
      sessionRef.current = null;
      setConnected(false);
      setRendering(false);
      setError(null);
      return () => {
        cancelled = true;
      };
    }

    const el = videoRef.current;

    const attempt = async () => {
      if (cancelled) return;
      try {
        const session = await startWhepWatch({
          watchUrl,
          videoEl: el,
        });
        if (cancelled) {
          session.close();
          return;
        }
        sessionRef.current = session;
        setConnected(true);
        setError(null);

        // Frame watchdog: `videoWidth` only grows once the first decoded
        // keyframe is presented. If RTP flows but nothing decodes (wrong
        // codec, dropped IDR), bounce the watch — the fresh session makes
        // the SFU fire a PLI at the publisher.
        let waitedMs = 0;
        frameWatchdog = setInterval(() => {
          waitedMs += 500;
          const hasFrames =
            el.videoWidth > 0 && el.videoHeight > 0 && !el.paused;
          if (hasFrames) {
            setRendering(true);
            waitedMs = 0;
            return;
          }
          setRendering(false);
          if (waitedMs >= BLACK_FRAME_RESTART_MS) {
            waitedMs = 0;
            clearInterval(frameWatchdog);
            session.close();
            sessionRef.current = null;
            setConnected(false);
            restart();
          }
        }, 500);
      } catch (e) {
        if (cancelled) return;
        sessionRef.current = null;
        setConnected(false);
        setRendering(false);
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
      if (frameWatchdog) clearInterval(frameWatchdog);
      sessionRef.current?.close();
      sessionRef.current = null;
      setConnected(false);
      setRendering(false);
    };
  }, [watchUrl, live, generation, restart]);

  return { ref: videoRef, connected, rendering, error };
}
