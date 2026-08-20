import { useWhepPlayer } from "../hooks/useWhepPlayer";
import { whepWatchUrl } from "../lib/api/client";
import { cn } from "../lib/utils";

export interface MultiviewTileProps {
  roomId: string;
  cameraId: string;
  label?: string;
  active?: "pgm" | "pvw" | null;
  onSelect?: () => void;
}

/** One real-time WHEP player tile in the multiviewer grid. */
export function MultiviewTile({
  roomId,
  cameraId,
  label,
  active,
  onSelect,
}: MultiviewTileProps) {
  const url = whepWatchUrl(roomId, cameraId);
  const { ref, connected, error } = useWhepPlayer(url);

  return (
    <button
      type="button"
      onClick={onSelect}
      className={cn(
        "group relative overflow-hidden rounded-md border border-border bg-muted text-left",
        active === "pgm" && "program-active",
        active === "pvw" && "preview-active",
      )}
    >
      <video
        ref={ref}
        autoPlay
        playsInline
        muted
        className="h-full w-full object-cover"
      />
      <div className="absolute inset-x-0 top-0 flex items-center justify-between bg-black/60 px-2 py-1 text-xs">
        <span className="font-mono">
          {label ?? `${roomId}/${cameraId}`}
        </span>
        <span className={cn(connected ? "text-emerald-400" : "text-amber-400")}>
          {connected ? "LIVE" : "…"}
        </span>
      </div>
      {error && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/70 p-2 text-center text-xs text-destructive">
          {error}
        </div>
      )}
    </button>
  );
}
