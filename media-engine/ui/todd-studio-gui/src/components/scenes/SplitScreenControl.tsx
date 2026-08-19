import type {
  CameraInfo,
  SplitOrientation,
  SplitScreenConfig,
  SourceRef,
} from "../../lib/api/types";
import { Button } from "../ui/Button";

export interface SplitScreenControlProps {
  /** Cameras of the active room (scenes don't cross rooms). */
  cameras: CameraInfo[];
  roomId: string;
  value: SplitScreenConfig;
  onChange(value: SplitScreenConfig): void;
}

/** Split-screen layout editor: orientation + weighted regions. */
export function SplitScreenControl({ cameras, roomId, value, onChange }: SplitScreenControlProps) {
  const firstCameraId = cameras[0]?.id ?? "";

  const setOrientation = (orientation: SplitOrientation) =>
    onChange({ ...value, orientation });

  const setRegionSource = (index: number, cameraId: string) => {
    const regions = value.regions.map((region, i) =>
      i === index
        ? { ...region, source: { room_id: roomId, camera_id: cameraId } }
        : region,
    );
    onChange({ ...value, regions });
  };

  const setRegionWeight = (index: number, weight: number) => {
    const regions = value.regions.map((region, i) =>
      i === index ? { ...region, weight } : region,
    );
    onChange({ ...value, regions });
  };

  const addRegion = () => {
    const source: SourceRef = { room_id: roomId, camera_id: firstCameraId };
    onChange({ ...value, regions: [...value.regions, { source, weight: 1 }] });
  };

  const removeRegion = (index: number) => {
    if (value.regions.length <= 2) return;
    onChange({
      ...value,
      regions: value.regions.filter((_, i) => i !== index),
    });
  };

  return (
    <div className="flex flex-col gap-2">
      <label className="flex items-center justify-between gap-2 text-[11px] text-muted-foreground">
        Orientation
        <select
          className="rounded-md border border-input bg-background px-2 py-1 text-xs text-foreground"
          value={value.orientation}
          onChange={(event) => setOrientation(event.target.value as SplitOrientation)}
        >
          <option value="horizontal">Horizontal</option>
          <option value="vertical">Vertical</option>
        </select>
      </label>

      {value.regions.map((region, index) => (
        <div key={index} className="flex items-center gap-2">
          <span className="w-5 text-right font-mono text-[10px] text-muted-foreground">
            {index + 1}
          </span>
          <select
            className="min-w-0 flex-1 rounded-md border border-input bg-background px-2 py-1 text-xs text-foreground"
            value={region.source.camera_id}
            onChange={(event) => setRegionSource(index, event.target.value)}
          >
            {cameras.map((camera) => (
              <option key={camera.id} value={camera.id}>
                {camera.label ?? camera.id}
              </option>
            ))}
          </select>
          <input
            type="range"
            min={0.1}
            max={3}
            step={0.1}
            className="w-16"
            title="weight"
            value={region.weight}
            onChange={(event) => setRegionWeight(index, Number(event.target.value))}
          />
          <span className="w-8 font-mono text-[10px] tabular-nums text-muted-foreground">
            ×{region.weight.toFixed(1)}
          </span>
          <Button
            variant="destructive"
            className="px-1.5 py-0.5 text-[10px]"
            disabled={value.regions.length <= 2}
            onClick={() => removeRegion(index)}
          >
            ✕
          </Button>
        </div>
      ))}

      <Button variant="outline" className="px-2 py-1 text-xs" onClick={addRegion}>
        + Region
      </Button>
    </div>
  );
}
