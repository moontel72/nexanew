import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/live_score/live_score_bloc.dart';
import '../../blocs/scoring_control/scoring_control_bloc.dart';
import '../../blocs/squad_setup/squad_setup_bloc.dart';
import '../../widgets/ball_by_ball_ticker.dart';
import '../../widgets/scoring_control_panel.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';
import 'squad_setup_page.dart';

/// Manager split-screen scoring console (Phase 1).
///
///   LEFT  — ScoringControlPanel: player selection (striker, non-striker,
///           bowler), toss/start flow, over & wicket transitions, ball
///           input, undo.
///   RIGHT — Real-time score header + recent balls ticker.
///
/// Fully BLoC-driven. This StatefulWidget only owns lifecycle wiring
/// (connect/disconnect) — there is no setState anywhere in the file.
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
    context.read<ScoringControlBloc>().add(LoadControlData(widget.matchId));
  }

  @override
  void dispose() {
    context.read<LiveScoreBloc>().add(DisconnectFromMatch());
    context.read<ScoringControlBloc>().add(ResetControl());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LiveScoreBloc, LiveScoreState>(
          listener: (context, state) {
            final notice = state is LiveScoreConnected ? state.notice : null;
            if (notice != null && notice.isNotEmpty) {
              _showNotice(context, notice, isError: notice.contains('Failed'));
            }
          },
        ),
        BlocListener<ScoringControlBloc, ScoringControlState>(
          listener: (context, state) {
            if (state is ScoringControlError) {
              _showNotice(context, state.message, isError: true);
            }
          },
        ),
      ],
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
              icon: const Icon(Icons.groups, color: Color(0xFF3B82F6)),
              tooltip: 'Lineup Setup',
              onPressed: () => _openSquadSetup(context),
            ),
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
            LiveScoreError(:final message) => _LoadError(
              message: message,
              onRetry: () => context
                  .read<LiveScoreBloc>()
                  .add(ConnectToMatch(widget.matchId)),
            ),
            LiveScoreUpdating(:final score, :final match) => _SplitLayout(
              matchId: widget.matchId,
              score: score,
              match: match,
              busy: true,
            ),
            LiveScoreConnected(:final score, :final match) => _SplitLayout(
              matchId: widget.matchId,
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

  void _showNotice(
    BuildContext context,
    String notice, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(notice),
          backgroundColor: isError
              ? CricketColors.wicket
              : CricketColors.complete,
        ),
      );
  }

  void _openSquadSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (ctx) => SquadSetupBloc(
            repo: RepositoryProvider.of<CricketRepository>(ctx),
          ),
          child: SquadSetupPage(matchId: widget.matchId),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Split layout: controls (left) + score & recent balls (right)
// ─────────────────────────────────────────────────────────────

class _SplitLayout extends StatelessWidget {
  final String matchId;
  final LiveScoreSnapshot score;
  final MatchModel? match;
  final bool busy;

  const _SplitLayout({
    required this.matchId,
    required this.score,
    required this.match,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final controls = ScoringControlPanel(matchId: matchId, busy: busy);
    final overview = _ScoreOverview(score: score, match: match);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: controls,
                ),
              ),
              const VerticalDivider(
                width: 1,
                color: CricketColors.textTertiary,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: overview,
                ),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [controls, const SizedBox(height: 16), overview],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Right panel: score header + recent balls
// ─────────────────────────────────────────────────────────────

class _ScoreOverview extends StatelessWidget {
  final LiveScoreSnapshot score;
  final MatchModel? match;

  const _ScoreOverview({required this.score, required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScoreHeader(score: score, match: match),
        const SizedBox(height: 16),
        BallByBallTicker(score: score),
      ],
    );
  }
}

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

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

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
