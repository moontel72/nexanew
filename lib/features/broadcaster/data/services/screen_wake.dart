// Platform-conditional screen wake lock for Todd Broadcaster.
//
// A backgrounded/locked phone stalls the browser video encoder: audio
// keeps flowing while video frames stop — the engine then sees an
// audio-only session and the Studio tile 409s forever. Keeping the
// screen awake (web) and restarting capture on tab regain closes that
// failure mode.

export 'screen_wake_io.dart' if (dart.library.html) 'screen_wake_web.dart';
