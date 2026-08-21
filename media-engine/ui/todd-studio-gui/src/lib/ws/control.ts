// Control-plane WebSocket client — the director UI's live mirror of the
// broadcast state (rooms, cameras, PGM program, cricket sync config).
//
// The server pushes a full `snapshot` on connect and incremental events
// afterwards; this client folds events into a local state object so every
// React panel reads one consistent, current view without polling.

import { env } from "../utils";
import { getToken } from "../auth/authStore";
import type {
  AudioMixView,
  BallByBallStateDto,
  ControlEvent,
  CricketConfigView,
  ForwardingStatus,
  OverlayState,
  ProgramState,
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
};

export interface ControlFeed {
  close(): void;
  subscribe(listener: (state: ControlState) => void): () => void;
  getState(): ControlState;
}

/** Resolves the WebSocket base for same-origin deployments (empty
 * `VITE_API_BASE_URL`) and absolute API origins alike. */
function wsBaseUrl(): string {
  if (env.apiBaseUrl) return env.apiBaseUrl.replace(/^http/, "ws");
  const scheme = window.location.protocol === "https:" ? "wss:" : "ws:";
  return `${scheme}//${window.location.host}`;
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

  const scheduleReconnect = () => {
    if (closed) return;
    retry = setTimeout(connect, 2000);
  };

  function connect() {
    if (closed) return;
    const token = getToken();
    if (!token) {
      // Signed out — retry once auth is restored (the hook also tears
      // this feed down via close(), so this is just a safety net).
      scheduleReconnect();
      return;
    }
    const url = `${wsBaseUrl()}/api/v1/control/ws?token=${encodeURIComponent(token)}`;
    socket = new WebSocket(url);

    socket.onopen = () => {
      // The server sends the full snapshot immediately after upgrade.
    };
    socket.onmessage = (message) => {
      try {
        const event = JSON.parse(message.data as string) as ControlEvent;
        state = applyEvent(state, event);
        emit();
      } catch {
        // Malformed frame — ignore, keep the feed alive.
      }
    };
    socket.onclose = () => {
      if (!closed) {
        state = { ...state, connected: false, error: "control connection lost" };
        emit();
      }
      scheduleReconnect();
    };
    socket.onerror = () => socket?.close();
  }

  connect();

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
