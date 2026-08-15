import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../blocs/live_score/live_score_bloc.dart';
import '../blocs/scoring_control/scoring_control_bloc.dart';
import '../../data/models/cricket_models.dart';
import 'player_picker_sheet.dart';
import 'shot_direction_sheet.dart';

/// Left panel of the split-screen scoring console: player selection,
/// toss/start flow, ball input, wicket flow, and undo.
///
/// 100% BLoC-driven — this widget (and everything below) contains no
/// local mutable state (no setState).
class ScoringControlPanel extends StatelessWidget {
  final String matchId;
  final bool busy;

  const ScoringControlPanel({
    super.key,
    required this.matchId,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoringControlBloc, ScoringControlState>(
      builder: (context, state) => switch (state) {
        ScoringControlInitial() || ScoringControlLoading() => const Center(
          child: CircularProgressIndicator(color: CricketColors.complete),
        ),
        ScoringControlError(:final message) => _ControlError(
          message: message,
          onRetry: () =>
              context.read<ScoringControlBloc>().add(LoadControlData(matchId)),
        ),
        ScoringControlLoaded() => _buildSections(context, state),
      },
    );
  }

  Widget _buildSections(BuildContext context, ScoringControlLoaded c) {
    final status = c.match?.status ?? 'unknown';
    final matchStarted =
        status == 'in_progress' ||
        status == 'innings_break' ||
        status == 'completed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (busy)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(color: CricketColors.complete),
          ),
        if (!matchStarted) ...[
          _TossCard(control: c, busy: busy),
          const SizedBox(height: 12),
        ],
        if (matchStarted) ...[
          if (c.playerTrackingDisabled)
            _TrackingBanner(control: c)
          else if (c.needsOpeners)
            _OpenersCard(control: c)
          else if (c.awaitingBowler)
            _BowlerChangeCard(control: c)
          else if (c.awaitingNextBatter)
            _NextBatterCard(control: c)
          else
            _CreaseCard(control: c),
          if (matchStarted) const SizedBox(height: 12),
        ],
        _BallInputGrid(busy: busy, control: c),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
            ),
            onPressed: busy
                ? null
                : () => context.read<LiveScoreBloc>().add(UndoBall()),
            icon: const Icon(Icons.undo),
            label: const Text('UNDO LAST BALL'),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────

class _ControlError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ControlError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: CricketColors.wicket),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Toss / start card (match not in progress)
// ─────────────────────────────────────────────────────────────

class _TossCard extends StatelessWidget {
  final ScoringControlLoaded control;
  final bool busy;

  const _TossCard({required this.control, required this.busy});

  @override
  Widget build(BuildContext context) {
    final c = control;
    final match = c.match;
    final status = match?.status ?? 'unknown';
    final teamAId = match?.teamAId;
    final teamBId = match?.teamBId;
    final teamAName = match?.teamAName ?? match?.teamAShort ?? 'Team A';
    final teamBName = match?.teamBName ?? match?.teamBShort ?? 'Team B';

    final canToss =
        teamAId != null &&
        teamAId.isNotEmpty &&
        teamBId != null &&
        teamBId.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_cricket, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                status == 'toss_done'
                    ? 'Toss recorded — start the match'
                    : 'Match not started',
                style: const TextStyle(
                  color: CricketColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status == 'scheduled'
                ? 'Record the toss, then start the first innings.'
                : 'Start the first innings to begin scoring.',
            style: const TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (status == 'scheduled' && !canToss)
            const Text(
              'Team details are missing for this fixture — check the fixture scheduler.',
              style: TextStyle(color: CricketColors.wicket, fontSize: 12),
            ),
          if (status == 'scheduled' && canToss && !c.showTossForm)
            OutlinedButton.icon(
              icon: const Icon(Icons.flip_camera_android),
              label: const Text('Record Toss'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF59E0B),
                side: const BorderSide(color: Color(0xFFF59E0B)),
              ),
              onPressed: busy
                  ? null
                  : () => context.read<ScoringControlBloc>().add(
                      TossToggleForm(),
                    ),
            ),
          if (status == 'scheduled' && canToss && c.showTossForm) ...[
            DropdownButtonFormField<String?>(
              value: c.tossWinnerTeamId,
              dropdownColor: const Color(0xFF0F2936),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Toss Winner',
                labelStyle: TextStyle(color: Color(0xFFBDD8DB)),
                filled: true,
                fillColor: Color(0xFF0F2936),
              ),
              items: [
                DropdownMenuItem(value: teamAId, child: Text(teamAName)),
                DropdownMenuItem(value: teamBId, child: Text(teamBName)),
              ],
              onChanged: (v) =>
                  context.read<ScoringControlBloc>().add(TossSelectWinner(v)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: c.tossDecision,
              dropdownColor: const Color(0xFF0F2936),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Toss Decision',
                labelStyle: TextStyle(color: Color(0xFFBDD8DB)),
                filled: true,
                fillColor: Color(0xFF0F2936),
              ),
              items: const [
                DropdownMenuItem(value: 'bat', child: Text('Bat first')),
                DropdownMenuItem(value: 'bowl', child: Text('Bowl first')),
              ],
              onChanged: (v) => context.read<ScoringControlBloc>().add(
                TossSelectDecision(v ?? 'bat'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Record Toss & Start Match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                ),
                onPressed: busy || c.tossWinnerTeamId == null
                    ? null
                    : () {
                        final winner = c.tossWinnerTeamId!;
                        final decision = c.tossDecision;
                        final batting = decision == 'bat'
                            ? winner
                            : (winner == teamAId ? teamBId : teamAId);
                        final bowling = batting == teamAId ? teamBId : teamAId;
                        context.read<LiveScoreBloc>().add(
                          StartMatch(
                            tossWinnerTeamId: winner,
                            tossDecision: decision,
                            battingTeamId: batting,
                            bowlingTeamId: bowling,
                          ),
                        );
                      },
              ),
            ),
          ],
          if (status == 'toss_done')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                ),
                onPressed: busy
                    ? null
                    : () =>
                          context.read<LiveScoreBloc>().add(const StartMatch()),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Player-tracking banner (legacy mode)
// ─────────────────────────────────────────────────────────────

class _TrackingBanner extends StatelessWidget {
  final ScoringControlLoaded control;

  const _TrackingBanner({required this.control});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CricketColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Player tracking is off — balls are recorded without batter/bowler attribution.',
              style: TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<ScoringControlBloc>().add(TogglePlayerTracking()),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Openers selection (innings start)
// ─────────────────────────────────────────────────────────────

class _OpenersCard extends StatelessWidget {
  final ScoringControlLoaded control;

  const _OpenersCard({required this.control});

  @override
  Widget build(BuildContext context) {
    final c = control;
    return _SelectionCard(
      icon: Icons.sports_cricket,
      accent: CricketColors.complete,
      title: 'First over — select players',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PickRow(
            label: 'Striker (opener)',
            name: c.playerById(c.strikerId)?.name,
            onTap: () => _pickStriker(context),
          ),
          _PickRow(
            label: 'Non-striker (opener)',
            name: c.playerById(c.nonStrikerId)?.name,
            onTap: () => _pickNonStriker(context),
          ),
          _PickRow(
            label: 'Opening bowler',
            name: c.playerById(c.bowlerId)?.name,
            onTap: () => _pickBowler(context),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () =>
                context.read<ScoringControlBloc>().add(TogglePlayerTracking()),
            child: const Text(
              'Skip player tracking (legacy scoring)',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStriker(BuildContext context) async {
    final c = context.read<ScoringControlBloc>().state;
    if (c is! ScoringControlLoaded) return;
    final id = await showPlayerPickerSheet(
      context,
      title: 'Select Striker',
      players: c.battingPlayers,
      selectedId: c.strikerId,
    );
    if (id != null && context.mounted) {
      context.read<ScoringControlBloc>().add(SelectStriker(id));
    }
  }

  Future<void> _pickNonStriker(BuildContext context) async {
    final c = context.read<ScoringControlBloc>().state;
    if (c is! ScoringControlLoaded) return;
    final id = await showPlayerPickerSheet(
      context,
      title: 'Select Non-Striker',
      players: c.battingPlayers,
      selectedId: c.nonStrikerId,
    );
    if (id != null && context.mounted) {
      context.read<ScoringControlBloc>().add(SelectNonStriker(id));
    }
  }

  Future<void> _pickBowler(BuildContext context) async {
    final c = context.read<ScoringControlBloc>().state;
    if (c is! ScoringControlLoaded) return;
    final id = await showPlayerPickerSheet(
      context,
      title: 'Select Opening Bowler',
      players: c.bowlingPlayers,
      selectedId: c.bowlerId,
    );
    if (id != null && context.mounted) {
      context.read<ScoringControlBloc>().add(SelectBowler(id));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Bowler change (over complete)
// ─────────────────────────────────────────────────────────────

class _BowlerChangeCard extends StatelessWidget {
  final ScoringControlLoaded control;

  const _BowlerChangeCard({required this.control});

  @override
  Widget build(BuildContext context) {
    final c = control;
    final eligible = c.eligibleBowlers;
    final maxOvers = c.maxOversPerBowler ?? 4;

    return _SelectionCard(
      icon: Icons.autorenew,
      accent: const Color(0xFF3B82F6),
      title: 'Over complete — select new bowler',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eligible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No eligible bowlers found (over limit: $maxOvers overs per bowler).',
                style: const TextStyle(
                  color: CricketColors.wicket,
                  fontSize: 12,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: eligible.map((p) {
                final stats = c.bowlerStatsFor(p.id);
                return ChoiceChip(
                  label: Text(
                    '${p.name} (${stats?.overs.toStringAsFixed(1) ?? '0.0'} ov)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: c.bowlerId == p.id,
                  backgroundColor: CricketColors.inputFill,
                  selectedColor: const Color(0xFF3B82F6),
                  labelStyle: const TextStyle(color: Colors.white),
                  onSelected: (_) => context.read<ScoringControlBloc>().add(
                    SelectBowler(p.id),
                  ),
                );
              }).toList(),
            ),
          TextButton(
            onPressed: () =>
                context.read<ScoringControlBloc>().add(TogglePlayerTracking()),
            child: const Text(
              'Skip player tracking (legacy scoring)',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Next batter (wicket without replacement)
// ─────────────────────────────────────────────────────────────

class _NextBatterCard extends StatelessWidget {
  final ScoringControlLoaded control;

  const _NextBatterCard({required this.control});

  @override
  Widget build(BuildContext context) {
    final c = control;
    final suggestion = c.nextBatterSuggestion;

    return _SelectionCard(
      icon: Icons.person_add,
      accent: CricketColors.wicket,
      title: 'Wicket fell — select next batter',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (suggestion != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: CricketColors.textAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Suggested: ${suggestion.name}',
                      style: const TextStyle(
                        color: CricketColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _PickRow(
            label: 'Next batter',
            name: c.playerById(c.strikerId)?.name,
            onTap: () => _pickNextBatter(context),
          ),
          TextButton(
            onPressed: () =>
                context.read<ScoringControlBloc>().add(TogglePlayerTracking()),
            child: const Text(
              'Skip player tracking (legacy scoring)',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickNextBatter(BuildContext context) async {
    final c = context.read<ScoringControlBloc>().state;
    if (c is! ScoringControlLoaded) return;
    final dismissedIds = c.batters
        .where((b) => b.dismissed)
        .map((b) => b.playerId)
        .toSet();
    final candidates = c.battingPlayers
        .where((p) => p.id != c.nonStrikerId && !dismissedIds.contains(p.id))
        .toList();
    final id = await showPlayerPickerSheet(
      context,
      title: 'Select Next Batter',
      players: candidates,
      selectedId: c.strikerId,
    );
    if (id != null && context.mounted) {
      context.read<ScoringControlBloc>().add(SelectStriker(id));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Players on the crease
// ─────────────────────────────────────────────────────────────

class _CreaseCard extends StatelessWidget {
  final ScoringControlLoaded control;

  const _CreaseCard({required this.control});

  @override
  Widget build(BuildContext context) {
    final c = control;
    final striker = c.playerById(c.strikerId);
    final nonStriker = c.playerById(c.nonStrikerId);
    final bowler = c.playerById(c.bowlerId);
    final strikerStats = _statsOf(c, c.strikerId);
    final nonStrikerStats = _statsOf(c, c.nonStrikerId);
    final bowlerStats = c.bowlerStatsFor(c.bowlerId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CricketColors.textAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _BatterTile(
                  label: 'STRIKER',
                  name: striker?.name,
                  stats: strikerStats,
                  color: CricketColors.textAccent,
                  onTap: () => _pickStriker(context),
                ),
              ),
              IconButton(
                tooltip: 'Swap strike',
                icon: const Icon(
                  Icons.swap_horiz,
                  color: CricketColors.textSecondary,
                ),
                onPressed: () =>
                    context.read<ScoringControlBloc>().add(SwapStrike()),
              ),
              Expanded(
                child: _BatterTile(
                  label: 'NON-STRIKER',
                  name: nonStriker?.name,
                  stats: nonStrikerStats,
                  color: CricketColors.textSecondary,
                  onTap: () => _pickNonStriker(context),
                ),
              ),
            ],
          ),
          const Divider(color: CricketColors.textTertiary, height: 16),
          _BowlerTile(
            name: bowler?.name,
            stats: bowlerStats,
            onTap: c.awaitingBowler ? () => _pickBowler(context) : null,
          ),
        ],
      ),
    );
  }

  static String? _statsOf(ScoringControlLoaded c, String? playerId) {
    if (playerId == null) return null;
    for (final b in c.batters) {
      if (b.playerId == playerId) {
        return '${b.runs} (${b.balls}) · SR ${b.strikeRate.toStringAsFixed(0)}';
      }
    }
    return null;
  }

  Future<void> _pickStriker(BuildContext context) async {
    final c = context.read<ScoringControlBloc>().state;
    if (c is! ScoringControlLoaded) return;
    final id = await showPlayerPickerSheet(
      context,
      title: 'Select Striker',
      players: c.battingPlayers,
      selectedId: c.strikerId,
    );
    if (id != null && context.mounted) {
      context.read<ScoringControlBloc>().add(SelectStriker(id));
    }
  }

  Future<void> _pickNonStriker(BuildContext context) async {
    final c = context.read<ScoringControlBloc>().state;
    if (c is! ScoringControlLoaded) return;
    final id = await showPlayerPickerSheet(
      context,
      title: 'Select Non-Striker',
      players: c.battingPlayers,
      selectedId: c.nonStrikerId,
    );
    if (id != null && context.mounted) {
      context.read<ScoringControlBloc>().add(SelectNonStriker(id));
    }
  }

  Future<void> _pickBowler(BuildContext context) async {
    final c = context.read<ScoringControlBloc>().state;
    if (c is! ScoringControlLoaded) return;
    final id = await showPlayerPickerSheet(
      context,
      title: 'Select Bowler',
      players: c.eligibleBowlers,
      selectedId: c.bowlerId,
    );
    if (id != null && context.mounted) {
      context.read<ScoringControlBloc>().add(SelectBowler(id));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Small building blocks
// ─────────────────────────────────────────────────────────────

class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final Widget child;

  const _SelectionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: CricketColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PickRow extends StatelessWidget {
  final String label;
  final String? name;
  final VoidCallback onTap;

  const _PickRow({
    required this.label,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: CricketColors.textPrimary,
          side: const BorderSide(color: CricketColors.textTertiary),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name ?? '— tap to select —',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: name != null
                      ? CricketColors.textPrimary
                      : CricketColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: CricketColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatterTile extends StatelessWidget {
  final String label;
  final String? name;
  final String? stats;
  final Color color;
  final VoidCallback onTap;

  const _BatterTile({
    required this.label,
    required this.name,
    required this.stats,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CricketColors.inputFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name ?? '—',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (stats != null) ...[
              const SizedBox(height: 2),
              Text(
                stats!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BowlerTile extends StatelessWidget {
  final String? name;
  final BowlerStats? stats;
  final VoidCallback? onTap;

  const _BowlerTile({required this.name, required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: CricketColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null
                ? const Color(0xFF3B82F6).withOpacity(0.6)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.sports_cricket,
              color: CricketColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'BOWLER',
              style: TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name ?? '— select bowler —',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: name != null
                      ? CricketColors.textPrimary
                      : CricketColors.wicket,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (stats != null) ...[
              const SizedBox(width: 8),
              Text(
                '${stats!.overs.toStringAsFixed(1)} ov · ${stats!.runs}r · ${stats!.wickets}w',
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Ball input grid
// ─────────────────────────────────────────────────────────────

class _BallInputGrid extends StatelessWidget {
  final bool busy;
  final ScoringControlLoaded control;

  const _BallInputGrid({required this.busy, required this.control});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [0, 1, 2, 3].map((runs) {
            return _RunButton(
              label: runs.toString(),
              runs: runs,
              color: runs == 0
                  ? CricketColors.textSecondary
                  : runs == 3
                  ? CricketColors.runThree
                  : CricketColors.textPrimary,
              busy: busy,
              onBall: (ball) =>
                  context.read<LiveScoreBloc>().add(SubmitBall(ball)),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _RunButton(
              label: 'FOUR',
              runs: 4,
              color: CricketColors.runFour,
              busy: busy,
              onBoundary: () => _openBoundarySheet(context, 4),
              onBall: (ball) =>
                  context.read<LiveScoreBloc>().add(SubmitBall(ball)),
            ),
            _RunButton(
              label: 'SIX',
              runs: 6,
              color: CricketColors.runSix,
              busy: busy,
              onBoundary: () => _openBoundarySheet(context, 6),
              onBall: (ball) =>
                  context.read<LiveScoreBloc>().add(SubmitBall(ball)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ExtraButton(
              label: 'WD',
              extrasType: 'wide',
              busy: busy,
              onBall: (ball) =>
                  context.read<LiveScoreBloc>().add(SubmitBall(ball)),
            ),
            _ExtraButton(
              label: 'NB',
              extrasType: 'no_ball',
              busy: busy,
              onBall: (ball) =>
                  context.read<LiveScoreBloc>().add(SubmitBall(ball)),
            ),
            _WicketButton(busy: busy, onTap: () => _openWicketSheet(context)),
            _ExtraButton(
              label: 'BYE',
              extrasType: 'bye',
              busy: busy,
              onBall: (ball) =>
                  context.read<LiveScoreBloc>().add(SubmitBall(ball)),
            ),
            _ExtraButton(
              label: 'LB',
              extrasType: 'leg_bye',
              busy: busy,
              onBall: (ball) =>
                  context.read<LiveScoreBloc>().add(SubmitBall(ball)),
            ),
          ],
        ),
      ],
    );
  }

  /// Compose the backend ball payload from the current selection state.
  static Map<String, dynamic> buildBall(
    ScoringControlLoaded c, {
    required int runs,
    String? extrasType,
  }) {
    return {
      'runs': runs,
      if (extrasType != null) 'extras_type': extrasType,
      if (!c.playerTrackingDisabled) ...{
        if (c.strikerId != null) 'batsman_id': c.strikerId!,
        if (c.nonStrikerId != null) 'non_striker_id': c.nonStrikerId!,
        if (c.bowlerId != null) 'bowler_id': c.bowlerId!,
      },
    };
  }

  void _openBoundarySheet(BuildContext context, int runs) {
    final controlBloc = context.read<ScoringControlBloc>();
    final scoreBloc = context.read<LiveScoreBloc>();

    controlBloc.add(BoundaryTapped(runs));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: controlBloc),
          BlocProvider.value(value: scoreBloc),
        ],
        child: const ShotDirectionSheet(),
      ),
    ).whenComplete(() {
      if (!controlBloc.isClosed) controlBloc.add(CloseBoundary());
    });
  }

  void _openWicketSheet(BuildContext context) {
    final controlBloc = context.read<ScoringControlBloc>();
    final scoreBloc = context.read<LiveScoreBloc>();
    final c = controlBloc.state;
    if (c is! ScoringControlLoaded) return;

    controlBloc.add(WicketOpen());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: controlBloc),
          BlocProvider.value(value: scoreBloc),
        ],
        child: const WicketSheet(),
      ),
    ).whenComplete(() {
      if (!controlBloc.isClosed) controlBloc.add(WicketClose());
    });
  }
}

class _RunButton extends StatelessWidget {
  final String label;
  final int runs;
  final Color color;
  final bool busy;
  final void Function(Map<String, dynamic> ball) onBall;

  /// Phase 5 — when set, the tap opens the shot-direction flow instead
  /// of submitting the ball directly.
  final VoidCallback? onBoundary;

  const _RunButton({
    required this.label,
    required this.runs,
    required this.color,
    required this.busy,
    required this.onBall,
    this.onBoundary,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.read<ScoringControlBloc>().state;
    final ball = c is ScoringControlLoaded
        ? _BallInputGrid.buildBall(c, runs: runs)
        : <String, dynamic>{'runs': runs};

    return GestureDetector(
      onTap: busy ? null : (onBoundary ?? () => onBall(ball)),
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
            color: busy ? color.withOpacity(0.4) : color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ExtraButton extends StatelessWidget {
  final String label;
  final String extrasType;
  final bool busy;
  final void Function(Map<String, dynamic> ball) onBall;

  const _ExtraButton({
    required this.label,
    required this.extrasType,
    required this.busy,
    required this.onBall,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.read<ScoringControlBloc>().state;
    final ball = c is ScoringControlLoaded
        ? _BallInputGrid.buildBall(c, runs: 1, extrasType: extrasType)
        : <String, dynamic>{'runs': 1, 'extras_type': extrasType};

    return GestureDetector(
      onTap: busy ? null : () => onBall(ball),
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
          style: TextStyle(
            color: busy
                ? AppColors.warning.withOpacity(0.4)
                : AppColors.warning,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _WicketButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;

  const _WicketButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: CricketColors.wicket.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CricketColors.wicket.withOpacity(0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          'W',
          style: TextStyle(
            color: busy
                ? CricketColors.wicket.withOpacity(0.4)
                : CricketColors.wicket,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Wicket sheet (BLoC-driven dismissal form)
// ─────────────────────────────────────────────────────────────

class WicketSheet extends StatelessWidget {
  const WicketSheet({super.key});

  static const wicketTypes = [
    'bowled',
    'caught',
    'lbw',
    'run_out',
    'stumped',
    'hit_wicket',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoringControlBloc, ScoringControlState>(
      builder: (context, state) {
        if (state is! ScoringControlLoaded) {
          return const SizedBox.shrink();
        }
        final c = state;
        final striker = c.playerById(c.strikerId);
        final nonStriker = c.playerById(c.nonStrikerId);
        final dismissedOptions = <PlayerModel>[
          if (striker != null) striker,
          if (nonStriker != null) nonStriker,
        ];

        final dismissedIds = c.batters
            .where((b) => b.dismissed)
            .map((b) => b.playerId)
            .toSet();
        final nextBatterOptions = c.battingPlayers
            .where(
              (p) =>
                  p.id != c.wicketDismissedId &&
                  p.id != c.strikerId &&
                  p.id != c.nonStrikerId &&
                  !dismissedIds.contains(p.id),
            )
            .toList();

        return Container(
          decoration: const BoxDecoration(
            color: CricketColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Record Wicket',
                  style: TextStyle(
                    color: CricketColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Phase 5 — dismissal mode: wicket vs retired hurt.
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text(
                        'Wicket',
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: c.wicketMode != 'retired_hurt',
                      backgroundColor: CricketColors.inputFill,
                      selectedColor: CricketColors.wicket,
                      labelStyle: const TextStyle(color: Colors.white),
                      onSelected: (_) => context.read<ScoringControlBloc>().add(
                        const WicketSelectMode('wicket'),
                      ),
                    ),
                    ChoiceChip(
                      label: const Text(
                        'Retired hurt',
                        style: TextStyle(fontSize: 12),
                      ),
                      selected: c.wicketMode == 'retired_hurt',
                      backgroundColor: CricketColors.inputFill,
                      selectedColor: const Color(0xFFF59E0B),
                      labelStyle: const TextStyle(color: Colors.white),
                      onSelected: (_) => context.read<ScoringControlBloc>().add(
                        const WicketSelectMode('retired_hurt'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (dismissedOptions.isNotEmpty) ...[
                  Text(
                    c.wicketMode == 'retired_hurt'
                        ? 'RETIRING BATTER'
                        : 'DISMISSED BATTER',
                    style: const TextStyle(
                      color: CricketColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: dismissedOptions.map((p) {
                      return ChoiceChip(
                        label: Text(
                          p.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: c.wicketDismissedId == p.id,
                        backgroundColor: CricketColors.inputFill,
                        selectedColor: CricketColors.wicket,
                        labelStyle: const TextStyle(color: Colors.white),
                        onSelected: (_) => context
                            .read<ScoringControlBloc>()
                            .add(WicketSelectDismissed(p.id)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (c.wicketMode == 'retired_hurt') ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Retired hurt is not a dismissal — no wicket is credited.',
                    style: TextStyle(
                      color: CricketColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (c.wicketMode != 'retired_hurt') ...[
                  const Text(
                    'WICKET TYPE',
                    style: TextStyle(
                      color: CricketColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: wicketTypes.map((t) {
                      return ChoiceChip(
                        label: Text(
                          t.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: c.wicketType == t,
                        backgroundColor: CricketColors.inputFill,
                        selectedColor: CricketColors.wicket,
                        labelStyle: const TextStyle(color: Colors.white),
                        onSelected: (_) => context
                            .read<ScoringControlBloc>()
                            .add(WicketSelectType(t)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'NEXT BATTER',
                  style: TextStyle(
                    color: CricketColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String?>(
                  value: c.wicketNextBatterId,
                  dropdownColor: const Color(0xFF0F2936),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF0F2936),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('— skip (unknown) —'),
                    ),
                    ...nextBatterOptions.map(
                      (p) => DropdownMenuItem<String?>(
                        value: p.id,
                        child: Text(p.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => context.read<ScoringControlBloc>().add(
                    WicketSelectNextBatter(v ?? ''),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CricketColors.textSecondary,
                          side: const BorderSide(
                            color: CricketColors.textTertiary,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('RECORD'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CricketColors.wicket,
                        ),
                        onPressed: c.wicketDismissedId == null
                            ? null
                            : () => _submit(context, c),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context, ScoringControlLoaded c) {
    final isRetiredHurt = c.wicketMode == 'retired_hurt';

    final ball = <String, dynamic>{
      'runs': 0,
      if (isRetiredHurt) ...{
        'is_wicket': false,
        if (c.wicketDismissedId != null)
          'retired_player_id': c.wicketDismissedId!,
      } else ...{
        'is_wicket': true,
        'wicket_type': c.wicketType,
        if (c.wicketDismissedId != null)
          'dismissed_player_id': c.wicketDismissedId!,
      },
      if (c.wicketNextBatterId != null && c.wicketNextBatterId!.isNotEmpty)
        'next_batter_id': c.wicketNextBatterId!,
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
