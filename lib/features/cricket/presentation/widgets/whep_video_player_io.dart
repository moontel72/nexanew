// Native implementation of the WHEP player.
//
// WebRTC playback on mobile/desktop needs a WebRTC stack plus signalling, which
// these apps do not ship: both cricket deployments are web-only, and the web
// build renders the real player. Shows a clear placeholder instead of a fake
// player.

import 'package:flutter/material.dart';

Widget buildPlatformWhepPlayer({
  required BuildContext context,
  required String url,
  required String token,
  List<dynamic> iceServers = const [],
  bool autoPlay = true,
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
            'Live WebRTC playback on this platform needs a native video stack.\nWeb builds render the full player.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFA0AAB8), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
