// WebSocket Hub — Panel-aware real-time event client
//
// Singleton stream hub for all NexaTrace WebSocket channels (Step 3 backend).
// Provides:
//   • Exponential backoff reconnection (1s → 2s → 4s → 8s → max 30s)
//   • Typed stream filters for bus_fleet_gps, freight_auction_pool, notification_blast
//   • Clean teardown on PanelLogoutRequested to prevent memory leaks
//   • Pluggable transport — swap WebSocket / Pusher / Supabase without changing callers
//
// Channel map (from Step 3 backend):
//   fleet.{company_id}        → FleetLocationUpdated, TripStatusChanged
//   trip.{trip_id}            → TripStatusChanged, DriverLocationUpdated
//   driver.{driver_id}        → DriverLocationUpdated
//   auction.{load_id}         → AuctionBidPlaced
//   delivery.{delivery_id}    → DeliveryConfirmed
//   bus.{route_id}            → BusLocationUpdated (Step 14)
//   store_keeper.{id}         → GeofenceScanUnlocked (Step 4)
//   admin.notifications       → NotificationBlastJob broadcasts

import 'dart:async';
import 'dart:convert';
import 'dart:io' show WebSocket, WebSocketException;
import 'package:flutter/foundation.dart';
import 'package:nexatrace_system/core/navigation/panel_routes.dart';

// ─────────────────────────────────────────────────────────────
// Event payload types
// ─────────────────────────────────────────────────────────────

typedef WsEventCallback = void Function(Map<String, dynamic> event);

/// Parsed WebSocket frame from the backend.
class WsEvent {
  final String channel;
  final String event;   // e.g. "FleetLocationUpdated"
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  const WsEvent({
    required this.channel,
    required this.event,
    required this.payload,
    required this.timestamp,
  });
  factory WsEvent.fromJson(Map<String, dynamic> json) => WsEvent(
    channel: json['channel']?.toString() ?? '',
    event: json['event']?.toString() ?? '',
    payload: (json['data'] ?? json['payload'] is Map)
        ? Map<String, dynamic>.from(json['data'] ?? json['payload'])
        : <String, dynamic>{},
    timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
  );
}

// ─────────────────────────────────────────────────────────────
// WebSocket Hub
// ─────────────────────────────────────────────────────────────

class WebSocketHub {
  static WebSocketHub? _instance;

  final String _baseUrl;
  WebSocket? _socket;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  /// Current backoff delay in seconds.
  int _backoffSeconds = 1;
  static const int _maxBackoffSeconds = 30;
  static const int _pingIntervalSeconds = 30;

  /// Whether a deliberate disconnect was requested (supresses reconnect).
  bool _disposed = false;

  /// Active channel subscriptions: channelName → callback.
  final Map<String, List<WsEventCallback>> _subscriptions = {};

  /// Broadcast stream controller — relays all parsed events.
  final StreamController<WsEvent> _eventController =
      StreamController<WsEvent>.broadcast();

  // ── Singleton ─────────────────────────────────────────────

  factory WebSocketHub({required String baseUrl}) {
    _instance ??= WebSocketHub._internal(baseUrl);
    return _instance!;
  }

  static WebSocketHub get instance {
    if (_instance == null) {
      throw StateError('WebSocketHub not initialized. Call WebSocketHub(baseUrl: ...) first.');
    }
    return _instance!;
  }

  WebSocketHub._internal(this._baseUrl);

  // ── Public stream accessors ───────────────────────────────

  /// Raw event stream — all channels.
  Stream<WsEvent> get events => _eventController.stream;

  /// Bus fleet GPS + ETA updates (Step 14).
  Stream<WsEvent> get busFleetGps => events.where(
    (e) => e.channel.startsWith('bus.') && e.event == 'BusLocationUpdated',
  );

  /// Freight auction bid updates (Step 6).
  Stream<WsEvent> get freightAuctionPool => events.where(
    (e) => e.channel.startsWith('auction.') && e.event == 'AuctionBidPlaced',
  );

  /// Notification blasts from Super Admin (Step 7).
  Stream<WsEvent> get notificationBlast => events.where(
    (e) => e.channel == 'admin.notifications',
  );

  /// Fleet location stream (factory/truck panels).
  Stream<WsEvent> get fleetLocations => events.where(
    (e) => e.channel.startsWith('fleet.') && e.event == 'FleetLocationUpdated',
  );

  /// Geofence scan unlock events (Step 4).
  Stream<WsEvent> get geofenceScans => events.where(
    (e) => e.channel.startsWith('store_keeper.') && e.event == 'GeofenceScanUnlocked',
  );

  // ── Connection management ─────────────────────────────────

  /// Open a WebSocket connection to the backend.
  Future<void> connect({String? authToken}) async {
    _disposed = false;
    final wsUrl = _baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    final uri = Uri.parse('$wsUrl/ws');

    try {
      _socket = await WebSocket.connect(
        uri.toString(),
        headers: {
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 10));

      _backoffSeconds = 1; // Reset backoff on successful connect.
      _startPing();
      _socket!.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      if (kDebugMode) debugPrint('WS_HUB: Connected to $uri');
    } on WebSocketException catch (e) {
      if (kDebugMode) debugPrint('WS_HUB: Connection failed — ${e.message}');
      _scheduleReconnect();
    } on TimeoutException {
      if (kDebugMode) debugPrint('WS_HUB: Connection timed out');
      _scheduleReconnect();
    }
  }

  /// Subscribe to a specific channel with a callback.
  void subscribe(String channel, WsEventCallback callback) {
    _subscriptions.putIfAbsent(channel, () => []).add(callback);
    // Send subscription frame if using a protocol (Pusher/Soketi-style).
    _sendFrame({'type': 'subscribe', 'channel': channel});
    if (kDebugMode) debugPrint('WS_HUB: Subscribed to $channel');
  }

  /// Unsubscribe from a channel.
  void unsubscribe(String channel, [WsEventCallback? callback]) {
    if (callback != null) {
      _subscriptions[channel]?.remove(callback);
      if (_subscriptions[channel]?.isEmpty ?? false) {
        _subscriptions.remove(channel);
      }
    } else {
      _subscriptions.remove(channel);
    }
    _sendFrame({'type': 'unsubscribe', 'channel': channel});
  }

  /// Clean disconnect — called on logout or app teardown.
  void disconnect() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _socket?.close();
    _socket = null;
    _subscriptions.clear();
    if (kDebugMode) debugPrint('WS_HUB: Disconnected');
  }

  /// Called when `PanelLogoutRequested` is dispatched.
  void onLogout(UserPanel panel) {
    disconnect();
    // Re-initialize for next session.
    _instance = null;
  }

  void dispose() => disconnect();

  // ── Internal message handling ─────────────────────────────

  void _onMessage(dynamic raw) {
    try {
      final Map<String, dynamic> frame;
      if (raw is String) {
        frame = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map) {
        frame = Map<String, dynamic>.from(raw);
      } else {
        return;
      }

      final event = WsEvent.fromJson(frame);
      _eventController.add(event);

      // Dispatch to channel-specific subscribers.
      final channelSubs = _subscriptions[event.channel];
      if (channelSubs != null) {
        for (final cb in channelSubs) {
          cb(event.payload);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('WS_HUB: Parse error — $e');
    }
  }

  void _onError(Object error) {
    if (kDebugMode) debugPrint('WS_HUB: Error — $error');
    _socket?.close();
  }

  void _onDone() {
    if (kDebugMode) debugPrint('WS_HUB: Connection closed');
    if (!_disposed) _scheduleReconnect();
  }

  // ── Reconnection with exponential backoff ─────────────────

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: _backoffSeconds);
    if (kDebugMode) {
      debugPrint('WS_HUB: Reconnecting in ${_backoffSeconds}s');
    }
    _reconnectTimer = Timer(delay, () {
      _backoffSeconds = (_backoffSeconds * 2).clamp(1, _maxBackoffSeconds);
      connect();
    });
  }

  // ── Keep-alive ping ──────────────────────────────────────

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      Duration(seconds: _pingIntervalSeconds),
      (_) => _sendFrame({'type': 'ping'}),
    );
  }

  void _sendFrame(Map<String, dynamic> frame) {
    try {
      _socket?.add(jsonEncode(frame));
    } catch (_) {}
  }
}
