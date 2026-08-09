import 'package:flutter/material.dart';
import '../../data/models/cricket_models.dart';

/// Ball-by-ball recent-over ticker with visual run/wicket indicators.
class BallByBallTicker extends StatelessWidget {
  final LiveScoreSnapshot score;

  const BallByBallTicker({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final balls = score.recentBalls;
    if (balls.isEmpty) {
      return const Center(
        child: Text('No deliveries yet.', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E31),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT BALLS',
            style: TextStyle(
              color: Colors.grey,
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
              return _BallIndicator(ball: ball);
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (score.lastWicketInfo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                score.lastWicketInfo!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _BallIndicator extends StatelessWidget {
  final RecentBall ball;
  const _BallIndicator({required this.ball});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor = Colors.white;

    if (ball.isWicket) {
      bgColor = Colors.red;
    } else {
      switch (ball.runs) {
        case 0:
          bgColor = Colors.grey.withOpacity(0.3);
          break;
        case 4:
          bgColor = Colors.green;
          break;
        case 6:
          bgColor = Colors.blue;
          break;
        default:
          bgColor = Colors.grey;
      }
    }

    if (ball.extrasType == 'wide') {
      bgColor = Colors.orange;
    } else if (ball.extrasType == 'no_ball') {
      bgColor = Colors.orange.shade700;
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        ball.display,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
