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

  // Liveness comes from the engine's telemetry feed. ONLY video bytes
  // count: a camera whose video RTP is above ~1 kbps is genuinely sending
  // picture right now, so a WHEP watch will succeed. Audio-only ingress
  // (Opus, 48 kHz) or a WHIP session that is merely ICE-connected must
  // NOT start the watch — that produced the 40s-after-broadcast-start
  // flash: WHEP mounted on audio-only, 409 polling, then a second flash
  // when the real video track arrived ~2 min later. Now the tile flips
  // from OFF straight to video exactly once.
  const liveKeys = new Set<string>();
  for (const stream of telemetry?.streams ?? []) {
    if (stream.ingress_bps > 1000 && (stream.clock_rate ?? 48000) >= 90000) {
      liveKeys.add(`${stream.room_id}/${stream.camera_id}`);
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
