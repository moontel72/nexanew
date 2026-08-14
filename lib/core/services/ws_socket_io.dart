// Native (dart:io) WebSocket adapter for the WebSocketHub.
//
// Supports custom headers (Bearer auth) — used by the native panels.

import 'dart:io' show WebSocket;

/// Minimal platform-neutral WebSocket wrapper.
class WsSocket {
  final WebSocket _socket;

  WsSocket._(this._socket);

  /// Incoming frames stream.
  Stream<dynamic> get stream => _socket;

  /// Send a frame (accepts any object; WebSocket sends the toString()).
  void add(Object data) => _socket.add(data);

  /// Close the connection.
  Future<void> close() => _socket.close();
}

/// Open a WebSocket connection to [url] with optional [headers].
Future<WsSocket> connectWsSocket(
  String url, {
  Map<String, String> headers = const {},
}) async {
  final socket = await WebSocket.connect(url, headers: headers);
  return WsSocket._(socket);
}
