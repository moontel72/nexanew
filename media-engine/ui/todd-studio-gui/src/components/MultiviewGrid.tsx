import { useDirector } from "../lib/director/directorService";
import { useTelemetry } from "../hooks/useTelemetry";
import { cn } from "../lib/utils";
import { MultiviewTile } from "./MultiviewTile";

export interface CameraFeed {
  roomId: string;
  cameraId: string;
}

export interface MultiviewGridProps {
  feeds: CameraFeed[];
}

/** Multiviewer grid: every active camera feed as a live WHEP player.
 * The grid divides the canvas dynamically from the feed count: one
 * camera fills it, two/three/four run in a row, more wrap in rows. */
export function MultiviewGrid({ feeds }: MultiviewGridProps) {
  const { state, preview } = useDirector();
  const telemetry = useTelemetry();

  // Liveness comes from the engine's telemetry feed. Primary signal: RTP
  // ingress — a camera whose rolling bitrate is above ~1 kbps is genuinely
  // sending media right now (tracks registered, codec known), so a WHEP
  // watch is guaranteed to work. `ingress_bps` decays to zero a couple of
  // seconds after media stops; the lifetime `packets_in` counter must NOT
  // be used here — it never resets, so a stopped camera stayed "live"
  // forever (tile stuck on "…" with 409 polling instead of showing OFF).
  // The WHIP ICE sessions are a secondary signal covering the window
  // between track registration and the first RTP sample. Tiles only start
  // their WHEP watch for live cameras, so reconnect churn (WHIP takeover)
  // never produces 409 polling — the tile simply waits until the camera
  // is back. Before the first snapshot arrives (`telemetry` null) we treat
  // every camera as live to keep the old blind-watch behaviour as a
  // fallback.
  const liveKeys = new Set<string>();
  for (const stream of telemetry?.streams ?? []) {
    if (stream.ingress_bps > 1000) {
      liveKeys.add(`${stream.room_id}/${stream.camera_id}`);
    }
  }
  for (const session of telemetry?.ice_sessions ?? []) {
    // Only fully "connected" WHIP sessions count. "connecting" means the
    // offer was accepted but no media path exists yet — starting WHEP on
    // it produces the exact 409 churn the engine logs (camera not live).
    if (session.kind === "whip" && session.state === "connected") {
      liveKeys.add(`${session.room_id}/${session.camera_id}`);
    }
  }
  const livenessKnown = telemetry !== null;

  // One camera = full canvas: the tile stretches edge-to-edge (no gap,
  // no padding) so the active player truly fills the frame. Otherwise one
  // column per camera (capped at four) and the remaining cameras wrap
  // onto new rows.
  const single = feeds.length <= 1;
  const columns = single ? 1 : Math.min(feeds.length, 4);

  return (
    <div
      className={cn(
        "grid h-full min-h-0",
        single ? "p-0 gap-0" : "gap-2 overflow-y-auto p-2",
      )}
      style={{
        gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))`,
        gridAutoRows: single ? "1fr" : "minmax(120px, 1fr)",
      }}
    >
      {feeds.map((feed) => {
        const key = `${feed.roomId}/${feed.cameraId}`;
        const active =
          state.pgm?.roomId === feed.roomId &&
          state.pgm?.cameraId === feed.cameraId
            ? "pgm"
            : state.pvw?.roomId === feed.roomId &&
                state.pvw?.cameraId === feed.cameraId
              ? "pvw"
              : null;
        return (
          <MultiviewTile
            key={key}
            roomId={feed.roomId}
            cameraId={feed.cameraId}
            live={!livenessKnown || liveKeys.has(key)}
            active={active}
            flush={single}
            onSelect={() => preview(feed)}
          />
        );
      })}
    </div>
  );
}
