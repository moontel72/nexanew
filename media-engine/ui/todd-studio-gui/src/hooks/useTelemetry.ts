import { useEffect, useState } from "react";
import { connectTelemetry, type TelemetryFeed } from "../lib/ws/telemetry";
import type { TelemetrySnapshot } from "../lib/api/types";

let sharedFeed: TelemetryFeed | undefined;

/** One shared telemetry socket per app, consumed by every panel. */
export function useTelemetry(): TelemetrySnapshot | null {
  const [snapshot, setSnapshot] = useState<TelemetrySnapshot | null>(null);

  useEffect(() => {
    if (!sharedFeed) sharedFeed = connectTelemetry();
    const feed = sharedFeed;
    const unsubscribe = feed.subscribe(setSnapshot);
    return () => {
      unsubscribe();
    };
  }, []);

  return snapshot;
}
