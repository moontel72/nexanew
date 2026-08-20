import { useEffect, useMemo, useState } from "react";
import { DirectorProvider } from "./lib/director/directorService";
import { useRooms } from "./hooks/useRooms";
import { useTelemetry } from "./hooks/useTelemetry";
import { useControlState } from "./hooks/useControlState";
import { env } from "./lib/utils";
import {
  clearToken,
  getEmail,
  isAuthenticated,
  onAuthChange,
} from "./lib/auth/authStore";
import { Login } from "./components/Login";
import { Button } from "./components/ui/Button";
import { MultiviewGrid } from "./components/MultiviewGrid";
import { VisionSwitcher } from "./components/VisionSwitcher";
import { TransitionBar } from "./components/TransitionBar";
import { ReplayDirector } from "./components/ReplayDirector";
import { Scoreboard } from "./components/Scoreboard";
import { SegmentManager } from "./components/SegmentManager";
import { InputPanel } from "./components/InputPanel";
import { SettingsPanel } from "./components/SettingsPanel";
import { SceneComposer } from "./components/scenes/SceneComposer";
import { AudioMixer } from "./components/AudioMixer";
import { OverlayPanel } from "./components/OverlayPanel";
import { BroadcastPanel } from "./components/BroadcastPanel";
import { OverlayController } from "./components/overlays/OverlayController";

export default function App() {
  const [authed, setAuthed] = useState(() => isAuthenticated());

  // Follow login / logout / token expiry from the auth store.
  useEffect(() => onAuthChange(() => setAuthed(isAuthenticated())), []);

  const { rooms } = useRooms();
  const telemetry = useTelemetry();
  const control = useControlState();
  const [overlayEvent, setOverlayEvent] = useState<string | null>(null);

  // Active match: the runtime sync config wins; the build-time env value
  // only bridges the gap until a director configures matches.
  const matchId =
    control.cricket?.match_configs[0]?.match_id ??
    (env.cricketMatchIds.split(",")[0]?.trim() || null);

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

  // Phase-1 SSO gate: no director UI until the Laravel login succeeds.
  if (!authed) {
    return <Login onAuthenticated={() => setAuthed(true)} />;
  }

  return (
    <DirectorProvider>
      <div className="flex h-screen flex-col bg-background">
        {/* Session bar: signed-in identity + sign out. */}
        <header className="flex items-center justify-between border-b border-border px-4 py-2">
          <div className="text-sm font-semibold tracking-wide">Todd Studio</div>
          <div className="flex items-center gap-3">
            <span className="text-xs text-muted-foreground">{getEmail()}</span>
            <Button
              variant="outline"
              className="px-2 py-1 text-xs"
              onClick={() => clearToken()}
            >
              Sign out
            </Button>
          </div>
        </header>

        <div className="grid min-h-0 flex-1 grid-cols-[minmax(0,1fr)_340px]">
          {/* Program / multiview area */}
          <main className="relative flex min-w-0 flex-col gap-2 overflow-hidden p-2">
            <Scoreboard matchId={matchId} />
            <div className="relative min-h-0 flex-1">
              <MultiviewGrid
                feeds={feeds}
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
              <span className={control.connected ? "text-emerald-400" : "text-amber-400"}>
                {control.connected ? "control plane live" : "control plane offline"}
              </span>
            </footer>
          </main>

          {/* Director control sidebar */}
          <aside className="flex min-h-0 flex-col gap-3 overflow-y-auto border-l border-border p-3">
            <InputPanel />
            <VisionSwitcher />
            <TransitionBar />
            <SceneComposer />
            <AudioMixer />
            <OverlayPanel onLocalEvent={setOverlayEvent} />
            <BroadcastPanel />
            <ReplayDirector
              roomId={feeds[0]?.roomId ?? ""}
              cameraIds={cameraIds}
            />
            <SegmentManager onFire={() => setOverlayEvent("BREAK")} />
            <SettingsPanel />
          </aside>
        </div>
      </div>
    </DirectorProvider>
  );
}
