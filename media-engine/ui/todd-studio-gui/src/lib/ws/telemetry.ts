// WebSocket telemetry client — live stream diagnostics + replay/export
// event notifications from the media engine.

import { env } from "../utils";
import type { TelemetrySnapshot } from "../api/types";

export interface TelemetryFeed {
  close(): void;
  subscribe(listener: (snapshot: TelemetrySnapshot) => void): () => void;
}

/** Connects to `GET /api/v1/telemetry/ws` and fans snapshots out. */
export function connectTelemetry(): TelemetryFeed {
  const listeners = new Set<(snapshot: TelemetrySnapshot) => void>();
  let socket: WebSocket | undefined;
  let closed = false;
  let retry: ReturnType<typeof setTimeout> | undefined;

  const scheduleReconnect = () => {
    if (closed) return;
    retry = setTimeout(connect, 2000);
  };

  function connect() {
    if (closed) return;
    const url = env.apiBaseUrl.replace(/^http/, "ws") + "/api/v1/telemetry/ws";
    socket = new WebSocket(url);
    socket.onmessage = (event) => {
      try {
        const snapshot = JSON.parse(event.data as string) as TelemetrySnapshot;
        listeners.forEach((l) => l(snapshot));
      } catch {
        // malformed frame — ignore, keep the feed alive
      }
    };
    socket.onclose = scheduleReconnect;
    socket.onerror = () => socket?.close();
  }

  connect();

  return {
    close() {
      closed = true;
      if (retry) clearTimeout(retry);
      socket?.close();
      listeners.clear();
    },
    subscribe(listener) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
  };
}
