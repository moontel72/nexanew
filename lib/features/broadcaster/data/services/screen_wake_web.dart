// Web (package:web) Screen Wake Lock integration.
//
// A locked/backgrounded phone stops the browser video encoder while
// audio continues — the studio sees an audio-only session (409s) and a
// black tile. The Wake Lock API keeps the screen on during broadcast;
// the sentinel is re-acquired automatically when the tab regains
// visibility.

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Screen wake lock for web builds.
class ScreenWake {
  web.WakeLockSentinel? _sentinel;
  StreamSubscription<web.Event>? _visibilitySub;

  Future<void> acquire() async {
    try {
      final lock = web.window.navigator.wakeLock;
      _sentinel = await lock.request('screen').toDart;
    } catch (_) {
      _sentinel = null;
    }
    _visibilitySub ??= web.CustomEventProviders.visibilityChangeEvent
        .forTarget(web.window)
        .listen((event) {
          if (web.document.visibilityState == 'visible') {
            acquire();
          }
        });
  }

  Future<void> release() async {
    await _visibilitySub?.cancel();
    _visibilitySub = null;
    try {
      await _sentinel?.release().toDart;
    } catch (_) {
      // Sentinel already released or not supported.
    }
    _sentinel = null;
  }
}
