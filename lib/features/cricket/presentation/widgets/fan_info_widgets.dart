import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';

/// Phase 4 — scrolling ball-by-ball commentary feed (newest first).
/// Pure function of the live snapshot; the list re-renders on every
/// realtime push.
class CommentaryFeed extends StatelessWidget {
  final LiveScoreSnapshot score;

  const CommentaryFeed({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final entries = score.commentary;

    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No commentary yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: CricketColors.textSecondary, fontSize: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _CommentaryTile(entry: entries[i]),
          if (i != entries.length - 1)
            const Divider(color: CricketColors.textTertiary, height: 1),
        ],
      ],
    );
  }
}

class _CommentaryTile extends StatelessWidget {
  final CommentaryModel entry;

  const _CommentaryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = switch (entry.event) {
      'wicket' => CricketColors.wicket,
      'boundary_four' => CricketColors.runFour,
      'boundary_six' => CricketColors.runSix,
      'wide' || 'no_ball' => const Color(0xFFF59E0B),
      _ => CricketColors.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              entry.over.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.text,
              style: const TextStyle(
                color: CricketColors.textPrimary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phase 4 — compact extras breakdown (wides, no-balls, byes, leg-byes).
class ExtrasBreakdown extends StatelessWidget {
  final LiveScoreSnapshot score;

  const ExtrasBreakdown({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final extras = score.extras ?? const <String, dynamic>{};
    final wides = extras['wides'] as int? ?? 0;
    final noBalls = extras['no_balls'] as int? ?? 0;
    final byes = extras['byes'] as int? ?? 0;
    final legByes = extras['leg_byes'] as int? ?? 0;
    final total = extras['total'] as int? ?? (wides + noBalls + byes + legByes);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CricketColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text(
            'EXTRAS',
            style: TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          _ExtrasChip(label: 'WD', value: wides),
          _ExtrasChip(label: 'NB', value: noBalls),
          _ExtrasChip(label: 'B', value: byes),
          _ExtrasChip(label: 'LB', value: legByes),
          const Spacer(),
          Text(
            '$total',
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtrasChip extends StatelessWidget {
  final String label;
  final int value;

  const _ExtrasChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: CricketColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Phase 4 — compact fall-of-wickets timeline.
class FallOfWicketsStrip extends StatelessWidget {
  final LiveScoreSnapshot score;

  const FallOfWicketsStrip({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final fow = score.fallOfWickets ?? const [];

    if (fow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CricketColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FALL OF WICKETS',
            style: TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: fow.map((f) {
              final wicket = f['wicket_number'] as int? ?? 0;
              final runs = f['runs'] as int? ?? 0;
              final overs = (f['overs'] as num?)?.toDouble() ?? 0;
              final name = f['player_out_name'] as String?;
              final label =
                  'W$wicket · $runs/$wicket (${overs.toStringAsFixed(1)} ov)'
                  '${name != null ? ' · $name' : ''}';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CricketColors.wicket.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: CricketColors.wicket,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
