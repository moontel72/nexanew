// Direct-render WHEP tile: the video element is mounted as a bare DOM
// node and `srcObject` is bound imperatively — React never touches the
// element after mount, so no re-render, overlay, state-manager flag or
// virtual-DOM reconciliation can detach the MediaStream and leave a
// black tile while egress bytes flow.

import { useWhepPlayer } from "../hooks/useWhepPlayer";
import { whepWatchUrl } from "../lib/api/client";
import { cn } from "../lib/utils";

export interface MultiviewTileProps {
  roomId: string;
  cameraId: string;
  label?: string;
  /** Whether the camera is actively ingesting (telemetry-driven). */
  live?: boolean;
  active?: "pgm" | "pvw" | null;
  /** Full-frame mode: no rounding/border so the tile fills the canvas. */
  flush?: boolean;
  onSelect?: () => void;
}

/** One real-time WHEP player tile in the multiviewer grid. */
export function MultiviewTile({
  roomId,
  cameraId,
  label,
  live = true,
  active,
  flush = false,
  onSelect,
}: MultiviewTileProps) {
  const url = whepWatchUrl(roomId, cameraId);
  const { ref, connected, error, rendering } = useWhepPlayer(url, live);

  return (
    <div
      role="button"
      tabIndex={0}
      onClick={onSelect}
      className={cn(
        "group relative h-full w-full overflow-hidden bg-black text-left",
        flush ? "border-0 rounded-none" : "rounded-md border border-border",
        active === "pgm" && "program-active",
        active === "pvw" && "preview-active",
      )}
    >
      {/* Fail-safe direct mount: inline styles force visibility so no
          stylesheet rule, wrapper transform or overlay can hide the
          decoded frames. */}
      <video
        ref={ref}
        autoPlay
        playsInline
        muted
        style={{
          display: "block",
          position: "absolute",
          inset: 0,
          width: "100%",
          height: "100%",
          objectFit: "cover",
          opacity: 1,
          visibility: "visible",
          background: "#000",
        }}
      />
      <div className="absolute inset-x-0 top-0 flex items-center justify-between bg-black/60 px-2 py-1 text-xs">
        <span className="font-mono">{label ?? `${roomId}/${cameraId}`}</span>
        <span className={cn(connected ? "text-emerald-400" : "text-amber-400")}>
          {!live ? "OFF" : connected ? "LIVE" : "…"}
        </span>
      </div>
      {error && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/70 p-2 text-center text-xs text-destructive">
          {error}
        </div>
      )}
      {connected && !rendering && (
        <div className="absolute inset-x-0 bottom-0 flex justify-center bg-black/60 px-2 py-1 text-[10px] text-amber-400">
          waiting for video frames…
        </div>
      )}
    </div>
  );
}
