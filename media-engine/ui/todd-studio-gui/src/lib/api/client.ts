// Typed REST client for the media engine (todd-signaling control plane).
//
// The director GUI only talks to the *control plane*: room management,
// WHEP watch signaling, replay triggers and telemetry. Vision-switch and
// scoreboard services build on top of this base.

import { env } from "../utils";
import { clearToken, getToken } from "../auth/authStore";
import type {
  AddCameraResponse,
  AudioMixView,
  AudioMixerConfig,
  CameraInfo,
  CameraSpec,
  CreateRoomResponse,
  CricketConfigUpdate,
  CricketConfigView,
  ExportStatus,
  ForwardingStatus,
  ForwardTargetRequest,
  HighlightEntryDto,
  OverlayCommand,
  OverlayState,
  PollStateDto,
  ProgramState,
  ProgramTransitionRequest,
  ReplayInfo,
  ReplayTriggerRequest,
  ReplayVarStateDto,
  Room,
  UpdateCameraRequest,
} from "./types";

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
  }
}

async function request<T>(
  path: string,
  init: RequestInit & { token?: string | null },
): Promise<T> {
  const headers = new Headers(init.headers);
  // The SSO JWT is read from the auth store at call time — never from a
  // build-time env var.
  const token = init.token || getToken();
  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }
  const res = await fetch(`${env.apiBaseUrl}${path}`, { ...init, headers });
  if (res.status === 401) {
    // The token expired or was revoked — drop it so the app falls back
    // to the login screen.
    clearToken();
  }
  if (!res.ok) {
    let message = res.statusText;
    try {
      const body = (await res.json()) as { error?: string };
      if (body.error) message = body.error;
    } catch {
      // non-JSON error body
    }
    throw new ApiError(res.status, message);
  }
  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

export const api = {
  async createRoom(name: string, cameraIds: string[], token: string | null) {
    return request<CreateRoomResponse>("/api/v1/room/create", {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, camera_ids: cameraIds, ttl_secs: 86400 }),
    });
  },

  async listRooms(token: string | null) {
    return request<Room[]>("/api/v1/room/list", { method: "GET", token });
  },

  async deleteRoom(roomId: string, token: string | null) {
    return request<void>(`/api/v1/room/${encodeURIComponent(roomId)}`, {
      method: "DELETE",
      token,
    });
  },

  async getRoom(roomId: string, token: string | null) {
    return request<Room>(`/api/v1/room/${roomId}`, { method: "GET", token });
  },

  async addCamera(roomId: string, spec: CameraSpec, token: string | null) {
    return request<AddCameraResponse>(`/api/v1/room/${roomId}/camera`, {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(spec),
    });
  },

  async updateCamera(
    roomId: string,
    cameraId: string,
    update: UpdateCameraRequest,
    token: string | null,
  ) {
    return request<CameraInfo>(
      `/api/v1/room/${roomId}/camera/${encodeURIComponent(cameraId)}`,
      {
        method: "PUT",
        token,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(update),
      },
    );
  },

  async removeCamera(roomId: string, cameraId: string, token: string | null) {
    return request<void>(
      `/api/v1/room/${roomId}/camera/${encodeURIComponent(cameraId)}`,
      { method: "DELETE", token },
    );
  },

  async getCricketConfig(token: string | null) {
    return request<CricketConfigView>("/api/v1/cricket/config", {
      method: "GET",
      token,
    });
  },

  async setProgramTransition(req: ProgramTransitionRequest, token: string | null) {
    return request<ProgramState>("/api/v1/program/transition", {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req),
    });
  },

  async getProgram(roomId: string, token: string | null) {
    return request<ProgramState>(`/api/v1/program/${encodeURIComponent(roomId)}`, {
      method: "GET",
      token,
    });
  },

  async getAudioMix(roomId: string, token: string | null) {
    return request<AudioMixView>(`/api/v1/audio/mix/${encodeURIComponent(roomId)}`, {
      method: "GET",
      token,
    });
  },

  async updateAudioMix(roomId: string, config: AudioMixerConfig, token: string | null) {
    return request<AudioMixView>(`/api/v1/audio/mix/${encodeURIComponent(roomId)}`, {
      method: "PUT",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(config),
    });
  },

  async getOverlays(roomId: string, token: string | null) {
    return request<OverlayState>(`/api/v1/program/overlay/${encodeURIComponent(roomId)}`, {
      method: "GET",
      token,
    });
  },

  async applyOverlay(roomId: string, command: OverlayCommand, token: string | null) {
    return request<OverlayState>("/api/v1/program/overlay", {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ room_id: roomId, command }),
    });
  },

  async clearOverlays(roomId: string, token: string | null) {
    return request<OverlayState>(`/api/v1/program/overlay/${encodeURIComponent(roomId)}`, {
      method: "DELETE",
      token,
    });
  },

  async addProgramForward(roomId: string, target: ForwardTargetRequest, token: string | null) {
    return request<ForwardingStatus>(`/api/v1/room/${encodeURIComponent(roomId)}/forward`, {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(target),
    });
  },

  async stopForward(key: string, token: string | null) {
    return request<ForwardingStatus>(`/api/v1/forward/${encodeURIComponent(key)}`, {
      method: "DELETE",
      token,
    });
  },

  async listForwards(token: string | null) {
    return request<ForwardingStatus[]>("/api/v1/forward/list", { method: "GET", token });
  },

  async updateCricketConfig(config: CricketConfigUpdate, token: string | null) {
    return request<CricketConfigView>("/api/v1/cricket/config", {
      method: "PUT",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(config),
    });
  },

  async triggerReplay(req: ReplayTriggerRequest, token: string | null) {
    return request<ReplayInfo>("/api/v1/replay/trigger", {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req),
    });
  },

  async listReplays(token: string | null) {
    return request<ReplayInfo[]>("/api/v1/replay/list", { method: "GET", token });
  },

  async closeReplay(replayId: string, token: string | null) {
    return request<void>(`/api/v1/replay/${replayId}`, {
      method: "DELETE",
      token,
    });
  },

  async exportReplay(
    replayId: string,
    body: {
      camera_id: string;
      target: {
        url: string;
        encoder?: string;
        bitrate_kbps?: number;
        keyframe_interval?: number;
        audio?: unknown;
      };
      speed?: number;
    },
    token: string | null,
  ) {
    return request<ExportStatus>(`/api/v1/replay/${replayId}/export`, {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ replay_id: replayId, ...body }),
    });
  },

  // ── VAR review (Phase 5) ──────────────────────────────────────

  async getReplayVarState(replayId: string, token: string | null) {
    return request<ReplayVarStateDto>(`/api/v1/replay/${replayId}/var/state`, {
      method: "GET",
      token,
    });
  },

  async seekReplay(replayId: string, frame: number, token: string | null) {
    return request<ReplayVarStateDto>(`/api/v1/replay/${replayId}/var/seek`, {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ frame }),
    });
  },

  // ── Spectator polls (Phase 5) ─────────────────────────────────

  async createPoll(
    roomId: string,
    body: { question: string; options: string[] },
    token: string | null,
  ) {
    return request<PollStateDto>(`/api/v1/poll/${encodeURIComponent(roomId)}`, {
      method: "POST",
      token,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  },

  async votePoll(roomId: string, option: number) {
    return request<PollStateDto>(`/api/v1/poll/${encodeURIComponent(roomId)}/vote`, {
      method: "POST",
      token: null,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ option }),
    });
  },

  async getPoll(roomId: string) {
    return request<PollStateDto>(`/api/v1/poll/${encodeURIComponent(roomId)}`, {
      method: "GET",
      token: null,
    });
  },

  async clearPoll(roomId: string, token: string | null) {
    return request<void>(`/api/v1/poll/${encodeURIComponent(roomId)}`, {
      method: "DELETE",
      token,
    });
  },

  // ── Innings highlights (Phase 5) ──────────────────────────────

  async getHighlights(token: string | null) {
    return request<HighlightEntryDto[]>("/api/v1/highlights", {
      method: "GET",
      token,
    });
  },
};

export function whepWatchUrl(
  roomId: string,
  cameraId: string,
  rid?: string,
): string {
  const base = `${env.whepBaseUrl}/api/v1/whep/watch/${roomId}/${cameraId}`;
  return rid ? `${base}?rid=${encodeURIComponent(rid)}` : base;
}

export function replayWatchUrl(replayId: string, cameraId: string): string {
  return `${env.whepBaseUrl}/api/v1/replay/watch/${replayId}/${cameraId}`;
}
