// FFI Bridge Config — Rust native module initialization & diagnostics
//
// Triggers `RustLib.init()` for flutter_rust_bridge, loads the platform
// dynamic library, and provides fallback diagnostics for web/simulator
// environments where native code is unavailable.
//
// Integration:
//   Call `RustBridgeConfig.ensureInitialized()` early in main().
//   Check `RustBridgeConfig.isNativeAvailable` before calling native functions.

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:trace_odd/rust_module/ffi_config.dart' as ffi;

class RustBridgeConfig {
  RustBridgeConfig._();

  static bool _initialized = false;
  static bool _nativeAvailable = false;
  static String _diagnosticInfo = '';

  /// Whether the native Rust library was successfully loaded.
  static bool get isNativeAvailable => _nativeAvailable;

  /// Human-readable diagnostic string for debugging.
  static String get diagnosticInfo => _diagnosticInfo;

  /// Initialize the Rust bridge.  Safe to call multiple times.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    try {
      if (kIsWeb) {
        _diagnosticInfo = 'Web runtime — native Rust bridge unavailable';
        return;
      }

      ffi.RustFFI.init();
      ffi.RustModule.initRustModule();
      _nativeAvailable = true;
      _diagnosticInfo =
          'Native Rust bridge loaded — ${Platform.operatingSystem} / ${Platform.version}';

      if (kDebugMode) debugPrint('CRYPTO_BRIDGE: $_diagnosticInfo');
    } catch (e) {
      _nativeAvailable = false;
      _diagnosticInfo = 'Native bridge load failed: $e';
      if (kDebugMode) debugPrint('CRYPTO_BRIDGE: $_diagnosticInfo');
    }
  }

  /// Reset to uninitialized state (useful for testing / hot restart).
  static void reset() {
    _initialized = false;
    _nativeAvailable = false;
    _diagnosticInfo = '';
  }
}
