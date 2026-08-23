// Deep links into the bilingual operator manual (docs.traceodd.com).
//
// In the packaged desktop app, external URLs must go through the Tauri
// opener plugin — WebView2 blocks `window.open`/`target=_blank` unless a
// plugin handles them. The web build falls back to a plain new-tab open.

import { openUrl } from "@tauri-apps/plugin-opener";

/** True inside the packaged Tauri desktop shell (false on the web build). */
export function isDesktopShell(): boolean {
  return typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;
}

export const MANUAL_BASE = "https://docs.traceodd.com";

/** Desktop app download portal (traceodd.com/download). */
export const DOWNLOAD_URL = "https://traceodd.com/download/";

/** Absolute manual URL for a docs path (defaults to the Cricket overview). */
export function manualUrl(path = "/cricket/intro"): string {
  return `${MANUAL_BASE}${path.startsWith("/") ? path : `/${path}`}`;
}

/** Opens a manual page in the system browser (web: new tab). */
export function openManual(path = "/cricket/intro"): void {
  const url = manualUrl(path);
  if (isDesktopShell()) {
    openUrl(url).catch(() => {
      window.open(url, "_blank", "noopener,noreferrer");
    });
  } else {
    window.open(url, "_blank", "noopener,noreferrer");
  }
}

/** Opens the desktop app download portal (web: same tab, it's a download page). */
export function openDownload(): void {
  window.open(DOWNLOAD_URL, "_blank", "noopener,noreferrer");
}
