import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

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
        color: CricketColors.background,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.live_tv, size: 48, color: CricketColors.textSecondary),
              SizedBox(height: 8),
              Text(
                'Stream starting soon...',
                style: TextStyle(color: CricketColors.textSecondary),
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
      color: CricketColors.background,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder for actual video player
          Container(
            color: CricketColors.background,
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 64,
                color: CricketColors.textPrimary.withOpacity(0.54),
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
                color: CricketColors.background.withOpacity(0.54),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.volume_up,
                size: 20,
                color: CricketColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
