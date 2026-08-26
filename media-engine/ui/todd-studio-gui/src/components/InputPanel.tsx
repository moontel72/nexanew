import { useState } from "react";
import { api, ApiError } from "../lib/api/client";
import type {
  CameraInfo,
  CameraSourceKind,
  CreateRoomResponse,
  Room,
  UpdateCameraRequest,
} from "../lib/api/types";
import { useControlState } from "../hooks/useControlState";
import { useDirector } from "../lib/director/directorService";
import { cn } from "../lib/utils";
import { getToken } from "../lib/auth/authStore";
import { Button } from "./ui/Button";

const SOURCE_KINDS: Array<{ value: CameraSourceKind; label: string }> = [
  { value: "whip", label: "WHIP" },
  { value: "rtsp", label: "RTSP" },
  { value: "rtmp", label: "RTMP" },
];

const KIND_BADGE: Record<CameraSourceKind, string> = {
  whip: "bg-primary/20 text-primary",
  rtsp: "bg-accent/20 text-accent",
  rtmp: "bg-muted text-muted-foreground",
};

interface CameraForm {
  cameraId: string;
  label: string;
  kind: CameraSourceKind;
  group: string;
}

const EMPTY_FORM: CameraForm = { cameraId: "", label: "", kind: "whip", group: "" };

interface AddResult {
  cameraId: string;
  ingestToken: string;
  whipBaseUrl: string;
}

function kindBadge(kind: CameraSourceKind): string {
  return KIND_BADGE[kind] ?? KIND_BADGE.whip;
}

/**
 * "Hand this to the camera operator" card. The primary copy target is a
 * single WHIP URL that already carries `?token=…`, so the operator pastes
 * one string into the Broadcaster app and every field auto-fills.
 */
function LastAddedCard({
  added,
  copy,
  onDismiss,
}: {
  added: AddResult;
  copy: (text: string) => void;
  onDismiss: () => void;
}) {
  const whipUrl = `${added.whipBaseUrl}/${added.cameraId}?token=${encodeURIComponent(added.ingestToken)}`;
  return (
    <div className="rounded-md border border-accent/40 bg-accent/10 p-2 text-xs">
      <div className="mb-1 font-medium text-accent">
        {added.cameraId} added — paste this in the Broadcaster app:
      </div>
      <div className="mb-1 break-all font-mono">WHIP URL: {whipUrl}</div>
      <div className="break-all font-mono">ingest token: {added.ingestToken}</div>
      <div className="mt-2 flex gap-2">
        <Button
          variant="outline"
          className="px-2 py-1 text-xs"
          onClick={() => void copy(whipUrl)}
        >
          Copy WHIP URL
        </Button>
        <Button
          variant="outline"
          className="px-2 py-1 text-xs"
          onClick={() => void copy(added.ingestToken)}
        >
          Copy token
        </Button>
        <Button variant="ghost" className="px-2 py-1 text-xs" onClick={onDismiss}>
          Dismiss
        </Button>
      </div>
    </div>
  );
}

/**
 * Dynamic camera input management: add/remove/reconfigure camera sources
 * of every live room. PGM comes from the control plane; PVW from the
 * director's preview bus.
 */
export function InputPanel() {
  const control = useControlState();
  const { state: director } = useDirector();

  const [form, setForm] = useState<CameraForm>(EMPTY_FORM);
  const [selectedRoomId, setSelectedRoomId] = useState<string>("");
  const [roomName, setRoomName] = useState("");
  const [roomCameraIds, setRoomCameraIds] = useState("");
  const [roomResult, setRoomResult] = useState<CreateRoomResponse | null>(null);
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);
  const [lastAdded, setLastAdded] = useState<AddResult | null>(null);
  const [editing, setEditing] = useState<string | null>(null);
  const [editForm, setEditForm] = useState<UpdateCameraRequest>({});

  const rooms = control.rooms;

  const effectiveRoomId = selectedRoomId || rooms[0]?.id || "";

  const resetForm = () => {
    setForm(EMPTY_FORM);
    setBusy(false);
    setActionError(null);
  };

  const runAction = async (action: () => Promise<unknown>) => {
    setBusy(true);
    setActionError(null);
    try {
      await action();
    } catch (error) {
      setActionError(error instanceof ApiError ? error.message : (error as Error).message);
      throw error;
    } finally {
      setBusy(false);
    }
  };

  const handleCreateRoom = () => {
    const name = roomName.trim();
    if (!name) {
      setActionError("Enter a room name first");
      return;
    }
    const cameraIds = roomCameraIds
      .split(",")
      .map((id) => id.trim())
      .filter((id) => id.length > 0);
    void runAction(async () => {
      const result = await api.createRoom(name, cameraIds, getToken());
      setRoomResult(result);
      setRoomName("");
      setRoomCameraIds("");
      setSelectedRoomId(result.room.id);
    }).catch(() => undefined);
  };

  const handleAdd = () => {
    const cameraId = form.cameraId.trim();
    if (!effectiveRoomId || !cameraId) {
      setActionError("Select a room and enter a camera id");
      return;
    }
    void runAction(async () => {
      const result = await api.addCamera(
        effectiveRoomId,
        {
          id: cameraId,
          label: form.label.trim() || null,
          kind: form.kind,
          group: form.group.trim() || null,
        },
        getToken(),
      );
      setLastAdded({
        cameraId,
        ingestToken: result.ingest_token,
        whipBaseUrl: result.whip_base_url,
      });
      resetForm();
    }).catch(() => undefined);
  };

  const handleRemove = (room: Room, camera: CameraInfo) => {
    if (!window.confirm(`Remove camera "${camera.label ?? camera.id}" from ${room.name}?`)) {
      return;
    }
    void runAction(() => api.removeCamera(room.id, camera.id, getToken())).catch(
      () => undefined,
    );
  };

  const startEdit = (camera: CameraInfo) => {
    setEditing(camera.id);
    setEditForm({
      label: camera.label ?? "",
      kind: camera.kind,
      group: camera.group ?? "",
    });
  };

  const handleSaveEdit = (room: Room, cameraId: string) => {
    void runAction(async () => {
      await api.updateCamera(room.id, cameraId, editForm, getToken());
      setEditing(null);
      setEditForm({});
    }).catch(() => undefined);
  };

  const copy = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
    } catch {
      // Clipboard unavailable (e.g. non-secure context) — the value stays
      // visible so the director can copy it manually.
    }
  };

  return (
    <section className="flex flex-col gap-3 rounded-md border border-border bg-muted/40 p-3">
      <header className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
        Camera Inputs
      </header>

      {/* Create room */}
      <div className="flex flex-col gap-2 rounded-md border border-border bg-background/60 p-2">
        <div className="text-[11px] font-medium text-muted-foreground">
          New room
        </div>
        <div className="flex gap-2">
          <input
            className="min-w-0 flex-1 rounded-md border border-input bg-background px-2 py-1 text-xs"
            placeholder="room name (e.g. Main Ground)"
            value={roomName}
            onChange={(event) => setRoomName(event.target.value)}
          />
          <Button
            variant="outline"
            className="shrink-0 px-2 py-1 text-xs"
            onClick={handleCreateRoom}
            disabled={busy}
          >
            Create
          </Button>
        </div>
        <input
          className="rounded-md border border-input bg-background px-2 py-1 text-xs"
          placeholder="camera ids (optional, comma-separated: cam-1, cam-2)"
          value={roomCameraIds}
          onChange={(event) => setRoomCameraIds(event.target.value)}
        />
        {roomResult && (
          <div className="flex flex-col gap-1">
            <div className="text-[11px] text-accent">
              Room "{roomResult.room.name}" created — id:
            </div>
            <div className="break-all font-mono text-[10px] text-muted-foreground">
              {roomResult.room.id}
            </div>
            {Object.entries(roomResult.ingest_tokens).length > 0 && (
              <div className="text-[11px] text-accent">Camera ingest tokens:</div>
            )}
            {Object.entries(roomResult.ingest_tokens).map(([cameraId, token]) => (
              <div key={cameraId} className="flex items-center justify-between gap-2">
                <span className="truncate font-mono text-[10px] text-muted-foreground">
                  {cameraId}
                </span>
                <Button
                  variant="ghost"
                  className="px-1 py-0.5 text-[10px]"
                  onClick={() => void copy(token)}
                >
                  Copy token
                </Button>
              </div>
            ))}
            <div className="text-[11px] text-muted-foreground">
              WHIP base: <span className="font-mono">{roomResult.whip_base_url}</span>
            </div>
            <Button
              variant="ghost"
              className="self-end px-2 py-0.5 text-[10px]"
              onClick={() => setRoomResult(null)}
            >
              Dismiss
            </Button>
          </div>
        )}
      </div>

      {/* Add camera */}
      <div className="flex flex-col gap-2">
        <select
          className="rounded-md border border-input bg-background px-2 py-1 text-xs"
          value={effectiveRoomId}
          onChange={(event) => setSelectedRoomId(event.target.value)}
          disabled={rooms.length === 0}
        >
          {rooms.length === 0 && <option value="">No rooms yet</option>}
          {rooms.map((room) => (
            <option key={room.id} value={room.id}>
              {room.name}
            </option>
          ))}
        </select>

        <input
          className="rounded-md border border-input bg-background px-2 py-1 text-xs"
          placeholder="camera id (e.g. cam-4)"
          value={form.cameraId}
          onChange={(event) => setForm({ ...form, cameraId: event.target.value })}
        />
        <input
          className="rounded-md border border-input bg-background px-2 py-1 text-xs"
          placeholder="label (e.g. Cam 4 — Long On)"
          value={form.label}
          onChange={(event) => setForm({ ...form, label: event.target.value })}
        />
        <div className="grid grid-cols-2 gap-2">
          <select
            className="rounded-md border border-input bg-background px-2 py-1 text-xs"
            value={form.kind}
            onChange={(event) =>
              setForm({ ...form, kind: event.target.value as CameraSourceKind })
            }
          >
            {SOURCE_KINDS.map((kind) => (
              <option key={kind.value} value={kind.value}>
                {kind.label}
              </option>
            ))}
          </select>
          <input
            className="rounded-md border border-input bg-background px-2 py-1 text-xs"
            placeholder="group (e.g. ground)"
            value={form.group}
            onChange={(event) => setForm({ ...form, group: event.target.value })}
          />
        </div>
        <Button onClick={handleAdd} disabled={busy || !effectiveRoomId}>
          {busy ? "Adding…" : "Add Camera"}
        </Button>
      </div>

      {lastAdded && (
        <LastAddedCard
          added={lastAdded}
          copy={copy}
          onDismiss={() => setLastAdded(null)}
        />
      )}

      {actionError && (
        <div className="rounded-md bg-destructive/20 p-2 text-xs text-destructive">
          {actionError}
        </div>
      )}

      {/* Camera registry per room */}
      <div className="flex flex-col gap-2">
        {rooms.length === 0 && (
          <div className="text-xs text-muted-foreground">No rooms created yet.</div>
        )}
        {rooms.map((room) => {
          const program = control.programs[room.id];
          return (
            <div key={room.id} className="flex flex-col gap-1">
              <div className="flex items-center justify-between">
                <span className="truncate text-xs font-semibold text-foreground">
                  {room.name}
                </span>
                <span className="font-mono text-[10px] text-muted-foreground">{room.id}</span>
              </div>

              {room.cameras.map((camera) => {
                const isPgm =
                  program?.camera_id === camera.id ||
                  (director.pgm?.roomId === room.id && director.pgm?.cameraId === camera.id);
                const isPvw = director.pvw?.roomId === room.id && director.pvw?.cameraId === camera.id;
                const isEditing = editing === camera.id;
                return (
                  <div
                    key={camera.id}
                    className="flex flex-col gap-1 rounded-md border border-border bg-background/60 p-2"
                  >
                    <div className="flex items-center justify-between gap-2">
                      <div className="flex min-w-0 items-center gap-2">
                        <span
                          className={cn(
                            "h-2 w-2 shrink-0 rounded-full",
                            camera.active ? "bg-emerald-400" : "bg-amber-500/60",
                          )}
                          title={camera.active ? "live ingest" : "no live session"}
                        />
                        <span className="truncate text-xs font-medium">
                          {camera.label ?? camera.id}
                        </span>
                        <span className={cn("rounded px-1 py-0.5 text-[10px] font-semibold", kindBadge(camera.kind))}>
                          {camera.kind.toUpperCase()}
                        </span>
                        {camera.group && (
                          <span className="rounded bg-muted px-1 py-0.5 text-[10px] text-muted-foreground">
                            {camera.group}
                          </span>
                        )}
                      </div>
                      <div className="flex shrink-0 items-center gap-1">
                        {isPgm && (
                          <span className="rounded bg-destructive px-1.5 py-0.5 text-[10px] font-bold">
                            PGM
                          </span>
                        )}
                        {isPvw && (
                          <span className="rounded bg-accent px-1.5 py-0.5 text-[10px] font-bold">
                            PVW
                          </span>
                        )}
                      </div>
                    </div>

                    {isEditing ? (
                      <div className="flex flex-col gap-1">
                        <input
                          className="rounded-md border border-input bg-background px-2 py-1 text-xs"
                          value={editForm.label ?? ""}
                          placeholder="label"
                          onChange={(event) =>
                            setEditForm({ ...editForm, label: event.target.value })
                          }
                        />
                        <div className="grid grid-cols-2 gap-1">
                          <select
                            className="rounded-md border border-input bg-background px-2 py-1 text-xs"
                            value={editForm.kind ?? camera.kind}
                            onChange={(event) =>
                              setEditForm({
                                ...editForm,
                                kind: event.target.value as CameraSourceKind,
                              })
                            }
                          >
                            {SOURCE_KINDS.map((kind) => (
                              <option key={kind.value} value={kind.value}>
                                {kind.label}
                              </option>
                            ))}
                          </select>
                          <input
                            className="rounded-md border border-input bg-background px-2 py-1 text-xs"
                            value={editForm.group ?? ""}
                            placeholder="group"
                            onChange={(event) =>
                              setEditForm({ ...editForm, group: event.target.value })
                            }
                          />
                        </div>
                        <div className="flex gap-1">
                          <Button
                            className="px-2 py-1 text-xs"
                            disabled={busy}
                            onClick={() => void handleSaveEdit(room, camera.id)}
                          >
                            Save
                          </Button>
                          <Button
                            variant="ghost"
                            className="px-2 py-1 text-xs"
                            onClick={() => {
                              setEditing(null);
                              setEditForm({});
                            }}
                          >
                            Cancel
                          </Button>
                        </div>
                      </div>
                    ) : (
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-[10px] text-muted-foreground">
                          {camera.id} {camera.active ? "· LIVE" : "· idle"}
                        </span>
                        <div className="flex gap-1">
                          <Button
                            variant="outline"
                            className="px-2 py-1 text-xs"
                            onClick={() => startEdit(camera)}
                          >
                            Edit
                          </Button>
                          <Button
                            variant="destructive"
                            className="px-2 py-1 text-xs"
                            disabled={busy}
                            onClick={() => void handleRemove(room, camera)}
                          >
                            Remove
                          </Button>
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          );
        })}
      </div>
    </section>
  );
}
