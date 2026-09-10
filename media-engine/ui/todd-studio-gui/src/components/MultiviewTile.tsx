// Tile player: renders one camera feed as either a WHEP (WebRTC)
// direct-mount or an HLS <video> element. The mode is chosen by props:
// when `hlsUrl` is set the tile uses hls.js (Stage 1 bridge); otherwise
// the WHEP player subscribes to the engine's SFU egress.
//
// Direct-render: the video element is mounted as a bare DOM node and
// `srcObject` / `src` is bound imperatively — React never touches the
// element after mount, so no re-render, overlay, state-manager flag or
// virtual-DOM reconciliation can detach the MediaStream and leave a
// black tile while egress bytes flow.

import { useEffect, useRef, useState } from "react";
import { useWhepPlayer } from "../hooks/useWhepPlayer";
import { whepWatchUrl } from "../lib/api/client";
import { startHlsPlayer, type HlsPlayerSession } from "../lib/hls/hlsPlayer";
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
  /** HLS manifest URL — when set, the tile plays HLS instead of WHEP. */
  hlsUrl?: string | null;
  onSelect?: () => void;
}

/** One real-time player tile in the multiviewer grid.
 * Supports WHEP (WebRTC) and HLS modes. */
export function MultiviewTile({
  roomId,
  cameraId,
  label,
  live = true,
  active,
  flush = false,
  hlsUrl,
  onSelect,
}: MultiviewTileProps) {
  const isHls = !!hlsUrl;

  // WHEP mode: the existing hook manages the RTCPeerConnection lifecycle.
  const whepUrl = isHls ? null : whepWatchUrl(roomId, cameraId);
  const whep = useWhepPlayer(whepUrl, live && !isHls);

  // HLS mode: attach hls.js to a <video> ref.
  const hlsRef = useRef<HTMLVideoElement>(null);
  const [hlsConnected, setHlsConnected] = useState(false);
  const [hlsRendering, setHlsRendering] = useState(false);
  const [hlsError, setHlsError] = useState<string | null>(null);

  useEffect(() => {
    if (!isHls || !live || !hlsUrl || !hlsRef.current) {
      setHlsConnected(false);
      setHlsRendering(false);
      return;
    }
    setHlsConnected(true);
    const session: HlsPlayerSession = startHlsPlayer(
      hlsRef.current,
      hlsUrl,
      {
        onRendering: () => setHlsRendering(true),
        onError: (msg) => setHlsError(msg),
      },
    );
    return () => session.close();
  }, [isHls, live, hlsUrl]);

  // Pick the right player state based on mode.
  const ref = isHls ? hlsRef : whep.ref;
  const connected = isHls ? hlsConnected : whep.connected;
  const rendering = isHls ? hlsRendering : whep.rendering;
  const error = isHls ? hlsError : whep.error;
  const modeLabel = isHls ? "HLS" : "LIVE";

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
          {!live ? "OFF" : connected ? modeLabel : "…"}
        </span>
      </div>
      {error && (
        <div className="absolute inset-0 flex items-center justify-center bg-black/70 p-2 text-center text-xs text-destructive">
          {error}
        </div>
      )}
      {connected && !rendering && (
        <div className="absolute inset-x-0 bottom-0 flex justify-center bg-black/60 px-2 py-1 text-[10px] text-amber-400">
          {isHls ? "loading HLS stream…" : "waiting for video frames…"}
        </div>
      )}
    </div>
  );
}
