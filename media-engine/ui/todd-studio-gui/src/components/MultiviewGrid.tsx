import { useDirector } from "../lib/director/directorService";
import { useTelemetry } from "../hooks/useTelemetry";
import { MultiviewTile } from "./MultiviewTile";

export interface CameraFeed {
  roomId: string;
  cameraId: string;
}

export interface MultiviewGridProps {
  feeds: CameraFeed[];
  columns?: 2 | 3 | 4;
}

/** Multiviewer grid: every active camera feed as a live WHEP player. */
export function MultiviewGrid({
  feeds,
  columns = 4,
}: MultiviewGridProps) {
  const { state, preview } = useDirector();
  const telemetry = useTelemetry();

  // Liveness comes from the engine's telemetry feed: a camera is live
  // when it has a WHIP ICE session in the `connected` state. Tiles only
  // start their WHEP watch for live cameras, so reconnect churn (WHIP
  // takeover) never produces 409 polling — the tile simply waits until
  // the camera is back. Before the first snapshot arrives (`telemetry`
  // null) we treat every camera as live to keep the old blind-watch
  // behaviour as a fallback.
  const liveKeys = new Set<string>();
  for (const session of telemetry?.ice_sessions ?? []) {
    if (session.kind === "whip" && session.state === "connected") {
      liveKeys.add(`${session.room_id}/${session.camera_id}`);
    }
  }
  const livenessKnown = telemetry !== null;

  return (
    <div
      className="grid h-full min-h-0 gap-2 overflow-y-auto p-2"
      style={{
        gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))`,
        gridAutoRows: "minmax(120px, 1fr)",
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
            onSelect={() => preview(feed)}
          />
        );
      })}
    </div>
  );
}
