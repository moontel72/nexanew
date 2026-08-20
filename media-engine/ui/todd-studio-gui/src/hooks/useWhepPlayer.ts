import { useEffect, useRef, useState, type RefObject } from "react";
import { startWhepWatch, type WhepSession } from "../lib/webrtc/whep";

export interface WhepPlayerState {
  ref: RefObject<HTMLVideoElement>;
  connected: boolean;
  error: string | null;
}

/** Manages one WHEP viewer stream bound to a <video> element. */
export function useWhepPlayer(watchUrl: string | null): WhepPlayerState {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const sessionRef = useRef<WhepSession | null>(null);

  useEffect(() => {
    if (!watchUrl || !videoRef.current) return;

    let cancelled = false;
    setError(null);

    startWhepWatch({ watchUrl, videoEl: videoRef.current })
      .then((session) => {
        if (cancelled) {
          session.close();
          return;
        }
        sessionRef.current = session;
        setConnected(true);
      })
      .catch((e: Error) => {
        if (!cancelled) setError(e.message);
      });

    return () => {
      cancelled = true;
      sessionRef.current?.close();
      sessionRef.current = null;
      setConnected(false);
    };
  }, [watchUrl]);

  return { ref: videoRef, connected, error };
}
