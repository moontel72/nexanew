// DTOs mirroring the Rust `todd-common` / `todd-replay` JSON contracts
// (snake_case, as returned by the media engine).

/// How a camera's media reaches the engine.
export type CameraSourceKind = "whip" | "rtsp" | "rtmp";

export interface CameraInfo {
  id: string;
  label?: string | null;
  kind: CameraSourceKind;
  group?: string | null;
  active: boolean;
}

/// Camera metadata supplied when creating or adding a camera.
export interface CameraSpec {
  id: string;
  label?: string | null;
  kind?: CameraSourceKind;
  group?: string | null;
}

/// Partial camera metadata update (omitted fields keep their value).
export interface UpdateCameraRequest {
  label?: string;
  kind?: CameraSourceKind;
  group?: string;
}

export interface AddCameraResponse {
  camera: CameraInfo;
  ingest_token: string;
  whip_base_url: string;
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
  room_id: string;
  event: string;
  speed: number;
  lookback_ms: number;
  created_at_ms: number;
  status: "playing" | "finished";
  cameras: ReplayCameraInfo[];
}

/** Frame-accurate VAR review state of one replay session. */
export interface VarCameraDto {
  camera_id: string;
  frames: number;
}

export interface ReplayVarStateDto {
  replay_id: string;
  room_id: string;
  current_frame: number;
  total_frames: number;
  cameras: VarCameraDto[];
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

/** Broadcaster device health (pushed by the ground cameras). */
export interface DeviceTelemetryEntryDto {
  room_id: string;
  camera_id: string;
  battery_pct?: number | null;
  fps?: number | null;
  uplink_kbps?: number | null;
  dropped_frames?: number | null;
  quality?: "good" | "fair" | "poor" | string | null;
}

export interface TelemetrySnapshot {
  metrics: [string, number][];
  streams: StreamFeedEntry[];
  ice_sessions: IceSessionInfo[];
  audio_levels: AudioLevelEntry[];
  devices: DeviceTelemetryEntryDto[];
}

// --------------------------------------------------------------------------
// Vision switcher / program (PGM) state
// --------------------------------------------------------------------------

export type TransitionKind = "cut" | "fade" | "luma_wipe" | "stinger";

/// Animated overlay asset played during a stinger transition.
export interface StingerSpec {
  asset_url?: string | null;
}

/// A camera source within a scene (scenes reference cameras of the same
/// room).
export interface SourceRef {
  room_id: string;
  camera_id: string;
}

/// Picture-in-picture placement (normalized 0–1 coordinates).
export interface PiPConfig {
  main: SourceRef;
  overlay: SourceRef;
  overlay_x: number;
  overlay_y: number;
  overlay_width: number;
  overlay_height: number;
  overlay_opacity: number;
}

export type SplitOrientation = "horizontal" | "vertical";

export interface SplitRegion {
  source: SourceRef;
  weight: number;
}

export interface SplitScreenConfig {
  orientation: SplitOrientation;
  regions: SplitRegion[];
}

export interface SideBySideConfig {
  left: SourceRef;
  right: SourceRef;
}

/// Serde-adjacently-tagged scene layout (the `kind` field discriminates;
/// the variant fields are flattened into the same object).
export type SceneLayout =
  | { kind: "fullscreen" }
  | ({ kind: "picture_in_picture" } & PiPConfig)
  | ({ kind: "split_screen" } & SplitScreenConfig)
  | ({ kind: "side_by_side" } & SideBySideConfig);

export interface ProgramTransitionRequest {
  room_id: string;
  camera_id: string;
  transition: TransitionKind;
  duration_ms?: number;
  layout?: SceneLayout;
  stinger?: StingerSpec;
}

export interface ProgramState {
  room_id: string;
  camera_id: string;
  rid: string;
  transition: TransitionKind;
  duration_ms: number;
  layout: SceneLayout;
  stinger?: StingerSpec | null;
  updated_at_ms: number;
}

// --------------------------------------------------------------------------
// Program overlays (server-side burn-in)
// --------------------------------------------------------------------------

export interface ScoreboardOverlay {
  enabled: boolean;
  title: string;
  subtitle: string;
}

export interface EventPopupSpec {
  text: string;
  subtext?: string | null;
  duration_ms: number;
}

export interface WatermarkSpec {
  asset_url: string;
  x: number;
  y: number;
}

export interface OverlayState {
  scoreboard?: ScoreboardOverlay | null;
  popup?: EventPopupSpec | null;
  watermark?: WatermarkSpec | null;
}

export type OverlayCommand =
  | { kind: "scoreboard"; enabled: boolean; title: string; subtitle: string }
  | { kind: "event_popup"; text: string; subtext?: string | null; duration_ms?: number }
  | { kind: "watermark"; enabled: boolean; asset_url?: string | null; x: number; y: number };

// --------------------------------------------------------------------------
// Broadcast output distribution
// --------------------------------------------------------------------------

export type ForwardSource = "camera" | "program";
export type ForwardState = "starting" | "running" | "stopped" | "failed";

export interface ForwardingStatus {
  key: string;
  room_id: string;
  source: ForwardSource;
  kind: "rtmp" | "srt" | "file" | "webrtc_viewer";
  url: string;
  state: ForwardState;
  started_at_ms: number;
  error?: string | null;
}

export interface ForwardTargetRequest {
  camera_id: string;
  source: ForwardSource;
  kind: "rtmp" | "srt" | "file" | "webrtc_viewer";
  url: string;
  encoder?: "auto" | "nvenc" | "amf" | "qsv" | "x264" | "passthrough";
  bitrate_kbps?: number;
  keyframe_interval?: number;
  rid?: string | null;
  audio?: AudioMixerConfig;
}

// --------------------------------------------------------------------------
// Audio mix (per-room, carried by the control-plane snapshot)
// --------------------------------------------------------------------------

export type AudioBus = "commentary" | "ambient" | "sfx" | "music";

export interface AudioBusSpec {
  bus: AudioBus;
  enabled: boolean;
  /** Fader gain in dB (0 = unity); the UI presents a 0–2× multiplier. */
  volume_db: number;
  muted: boolean;
  solo: boolean;
  /** Trim gain in dB, clamped [-24, +24]. */
  gain_db: number;
  /** Lip-sync correction delay in ms, clamped [0, 500]. */
  delay_ms: number;
}

export interface AudioMixerConfig {
  buses: AudioBusSpec[];
  master_volume_db: number;
}

/** Real-time level metering of one bus (dBFS). */
export interface BusMetering {
  bus: string;
  peak_db: number;
  rms_db: number;
}

/** Read model of GET/PUT /api/v1/audio/mix/{room_id}. */
export interface AudioMixView {
  config: AudioMixerConfig;
  metering: BusMetering[];
}

/** Audio level entry in the telemetry WebSocket snapshot. */
export interface AudioLevelEntry {
  room_id: string;
  bus: string;
  peak_db: number;
  rms_db: number;
}

// --------------------------------------------------------------------------
// Cricket manager sync configuration
// --------------------------------------------------------------------------

export interface CricketMatchConfig {
  match_id: string;
  label: string;
}

export type MatchSyncState = "pending" | "synced" | "error";

/** Which transport delivered the last successful sync. */
export type SyncTransport = "pending" | "push" | "poll";

export interface MatchSyncStatus {
  match_id: string;
  state: MatchSyncState;
  transport: SyncTransport;
  last_ok_at_ms?: number | null;
  last_error?: string | null;
}

export interface CricketConfigView {
  base_url: string;
  match_configs: CricketMatchConfig[];
  poll_ms: number;
  api_token_set: boolean;
  sync: MatchSyncStatus[];
  /** Match the manager is currently operating (shared context). */
  active_match_id: string | null;
  /** True while the engine's Reverb push socket is connected. */
  push_connected: boolean;
}

export interface CricketConfigUpdate {
  match_configs: CricketMatchConfig[];
  poll_ms?: number;
  api_token?: string;
}

// --------------------------------------------------------------------------
// Ball-by-ball scoreboard state (mirrors Rust `BallByBallState`)
// --------------------------------------------------------------------------

/** One classified scoring event (drives auto-graphics + auto-replay). */
export interface BallEventDto {
  /** "four" | "six" | "wicket" | "catch" | "milestone" | "other" */
  kind: string;
  /** Ready-to-burn popup text, e.g. "SIX — Square Leg". */
  text: string;
  runs: number;
  zone?: string | null;
  direction?: number | null;
  x?: number | null;
  y?: number | null;
  milestone_runs?: number | null;
  milestone_player?: string | null;
}

export interface BallByBallStateDto {
  match_id: string;
  batting_team: string;
  bowling_team: string;
  runs: number;
  wickets: number;
  overs: number;
  run_rate: number;
  batter_on_strike: string;
  batter_non_strike: string;
  bowler: string;
  recent_balls: string[];
  updated_at_ms: number;
  last_event?: BallEventDto | null;
}

// --------------------------------------------------------------------------
// Spectator polls (Phase 5 fan engagement)
// --------------------------------------------------------------------------

export interface PollOptionDto {
  label: string;
  votes: number;
}

export interface PollStateDto {
  question: string;
  options: PollOptionDto[];
  active: boolean;
  updated_at_ms: number;
}

// --------------------------------------------------------------------------
// Innings highlight playlist (Phase 5)
// --------------------------------------------------------------------------

export interface HighlightEntryDto {
  replay_id: string;
  event: string;
  match_id?: string | null;
  created_at_ms: number;
}

// --------------------------------------------------------------------------
// Control-plane WebSocket events
// --------------------------------------------------------------------------

/// One room's full state as pushed by the control plane.
export type ControlRoomSnapshot = Room & {
  program: ProgramState | null;
  mixer: AudioMixerConfig;
};

export type ControlEvent =
  | {
      type: "snapshot";
      rooms: ControlRoomSnapshot[];
      cricket: CricketConfigView;
      scores: BallByBallStateDto[];
      replays: ReplayInfo[];
      polls: Array<{ room_id: string } & PollStateDto>;
      highlights: HighlightEntryDto[];
    }
  | { type: "room_created"; room: Room }
  | { type: "room_deleted"; room_id: string }
  | {
      type: "camera_added";
      room_id: string;
      camera: CameraInfo;
      ingest_token: string;
      whip_base_url: string;
    }
  | { type: "camera_updated"; room_id: string; camera: CameraInfo }
  | { type: "camera_removed"; room_id: string; camera_id: string }
  | { type: "program_changed"; program: ProgramState }
  | { type: "audio_mixer_changed"; room_id: string; mix: AudioMixView }
  | { type: "overlay_changed"; room_id: string; overlays: OverlayState }
  | { type: "forwarding_changed"; status: ForwardingStatus }
  | { type: "cricket_config_changed"; config: CricketConfigView }
  | { type: "score_updated"; match_id: string; score: BallByBallStateDto }
  | { type: "replay_created"; replay: ReplayInfo }
  | { type: "poll_changed"; room_id: string; poll: PollStateDto }
  | { type: "poll_cleared"; room_id: string }
  | { type: "highlight_added"; entry: HighlightEntryDto };
