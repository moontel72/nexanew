import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../broadcaster_constants.dart';
import '../data/services/device_telemetry.dart';
import '../data/services/whip_client.dart';

/// Connection configuration supplied by the camera operator (or the
/// studio director). Every value comes from user input — nothing is
/// hardcoded or defaulted inside the engine calls.
class BroadcasterConfig {
  const BroadcasterConfig({
    required this.baseUrl,
    required this.roomId,
    required this.cameraId,
    required this.token,
    this.stunUrl = '',
    this.turnUrl = '',
  });

  final String baseUrl;
  final String roomId;
  final String cameraId;
  final String token;
  final String stunUrl;
  final String turnUrl;
}

/// Selectable camera profile (720p / 1080p).
/// See `broadcaster_constants.dart` for profiles and tunables.
enum BroadcasterPhase { idle, connecting, live, reconnecting, stopped }

/// Immutable UI state for the broadcaster control plane.
class BroadcasterState {
  const BroadcasterState({
    this.phase = BroadcasterPhase.idle,
    this.config,
    this.renderer,
    this.facingMode = 'environment',
    this.profile = kDefaultCameraProfile,
    this.targetFps = BroadcasterConstants.defaultFps,
    this.torchOn = false,
    this.audioMuted = false,
    this.connectionState,
    this.health,
    this.reconnectAttempt = 0,
    this.reconnectDelay,
    this.error,
    this.notice,
  });

  final BroadcasterPhase phase;
  final BroadcasterConfig? config;

  /// Live local preview surface. Non-null while the camera is opened.
  final RTCVideoRenderer? renderer;

  /// `environment` (rear) or `user` (front) lens.
  final String facingMode;
  final CameraProfile profile;
  final int targetFps;
  final bool torchOn;
  final bool audioMuted;
  final RTCPeerConnectionState? connectionState;
  final DeviceHealth? health;
  final int reconnectAttempt;
  final Duration? reconnectDelay;
  final String? error;
  final String? notice;

  BroadcasterState copyWith({
    BroadcasterPhase? phase,
    BroadcasterConfig? config,
    RTCVideoRenderer? renderer,
    String? facingMode,
    CameraProfile? profile,
    int? targetFps,
    bool? torchOn,
    bool? audioMuted,
    RTCPeerConnectionState? connectionState,
    DeviceHealth? health,
    int? reconnectAttempt,
    Duration? reconnectDelay,
    String? error,
    String? notice,
    bool clearNotice = false,
  }) {
    return BroadcasterState(
      phase: phase ?? this.phase,
      config: config ?? this.config,
      renderer: renderer ?? this.renderer,
      facingMode: facingMode ?? this.facingMode,
      profile: profile ?? this.profile,
      targetFps: targetFps ?? this.targetFps,
      torchOn: torchOn ?? this.torchOn,
      audioMuted: audioMuted ?? this.audioMuted,
      connectionState: connectionState ?? this.connectionState,
      health: health ?? this.health,
      reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
      reconnectDelay: reconnectDelay ?? this.reconnectDelay,
      error: error,
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}

sealed class BroadcasterEvent {
  const BroadcasterEvent();
}

final class BroadcastStart extends BroadcasterEvent {
  const BroadcastStart(this.config);
  final BroadcasterConfig config;
}

final class BroadcastStop extends BroadcasterEvent {
  const BroadcastStop();
}

final class SwitchCameraRequested extends BroadcasterEvent {
  const SwitchCameraRequested();
}

final class ToggleTorchRequested extends BroadcasterEvent {
  const ToggleTorchRequested();
}

final class ProfileChanged extends BroadcasterEvent {
  const ProfileChanged(this.profile);
  final CameraProfile profile;
}

final class FpsChanged extends BroadcasterEvent {
  const FpsChanged(this.fps);
  final int fps;
}

final class ToggleAudioMuteRequested extends BroadcasterEvent {
  const ToggleAudioMuteRequested();
}

final class _ConnectionStateChanged extends BroadcasterEvent {
  const _ConnectionStateChanged(this.state);
  final RTCPeerConnectionState state;
}

final class _HealthChanged extends BroadcasterEvent {
  const _HealthChanged(this.health);
  final DeviceHealth health;
}

final class _RetryConnect extends BroadcasterEvent {
  const _RetryConnect();
}

/// Outcome of one camera-open + WHIP negotiation attempt.
sealed class _OpenResult {
  const _OpenResult();
}

final class _OpenConnected extends _OpenResult {
  const _OpenConnected();
}

final class _OpenFailed extends _OpenResult {
  const _OpenFailed(this.message);

  final String message;
}

/// Drives the mobile broadcaster: WHIP ingest lifecycle, camera
/// controls, device telemetry, and auto-reconnect with exponential
/// backoff.
class BroadcasterCubit extends Bloc<BroadcasterEvent, BroadcasterState> {
  BroadcasterCubit({BroadcasterConfig? initialConfig})
    : super(BroadcasterState(config: initialConfig)) {
    on<BroadcastStart>(_onStart);
    on<BroadcastStop>(_onStop);
    on<SwitchCameraRequested>(_onSwitchCamera);
    on<ToggleTorchRequested>(_onToggleTorch);
    on<ProfileChanged>(_onProfileChanged);
    on<FpsChanged>(_onFpsChanged);
    on<ToggleAudioMuteRequested>(_onToggleMute);
    on<_ConnectionStateChanged>(_onConnectionStateChanged);
    on<_HealthChanged>(_onHealthChanged);
    on<_RetryConnect>(_onRetryConnect);
  }

  WhipClient? _client;
  WhipSession? _session;
  DeviceTelemetry? _telemetry;
  RTCVideoRenderer? _renderer;
  RTCPeerConnection? _pc;
  Timer? _reconnectTimer;
  Timer? _rendererDisposeTimer;
  int _reconnectAttempt = 0;
  bool _started = false;

  @override
  Future<void> close() async {
    // Dispose the renderer immediately so the delayed-dispose timer can
    // never fire after the cubit is closed.
    await _teardown(disposeRendererNow: true);
    await super.close();
  }

  Future<void> _onStart(
    BroadcastStart event,
    Emitter<BroadcasterState> emit,
  ) async {
    if (_started) return;

    final baseUrl = event.config.baseUrl.trim();
    final roomId = event.config.roomId.trim();
    final cameraId = event.config.cameraId.trim();
    final token = event.config.token.trim();
    if (baseUrl.isEmpty ||
        roomId.isEmpty ||
        cameraId.isEmpty ||
        token.isEmpty) {
      emit(
        state.copyWith(
          phase: BroadcasterPhase.stopped,
          error: 'Base URL, room, camera and token are all required.',
        ),
      );
      return;
    }

    _started = true;
    _reconnectAttempt = 0;
    _client = WhipClient(baseUrl: baseUrl);
    _telemetry = DeviceTelemetry(
      wsBaseUrl: wsBaseUrlFor(baseUrl),
      roomId: roomId,
      cameraId: cameraId,
    );
    _telemetry!.onSample = (DeviceHealth sample) {
      if (!isClosed) add(_HealthChanged(sample));
    };

    _renderer = RTCVideoRenderer();
    try {
      await _renderer!.initialize();
    } catch (err) {
      await _teardown(disposeRendererNow: true);
      emit(
        const BroadcasterState().copyWith(
          phase: BroadcasterPhase.stopped,
          error: 'Preview surface failed to initialize: $err',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: BroadcasterPhase.connecting,
        config: event.config,
        renderer: _renderer,
      ),
    );
    _handleOpenResult(await _attemptOpen(), emit);
  }

  Future<void> _onStop(
    BroadcastStop event,
    Emitter<BroadcasterState> emit,
  ) async {
    await _teardown();
    emit(
      const BroadcasterState().copyWith(
        phase: BroadcasterPhase.stopped,
        config: state.config,
      ),
    );
  }

  Future<void> _onRetryConnect(
    _RetryConnect event,
    Emitter<BroadcasterState> emit,
  ) async {
    _handleOpenResult(await _attemptOpen(), emit);
  }

  Future<void> _onSwitchCamera(
    SwitchCameraRequested event,
    Emitter<BroadcasterState> emit,
  ) async {
    final s = state;
    if (s.phase != BroadcasterPhase.live) return;

    final newFacing = s.facingMode == 'environment' ? 'user' : 'environment';
    final track = _videoTrack();
    if (track != null) {
      try {
        final switched = await Helper.switchCamera(track);
        if (switched) {
          emit(
            s.copyWith(
              facingMode: newFacing,
              torchOn: false,
              clearNotice: true,
            ),
          );
          return;
        }
      } catch (_) {
        // Lens swap unsupported — fall through to capture restart.
      }
    }

    emit(
      s.copyWith(
        facingMode: newFacing,
        torchOn: false,
        notice: 'Restarting capture for camera switch…',
      ),
    );
    await _restartCapture(emit);
  }

  Future<void> _onToggleTorch(
    ToggleTorchRequested event,
    Emitter<BroadcasterState> emit,
  ) async {
    final s = state;
    if (s.phase != BroadcasterPhase.live) return;

    final track = _videoTrack();
    if (track == null) return;

    try {
      final supported = await track.hasTorch();
      if (!supported) {
        emit(
          s.copyWith(notice: 'Torch is not available on the active camera.'),
        );
        return;
      }
      final next = !s.torchOn;
      await track.setTorch(next);
      emit(s.copyWith(torchOn: next, clearNotice: true));
    } catch (_) {
      emit(s.copyWith(notice: 'Failed to toggle the torch.'));
    }
  }

  Future<void> _onProfileChanged(
    ProfileChanged event,
    Emitter<BroadcasterState> emit,
  ) async {
    final s = state;
    if (s.profile == event.profile) return;

    final track = _videoTrack();
    if (track != null && s.phase == BroadcasterPhase.live) {
      try {
        await track.applyConstraints(<String, dynamic>{
          'width': event.profile.width,
          'height': event.profile.height,
          'frameRate': s.targetFps,
        });
        emit(s.copyWith(profile: event.profile, clearNotice: true));
        return;
      } catch (_) {
        // Constraint renegotiation unsupported — restart capture.
      }
    }

    emit(s.copyWith(profile: event.profile));
    if (s.phase == BroadcasterPhase.live) {
      await _restartCapture(emit);
    }
  }

  Future<void> _onFpsChanged(
    FpsChanged event,
    Emitter<BroadcasterState> emit,
  ) async {
    final s = state;
    if (s.targetFps == event.fps) return;

    final track = _videoTrack();
    if (track != null && s.phase == BroadcasterPhase.live) {
      try {
        await track.applyConstraints(<String, dynamic>{
          'width': s.profile.width,
          'height': s.profile.height,
          'frameRate': event.fps,
        });
        emit(s.copyWith(targetFps: event.fps, clearNotice: true));
        return;
      } catch (_) {
        // Constraint renegotiation unsupported — restart capture.
      }
    }

    emit(s.copyWith(targetFps: event.fps));
    if (s.phase == BroadcasterPhase.live) {
      await _restartCapture(emit);
    }
  }

  Future<void> _onToggleMute(
    ToggleAudioMuteRequested event,
    Emitter<BroadcasterState> emit,
  ) async {
    final s = state;
    final muted = !s.audioMuted;
    for (final track
        in _session?.stream.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !muted;
    }
    emit(s.copyWith(audioMuted: muted, clearNotice: true));
  }

  Future<void> _onConnectionStateChanged(
    _ConnectionStateChanged event,
    Emitter<BroadcasterState> emit,
  ) async {
    if (!_started) return;

    emit(state.copyWith(connectionState: event.state, clearNotice: true));

    switch (event.state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        _reconnectAttempt = 0;
        emit(
          state.copyWith(
            phase: BroadcasterPhase.live,
            reconnectAttempt: 0,
            reconnectDelay: null,
            error: null,
          ),
        );
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        if (state.phase == BroadcasterPhase.live ||
            state.phase == BroadcasterPhase.connecting) {
          _scheduleReconnect(emit);
        }
      case RTCPeerConnectionState.RTCPeerConnectionStateNew ||
          RTCPeerConnectionState.RTCPeerConnectionStateConnecting ||
          RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        break;
    }
  }

  void _onHealthChanged(_HealthChanged event, Emitter<BroadcasterState> emit) {
    emit(state.copyWith(health: event.health));
  }

  /// Opens the camera, refreshes the preview and negotiates the WHIP
  /// ingest. Pure work — callers emit state based on the result.
  Future<_OpenResult> _attemptOpen() async {
    final s = state;
    final config = s.config;
    if (config == null || _client == null || _telemetry == null) {
      return const _OpenFailed('Missing connection configuration.');
    }

    // Drop the previous session (if any) before opening a fresh one.
    await _session?.close();
    _session = null;
    _pc = null;

    MediaStream stream;
    try {
      stream = await _client!.openCamera(
        facingMode: s.facingMode,
        width: s.profile.width,
        height: s.profile.height,
        fps: s.targetFps,
        audioEnabled: !s.audioMuted,
      );
    } catch (err) {
      return _OpenFailed('Camera capture failed: $err');
    }

    final renderer = _renderer;
    if (renderer != null) {
      try {
        renderer.srcObject = stream;
      } catch (err) {
        // The preview rejected the stream — release it so the camera is
        // not left open with no owner.
        try {
          await stream.dispose();
        } catch (_) {
          // Already disposed.
        }
        return _OpenFailed('Preview attach failed: $err');
      }
    }

    WhipSession session;
    try {
      session = await _client!.connect(
        roomId: config.roomId,
        cameraId: config.cameraId,
        token: config.token,
        stream: stream,
        stunUrl: config.stunUrl,
        turnUrl: config.turnUrl.isEmpty ? null : config.turnUrl,
      );
    } catch (err) {
      return _OpenFailed('WHIP ingest failed: $err');
    }

    _session = session;
    _pc = session.pc;
    _telemetry!.attach(session.pc);
    // A reconnect may leave the previous telemetry socket/timer running;
    // stop it before opening a fresh one to avoid leaking both.
    _telemetry!.stop();
    _telemetry!.start();
    session.pc.onConnectionState = (RTCPeerConnectionState st) {
      if (!isClosed) add(_ConnectionStateChanged(st));
    };
    return const _OpenConnected();
  }

  /// Applies an open/connect outcome: publish live state or schedule
  /// the next backoff retry.
  void _handleOpenResult(_OpenResult result, Emitter<BroadcasterState> emit) {
    if (!_started) return;

    switch (result) {
      case _OpenConnected():
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        _reconnectAttempt = 0;
        // WHIP 201 only means the engine accepted the offer — media
        // flows only once ICE reaches `connected`. Keep the tile honest:
        // stay in `connecting` until the peer-connection state callback
        // promotes us (or reports failure, which schedules a reconnect).
        final iceConnected =
            _pc?.connectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateConnected;
        emit(
          state.copyWith(
            phase: iceConnected
                ? BroadcasterPhase.live
                : BroadcasterPhase.connecting,
            connectionState: _pc?.connectionState,
            reconnectAttempt: 0,
            reconnectDelay: null,
            error: null,
            clearNotice: true,
          ),
        );
      case _OpenFailed(:final message):
        if (_reconnectAttempt >= BroadcasterConstants.maxReconnectAttempts) {
          unawaited(_teardown());
          emit(
            const BroadcasterState().copyWith(
              phase: BroadcasterPhase.stopped,
              config: state.config,
              error: '$message — reconnection attempts exhausted.',
            ),
          );
          return;
        }
        emit(state.copyWith(notice: message));
        _scheduleReconnect(emit);
    }
  }

  /// Reopens camera + WHIP after a profile change that required a
  /// restart. Keeps the connecting phase while negotiating.
  Future<void> _restartCapture(Emitter<BroadcasterState> emit) async {
    if (_session == null) return;
    emit(state.copyWith(phase: BroadcasterPhase.connecting));
    _handleOpenResult(await _attemptOpen(), emit);
  }

  /// Schedules the next reconnect using exponential backoff.
  void _scheduleReconnect(Emitter<BroadcasterState> emit) {
    if (!_started) return;

    _reconnectAttempt += 1;
    if (_reconnectAttempt > BroadcasterConstants.maxReconnectAttempts) {
      unawaited(_teardown());
      emit(
        const BroadcasterState().copyWith(
          phase: BroadcasterPhase.stopped,
          config: state.config,
          error: 'Connection lost — reconnection attempts exhausted.',
        ),
      );
      return;
    }

    final seconds = math.min(
      1 << (_reconnectAttempt - 1),
      BroadcasterConstants.maxBackoffSeconds,
    );
    final delay = Duration(seconds: seconds);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!isClosed) add(const _RetryConnect());
    });
    emit(
      state.copyWith(
        phase: BroadcasterPhase.reconnecting,
        reconnectAttempt: _reconnectAttempt,
        reconnectDelay: delay,
      ),
    );
  }

  /// Releases all live resources: WHIP session, telemetry socket,
  /// reconnect timer, peer connection reference and the preview surface.
  ///
  /// When [disposeRendererNow] is false the renderer disposal is deferred
  /// by [BroadcasterConstants.rendererDisposeDelay] so a still-mounted
  /// RTCVideoView can detach first; the pending timer is cancelled by the
  /// next teardown/close so it cannot outlive the cubit.
  Future<void> _teardown({bool disposeRendererNow = false}) async {
    _started = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _rendererDisposeTimer?.cancel();
    _rendererDisposeTimer = null;
    _telemetry?.stop();
    _telemetry = null;
    await _session?.close();
    _session = null;
    _pc = null;

    final renderer = _renderer;
    _renderer = null;
    if (renderer != null) {
      try {
        renderer.srcObject = null;
      } catch (_) {
        // Surface already released.
      }
      if (disposeRendererNow) {
        try {
          await renderer.dispose();
        } catch (_) {
          // Already disposed.
        }
      } else {
        // Delay disposal so a still-mounted RTCVideoView can detach first.
        _rendererDisposeTimer = Timer(
          BroadcasterConstants.rendererDisposeDelay,
          () => unawaited(renderer.dispose()),
        );
      }
    }
  }

  MediaStreamTrack? _videoTrack() {
    for (final track
        in _session?.stream.getVideoTracks() ?? <MediaStreamTrack>[]) {
      return track;
    }
    return null;
  }
}
