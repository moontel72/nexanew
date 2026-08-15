import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';

/// Colored ball indicator used by the public ball-by-ball ticker and the
/// manager's correction history (shared — single implementation).
class BallBadge extends StatelessWidget {
  final RecentBall ball;

  const BallBadge({super.key, required this.ball});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    const textColor = CricketColors.textPrimary;

    if (ball.isWicket) {
      bgColor = CricketColors.wicket;
    } else {
      switch (ball.runs) {
        case 0:
          bgColor = CricketColors.textTertiary.withOpacity(0.3);
          break;
        case 4:
          bgColor = CricketColors.runFour;
          break;
        case 6:
          bgColor = CricketColors.teamA;
          break;
        default:
          bgColor = CricketColors.textSecondary;
      }
    }

    if (ball.extrasType == 'wide' || ball.extrasType == 'no_ball') {
      bgColor = CricketColors.roleAllRounder;
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
        style: const TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
