import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../blocs/live_score/live_score_bloc.dart';
import '../blocs/scoring_control/scoring_control_bloc.dart';

/// Phase 5 — optional shot-direction picker shown after the scorer taps
/// FOUR or SIX. Submits the boundary with `shot_direction` so the public
/// wagon wheel renders real data instead of estimated directions.
///
/// Direction convention (matches the analytics engine): 0 = straight
/// down the ground, leg side 0–180, off side 180–360.
class ShotDirectionSheet extends StatelessWidget {
  const ShotDirectionSheet({super.key});

  static const directions = <({String label, int degrees, IconData icon})>[
    (label: 'Straight', degrees: 0, icon: Icons.arrow_upward),
    (label: 'Mid-wicket', degrees: 45, icon: Icons.arrow_outward),
    (label: 'Square leg', degrees: 90, icon: Icons.arrow_forward),
    (label: 'Fine leg', degrees: 135, icon: Icons.arrow_downward),
    (label: 'Long on', degrees: 180, icon: Icons.arrow_downward),
    (label: 'Third man', degrees: 225, icon: Icons.arrow_back),
    (label: 'Point', degrees: 270, icon: Icons.arrow_back),
    (label: 'Cover', degrees: 315, icon: Icons.arrow_upward),
  ];

  @override
  Widget build(BuildContext context) {
    final control = context.read<ScoringControlBloc>().state;
    if (control is! ScoringControlLoaded ||
        control.pendingBoundaryRuns == null) {
      return const SizedBox.shrink();
    }

    final runs = control.pendingBoundaryRuns!;

    return Container(
      decoration: const BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            runs == 4 ? 'FOUR! — shot direction' : 'SIX! — shot direction',
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Optional — powers the wagon wheel. Skip to record without it.',
            style: TextStyle(color: CricketColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: directions.map((d) {
              return ChoiceChip(
                avatar: Icon(d.icon, size: 16, color: Colors.white),
                label: Text(d.label, style: const TextStyle(fontSize: 12)),
                backgroundColor: CricketColors.inputFill,
                selectedColor: runs == 4
                    ? CricketColors.runFour
                    : CricketColors.runSix,
                labelStyle: const TextStyle(color: Colors.white),
                selected: false,
                onSelected: (_) => _submit(context, control, runs, d.degrees),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CricketColors.textSecondary,
                    side: const BorderSide(color: CricketColors.textTertiary),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: const Text('SKIP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CricketColors.textSecondary,
                  ),
                  onPressed: () => _submit(context, control, runs, null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(
    BuildContext context,
    ScoringControlLoaded c,
    int runs,
    int? degrees,
  ) {
    final ball = <String, dynamic>{
      'runs': runs,
      if (degrees != null) 'shot_direction': degrees,
      if (!c.playerTrackingDisabled) ...{
        if (c.strikerId != null) 'batsman_id': c.strikerId!,
        if (c.nonStrikerId != null) 'non_striker_id': c.nonStrikerId!,
        if (c.bowlerId != null) 'bowler_id': c.bowlerId!,
      },
    };

    context.read<LiveScoreBloc>().add(SubmitBall(ball));
    Navigator.pop(context);
  }
}
