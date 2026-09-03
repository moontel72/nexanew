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
const RETRY_BASE_MS = 2000;
// Cap at 8s: a longer backoff delays the first successful watch by up to
// 15s after the camera's video finally starts (the 409 "not live" window
// is exactly when attempts are at their max).
const RETRY_MAX_MS = 8000;

/**
 * Backoff for retryable failures. 409 = "camera not live yet" is the
 * normal state while a phone publishes audio-only (video encoder still
 * starting) — exponential backoff stops the browser console from being
 * spammed with 409 resource errors every two seconds while the tile
 * still picks the feed up within a few seconds of real video RTP.
 */
function nextRetryDelay(attempts: number): number {
  return Math.min(RETRY_BASE_MS * Math.pow(2, Math.min(attempts, 3)), RETRY_MAX_MS);
}

/** When a session is up but no frame has been decoded for this long, the
 * hook force-restarts the watch (fresh WHEP POST → fresh keyframe PLI
 * from the SFU). Heals the "LIVE badge but black tile" state. 10s: a slow
 * encoder's keyframe can take several seconds after the PLI, and a 4s
 * watchdog kept bouncing sessions before the IDR ever arrived. */
const BLACK_FRAME_RESTART_MS = 10000;

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

    const attempt = async (attempts = 0) => {
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
          // tile in the "waiting" state and retry with backoff.
          retryTimer = setTimeout(
            () => void attempt(attempts + 1),
            nextRetryDelay(attempts),
          );
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
