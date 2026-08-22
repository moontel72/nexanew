import { useCallback, useEffect, useRef, useState } from "react";
import { api } from "../lib/api/client";
import { useControlState } from "./useControlState";
import { getToken } from "../lib/auth/authStore";
import { clampDb, defaultMix, withBus } from "../lib/audio/audioMixer";
import {
  loadPersistedState,
  savePersistedState,
} from "../lib/persistence/persistState";
import type { AudioBus, AudioBusSpec, AudioMixerConfig } from "../lib/api/types";

export type AudioBusPatch = Partial<AudioBusSpec>;

export interface AudioMixerApi {
  /** The mix the console shows (optimistic draft, else server state). */
  config: AudioMixerConfig;
  /** True while a PUT is in flight. */
  pending: boolean;
  /** Last PUT error, if any. */
  error: string | null;
  /** Patches one bus (fader/mute/solo/gain/delay) and syncs to the
   * server after a short debounce. */
  setBus(bus: AudioBus, patch: AudioBusPatch): void;
  /** Sets the master fader (dB). */
  setMaster(volumeDb: number): void;
}

/** Debounce before an optimistic fader move is pushed to the server. */
const SYNC_DEBOUNCE_MS = 250;

/**
 * Per-room audio mixer state: optimistic local faders reconciled against
 * the control-plane WebSocket (`audio_mixer_changed` events). Fader drags
 * update the draft immediately; a debounced PUT persists them.
 */
export function useAudioMixer(roomId: string): AudioMixerApi {
  const control = useControlState();
  const token = getToken();

  const serverConfig: AudioMixerConfig | null =
    roomId && control.audioMixes[roomId] ? control.audioMixes[roomId].config : null;

  // Phase 4: restore the pre-refresh mix synchronously at mount; the
  // control feed re-adopts the authoritative server state once it
  // connects (and this draft is the recovery source if the engine
  // restarted and lost its in-memory mix).
  const [draft, setDraft] = useState<AudioMixerConfig | null>(() =>
    roomId ? (loadPersistedState().audioByRoom[roomId] ?? null) : null,
  );
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const editingRef = useRef(false);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const latestDraftRef = useRef<AudioMixerConfig | null>(null);
  latestDraftRef.current = draft;

  // Adopt server state whenever it arrives and the director isn't
  // mid-drag.
  useEffect(() => {
    if (!serverConfig) return;
    if (editingRef.current) return;
    setDraft(serverConfig);
  }, [serverConfig]);

  // Initial hydration when the control feed has no mix for the room yet.
  useEffect(() => {
    if (!roomId || !token || serverConfig || draft) return;
    let cancelled = false;
    api
      .getAudioMix(roomId, token)
      .then((view) => {
        if (!cancelled && !editingRef.current) setDraft(view.config);
      })
      .catch(() => {
        // The control feed will deliver the mix once connected.
      });
    return () => {
      cancelled = true;
    };
  }, [roomId, token, serverConfig, draft]);

  const push = useCallback(
    (next: AudioMixerConfig) => {
      editingRef.current = true;
      setDraft(next);
      setError(null);
      // Phase 4: persist the console so a refresh restores the mix.
      if (roomId) {
        savePersistedState({ audioByRoom: { [roomId]: next } });
      }

      if (debounceRef.current) clearTimeout(debounceRef.current);
      debounceRef.current = setTimeout(() => {
        setPending(true);
        api
          .updateAudioMix(roomId, next, token)
          .then((view) => {
            editingRef.current = false;
            // The server echo (or the WS event) re-adopts below.
            if (!view.config) return;
            setDraft((current) => (editingRef.current ? current : view.config));
          })
          .catch((saveError: Error) => {
            editingRef.current = false;
            setError(saveError.message);
          })
          .finally(() => setPending(false));
      }, SYNC_DEBOUNCE_MS);
    },
    [roomId, token],
  );

  const setBus = useCallback(
    (bus: AudioBus, patch: AudioBusPatch) => {
      const base = latestDraftRef.current ?? serverConfig ?? defaultMix();
      const next = withBus(base, bus, patch);
      push(next);
    },
    [push, serverConfig],
  );

  const setMaster = useCallback(
    (volumeDb: number) => {
      const base = latestDraftRef.current ?? serverConfig ?? defaultMix();
      push({ ...base, master_volume_db: clampDb(volumeDb) });
    },
    [push, serverConfig],
  );

  useEffect(() => {
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, []);

  return {
    config: draft ?? serverConfig ?? defaultMix(),
    pending,
    error,
    setBus,
    setMaster,
  };
}
