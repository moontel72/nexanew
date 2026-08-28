// Control-plane WebSocket client — the director UI's live mirror of the
// broadcast state (rooms, cameras, PGM program, cricket sync config).
//
// The server pushes a full `snapshot` on connect and incremental events
// afterwards; this client folds events into a local state object so every
// React panel reads one consistent, current view without polling.

import { wsBaseUrl } from "../utils";
import {
  getToken,
  refreshToken,
  tokenExpirySeconds,
} from "../auth/authStore";
import type {
  AudioMixView,
  BallByBallStateDto,
  ControlEvent,
  CricketConfigView,
  ForwardingStatus,
  HighlightEntryDto,
  OverlayState,
  PollStateDto,
  ProgramState,
  ReplayInfo,
  Room,
} from "../api/types";

export interface ControlState {
  /** True when the socket is open and a snapshot has been applied. */
  connected: boolean;
  /** Last transport error message, if any. */
  error: string | null;
  rooms: Room[];
  /** Program (PGM) sources keyed by room id. */
  programs: Record<string, ProgramState>;
  /** Audio mixes keyed by room id. */
  audioMixes: Record<string, AudioMixView>;
  /** Program overlay states keyed by room id. */
  overlays: Record<string, OverlayState>;
  /** Output forwarders keyed by forwarder key. */
  forwarders: Record<string, ForwardingStatus>;
  cricket: CricketConfigView | null;
  /** Push-delivered ball-by-ball states keyed by match id. */
  scores: Record<string, BallByBallStateDto>;
  /** Live replay sessions (manual + auto-tagged) keyed by replay id. */
  replays: Record<string, ReplayInfo>;
  /** Active spectator polls keyed by room id. */
  polls: Record<string, PollStateDto>;
  /** Innings highlight playlist (newest first). */
  highlights: HighlightEntryDto[];
}

const EMPTY_STATE: ControlState = {
  connected: false,
  error: null,
  rooms: [],
  programs: {},
  audioMixes: {},
  overlays: {},
  forwarders: {},
  cricket: null,
  scores: {},
  replays: {},
  polls: {},
  highlights: [],
};

export interface ControlFeed {
  close(): void;
  subscribe(listener: (state: ControlState) => void): () => void;
  getState(): ControlState;
}

function upsertRoom(rooms: Room[], room: Room): Room[] {
  const index = rooms.findIndex((existing) => existing.id === room.id);
  if (index === -1) return [...rooms, room];
  const next = [...rooms];
  next[index] = room;
  return next;
}

function upsertCamera(rooms: Room[], roomId: string, camera: Room["cameras"][number]): Room[] {
  return rooms.map((room) => {
    if (room.id !== roomId) return room;
    const index = room.cameras.findIndex((existing) => existing.id === camera.id);
    const cameras = [...room.cameras];
    if (index === -1) cameras.push(camera);
    else cameras[index] = camera;
    return { ...room, cameras };
  });
}

function removeCamera(rooms: Room[], roomId: string, cameraId: string): Room[] {
  return rooms.map((room) =>
    room.id !== roomId
      ? room
      : { ...room, cameras: room.cameras.filter((camera) => camera.id !== cameraId) },
  );
}

function applyEvent(state: ControlState, event: ControlEvent): ControlState {
  switch (event.type) {
    case "snapshot":
      return {
        ...state,
        connected: true,
        error: null,
        // `ControlRoomSnapshot` flattens the room fields (serde
        // `#[serde(flatten)]`), so each entry *is* a room.
        rooms: event.rooms,
        programs: Object.fromEntries(
          event.rooms
            .filter((entry): entry is typeof entry & { program: ProgramState } => entry.program !== null)
            .map((entry) => [entry.id, entry.program]),
        ),
        cricket: event.cricket,
        scores: Object.fromEntries(
          event.scores.map((score) => [score.match_id, score]),
        ),
        replays: Object.fromEntries(
          event.replays.map((replay) => [replay.replay_id, replay]),
        ),
        polls: Object.fromEntries(
          event.polls.map((poll) => [poll.room_id, poll]),
        ),
        highlights: event.highlights,
      };
    case "room_created":
      return { ...state, rooms: upsertRoom(state.rooms, event.room) };
    case "room_deleted": {
      const programs = { ...state.programs };
      delete programs[event.room_id];
      return {
        ...state,
        rooms: state.rooms.filter((room) => room.id !== event.room_id),
        programs,
      };
    }
    case "camera_added":
      return {
        ...state,
        rooms: upsertCamera(state.rooms, event.room_id, event.camera),
      };
    case "camera_updated":
      return {
        ...state,
        rooms: upsertCamera(state.rooms, event.room_id, event.camera),
      };
    case "camera_removed": {
      const programs = { ...state.programs };
      if (programs[event.room_id]?.camera_id === event.camera_id) {
        delete programs[event.room_id];
      }
      return {
        ...state,
        rooms: removeCamera(state.rooms, event.room_id, event.camera_id),
        programs,
      };
    }
    case "program_changed":
      return {
        ...state,
        programs: { ...state.programs, [event.program.room_id]: event.program },
      };
    case "audio_mixer_changed":
      return {
        ...state,
        audioMixes: { ...state.audioMixes, [event.room_id]: event.mix },
      };
    case "overlay_changed":
      return {
        ...state,
        overlays: { ...state.overlays, [event.room_id]: event.overlays },
      };
    case "forwarding_changed":
      return {
        ...state,
        forwarders: { ...state.forwarders, [event.status.key]: event.status },
      };
    case "cricket_config_changed":
      return { ...state, cricket: event.config };
    case "score_updated":
      return {
        ...state,
        scores: { ...state.scores, [event.match_id]: event.score },
      };
    case "replay_created":
      return {
        ...state,
        replays: { ...state.replays, [event.replay.replay_id]: event.replay },
      };
    case "poll_changed":
      return {
        ...state,
        polls: { ...state.polls, [event.room_id]: event.poll },
      };
    case "poll_cleared": {
      const polls = { ...state.polls };
      delete polls[event.room_id];
      return { ...state, polls };
    }
    case "highlight_added":
      return {
        ...state,
        highlights: [
          event.entry,
          ...state.highlights.filter((e) => e.replay_id !== event.entry.replay_id),
        ].slice(0, 200),
      };
  }
}

/** Connects to `GET /api/v1/control/ws` with the SSO JWT from the auth
 * store and folds events into a shared local state. One feed per app
 * instance. */
export function connectControl(): ControlFeed {
  let state: ControlState = { ...EMPTY_STATE };
  const listeners = new Set<(state: ControlState) => void>();
  let socket: WebSocket | undefined;
  let closed = false;
  let retry: ReturnType<typeof setTimeout> | undefined;

  const emit = () => listeners.forEach((listener) => listener(state));

  // Guards against a refresh storm: when a handshake fails with 401 the
  // socket closes and a reconnect is scheduled — every cycle would mint
  // a fresh token otherwise.
  let lastRefreshAt = 0;

  const scheduleReconnect = () => {
    if (closed) return;
    retry = setTimeout(() => void connect(), 2000);
  };

  async function connect() {
    if (closed) return;

    // Proactive + reactive refresh: never dial with a token that is past
    // (or within a minute of) its expiry — the engine rejects expired
    // SSO JWTs during the WebSocket upgrade with a 401 that the browser
    // can only observe as a bare close.
    let token = getToken();
    if (!token || (tokenExpirySeconds() ?? 0) < 60) {
      token = await refreshToken();
      if (!token) {
        scheduleReconnect();
        return;
      }
    }

    const url = `${wsBaseUrl()}/api/v1/control/ws?token=${encodeURIComponent(token)}`;
    const candidate = new WebSocket(url);
    socket = candidate;

    candidate.onopen = () => {
      lastRefreshAt = 0;
      // The server sends the full snapshot immediately after upgrade.
    };
    candidate.onmessage = (message) => {
      try {
        const event = JSON.parse(message.data as string) as ControlEvent;
        state = applyEvent(state, event);
        emit();
      } catch {
        // Malformed frame — ignore, keep the feed alive.
      }
    };
    candidate.onclose = () => {
      if (!closed) {
        state = { ...state, connected: false, error: "control connection lost" };
        emit();
      }
      // 401 upgrades close without ever opening; a fresh token fixes the
      // next attempt. Rate-limit to one refresh per 10s so a misconfigured
      // secret cannot hammer the issuer endpoint.
      const now = Date.now();
      if (!closed && now - lastRefreshAt > 10_000) {
        lastRefreshAt = now;
        void refreshToken().finally(() => scheduleReconnect());
      } else {
        scheduleReconnect();
      }
    };
    candidate.onerror = () => candidate?.close();
  }

  void connect();

  return {
    close() {
      closed = true;
      if (retry) clearTimeout(retry);
      socket?.close();
      listeners.clear();
      state = { ...EMPTY_STATE };
    },
    subscribe(listener) {
      listeners.add(listener);
      listener(state);
      return () => listeners.delete(listener);
    },
    getState() {
      return state;
    },
  };
}
