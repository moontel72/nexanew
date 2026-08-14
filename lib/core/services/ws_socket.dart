// Platform-conditional WebSocket abstraction for the shared WebSocketHub.
//
// dart:io and dart:html expose incompatible WebSocket classes, so the hub
// uses this conditional export instead of importing either directly. This
// keeps every panel (mobile + web builds) compiling from one hub.
//
// Import this file and use `WsSocket` / `connectWsSocket` — never import
// the platform files directly.

export 'ws_socket_io.dart' if (dart.library.html) 'ws_socket_web.dart';
