// NEXATRACE — BUS TRACKING WEBSOCKET (IO)
// ==========================================
// dart:io WebSocket implementation for native Flutter.
// Connects to Laravel Reverb via native WebSocket.
//
// MODULE: 8V — Live Bus Tracking Canvas

import 'dart:async';
import 'dart:convert';
import 'dart:io' show WebSocket;
import 'dart:math';
import 'bus_tracking_models.dart';

class BusTrackingWebsocketService implements IBusTrackingService {
  final String _baseUrl;
  final String _authToken;
  WebSocket? _socket;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  static const _maxReconnectAttempts = 10;

  @override
  TrackingConnectionState _state = TrackingConnectionState.disconnected;
  @override
  TrackingConnectionState get state => _state;

  final _locationController = StreamController<BusLocationUpdate>.broadcast();
  @override
  Stream<BusLocationUpdate> get locationStream => _locationController.stream;

  final _stateController = StreamController<TrackingConnectionState>.broadcast();
  @override
  Stream<TrackingConnectionState> get stateStream => _stateController.stream;

  BusTrackingWebsocketService({
    required String baseUrl,
    required String authToken,
  })  : _baseUrl = baseUrl,
        _authToken = authToken;

  @override
  Future<void> connect(String tripId, {String? busId}) async {
    await _close();
    _setState(TrackingConnectionState.connecting);
    _reconnectAttempts = 0;

    try {
      final wsUrl = _baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://')
          .replaceFirst('/api/v1', '');

      final appKey = 'nxbrv_app_key_nexa_2026';
      final uri = Uri.parse('$wsUrl/app/$appKey?protocol=7&client=flutter&version=1.0.0');
      _socket = await WebSocket.connect(uri.toString());

      final msg = jsonEncode({
        'event': 'pusher:subscribe',
        'data': {'channel': 'bus.$tripId', 'auth': _authToken},
      });
      _socket!.add(msg);

      _socket!.listen(
        (data) => _onMessage(data.toString()),
        onError: (_) {
          _setState(TrackingConnectionState.error);
          _scheduleReconnect(tripId);
        },
        onDone: () {
          if (_state != TrackingConnectionState.disconnected) {
            _scheduleReconnect(tripId);
          }
        },
        cancelOnError: false,
      );

      _setState(TrackingConnectionState.connected);
      _reconnectAttempts = 0;
      _startPing();
    } catch (_) {
      _setState(TrackingConnectionState.error);
      _scheduleReconnect(tripId);
    }
  }

  void _onMessage(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final eventName = json['event']?.toString() ?? '';
      final dataRaw = json['data'];
      if (dataRaw == null) return;

      Map<String, dynamic> data;
      if (dataRaw is String) {
        data = jsonDecode(dataRaw) as Map<String, dynamic>;
      } else if (dataRaw is Map) {
        data = Map<String, dynamic>.from(dataRaw);
      } else {
        return;
      }

      if (eventName == 'BusLocationUpdated') {
        _locationController.add(BusLocationUpdate.fromJson(data));
      }
    } catch (_) {}
  }

  void _scheduleReconnect(String tripId) {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _setState(TrackingConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: min(pow(2, _reconnectAttempts).toInt(), 60));
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect(tripId);
    });
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_socket?.readyState == WebSocket.open) {
        _socket?.add(jsonEncode({'event': 'pusher:ping', 'data': {}}));
      }
    });
  }

  @override
  Future<void> disconnect() async {
    await _close();
    _setState(TrackingConnectionState.disconnected);
  }

  Future<void> _close() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    await _socket?.close();
    _socket = null;
  }

  void _setState(TrackingConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  @override
  void dispose() {
    _close();
    _locationController.close();
    _stateController.close();
  }
}
