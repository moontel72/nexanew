// Cricket live-score realtime client — Laravel Reverb (Pusher protocol).
//
// Design (no hardcoding):
//  - Base URL comes from Environment (same-origin on web) — never literal.
//  - Reverb app key is fetched at runtime from the backend
//    `GET /api/v1/cricket/public/realtime-config` endpoint.
//  - Connection path `/app/{key}` is already reverse-proxied to Reverb by
//    Nginx on both cricket hosts, so the client always connects same-origin.
//
// Protocol: minimal Pusher client over web_socket_channel (works on web and
// native). Subscribes to public channel `cricket.match.{matchId}` and emits
// parsed event payloads. Reconnects with exponential backoff.

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// A named realtime event (e.g. `score.updated`, `stream.updated`) with its
/// JSON-decoded payload.
class CricketRealtimeEvent {
  final String event;
  final Map<String, dynamic> data;

  const CricketRealtimeEvent({required this.event, required this.data});
}

class CricketRealtimeClient {
  final String _baseUrl;
  final String _appKey;
  final String _wsPath;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  int _backoffSeconds = 1;
  static const int _maxBackoffSeconds = 30;

  final StreamController<CricketRealtimeEvent> _eventController =
      StreamController<CricketRealtimeEvent>.broadcast();

  String? _channelName;
  bool _disposed = false;

  CricketRealtimeClient({
    required String baseUrl,
    required String appKey,
    String wsPath = '/app',
  }) : _baseUrl = baseUrl,
       _appKey = appKey,
       _wsPath = wsPath;

  /// Parsed realtime events (event name + decoded payload).
  Stream<CricketRealtimeEvent> get events => _eventController.stream;

  /// Subscribe to a public Reverb channel.
  void subscribe(String channelName) {
    _channelName = channelName;
    _connect();
  }

  /// Drop the subscription (keeps the connection for potential reuse).
  void unsubscribe() {
    _channelName = null;
  }

  void _connect() {
    if (_disposed || _channelName == null) return;

    final wsBase = _baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    final uri = Uri.parse(
      '$wsBase$_wsPath/$_appKey?protocol=7&client=traceodd&version=1.0.0&flash=false',
    );

    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (_) {
      _scheduleReconnect();
      return;
    }

    _subscription?.cancel();
    _subscription = _channel!.stream.listen(
      _onFrame,
      onError: (_) => _scheduleReconnect(),
      onDone: () => _scheduleReconnect(),
      cancelOnError: true,
    );

    // Pusher clients subscribe immediately after the socket opens; Reverb
    // buffers the frame until the handshake completes. Re-sent on
    // `pusher:connection_established` as a safety net (idempotent).
    _sendSubscribe();
  }

  void _onFrame(dynamic raw) {
    if (raw is! String) return;

    Map<String, dynamic> frame;
    try {
      frame = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    switch (frame['event']?.toString() ?? '') {
      case 'pusher:connection_established':
        _backoffSeconds = 1;
        _sendSubscribe();
        break;
      case 'pusher:subscription_succeeded':
      case 'pusher:pong':
        break;
      default:
        final eventName = frame['event']?.toString() ?? '';
        final data = frame['data'];
        Map<String, dynamic> payload;
        if (data is String) {
          try {
            payload = jsonDecode(data) as Map<String, dynamic>;
          } catch (_) {
            return;
          }
        } else if (data is Map) {
          payload = Map<String, dynamic>.from(data);
        } else {
          return;
        }
        _eventController.add(
          CricketRealtimeEvent(event: eventName, data: payload),
        );
    }
  }

  void _sendSubscribe() {
    final channel = _channelName;
    if (channel == null) return;
    try {
      _channel!.sink.add(
        jsonEncode({
          'event': 'pusher:subscribe',
          'data': {'channel': channel},
        }),
      );
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (_disposed || _channelName == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _backoffSeconds), () {
      _backoffSeconds = (_backoffSeconds * 2).clamp(1, _maxBackoffSeconds);
      _connect();
    });
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _eventController.close();
  }
}
