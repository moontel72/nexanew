import { useDirector } from "../lib/director/directorService";
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

  return (
    <div
      className="grid gap-2 p-2"
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
            active={active}
            onSelect={() => preview(feed)}
          />
        );
      })}
    </div>
  );
}
