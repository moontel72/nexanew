// WatermarkControl — static brand-logo overlay, decoupled from the live
// popup controls (Phase 3 overlay refactor).
//
// Moved out of `OverlayPanel` into the config zone: it is one-time setup
// (PNG URL + corner toggle), not a high-frequency live control. Same
// state/API contract as before — self-contained, no shared state with
// the popup panel.

import { useEffect, useRef, useState } from "react";
import { useDirector } from "../lib/director/directorService";
import { useControlState } from "../hooks/useControlState";
import { getToken } from "../lib/auth/authStore";
import { api } from "../lib/api/client";

export function WatermarkControl() {
  const control = useControlState();
  const director = useDirector();
  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";

  const serverState = control.overlays[activeRoomId] ?? null;

  const [watermarkUrl, setWatermarkUrl] = useState("");
  const [watermarkOn, setWatermarkOn] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const hydratedRef = useRef(false);

  // Hydrate from the control feed (or a one-off GET).
  useEffect(() => {
    if (serverState) {
      if (!hydratedRef.current) {
        setWatermarkOn(!!serverState.watermark);
        setWatermarkUrl(serverState.watermark?.asset_url ?? "");
      }
      hydratedRef.current = true;
      return;
    }
    if (hydratedRef.current || !activeRoomId || !getToken()) return;
    let cancelled = false;
    api
      .getOverlays(activeRoomId, getToken())
      .then((state) => {
        if (cancelled) return;
        setWatermarkOn(!!state.watermark);
        setWatermarkUrl(state.watermark?.asset_url ?? "");
        hydratedRef.current = true;
      })
      .catch(() => {
        // The control feed delivers the state once connected.
      });
    return () => {
      cancelled = true;
    };
  }, [serverState, activeRoomId]);

  const sendWatermark = (enabled: boolean, url: string) => {
    if (!activeRoomId || !getToken()) return;
    setBusy(true);
    setError(null);
    api
      .applyOverlay(
        activeRoomId,
        { kind: "watermark", enabled, asset_url: url, x: 0.965, y: 0.02 },
        getToken(),
      )
      .catch((sendError: Error) => setError(sendError.message))
      .finally(() => setBusy(false));
  };

  const toggleWatermark = (enabled: boolean) => {
    setWatermarkOn(enabled);
    void sendWatermark(enabled, watermarkUrl);
  };

  return (
    <section className="flex flex-col gap-2 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Watermark / Logo
        <span className="font-mono text-[10px] normal-case">
          {busy ? "applying…" : activeRoomId || "no room"}
        </span>
      </header>

      <label className="flex items-center justify-between text-xs">
        Show on program
        <input
          type="checkbox"
          checked={watermarkOn}
          disabled={!activeRoomId}
          onChange={(event) => toggleWatermark(event.target.checked)}
        />
      </label>

      <input
        className="rounded-md border border-input bg-background px-2 py-1 text-xs"
        placeholder="transparent PNG URL"
        value={watermarkUrl}
        disabled={!activeRoomId}
        onChange={(event) => setWatermarkUrl(event.target.value)}
        onBlur={() =>
          watermarkOn &&
          void sendWatermark(true, watermarkUrl)
        }
      />

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
