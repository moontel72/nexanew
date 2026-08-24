// BrandControl — tournament brand overlay (left side), mirror of the
// WatermarkControl (right side Trace Odd logo).
//
// The subscription manager's OWN logo + name are burned into the program
// on the LEFT side; the Trace Odd watermark stays on the RIGHT. One-time
// setup: toggle + logo URL + brand name. Same state/API contract as the
// watermark control.

import { useEffect, useRef, useState } from "react";
import { useDirector } from "../lib/director/directorService";
import { useControlState } from "../hooks/useControlState";
import { getToken } from "../lib/auth/authStore";
import { api } from "../lib/api/client";
import {
  loadPersistedState,
  savePersistedState,
} from "../lib/persistence/persistState";

export function BrandControl() {
  const control = useControlState();
  const director = useDirector();
  const activeRoomId = director.state.pgm?.roomId ?? control.rooms[0]?.id ?? "";

  const serverState = control.overlays[activeRoomId] ?? null;

  // Restore the pre-refresh draft synchronously at mount; the control
  // feed re-adopts server state after reconnect.
  const persisted = loadPersistedState();

  const [brandUrl, setBrandUrl] = useState(persisted.brand.url);
  const [brandName, setBrandName] = useState(persisted.brand.name);
  const [brandOn, setBrandOn] = useState(persisted.brand.enabled);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const hydratedRef = useRef(false);

  // Hydrate from the control feed (or a one-off GET).
  useEffect(() => {
    if (serverState) {
      if (!hydratedRef.current) {
        setBrandOn(!!serverState.brand);
        setBrandUrl(serverState.brand?.asset_url ?? "");
        setBrandName(serverState.brand?.text ?? "");
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
        setBrandOn(!!state.brand);
        setBrandUrl(state.brand?.asset_url ?? "");
        setBrandName(state.brand?.text ?? "");
        hydratedRef.current = true;
      })
      .catch(() => {
        // The control feed delivers the state once connected.
      });
    return () => {
      cancelled = true;
    };
  }, [serverState, activeRoomId]);

  const sendBrand = (enabled: boolean, url: string, name: string) => {
    if (!activeRoomId || !getToken()) return;
    setBusy(true);
    setError(null);
    api
      .applyOverlay(
        activeRoomId,
        { kind: "brand", enabled, asset_url: url, text: name, x: 0.02, y: 0.02 },
        getToken(),
      )
      .catch((sendError: Error) => setError(sendError.message))
      .finally(() => setBusy(false));
  };

  const toggleBrand = (enabled: boolean) => {
    setBrandOn(enabled);
    savePersistedState({ brand: { enabled, url: brandUrl, name: brandName } });
    void sendBrand(enabled, brandUrl, brandName);
  };

  return (
    <section className="flex flex-col gap-2 rounded-md border border-border bg-muted/40 p-3">
      <header className="flex items-center justify-between text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Tournament Brand
        <span className="font-mono text-[10px] normal-case">
          {busy ? "applying…" : activeRoomId || "no room"}
        </span>
      </header>

      <label className="flex items-center justify-between text-xs">
        Show on program (left side)
        <input
          type="checkbox"
          checked={brandOn}
          disabled={!activeRoomId}
          onChange={(event) => toggleBrand(event.target.checked)}
        />
      </label>

      <input
        className="rounded-md border border-input bg-background px-2 py-1 text-xs"
        placeholder="Tournament name"
        value={brandName}
        disabled={!activeRoomId}
        onChange={(event) => {
          setBrandName(event.target.value);
          savePersistedState({ brand: { enabled: brandOn, url: brandUrl, name: event.target.value } });
        }}
        onBlur={() =>
          brandOn &&
          void sendBrand(true, brandUrl, brandName)
        }
      />

      <input
        className="rounded-md border border-input bg-background px-2 py-1 text-xs"
        placeholder="logo PNG URL"
        value={brandUrl}
        disabled={!activeRoomId}
        onChange={(event) => {
          setBrandUrl(event.target.value);
          savePersistedState({ brand: { enabled: brandOn, url: event.target.value, name: brandName } });
        }}
        onBlur={() =>
          brandOn &&
          void sendBrand(true, brandUrl, brandName)
        }
      />

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
