import { useEffect, useMemo, useState } from "react";
import { DirectorProvider } from "./lib/director/directorService";
import { useRooms } from "./hooks/useRooms";
import { useControlState } from "./hooks/useControlState";
import { env } from "./lib/utils";
import {
  applySsoFromUrl,
  clearToken,
  getEmail,
  isAuthenticated,
  onAuthChange,
  takeMatchHint,
} from "./lib/auth/authStore";
import { Login } from "./components/Login";
import { Button } from "./components/ui/Button";
import { UpdateManager } from "./components/UpdateManager";
import { isDesktopShell, openManual } from "./lib/docs";
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
import { WatermarkControl } from "./components/WatermarkControl";
import { WagonWheelMap } from "./components/WagonWheelMap";
import { BroadcastPanel } from "./components/BroadcastPanel";
import { OverlayController } from "./components/overlays/OverlayController";
import { TelemetryDashboard } from "./components/TelemetryDashboard";
import { VarReviewPanel } from "./components/VarReviewPanel";
import { PollOverlay, PollPanel } from "./components/PollOverlay";
import { HighlightsPanel } from "./components/HighlightsPanel";

export default function App() {
  const [authed, setAuthed] = useState(() => isAuthenticated());

  // Phase 1 unified SSO + deep-link: adopt a `?sso=` ticket and/or a
  // `?match=` hint BEFORE the first auth gate evaluation.
  useEffect(() => {
    applySsoFromUrl();
    setAuthed(isAuthenticated());
  }, []);

  // Follow login / logout / token expiry from the auth store.
  useEffect(() => onAuthChange(() => setAuthed(isAuthenticated())), []);

  const { rooms } = useRooms();
  const control = useControlState();
  const [overlayEvent, setOverlayEvent] = useState<string | null>(null);

  // Deep-link match hint (stripped from the URL on first read).
  const matchHint = useMemo(() => takeMatchHint(), []);

  // Active match: the engine-pushed context (mirrored from the Cricket
  // Manager's "active match" selection) wins; then the first configured
  // match; then the build-time env value / deep-link hint bridges the gap
  // until the engine delivers its config snapshot.
  const matchId =
    control.cricket?.active_match_id ??
    control.cricket?.match_configs[0]?.match_id ??
    matchHint ??
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
            {isDesktopShell() && (
              <Button
                variant="outline"
                className="px-2 py-1 text-xs"
                title="Check for app updates"
                onClick={() => window.dispatchEvent(new Event("todd:check-updates"))}
              >
                Check for Updates
              </Button>
            )}
            <Button
              variant="outline"
              className="px-2 py-1 text-xs"
              title="Operator manual — opens docs.traceodd.com"
              onClick={() => openManual("/cricket/book2-todd-studio")}
            >
              ? Manual
            </Button>
            <Button
              variant="outline"
              className="px-2 py-1 text-xs"
              onClick={() => clearToken()}
            >
              Sign out
            </Button>
          </div>
        </header>

        {/* Desktop-only: silent startup update check + update dialog. */}
        <UpdateManager />

        <div className="director-grid min-h-0 flex-1">
          {/* Program / multiview area */}
          <main className="director-program relative flex min-w-0 flex-col gap-2 overflow-hidden p-2">
            <Scoreboard matchId={matchId} />
            <div className="relative min-h-0 flex-1">
              <MultiviewGrid
                feeds={feeds}
                columns={feeds.length > 8 ? 4 : feeds.length > 2 ? 3 : 2}
              />
              <OverlayController event={overlayEvent} />
              <PollOverlay />
            </div>
            <TelemetryDashboard />
          </main>

          {/* Director control panel — Phase 2 Option A layout (pure CSS
              grid areas; see styles.css). Two zones:
              · priority: high-frequency live controls, pinned top
              · config:   one-time / static setup, collapsible accordion */}
          <aside className="director-panel">
            <section className="priority-zone" aria-label="Live controls">
              <WagonWheelMap />
              <VisionSwitcher />
              <TransitionBar />
              <ReplayDirector
                roomId={feeds[0]?.roomId ?? ""}
                cameraIds={cameraIds}
              />
              <VarReviewPanel />
              <OverlayPanel onLocalEvent={setOverlayEvent} />
              <AudioMixer />
            </section>

            <details className="config-zone" open>
              <summary>Setup &amp; Configuration</summary>
              <div className="config-zone-content">
                <InputPanel />
                <WatermarkControl />
                <PollPanel />
                <SceneComposer />
                <SegmentManager onFire={() => setOverlayEvent("BREAK")} />
                <BroadcastPanel />
                <HighlightsPanel />
                <SettingsPanel />
              </div>
            </details>
          </aside>
        </div>
      </div>
    </DirectorProvider>
  );
}
