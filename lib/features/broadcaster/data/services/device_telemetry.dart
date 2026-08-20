import 'dart:async';
import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:trace_odd/core/services/ws_socket.dart';

import '../../broadcaster_constants.dart';

/// Derives the WebSocket origin from an HTTP(S) API base URL so the
/// telemetry socket always matches the director-provided engine host.
String wsBaseUrlFor(String apiBaseUrl) {
  final uri = Uri.tryParse(apiBaseUrl);
  if (uri == null || !uri.hasScheme) return apiBaseUrl;
  return uri.replace(scheme: uri.scheme == 'https' ? 'wss' : 'ws').toString();
}

/// One device health sample, pushed to the media engine's telemetry
/// WebSocket and surfaced in the Studio director UI.
class DeviceHealth {
  const DeviceHealth({
    this.batteryPct,
    this.fps,
    this.uplinkKbps,
    this.droppedFrames,
    this.quality = 'good',
  });

  final int? batteryPct;
  final double? fps;
  final double? uplinkKbps;
  final int? droppedFrames;
  final String quality;
}

/// Streams device health (battery, encode FPS, uplink bitrate, dropped
/// frames, network quality) to `GET /api/v1/telemetry/ws` every
/// [BroadcasterConstants.telemetryInterval].
class DeviceTelemetry {
  DeviceTelemetry({
    required this.wsBaseUrl,
    required this.roomId,
    required this.cameraId,
  });

  /// WebSocket origin derived from the API base URL.
  final String wsBaseUrl;
  final String roomId;
  final String cameraId;

  WsSocket? _channel;
  Timer? _timer;
  int _generation = 0;
  final Battery _battery = Battery();
  int _lastBytesSent = 0;
  DateTime? _lastSampleAt;
  RTCPeerConnection? _pc;

  /// The latest computed health sample.
  DeviceHealth lastHealth = const DeviceHealth();

  /// Invoked after every computed sample so the UI layer can refresh
  /// without polling.
  void Function(DeviceHealth sample)? onSample;

  /// Attaches the live PeerConnection used for stats sampling.
  void attach(RTCPeerConnection? pc) {
    _pc = pc;
  }

  /// Opens the telemetry socket and starts the push interval.
  void start() {
    _generation++;
    _channel = null;
    unawaited(_connect(_generation));
    _timer = Timer.periodic(
      BroadcasterConstants.telemetryInterval,
      (_) => _sample(),
    );
  }

  Future<void> _connect(int generation) async {
    try {
      final socket = await connectWsSocket('$wsBaseUrl/api/v1/telemetry/ws');
      if (generation == _generation) {
        _channel = socket;
      } else {
        // stop()/start() raced this connect — drop the stale socket.
        unawaited(socket.close());
      }
    } catch (_) {
      // Engine unreachable — next start() reopens the socket.
      _channel = null;
    }
  }

  Future<void> _sample() async {
    final channel = _channel;
    if (channel == null) return;

    int? battery;
    try {
      battery = await _battery.batteryLevel;
    } catch (_) {
      battery = null;
    }

    double? fps;
    double? uplinkKbps;
    int? droppedFrames;
    String quality = 'good';
    final pc = _pc;
    if (pc != null) {
      try {
        final stats = await pc.getStats();
        final now = DateTime.now();
        int bytesSent = 0;
        for (final report in stats) {
          final values = report.values;
          if (report.type == 'outbound-rtp' && values['kind'] == 'video') {
            bytesSent = (values['bytesSent'] as num?)?.toInt() ?? 0;
            fps = (values['framesPerSecond'] as num?)?.toDouble();
            droppedFrames = (values['packetsLost'] as num?)?.toInt();
          }
          if (report.type == 'candidate-pair' &&
              values['state'] == 'succeeded') {
            final rtt =
                (values['currentRoundTripTime'] as num?)?.toDouble() ?? 0;
            quality = rtt < BroadcasterConstants.rttGoodThresholdSeconds
                ? 'good'
                : (rtt < BroadcasterConstants.rttFairThresholdSeconds
                      ? 'fair'
                      : 'poor');
          }
        }
        if (_lastSampleAt != null && bytesSent >= _lastBytesSent) {
          final seconds = now.difference(_lastSampleAt!).inMilliseconds / 1000;
          if (seconds > 0) {
            final deltaBytes = bytesSent - _lastBytesSent;
            uplinkKbps = deltaBytes * 8 / 1000 / seconds;
          }
        }
        _lastBytesSent = bytesSent;
        _lastSampleAt = now;
      } catch (_) {
        // Stats not available yet — keep the previous sample.
      }
    }

    lastHealth = DeviceHealth(
      batteryPct: battery,
      fps: fps,
      uplinkKbps: uplinkKbps,
      droppedFrames: droppedFrames,
      quality: quality,
    );
    onSample?.call(lastHealth);

    try {
      channel.add(
        jsonEncode(<String, dynamic>{
          'kind': 'device_telemetry',
          'room_id': roomId,
          'camera_id': cameraId,
          'battery_pct': battery,
          'fps': fps,
          'uplink_kbps': uplinkKbps,
          'dropped_frames': droppedFrames,
          'quality': quality,
        }),
      );
    } catch (_) {
      // Socket already closed — next start() reopens it.
    }
  }

  /// Stops the push interval and closes the socket.
  void stop() {
    _generation++;
    _timer?.cancel();
    _timer = null;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      // Close is asynchronous; the cubit never needs to await it.
      unawaited(channel.close());
    }
  }
}
