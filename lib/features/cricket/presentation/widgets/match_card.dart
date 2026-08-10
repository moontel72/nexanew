import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/cricket_models.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Compact match card for the tournament home page list.
/// Navigation uses go_router named routes for clean deep linking.
class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final teamA = match.teamAShort ?? match.teamAName ?? '—';
    final teamB = match.teamBShort ?? match.teamBName ?? '—';

    return GestureDetector(
      onTap: () {
        // Navigate to match analytics via go_router
        context.goNamed(
          'cricket_match_analytics',
          pathParameters: {'matchId': match.id},
          queryParameters: {'title': '$teamA vs $teamB'},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CricketColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: match.isLive
              ? Border.all(color: CricketColors.live.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$teamA vs $teamB',
                        style: TextStyle(
                          color: CricketColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (match.isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CricketColors.live,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LIVE',
                            style: TextStyle(
                              color: CricketColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (match.liveScore != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      match.liveScore!.score ?? '',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Overs: ${match.liveScore!.overs.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: CricketColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (match.venue != null)
              Flexible(
                child: Text(
                  match.venue!,
                  style: TextStyle(
                    color: CricketColors.textTertiary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
