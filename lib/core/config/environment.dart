// Environment Configuration
// Override defaults via --dart-define flags at build time:
//   flutter build web --dart-define=API_BASE_URL=https://cricket.traceodd.com

class Environment {
  Environment._();

  /// Base URL of the Laravel backend (no trailing slash).
  /// Defaults to the Hetzner server IP for development.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://135.181.46.27',
  );

  /// Whether the app is running in debug / development mode.
  static bool get isDevelopment {
    const isProd = bool.fromEnvironment('dart.vm.product');
    return !isProd;
  }
}
