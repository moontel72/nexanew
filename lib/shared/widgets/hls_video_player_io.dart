// Native implementation of the shared HLS player.
//
// HLS playback on mobile/desktop requires the `video_player` package,
// which is not yet a dependency (both cricket apps are web-only
// deployments today). Shows a clear placeholder instead of a fake player.

import 'package:flutter/material.dart';

Widget buildPlatformHlsPlayer({
  required BuildContext context,
  required String url,
  bool autoPlay = false,
}) {
  return Container(
    color: const Color(0xFF0A0E21),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.live_tv, size: 48, color: Color(0xFFA0AAB8)),
          SizedBox(height: 8),
          Text(
            'HLS playback on this platform requires the video_player package.\nWeb builds render a full player.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFA0AAB8), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
