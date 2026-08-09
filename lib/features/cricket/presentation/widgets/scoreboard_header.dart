import 'package:flutter/material.dart';
import '../../data/models/cricket_models.dart';

/// Live scoreboard — the core cricket score display.
class CricketScoreboard extends StatelessWidget {
  final LiveScoreSnapshot score;

  const CricketScoreboard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1E31), Color(0xFF0A0E21)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Team names
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                score.battingTeam ?? 'BAT',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              Text(
                score.bowlingTeam ?? 'BOWL',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Score line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score.score ?? '0/0',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '(${score.overs.toStringAsFixed(1)} ov)',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // CRR / RRR / Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(label: 'CRR', value: score.crr?.toStringAsFixed(2) ?? '-'),
              if (score.target != null)
                _Stat(label: 'TARGET', value: '${score.target}'),
              if (score.rrr != null)
                _Stat(label: 'RRR', value: score.rrr!.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(height: 8),

          // Partnership
          if (score.partnershipRuns > 0 || score.partnershipBalls > 0)
            Text(
              'Partnership: ${score.partnershipRuns}(${score.partnershipBalls})',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      );
}
