import { useMemo, useState } from "react";
import { DirectorProvider } from "./lib/director/directorService";
import { useRooms } from "./hooks/useRooms";
import { useTelemetry } from "./hooks/useTelemetry";
import { env } from "./lib/utils";
import { MultiviewGrid } from "./components/MultiviewGrid";
import { VisionSwitcher } from "./components/VisionSwitcher";
import { ReplayDirector } from "./components/ReplayDirector";
import { Scoreboard } from "./components/Scoreboard";
import { SegmentManager } from "./components/SegmentManager";
import { OverlayController } from "./components/overlays/OverlayController";

export default function App() {
  const { rooms } = useRooms(env.adminToken);
  const telemetry = useTelemetry();
  const [matchId] = useState<string | null>("demo");
  const [overlayEvent, setOverlayEvent] = useState<string | null>(null);

  const feeds = useMemo(
    () =>
      rooms.flatMap((room) =>
        room.cameras.map((camera) => ({
          roomId: room.id,
          cameraId: camera.id,
        })),
      ),
    [rooms],
  );

  const cameraIds = useMemo(
    () => feeds.map((feed) => feed.cameraId),
    [feeds],
  );

  return (
    <DirectorProvider>
      <div className="grid h-screen grid-cols-[minmax(0,1fr)_340px] bg-background">
        {/* Program / multiview area */}
        <main className="relative flex min-w-0 flex-col gap-2 overflow-hidden p-2">
          <Scoreboard matchId={matchId} />
          <div className="relative min-h-0 flex-1">
            <MultiviewGrid
              feeds={feeds}
              viewerToken={env.viewerToken}
              columns={feeds.length > 8 ? 4 : feeds.length > 2 ? 3 : 2}
            />
            <OverlayController event={overlayEvent} />
          </div>
          <footer className="flex items-center justify-between text-xs text-muted-foreground">
            <span>
              {telemetry
                ? `${telemetry.streams.length} active streams · ${telemetry.ice_sessions.length} sessions`
                : "connecting telemetry…"}
            </span>
            <button
              className="rounded border border-border px-2 py-1 hover:bg-muted"
              onClick={() => setOverlayEvent("SIX")}
            >
              Test 3D SIX
            </button>
          </footer>
        </main>

        {/* Director control sidebar */}
        <aside className="flex min-h-0 flex-col gap-3 overflow-y-auto border-l border-border p-3">
          <VisionSwitcher />
          <ReplayDirector
            roomId={feeds[0]?.roomId ?? ""}
            cameraIds={cameraIds}
            adminToken={env.adminToken}
          />
          <SegmentManager onFire={() => setOverlayEvent("BREAK")} />
        </aside>
      </div>
    </DirectorProvider>
  );
}
