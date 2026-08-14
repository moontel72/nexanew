import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/live_score/live_score_bloc.dart';
import '../../../data/models/cricket_models.dart';

/// Manager score control page — ball-by-ball input, undo, and the
/// toss → start flow that opens the match for live scoring.
///
/// Fully driven by LiveScoreBloc (loading / updating / connected states,
/// realtime score pushes, REST polling fallback, error notices).
class ManagerScorePage extends StatefulWidget {
  final String matchId;

  const ManagerScorePage({super.key, required this.matchId});

  @override
  State<ManagerScorePage> createState() => _ManagerScorePageState();
}

class _ManagerScorePageState extends State<ManagerScorePage> {
  @override
  void initState() {
    super.initState();
    context.read<LiveScoreBloc>().add(ConnectToMatch(widget.matchId));
  }

  @override
  void dispose() {
    context.read<LiveScoreBloc>().add(DisconnectFromMatch());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveScoreBloc, LiveScoreState>(
      listener: (context, state) {
        final notice = state is LiveScoreConnected ? state.notice : null;
        if (notice != null && notice.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(notice),
                backgroundColor: notice.contains('Failed')
                    ? CricketColors.wicket
                    : CricketColors.complete,
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: CricketColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Live Scoring'),
          backgroundColor: CricketColors.surface,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Color(0xFF10B981)),
              tooltip: 'Back to Dashboard',
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
        body: BlocBuilder<LiveScoreBloc, LiveScoreState>(
          builder: (context, state) => switch (state) {
            LiveScoreLoading() => const Center(
              child: CircularProgressIndicator(color: CricketColors.complete),
            ),
            LiveScoreError(:final message) => Center(
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
                    onPressed: () => context.read<LiveScoreBloc>().add(
                      ConnectToMatch(widget.matchId),
                    ),
                  ),
                ],
              ),
            ),
            LiveScoreUpdating(:final score, :final match) => _buildContent(
              context,
              score: score,
              match: match,
              busy: true,
            ),
            LiveScoreConnected(:final score, :final match) => _buildContent(
              context,
              score: score,
              match: match,
              busy: false,
            ),
            _ => const Center(
              child: Text(
                'Select a match to start scoring.',
                style: TextStyle(color: CricketColors.textSecondary),
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required LiveScoreSnapshot score,
    required MatchModel? match,
    required bool busy,
  }) {
    final status = match?.status ?? 'unknown';
    final matchStarted =
        status == 'in_progress' ||
        status == 'innings_break' ||
        status == 'completed';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Live score header ────────────────────────────────
        _ScoreHeader(score: score, match: match),
        const SizedBox(height: 16),

        if (busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(color: CricketColors.complete),
          ),

        // ── Match not started: toss + start flow ─────────────
        if (!matchStarted) ...[
          _TossPanel(match: match, busy: busy),
          const SizedBox(height: 16),
        ],

        // ── Ball input ───────────────────────────────────────
        if (matchStarted || status == 'toss_done')
          _BallButtonGrid(busy: busy, status: status),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Score header
// ─────────────────────────────────────────────────────────────

class _ScoreHeader extends StatelessWidget {
  final LiveScoreSnapshot score;
  final MatchModel? match;

  const _ScoreHeader({required this.score, required this.match});

  @override
  Widget build(BuildContext context) {
    final teamA = match?.teamAShort ?? match?.teamAName ?? 'T1';
    final teamB = match?.teamBShort ?? match?.teamBName ?? 'T2';
    final batting = score.battingTeam ?? '—';
    final bowling = score.bowlingTeam ?? '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CricketColors.textAccent.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            '$teamA vs $teamB',
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score.score ?? '0/0',
            style: const TextStyle(
              color: CricketColors.textAccent,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Overs: ${score.overs.toStringAsFixed(1)}'
            '${score.crr != null ? '  ·  CRR: ${score.crr!.toStringAsFixed(2)}' : ''}',
            style: const TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$batting batting · $bowling bowling',
            style: const TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (score.lastBallResult != null) ...[
            const SizedBox(height: 6),
            Text(
              'Last ball: ${score.lastBallResult}',
              style: const TextStyle(
                color: CricketColors.runFour,
                fontSize: 12,
              ),
            ),
          ],
          if (score.lastWicketInfo != null) ...[
            const SizedBox(height: 6),
            Text(
              score.lastWicketInfo!,
              style: const TextStyle(color: CricketColors.wicket, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Toss + start panel (match not in progress)
// ─────────────────────────────────────────────────────────────

class _TossPanel extends StatefulWidget {
  final MatchModel? match;
  final bool busy;

  const _TossPanel({required this.match, required this.busy});

  @override
  State<_TossPanel> createState() => _TossPanelState();
}

class _TossPanelState extends State<_TossPanel> {
  String? _tossWinnerId;
  String _tossDecision = 'bat';
  bool _showTossForm = false;

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final teamAId = match?.teamAId;
    final teamBId = match?.teamBId;
    final teamAName = match?.teamAName ?? match?.teamAShort ?? 'Team A';
    final teamBName = match?.teamBName ?? match?.teamBShort ?? 'Team B';
    final status = match?.status ?? 'unknown';

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

          // Toss form (only while scheduled)
          if (status == 'scheduled' && !canToss)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Team details are missing for this fixture — check the fixture scheduler.',
                style: TextStyle(color: CricketColors.wicket, fontSize: 12),
              ),
            ),

          if (status == 'scheduled' && canToss) ...[
            if (!_showTossForm)
              OutlinedButton.icon(
                icon: const Icon(Icons.flip_camera_android),
                label: const Text('Record Toss'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                ),
                onPressed: widget.busy
                    ? null
                    : () => setState(() => _showTossForm = true),
              )
            else ...[
              DropdownButtonFormField<String>(
                value: _tossWinnerId,
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
                onChanged: (v) => setState(() => _tossWinnerId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tossDecision,
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
                onChanged: (v) => setState(() => _tossDecision = v ?? 'bat'),
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
                  onPressed: widget.busy || _tossWinnerId == null
                      ? null
                      : () {
                          final winner = _tossWinnerId!;
                          final decision = _tossDecision;
                          final batting = decision == 'bat'
                              ? winner
                              : (winner == teamAId ? teamBId : teamAId);
                          final bowling = batting == teamAId
                              ? teamBId
                              : teamAId;
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
          ],

          // Start button (toss already done)
          if (status == 'toss_done')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                ),
                onPressed: widget.busy
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
// Ball input grid
// ─────────────────────────────────────────────────────────────

class _BallButtonGrid extends StatelessWidget {
  final bool busy;
  final String status;

  const _BallButtonGrid({required this.busy, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Run buttons
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
              color: CricketColors.runFour,
              busy: busy,
            ),
            _RunButton(
              label: 'SIX',
              runs: 6,
              color: CricketColors.runSix,
              busy: busy,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Wicket + Extras row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ExtraButton(label: 'WD', extrasType: 'wide', busy: busy),
            _ExtraButton(label: 'NB', extrasType: 'no_ball', busy: busy),
            _WicketButton(busy: busy),
            _ExtraButton(label: 'BYE', extrasType: 'bye', busy: busy),
            _ExtraButton(label: 'LB', extrasType: 'leg_bye', busy: busy),
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

class _RunButton extends StatelessWidget {
  final String label;
  final int runs;
  final Color color;
  final bool busy;

  const _RunButton({
    required this.label,
    required this.runs,
    required this.color,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: busy
        ? null
        : () => context.read<LiveScoreBloc>().add(SubmitBall({'runs': runs})),
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

class _WicketButton extends StatelessWidget {
  final bool busy;

  const _WicketButton({required this.busy});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: busy ? null : () => _showWicketDialog(context),
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: CricketColors.wicket.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
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
                context.read<LiveScoreBloc>().add(
                  SubmitBall({'runs': 0, 'is_wicket': true, 'wicket_type': t}),
                );
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
  final bool busy;

  const _ExtraButton({
    required this.label,
    required this.extrasType,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: busy
        ? null
        : () => context.read<LiveScoreBloc>().add(
            SubmitBall({'runs': 1, 'extras_type': extrasType}),
          ),
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
          color: busy ? AppColors.warning.withOpacity(0.4) : AppColors.warning,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
