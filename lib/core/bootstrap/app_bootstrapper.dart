// App Bootstrapper — Centralized async initialization pipeline
//
// Coordinates the exact chronological startup sequence for native engines,
// local storage, and network event buses.  Call once in main() before
// the MaterialApp renders.  Under 100 lines.
//
// Usage:
//   void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await AppBootstrapper.initialize();
//     runApp(const NexaTraceApp());
//   }

import 'package:flutter/foundation.dart';
import 'package:trace_odd/core/crypto/ffi_bridge_config.dart';
import 'package:trace_odd/core/services/offline_sync_engine.dart';
import 'package:trace_odd/core/services/websocket_hub.dart';

class AppBootstrapper {
  AppBootstrapper._();

  static bool _initialized = false;
  static String _statusLog = '';

  /// Human-readable boot sequence log for diagnostics.
  static String get statusLog => _statusLog;

  /// Run the full boot sequence.  Idempotent — safe to call multiple times.
  static Future<void> initialize({
    String wsBaseUrl = 'http://135.181.46.27',
    String? authToken,
  }) async {
    if (_initialized) return;
    _statusLog = '';
    final sw = Stopwatch()..start();

    try {
      // Step 1 — Native Rust crypto bridge (Setup 9).
      _log('Initializing Rust crypto bridge...');
      await RustBridgeConfig.ensureInitialized();
      _log('Rust bridge: ${RustBridgeConfig.diagnosticInfo}');

      // Step 2 — Offline sync engine with Hive box (Setup 5).
      _log('Initializing offline sync engine...');
      final syncEngine = OfflineSyncEngine();
      await syncEngine.init();
      _log('Sync engine ready — ${syncEngine.pendingCount} pending records');

      // Step 3 — WebSocket event bus (Setup 4).
      _log('Connecting WebSocket hub...');
      WebSocketHub(baseUrl: wsBaseUrl);
      await WebSocketHub.instance.connect(authToken: authToken);
      _log('WebSocket hub connected');

      _initialized = true;
    } catch (e, stack) {
      _log('BOOT ERROR: $e');
      if (kDebugMode) {
        debugPrint('APP_BOOT: Initialization failed — $e');
        debugPrint('APP_BOOT: $stack');
      }
      // Continue — the app degrades gracefully without native/WS.
      _initialized = true;
    }

    sw.stop();
    _log('Boot complete in ${sw.elapsedMilliseconds}ms');
    if (kDebugMode) {
      for (final line in _statusLog.split('\n')) {
        debugPrint('APP_BOOT: $line');
      }
    }
  }

  static void _log(String msg) {
    _statusLog += '$msg\n';
  }
}
