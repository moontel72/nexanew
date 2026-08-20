import { useEffect, useMemo, useState } from "react";
import { useDirector } from "../../lib/director/directorService";
import { useControlState } from "../../hooks/useControlState";
import type {
  CameraInfo,
  PiPConfig,
  SceneLayout,
  SideBySideConfig,
  SourceRef,
  SplitScreenConfig,
} from "../../lib/api/types";
import { PiPControl } from "./PiPControl";
import { SplitScreenControl } from "./SplitScreenControl";
import { Button } from "../ui/Button";

type LayoutKind = "fullscreen" | "picture_in_picture" | "split_screen" | "side_by_side";

const LAYOUT_KINDS: Array<{ value: LayoutKind; label: string }> = [
  { value: "fullscreen", label: "Fullscreen" },
  { value: "picture_in_picture", label: "Picture in Picture" },
  { value: "side_by_side", label: "Side by Side" },
  { value: "split_screen", label: "Split Screen" },
];

function sourceOf(roomId: string, cameraId: string): SourceRef {
  return { room_id: roomId, camera_id: cameraId };
}

function defaultPip(roomId: string, cameras: CameraInfo[]): PiPConfig {
  return {
    main: sourceOf(roomId, cameras[0]?.id ?? ""),
    overlay: sourceOf(roomId, cameras[1]?.id ?? cameras[0]?.id ?? ""),
    overlay_x: 0.72,
    overlay_y: 0.05,
    overlay_width: 0.26,
    overlay_height: 0.26,
    overlay_opacity: 1.0,
  };
}

function defaultSplit(roomId: string, cameras: CameraInfo[]): SplitScreenConfig {
  const second = cameras[1]?.id ?? cameras[0]?.id ?? "";
  return {
    orientation: "horizontal",
    regions: [
      { source: sourceOf(roomId, cameras[0]?.id ?? ""), weight: 1 },
      { source: sourceOf(roomId, second), weight: 1 },
    ],
  };
}

function defaultSideBySide(roomId: string, cameras: CameraInfo[]): SideBySideConfig {
  return {
    left: sourceOf(roomId, cameras[0]?.id ?? ""),
    right: sourceOf(roomId, cameras[1]?.id ?? cameras[0]?.id ?? ""),
  };
}

/** Scene composer: builds PiP / split / side-by-side layouts and applies
 * them to the server-side program mixer. */
export function SceneComposer() {
  const control = useControlState();
  const director = useDirector();

  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";
  const activeRoom = useMemo(
    () => control.rooms.find((room) => room.id === activeRoomId) ?? null,
    [control.rooms, activeRoomId],
  );
  const cameras = activeRoom?.cameras ?? [];

  const [kind, setKind] = useState<LayoutKind>("fullscreen");
  const [pip, setPip] = useState<PiPConfig>(() => defaultPip(activeRoomId, cameras));
  const [split, setSplit] = useState<SplitScreenConfig>(() => defaultSplit(activeRoomId, cameras));
  const [sideBySide, setSideBySide] = useState<SideBySideConfig>(() =>
    defaultSideBySide(activeRoomId, cameras),
  );

  // Re-anchor the drafts when the director moves to another room.
  useEffect(() => {
    if (!activeRoomId) return;
    setPip(defaultPip(activeRoomId, cameras));
    setSplit(defaultSplit(activeRoomId, cameras));
    setSideBySide(defaultSideBySide(activeRoomId, cameras));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeRoomId]);

  const layout: SceneLayout | null = useMemo(() => {
    switch (kind) {
      case "fullscreen":
        return { kind: "fullscreen" };
      case "picture_in_picture":
        return { kind: "picture_in_picture", ...pip };
      case "split_screen":
        return { kind: "split_screen", ...split };
      case "side_by_side":
        return { kind: "side_by_side", ...sideBySide };
    }
  }, [kind, pip, split, sideBySide]);

  const ready = cameras.length >= 1 && !!activeRoomId;

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Scene Composer
      </header>

      <div className="flex flex-col gap-1">
        <span className="text-[11px] text-muted-foreground">
          Room: <span className="text-foreground">{activeRoom?.name ?? "none"}</span>
        </span>
        <span className="text-[11px] text-muted-foreground">
          On air layout:{" "}
          <span className="font-mono text-foreground">{director.state.layout.kind}</span>
        </span>
      </div>

      <select
        className="rounded-md border border-input bg-background px-2 py-1 text-xs"
        value={kind}
        onChange={(event) => setKind(event.target.value as LayoutKind)}
      >
        {LAYOUT_KINDS.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>

      {kind === "picture_in_picture" && (
        <PiPControl cameras={cameras} roomId={activeRoomId} value={pip} onChange={setPip} />
      )}
      {kind === "split_screen" && (
        <SplitScreenControl cameras={cameras} roomId={activeRoomId} value={split} onChange={setSplit} />
      )}
      {kind === "side_by_side" && (
        <div className="grid grid-cols-2 gap-2">
          <label className="flex flex-col gap-1 text-[11px] text-muted-foreground">
            Left
            <select
              className="rounded-md border border-input bg-background px-2 py-1 text-xs text-foreground"
              value={sideBySide.left.camera_id}
              onChange={(event) =>
                setSideBySide({
                  ...sideBySide,
                  left: sourceOf(activeRoomId, event.target.value),
                })
              }
            >
              {cameras.map((camera) => (
                <option key={camera.id} value={camera.id}>
                  {camera.label ?? camera.id}
                </option>
              ))}
            </select>
          </label>
          <label className="flex flex-col gap-1 text-[11px] text-muted-foreground">
            Right
            <select
              className="rounded-md border border-input bg-background px-2 py-1 text-xs text-foreground"
              value={sideBySide.right.camera_id}
              onChange={(event) =>
                setSideBySide({
                  ...sideBySide,
                  right: sourceOf(activeRoomId, event.target.value),
                })
              }
            >
              {cameras.map((camera) => (
                <option key={camera.id} value={camera.id}>
                  {camera.label ?? camera.id}
                </option>
              ))}
            </select>
          </label>
        </div>
      )}

      <Button
        disabled={!ready || !layout || director.state.transitioning || !director.state.pvw}
        onClick={() => layout && director.applyScene(layout)}
      >
        {director.state.transitioning ? "Applying…" : "Apply Scene"}
      </Button>

      {!director.state.pvw && (
        <div className="text-[11px] text-muted-foreground">
          Select a Preview (PVW) source first to apply a scene.
        </div>
      )}
    </section>
  );
}
