// Automated segment / ad-timer manager.
//
// Configurable countdown timers (3 min / 5 min / custom). When a timer
// fires, the Studio UI can auto-cut to a break bumper / ad stream — the
// media-side switch is the same future `/api/v1/program/transition`
// control surface used by the vision switcher.

import { useCallback, useEffect, useRef, useState } from "react";

export const SEGMENT_PRESETS = {
  "3 min": 180,
  "5 min": 300,
} as const;

export interface SegmentManager {
  remainingSeconds: number;
  running: boolean;
  presetSeconds: number;
  start(): void;
  pause(): void;
  reset(seconds?: number): void;
  setPreset(seconds: number): void;
}

export function useSegmentManager(onFire?: () => void): SegmentManager {
  const [presetSeconds, setPreset] = useState<number>(SEGMENT_PRESETS["3 min"]);
  const [remainingSeconds, setRemaining] = useState<number>(SEGMENT_PRESETS["3 min"]);
  const [running, setRunning] = useState(false);
  const firedRef = useRef(false);

  useEffect(() => {
    if (!running) return;
    const id = setInterval(() => {
      setRemaining((s) => {
        if (s <= 1) {
          clearInterval(id);
          setRunning(false);
          if (!firedRef.current) {
            firedRef.current = true;
            onFire?.();
          }
          return 0;
        }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(id);
  }, [running, onFire]);

  const reset = useCallback(
    (seconds?: number) => {
      setRemaining(seconds ?? presetSeconds);
      firedRef.current = false;
      setRunning(false);
    },
    [presetSeconds],
  );

  return {
    remainingSeconds,
    running,
    presetSeconds,
    start: useCallback(() => setRunning(true), []),
    pause: useCallback(() => setRunning(false), []),
    reset,
    setPreset: useCallback((seconds: number) => {
      setPreset(seconds);
      setRemaining(seconds);
      firedRef.current = false;
      setRunning(false);
    }, []),
  };
}

export function formatClock(totalSeconds: number): string {
  const m = Math.floor(totalSeconds / 60)
    .toString()
    .padStart(2, "0");
  const s = (totalSeconds % 60).toString().padStart(2, "0");
  return `${m}:${s}`;
}
