// DTOs mirroring the Rust `todd-common` / `todd-replay` JSON contracts
// (snake_case, as returned by the media engine).

export interface CameraInfo {
  id: string;
  active: boolean;
}

export interface Room {
  id: string;
  name: string;
  created_at: string;
  expires_at: string;
  cameras: CameraInfo[];
}

export interface CreateRoomResponse {
  room: Room;
  ingest_tokens: Record<string, string>;
  viewer_token: string;
  whip_base_url: string;
}

export type ReplayEventKind =
  | "run_out"
  | "wicket"
  | "boundary"
  | "catch"
  | "custom";

export interface ReplayTriggerRequest {
  room_id: string;
  camera_ids?: string[];
  event: ReplayEventKind;
  lookback_ms: number;
  speed: number;
  loop_playback?: boolean;
}

export interface ReplayCameraInfo {
  camera_id: string;
  codec: string;
  packets: number;
}

export interface ReplayInfo {
  replay_id: string;
  event: string;
  speed: number;
  lookback_ms: number;
  created_at_ms: number;
  status: "playing" | "finished";
  cameras: ReplayCameraInfo[];
}

export type ExportState = "pending" | "running" | "done" | "failed";

export interface ExportStatus {
  export_id: string;
  replay_id: string;
  camera_id: string;
  state: ExportState;
  url: string;
  error?: string;
}

export interface StreamFeedEntry {
  room_id: string;
  camera_id: string;
  packets_in: number;
  bytes_in: number;
  packets_dropped: number;
  packets_forwarded: number;
  bytes_forwarded: number;
  rtt_ms: number;
  ingress_bps: number;
  egress_bps: number;
  jitter_ms: number;
}

export interface IceSessionInfo {
  kind: "whip" | "whep";
  room_id: string;
  camera_id: string;
  state: string;
}

export interface TelemetrySnapshot {
  metrics: [string, number][];
  streams: StreamFeedEntry[];
  ice_sessions: IceSessionInfo[];
}
