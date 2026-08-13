// Environment Configuration
//
// API base URL resolution (in priority order):
//   1. Explicit --dart-define=API_BASE_URL=... (build-time override)
//   2. Same-origin on web — the API is served from the same domain as the
//      app via Nginx, so the browser's current origin is always correct
//      (works on HTTP before SSL, HTTPS after SSL, IPs, and any subdomain).
//   3. Hetzner IP fallback for native (mobile/desktop) development.
//
// Build examples:
//   flutter build web --release --target=lib/main_cricket_manager.dart
//   flutter build web --release --dart-define=API_BASE_URL=https://cricket.traceodd.com

import 'package:flutter/foundation.dart' show kIsWeb;

class Environment {
  Environment._();

  static const String _defined = String.fromEnvironment('API_BASE_URL');

  /// Base URL of the Laravel backend (no trailing slash).
  static String get apiBaseUrl {
    if (_defined.isNotEmpty) return _defined;
    if (kIsWeb) {
      try {
        return Uri.base.origin;
      } catch (_) {
        // Unresolvable base URI — fall through to the IP default.
      }
    }
    return 'http://135.181.46.27';
  }

  /// Whether the app is running in debug / development mode.
  static bool get isDevelopment {
    const isProd = bool.fromEnvironment('dart.vm.product');
    return !isProd;
  }
}
