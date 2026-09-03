/// Shared constants for the Todd Broadcaster feature.
///
/// Every tunable value lives here so the WHIP client, telemetry service,
/// cubit and UI stay in sync without duplicating literals.
library;

/// Selectable camera profile (resolution + encoder bitrate ceiling).
class CameraProfile {
  const CameraProfile(this.label, this.width, this.height, this.bitrateKbps);

  final String label;
  final int width;
  final int height;

  /// Video encoder bitrate ceiling in kbps. Lower profiles use lower
  /// ceilings so a weak mobile uplink still delivers a stable feed.
  final int bitrateKbps;

  @override
  bool operator ==(Object other) =>
      other is CameraProfile && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(width, height);
}

/// Tuning constants shared across the broadcaster feature.
abstract final class BroadcasterConstants {
  /// Maximum reconnect attempts before the broadcast fails permanently.
  static const int maxReconnectAttempts = 6;

  /// Backoff ceiling: 1s, 2s, 4s, 8s, 16s, 30s, 30s…
  static const int maxBackoffSeconds = 30;

  /// Interval between device health samples pushed to the engine.
  static const Duration telemetryInterval = Duration(seconds: 2);

  /// RTT thresholds (seconds) for network quality classification.
  static const double rttGoodThresholdSeconds = 0.15;
  static const double rttFairThresholdSeconds = 0.4;

  /// ICE gathering poll bounds (max wait, poll step).
  ///
  /// 10s bound: behind carrier NAT, STUN (srflx) discovery can take a few
  /// seconds; posting the offer before it completes sends host-only
  /// candidates that the engine can never reach. Gathering normally
  /// completes well inside this window — the bound only prevents a hang.
  static const Duration iceGatherMaxWait = Duration(seconds: 10);
  static const Duration iceGatherPollStep = Duration(milliseconds: 100);

  /// STUN server used when the operator leaves the STUN field empty.
  ///
  /// Without it the phone only gathers host candidates (private IPs),
  /// which the engine can never reach behind carrier NAT — ICE fails and
  /// no media flows even though the WHIP signaling succeeds. A public
  /// STUN server gives the phone a server-reflexive (srflx) candidate.
  static const String defaultStunUrl = 'stun:stun.l.google.com:19302';

  /// Default capture frame rate. 25fps (PAL broadcast standard): ~20%
  /// less uplink than 30fps and the video encoder reaches its first
  /// keyframe faster on mid-range phones — the tile goes live sooner.
  static const int defaultFps = 25;

  /// Frame rates offered in the control UI.
  static const List<int> fpsOptions = <int>[25, 30, 60];

  /// Engine base URL shown as the connection form's hint.
  static const String engineUrlHint = 'https://studio.traceodd.com';

  /// Delay before the preview renderer is disposed after teardown so a
  /// still-mounted RTCVideoView can detach first.
  static const Duration rendererDisposeDelay = Duration(seconds: 1);
}

/// Default profile (480p): a stable size for mobile uplinks and a fast
/// encoder start — the 720p default kept re-warming a slow encoder on
/// every session restart.
const CameraProfile kDefaultCameraProfile = CameraProfile('480p', 854, 480, 800);

/// Profiles offered in the control UI (lowest first).
const List<CameraProfile> kCameraProfiles = <CameraProfile>[
  CameraProfile('360p', 640, 360, 500),
  kDefaultCameraProfile,
  CameraProfile('720p', 1280, 720, 2500),
  CameraProfile('1080p', 1920, 1080, 4500),
];
