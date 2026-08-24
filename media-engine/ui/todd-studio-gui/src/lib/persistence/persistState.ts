// Persisted director state — Phase 4 broadcast reliability.
//
// Survives a browser refresh mid-stream: scene composer drafts, audio
// mixer volumes, lower-third setup, watermark and transition settings
// are written to localStorage (debounced, merged, versioned) and
// restored synchronously at mount — before any network state arrives.
//
// Race-condition contract:
//   • Loads happen exactly once, in `useState` initializers (synchronous,
//     before the control feed / REST hydration can deliver anything).
//   • Writes are debounced (400 ms) and merged into one slot — fader
//     drags cannot interleave two writers.
//   • Server-pushed state remains authoritative AFTER reconnect: every
//     consumer already re-adopts the feed state, so a restored draft is
//     only a pre-connect fallback (and the recovery source when the
//     engine restarted and lost its in-memory mix).

import type { AudioMixerConfig, PiPConfig, SideBySideConfig, SplitScreenConfig } from "../api/types";

export type PersistedSceneKind = "fullscreen" | "picture_in_picture" | "split_screen" | "side_by_side";

export interface PersistedScene {
  kind: PersistedSceneKind;
  pip?: PiPConfig;
  split?: SplitScreenConfig;
  sideBySide?: SideBySideConfig;
}

export interface PersistedDirectorState {
  version: 1;
  audioByRoom: Record<string, AudioMixerConfig>;
  sceneByRoom: Record<string, PersistedScene>;
  scoreboard: { enabled: boolean; title: string; subtitle: string };
  autoGraphics: { enabled: boolean; durationMs: number };
  watermark: { enabled: boolean; url: string };
  brand: { enabled: boolean; url: string; name: string };
  transitionDurationMs: number;
}

const KEY_VERSION = "v1";
const STORAGE_KEY = `todd_studio_state_${KEY_VERSION}`;

const EMPTY_STATE: PersistedDirectorState = {
  version: 1,
  audioByRoom: {},
  sceneByRoom: {},
  scoreboard: { enabled: false, title: "", subtitle: "" },
  autoGraphics: { enabled: true, durationMs: 4000 },
  watermark: { enabled: false, url: "" },
  brand: { enabled: false, url: "", name: "" },
  transitionDurationMs: 600,
};

/** Decodes the SSO JWT `sub` claim to namespace state per account. */
function accountKey(): string {
  try {
    const raw = window.localStorage.getItem("todd_studio_jwt");
    if (!raw) return "default";
    const payload = JSON.parse(atob(raw.split(".")[1] ?? "")) as { sub?: string };
    return payload.sub ? String(payload.sub) : "default";
  } catch {
    return "default";
  }
}

function storageKey(): string {
  return `${STORAGE_KEY}:${accountKey()}`;
}

let debounceTimer: ReturnType<typeof setTimeout> | undefined;
let pending: PersistedDirectorState | null = null;

/** Synchronous load — safe to call inside `useState` initializers. */
export function loadPersistedState(): PersistedDirectorState {
  try {
    const raw = window.localStorage.getItem(storageKey());
    if (!raw) return { ...EMPTY_STATE };
    const parsed = JSON.parse(raw) as Partial<PersistedDirectorState>;
    return {
      ...EMPTY_STATE,
      ...parsed,
      audioByRoom: { ...(parsed.audioByRoom ?? {}) },
      sceneByRoom: { ...(parsed.sceneByRoom ?? {}) },
      scoreboard: { ...EMPTY_STATE.scoreboard, ...(parsed.scoreboard ?? {}) },
      autoGraphics: { ...EMPTY_STATE.autoGraphics, ...(parsed.autoGraphics ?? {}) },
      watermark: { ...EMPTY_STATE.watermark, ...(parsed.watermark ?? {}) },
      brand: { ...EMPTY_STATE.brand, ...(parsed.brand ?? {}) },
    };
  } catch {
    return { ...EMPTY_STATE };
  }
}

/**
 * Debounced merge-write. Call with a partial patch on any user change;
 * the write lands at most once per 400 ms and never throws.
 */
export function savePersistedState(patch: Partial<PersistedDirectorState>): void {
  try {
    pending = { ...(pending ?? loadPersistedState()), ...patch };
    if (debounceTimer) clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      const state = pending;
      pending = null;
      if (!state) return;
      try {
        window.localStorage.setItem(storageKey(), JSON.stringify(state));
      } catch {
        // Storage unavailable (private mode / quota) — memory-only session.
      }
    }, 400);
  } catch {
    // Never let persistence break the live control surface.
  }
}
