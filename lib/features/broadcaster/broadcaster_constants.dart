/// Shared constants for the Todd Broadcaster feature.
///
/// Every tunable value lives here so the WHIP client, telemetry service,
/// cubit and UI stay in sync without duplicating literals.
library;

/// Selectable camera profile (720p / 1080p).
class CameraProfile {
  const CameraProfile(this.label, this.width, this.height);

  final String label;
  final int width;
  final int height;

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
  static const Duration iceGatherMaxWait = Duration(seconds: 3);
  static const Duration iceGatherPollStep = Duration(milliseconds: 50);

  /// Default capture frame rate.
  static const int defaultFps = 30;

  /// Frame rates offered in the control UI.
  static const List<int> fpsOptions = <int>[30, 60];

  /// Engine base URL shown as the connection form's hint.
  static const String engineUrlHint = 'https://studio.traceodd.com';

  /// Delay before the preview renderer is disposed after teardown so a
  /// still-mounted RTCVideoView can detach first.
  static const Duration rendererDisposeDelay = Duration(seconds: 1);
}

/// Default profile (720p) used by the initial state and config form.
const CameraProfile kDefaultCameraProfile = CameraProfile('720p', 1280, 720);

/// Profiles offered in the control UI.
const List<CameraProfile> kCameraProfiles = <CameraProfile>[
  kDefaultCameraProfile,
  CameraProfile('1080p', 1920, 1080),
];
