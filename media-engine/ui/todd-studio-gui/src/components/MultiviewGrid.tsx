import { useDirector } from "../lib/director/directorService";
import { useTelemetry } from "../hooks/useTelemetry";
import { cn } from "../lib/utils";
import { MultiviewTile } from "./MultiviewTile";

export interface CameraFeed {
  roomId: string;
  cameraId: string;
  /** Source kind: "hls" cameras bypass engine liveness (no telemetry). */
  sourceKind?: "whip" | "rtsp" | "rtmp" | "hls";
  /** HLS manifest URL for RTMP/HLS bridge cameras (Stage 1). */
  hlsUrl?: string | null;
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

  // Liveness comes from the engine's telemetry feed. ANY ingress RTP
  // (audio or video) counts: a camera with audio-only traffic should
  // still trigger the WHEP watch — the 409 retry loop in useWhepPlayer
  // keeps polling until the video track registers, so the tile picks up
  // video the moment it arrives instead of staying OFF forever.
  //
  // The previous video-only gate (ingress_bps > 1000 && clock >= 90000)
  // meant audio-only cameras (common during encoder warm-up or after
  // TURN relay collapse) never subscribed at all — todd_whep_watches_total
  // stayed at zero. The black-frame watchdog in useWhepPlayer.ts handles
  // the post-subscribe stall case (connected but no decoded frames).
  const liveKeys = new Set<string>();
  for (const stream of telemetry?.streams ?? []) {
    if (stream.ingress_bps > 0) {
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
            live={
              !livenessKnown ||
              liveKeys.has(key) ||
              feed.sourceKind === "hls"
            }
            active={active}
            flush={single}
            hlsUrl={feed.hlsUrl}
            onSelect={() => preview(feed)}
          />
        );
      })}
    </div>
  );
}
