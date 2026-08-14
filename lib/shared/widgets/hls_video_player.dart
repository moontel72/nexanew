// HLS video player — shared widget for cricket live streaming.
//
// Conditional platform implementation:
//  - Web: real <video> element + vendored hls.js (web/vendor/hls.min.js),
//    which enables HLS playback on every browser (Chrome/Firefox/Edge
//    via MSE, Safari via native HLS).
//  - Native: graceful placeholder — mobile builds need the `video_player`
//    package for HLS; both cricket apps are currently web-only deployments.
//
// No hardcoding: the stream URL is passed in at runtime from the backend
// stream registry (hls_playlist_url), and the hls.js asset is served
// same-origin from the Flutter web build's static assets.

import 'package:flutter/material.dart';

import 'hls_video_player_web.dart'
    if (dart.library.io) 'hls_video_player_io.dart'
    as platform;

/// Renders an HLS stream in a resizable container.
class HlsVideoPlayer extends StatelessWidget {
  final String url;

  /// Autoplay muted (used on the public live page where browsers block
  /// unmuted autoplay).
  final bool autoPlay;

  const HlsVideoPlayer({super.key, required this.url, this.autoPlay = false});

  @override
  Widget build(BuildContext context) {
    return platform.buildPlatformHlsPlayer(
      context: context,
      url: url,
      autoPlay: autoPlay,
    );
  }
}
