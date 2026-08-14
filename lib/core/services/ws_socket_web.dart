// Web (dart:html) WebSocket adapter for the WebSocketHub.
//
// Browser WebSocket does not support custom headers — the headers argument
// is accepted for API symmetry but ignored on this platform. Channels used
// by the web panels are public/unauthenticated by design.

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

/// Minimal platform-neutral WebSocket wrapper.
class WsSocket {
  final html.WebSocket _socket;
  final StreamController<dynamic> _controller =
      StreamController<dynamic>.broadcast();

  WsSocket._(this._socket) {
    _socket.onMessage.listen((e) => _controller.add(e.data));
    _socket.onError.listen((e) => _controller.addError(e));
    _socket.onClose.listen((_) => _controller.close());
  }

  /// Incoming frames stream.
  Stream<dynamic> get stream => _controller.stream;

  /// Send a frame (no-op while the socket is still connecting).
  void add(Object data) {
    if (_socket.readyState == html.WebSocket.OPEN) {
      _socket.send(data.toString());
    }
  }

  /// Close the connection.
  Future<void> close() async {
    if (_socket.readyState == html.WebSocket.OPEN ||
        _socket.readyState == html.WebSocket.CONNECTING) {
      _socket.close();
    }
    await _controller.close();
  }
}

/// Open a WebSocket connection to [url].
///
/// Completes when the socket is OPEN, or with an error if the handshake
/// fails — mirroring dart:io's connect() semantics.
Future<WsSocket> connectWsSocket(
  String url, {
  Map<String, String> headers = const {},
}) {
  final socket = html.WebSocket(url);
  final completer = Completer<WsSocket>();

  socket.onOpen.first.then((_) {
    if (!completer.isCompleted) completer.complete(WsSocket._(socket));
  });
  socket.onError.first.then((e) {
    if (!completer.isCompleted) completer.completeError(e);
  });

  return completer.future;
}
