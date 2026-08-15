import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import '../../data/models/cricket_models.dart';
import 'ball_badge.dart';

/// Ball-by-ball recent-over ticker with visual run/wicket indicators.
class BallByBallTicker extends StatelessWidget {
  final LiveScoreSnapshot score;

  const BallByBallTicker({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final balls = score.recentBalls;
    if (balls.isEmpty) {
      return const Center(
        child: Text(
          'No deliveries yet.',
          style: TextStyle(color: CricketColors.textSecondary),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CricketColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT BALLS',
            style: TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          // Ball indicators in a wrap
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: balls.reversed.take(36).map((ball) {
              return BallBadge(ball: ball);
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (score.lastWicketInfo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CricketColors.wicket.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                score.lastWicketInfo!,
                style: const TextStyle(
                  color: CricketColors.wicket,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
