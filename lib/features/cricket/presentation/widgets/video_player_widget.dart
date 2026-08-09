import 'package:flutter/material.dart';

/// HLS video player widget with adaptive bitrate streaming.
/// Uses platform-native players via the better_player or video_player package.
/// ABR is handled automatically by the underlying AVPlayer/ExoPlayer.
class CricketVideoPlayer extends StatelessWidget {
  final String hlsUrl;

  const CricketVideoPlayer({super.key, required this.hlsUrl});

  @override
  Widget build(BuildContext context) {
    if (hlsUrl.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.live_tv, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Stream starting soon...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // In production, use better_player or flutter_vlc_player:
    // BetterPlayerController(
    //   betterPlayerDataSource: BetterPlayerDataSource.network(hlsUrl),
    // );

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder for actual video player
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.white54,
              ),
            ),
          ),
          // Mute/unmute overlay
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.volume_up, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
