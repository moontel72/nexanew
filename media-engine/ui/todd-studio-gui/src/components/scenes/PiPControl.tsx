import type { CameraInfo, PiPConfig, SourceRef } from "../../lib/api/types";

export interface PiPControlProps {
  /** Cameras of the active room (scenes don't cross rooms). */
  cameras: CameraInfo[];
  roomId: string;
  value: PiPConfig;
  onChange(value: PiPConfig): void;
}

function cameraLabel(camera: CameraInfo | undefined, fallback: string): string {
  return camera ? (camera.label ?? camera.id) : fallback;
}

/** Picture-in-picture layout editor: main + overlay source and the
 * overlay window geometry/opacity (normalized 0–1). */
export function PiPControl({ cameras, roomId, value, onChange }: PiPControlProps) {
  const source = (source: SourceRef): SourceRef =>
    source.room_id === roomId ? source : { room_id: roomId, camera_id: cameras[0]?.id ?? "" };

  const main = source(value.main);
  const overlay = source(value.overlay);

  const setMain = (cameraId: string) =>
    onChange({ ...value, main: { room_id: roomId, camera_id: cameraId } });
  const setOverlay = (cameraId: string) =>
    onChange({ ...value, overlay: { room_id: roomId, camera_id: cameraId } });

  const slider = (
    label: string,
    key: "overlay_x" | "overlay_y" | "overlay_width" | "overlay_height" | "overlay_opacity",
    min: number,
    max: number,
    step: number,
  ) => (
    <label className="flex items-center justify-between gap-2 text-[11px] text-muted-foreground">
      {label}
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        className="min-w-0 flex-1"
        value={value[key]}
        onChange={(event) => onChange({ ...value, [key]: Number(event.target.value) })}
      />
      <span className="w-8 text-right font-mono tabular-nums">
        {value[key].toFixed(2)}
      </span>
    </label>
  );

  return (
    <div className="flex flex-col gap-2">
      <div className="grid grid-cols-2 gap-2">
        <label className="flex flex-col gap-1 text-[11px] text-muted-foreground">
          Main source
          <select
            className="rounded-md border border-input bg-background px-2 py-1 text-xs text-foreground"
            value={main.camera_id}
            onChange={(event) => setMain(event.target.value)}
          >
            {cameras.map((camera) => (
              <option key={camera.id} value={camera.id}>
                {cameraLabel(camera, camera.id)}
              </option>
            ))}
          </select>
        </label>
        <label className="flex flex-col gap-1 text-[11px] text-muted-foreground">
          Overlay source
          <select
            className="rounded-md border border-input bg-background px-2 py-1 text-xs text-foreground"
            value={overlay.camera_id}
            onChange={(event) => setOverlay(event.target.value)}
          >
            {cameras.map((camera) => (
              <option key={camera.id} value={camera.id}>
                {cameraLabel(camera, camera.id)}
              </option>
            ))}
          </select>
        </label>
      </div>
      {slider("X", "overlay_x", 0, 0.9, 0.01)}
      {slider("Y", "overlay_y", 0, 0.9, 0.01)}
      {slider("Width", "overlay_width", 0.1, 1, 0.01)}
      {slider("Height", "overlay_height", 0.1, 1, 0.01)}
      {slider("Opacity", "overlay_opacity", 0.1, 1, 0.05)}
    </div>
  );
}
