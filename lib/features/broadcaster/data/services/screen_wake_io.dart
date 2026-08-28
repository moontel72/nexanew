// Non-web (Android APK): the platform keeps the screen awake while the
// camera preview is on, so this is a no-op that keeps the API uniform.

/// Screen wake lock for non-web builds — intentionally a no-op.
class ScreenWake {
  Future<void> acquire() async {}

  Future<void> release() async {}
}
