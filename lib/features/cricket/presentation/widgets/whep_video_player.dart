// WHEP (WebRTC) player — the public screen's preferred transport.
//
// Conditional platform implementation, mirroring `HlsVideoPlayer`:
//  - Web: a real <video> element driven by the vendored `web/vendor/whep.js`
//    client (sub-second, no segments, no playlist).
//  - Native: a placeholder — both cricket apps are web-only deployments.
//
// Why prefer WHEP: HLS is segmented by construction, so with a publisher whose
// keyframe interval stretches it plays 10-20s behind and stalls while it waits
// for the next segment. WebRTC has neither segments nor a playlist, so the same
// camera arrives sub-second and stays put.

import 'package:flutter/material.dart';

import 'whep_video_player_web.dart'
    if (dart.library.io) 'whep_video_player_io.dart'
    as platform;

class WhepVideoPlayer extends StatelessWidget {
  /// Same-origin watch path from the API's `whep.url` (`/whep/watch/...`).
  final String url;

  /// Short-lived viewer token minted by the backend for this room and camera.
  final String token;

  /// ICE servers from the API's `whep.ice_servers`.
  final List<dynamic> iceServers;

  final bool autoPlay;

  const WhepVideoPlayer({
    super.key,
    required this.url,
    required this.token,
    this.iceServers = const [],
    this.autoPlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return platform.buildPlatformWhepPlayer(
      context: context,
      url: url,
      token: token,
      iceServers: iceServers,
      autoPlay: autoPlay,
    );
  }
}
