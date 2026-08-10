import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/live_score/live_score_bloc.dart';
import '../../blocs/match_list/match_list_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';

/// Manager score control page — quick ball input + undo.
class ManagerScorePage extends StatelessWidget {
  final String matchId;

  const ManagerScorePage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<CricketRepository>(context);

    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Live Scoring'),
        backgroundColor: CricketColors.surface,
        foregroundColor: CricketColors.textPrimary,
      ),
      body: Column(
        children: [
          // Score display — using the shared scoreboard widget
          // But since we can't import widgets cleanly from manager scope,
          // embed inline
          if (matchId.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Match Score Controls',
                      style: TextStyle(
                        color: CricketColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _BallButtonGrid(repo: repo, matchId: matchId),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'Select a match to start scoring.',
                  style: TextStyle(color: CricketColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BallButtonGrid extends StatelessWidget {
  final CricketRepository repo;
  final String matchId;

  const _BallButtonGrid({required this.repo, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Run buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [0, 1, 2, 3].map((runs) {
              return _RunButton(
                label: runs.toString(),
                runs: runs,
                matchId: matchId,
                repo: repo,
                color: runs == 0
                    ? CricketColors.textSecondary
                    : runs == 3
                    ? CricketColors.runThree
                    : CricketColors.textPrimary,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Boundary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RunButton(
                label: 'FOUR',
                runs: 4,
                matchId: matchId,
                repo: repo,
                color: CricketColors.runFour,
              ),
              _RunButton(
                label: 'SIX',
                runs: 6,
                matchId: matchId,
                repo: repo,
                color: CricketColors.runSix,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Wicket + Extras row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ExtraButton(
                label: 'WD',
                extrasType: 'wide',
                matchId: matchId,
                repo: repo,
              ),
              _ExtraButton(
                label: 'NB',
                extrasType: 'no_ball',
                matchId: matchId,
                repo: repo,
              ),
              _WicketButton(matchId: matchId, repo: repo),
              _ExtraButton(
                label: 'BYE',
                extrasType: 'bye',
                matchId: matchId,
                repo: repo,
              ),
              _ExtraButton(
                label: 'LB',
                extrasType: 'leg_bye',
                matchId: matchId,
                repo: repo,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Undo button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
              ),
              onPressed: () => repo.undoLastBall(matchId),
              icon: const Icon(Icons.undo),
              label: const Text('UNDO LAST BALL'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunButton extends StatelessWidget {
  final String label;
  final int runs;
  final String matchId;
  final CricketRepository repo;
  final Color color;

  const _RunButton({
    required this.label,
    required this.runs,
    required this.matchId,
    required this.repo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => repo.updateScore(matchId, {'runs': runs}),
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class _WicketButton extends StatelessWidget {
  final String matchId;
  final CricketRepository repo;

  const _WicketButton({required this.matchId, required this.repo});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _showWicketDialog(context),
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: CricketColors.wicket.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CricketColors.wicket.withOpacity(0.5)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'W',
        style: TextStyle(
          color: CricketColors.wicket,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  void _showWicketDialog(BuildContext context) {
    final types = [
      'bowled',
      'caught',
      'lbw',
      'run_out',
      'stumped',
      'hit_wicket',
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CricketColors.surface,
        title: const Text(
          'Wicket Type',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: types.map((t) {
            return ListTile(
              title: Text(
                t.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(color: CricketColors.textPrimary),
              ),
              onTap: () {
                repo.updateScore(matchId, {
                  'runs': 0,
                  'is_wicket': true,
                  'wicket_type': t,
                });
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ExtraButton extends StatelessWidget {
  final String label;
  final String extrasType;
  final String matchId;
  final CricketRepository repo;

  const _ExtraButton({
    required this.label,
    required this.extrasType,
    required this.matchId,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () =>
        repo.updateScore(matchId, {'runs': 1, 'extras_type': extrasType}),
    child: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.warning,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
