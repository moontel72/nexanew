// VarReviewPanel — Phase 5 multi-camera VAR / decision review.
//
// Frame-accurate review of a replay session: pick a replay (manual or
// auto-tagged), pick a camera, and step through the synchronized
// timeline (1 / 5 frames, first / last). The engine re-paces EVERY
// camera stream from the same frame cursor, so switching cameras stays
// frame-synchronized for run-out / stumping calls.
//
// "Send to Air" cuts PGM to the reviewed camera through the standard
// program-transition API — the same path the vision switcher uses.

import { useEffect, useMemo, useState } from "react";
import { api, replayWatchUrl } from "../lib/api/client";
import { getToken } from "../lib/auth/authStore";
import { useControlState } from "../hooks/useControlState";
import { useWhepPlayer } from "../hooks/useWhepPlayer";
import { Button } from "./ui/Button";
import type { ReplayInfo, ReplayVarStateDto } from "../lib/api/types";

export function VarReviewPanel() {
  const control = useControlState();
  const replays = useMemo(
    () =>
      Object.values(control.replays).sort(
        (a, b) => b.created_at_ms - a.created_at_ms,
      ),
    [control.replays],
  );

  const [replayId, setReplayId] = useState<string>("");
  const [cameraId, setCameraId] = useState<string>("");
  const [varState, setVarState] = useState<ReplayVarStateDto | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sendingToAir, setSendingToAir] = useState(false);

  // The synchronized frame-accurate playback surface.
  const { ref } = useWhepPlayer(
    replayId && cameraId ? replayWatchUrl(replayId, cameraId) : "",
  );

  // Load VAR state whenever the replay selection changes.
  useEffect(() => {
    if (!replayId || !getToken()) {
      setVarState(null);
      return;
    }
    let cancelled = false;
    setBusy(true);
    api
      .getReplayVarState(replayId, getToken())
      .then((state) => {
        if (cancelled) return;
        setVarState(state);
        if (!cameraId || !state.cameras.some((c) => c.camera_id === cameraId)) {
          setCameraId(state.cameras[0]?.camera_id ?? "");
        }
      })
      .catch((loadError: Error) => {
        if (!cancelled) setError(loadError.message);
      })
      .finally(() => {
        if (!cancelled) setBusy(false);
      });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [replayId]);

  const seek = (frame: number) => {
    if (!replayId || !getToken()) return;
    setBusy(true);
    setError(null);
    api
      .seekReplay(replayId, frame, getToken())
      .then(setVarState)
      .catch((seekError: Error) => setError(seekError.message))
      .finally(() => setBusy(false));
  };

  const clamp = (value: number) =>
    Math.min(Math.max(value, 0), (varState?.total_frames ?? 1) - 1);

  const sendToAir = (replay: ReplayInfo) => {
    if (!cameraId) return;
    setSendingToAir(true);
    setError(null);
    api
      .setProgramTransition(
        { room_id: replay.room_id, camera_id: cameraId, transition: "cut" },
        getToken(),
      )
      .catch((airError: Error) => setError(airError.message))
      .finally(() => setSendingToAir(false));
  };

  const selectedReplay = replays.find((replay) => replay.replay_id === replayId);

  return (
    <section className="flex flex-col gap-2 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        VAR Review
      </header>

      <select
        className="rounded-md border border-input bg-background px-2 py-1 text-xs"
        value={replayId}
        onChange={(event) => setReplayId(event.target.value)}
      >
        <option value="">Select a replay…</option>
        {replays.slice(0, 8).map((replay) => (
          <option key={replay.replay_id} value={replay.replay_id}>
            {new Date(replay.created_at_ms).toLocaleTimeString()} · {replay.event} ·{" "}
            {replay.speed}x
          </option>
        ))}
      </select>

      {varState && (
        <>
          <div className="flex items-center gap-2">
            <select
              className="min-w-0 flex-1 rounded-md border border-input bg-background px-2 py-1 text-xs"
              value={cameraId}
              onChange={(event) => setCameraId(event.target.value)}
            >
              {varState.cameras.map((camera) => (
                <option key={camera.camera_id} value={camera.camera_id}>
                  {camera.camera_id} ({camera.frames}f)
                </option>
              ))}
            </select>
            <span className="shrink-0 font-mono text-[11px] tabular-nums text-muted-foreground">
              {varState.current_frame + 1} / {varState.total_frames}
            </span>
          </div>

          {/* Synchronized frame-accurate playback surface. */}
          <div className="aspect-video overflow-hidden rounded-md border border-border bg-black">
            <video ref={ref} autoPlay playsInline muted className="h-full w-full object-contain" />
          </div>

          {/* Frame stepping controls. */}
          <div className="grid grid-cols-6 gap-1">
            <Button
              variant="outline"
              className="px-1 py-1 text-[11px]"
              disabled={busy}
              onClick={() => seek(0)}
            >
              |&lt;
            </Button>
            <Button
              variant="outline"
              className="px-1 py-1 text-[11px]"
              disabled={busy}
              onClick={() => seek(clamp(varState.current_frame - 5))}
            >
              −5
            </Button>
            <Button
              variant="outline"
              className="px-1 py-1 text-[11px]"
              disabled={busy}
              onClick={() => seek(clamp(varState.current_frame - 1))}
            >
              −1
            </Button>
            <Button
              variant="outline"
              className="px-1 py-1 text-[11px]"
              disabled={busy}
              onClick={() => seek(clamp(varState.current_frame + 1))}
            >
              +1
            </Button>
            <Button
              variant="outline"
              className="px-1 py-1 text-[11px]"
              disabled={busy}
              onClick={() => seek(clamp(varState.current_frame + 5))}
            >
              +5
            </Button>
            <Button
              variant="outline"
              className="px-1 py-1 text-[11px]"
              disabled={busy}
              onClick={() => seek(clamp(varState.total_frames - 1))}
            >
              &gt;|
            </Button>
          </div>

          {selectedReplay && (
            <Button
              variant="destructive"
              disabled={sendingToAir || !cameraId}
              onClick={() => sendToAir(selectedReplay)}
            >
              {sendingToAir ? "Cutting…" : "Send to Air"}
            </Button>
          )}
        </>
      )}

      {!replayId && (
        <div className="text-[11px] text-muted-foreground">
          Trigger a replay (or let auto-tag create one) to review it
          frame-by-frame.
        </div>
      )}

      {error && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">{error}</div>
      )}
    </section>
  );
}
