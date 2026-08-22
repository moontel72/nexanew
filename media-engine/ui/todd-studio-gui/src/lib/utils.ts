import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/** Tailwind-aware class merge (shadcn `cn` helper). */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const env = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL ?? "",
  cricketManagerUrl: import.meta.env.VITE_CRICKET_MANAGER_URL ?? "",
  cricketMatchIds: import.meta.env.VITE_CRICKET_MATCH_IDS || "",
  whepBaseUrl:
    import.meta.env.VITE_WHEP_BASE_URL ||
    import.meta.env.VITE_API_BASE_URL ||
    "",
  stunUrl: import.meta.env.VITE_STUN_URL ?? "",
  turnUrl: import.meta.env.VITE_TURN_URL || "",
  gfxAssetUrl: import.meta.env.VITE_GFX_ASSET_URL || "",
};

/**
 * WebSocket base for the media engine. Supports same-origin deployments
 * (empty `VITE_API_BASE_URL` — derives `ws(s)://` from the page origin,
 * which also covers the `tauri://localhost` packaged origin) and absolute
 * API origins alike. Never returns a relative URL: `new WebSocket` throws
 * a `SyntaxError` on relative paths in browsers/WebView2.
 */
export function wsBaseUrl(): string {
  if (env.apiBaseUrl) return env.apiBaseUrl.replace(/^http/, "ws");
  const scheme = window.location.protocol === "https:" ? "wss:" : "ws:";
  return `${scheme}//${window.location.host}`;
}
