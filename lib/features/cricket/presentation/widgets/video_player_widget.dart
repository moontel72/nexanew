import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/shared/widgets/hls_video_player.dart';

/// HLS video player widget for cricket live streams.
///
/// Renders the shared HlsVideoPlayer (real <video> + hls.js on web) with
/// a cricket-themed "stream starting soon" fallback while the stream URL
/// is not yet available.
class CricketVideoPlayer extends StatelessWidget {
  final String hlsUrl;

  /// Autoplay muted — used on the public live page.
  final bool autoPlay;

  const CricketVideoPlayer({
    super.key,
    required this.hlsUrl,
    this.autoPlay = false,
  });

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

    return Stack(
      alignment: Alignment.center,
      children: [
        HlsVideoPlayer(url: hlsUrl, autoPlay: autoPlay),
        // Mute/unmute overlay (web controls handle audio; decorative badge)
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
              Icons.live_tv,
              size: 20,
              color: CricketColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
