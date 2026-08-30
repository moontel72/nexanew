// Android APK: real screen wake lock via a MainActivity MethodChannel
// (FLAG_KEEP_SCREEN_ON — no permission needed, normal brightness).
//
// The same failure the web build sees in the browser (screen sleeps →
// video encoder stalls → audio-only session → Studio tile 409s) happens
// on the APK when the screen times out: the activity pauses and camera
// capture stops. Keeping the screen on while the live view is open lets
// the broadcast run unattended on a tripod.
//
// Desktop builds (no channel handler) and tests degrade to a no-op.

import 'package:flutter/services.dart';

/// Screen wake lock for non-web builds (Android APK via MethodChannel).
class ScreenWake {
  static const MethodChannel _channel =
      MethodChannel('traceodd/broadcaster_wake');

  Future<void> acquire() async {
    try {
      await _channel.invokeMethod<void>('acquire');
    } on PlatformException {
      // Environment without the native handler — no-op.
    } on MissingPluginException {
      // No handler registered — no-op.
    }
  }

  Future<void> release() async {
    try {
      await _channel.invokeMethod<void>('release');
    } on PlatformException {
      // No-op.
    } on MissingPluginException {
      // No-op.
    }
  }
}
