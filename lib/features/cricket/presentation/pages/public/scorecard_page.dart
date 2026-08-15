import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/scorecard/scorecard_bloc.dart';
import '../../../data/models/cricket_models.dart';

/// Phase 4 — full scorecard page for public fans. Shows both innings with
/// batting & bowling tables, extras, fall of wickets, and match info.
/// Fully BLoC-driven — no local state.
class ScorecardPage extends StatelessWidget {
  final String matchId;

  const ScorecardPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scorecard'),
        backgroundColor: CricketColors.surface,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: CricketColors.complete),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<ScorecardBloc>().add(RefreshScorecard()),
          ),
        ],
      ),
      body: BlocBuilder<ScorecardBloc, ScorecardState>(
        builder: (context, state) => switch (state) {
          ScorecardInitial() || ScorecardLoading() => const Center(
            child: CircularProgressIndicator(color: CricketColors.complete),
          ),
          ScorecardError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(color: CricketColors.wicket),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () =>
                      context.read<ScorecardBloc>().add(LoadScorecard(matchId)),
                ),
              ],
            ),
          ),
          ScorecardLoaded(:final scorecard) => _buildScorecard(
            context,
            scorecard,
          ),
        },
      ),
    );
  }

  Widget _buildScorecard(BuildContext context, ScorecardModel s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MatchHeaderCard(scorecard: s),
        const SizedBox(height: 16),
        for (final innings in s.innings) ...[
          _InningsCard(innings: innings),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _MatchHeaderCard extends StatelessWidget {
  final ScorecardModel scorecard;

  const _MatchHeaderCard({required this.scorecard});

  @override
  Widget build(BuildContext context) {
    final s = scorecard;
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
            '${s.teamA} vs ${s.teamB}',
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (s.venue != null && s.venue!.isNotEmpty) s.venue!,
              if (s.matchType != null) s.matchType!.toUpperCase(),
              if (s.oversPerSide != null) '${s.oversPerSide} overs/side',
            ].join(' · '),
            style: const TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.status.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              color: CricketColors.textAccent,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InningsCard extends StatelessWidget {
  final ScorecardInnings innings;

  const _InningsCard({required this.innings});

  @override
  Widget build(BuildContext context) {
    final extras = innings.extras;
    final fow = innings.fallOfWickets;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CricketColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CricketColors.textTertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${innings.battingTeam} — ${innings.totalRuns}/${innings.totalWickets} '
                  '(${innings.totalOvers.toStringAsFixed(1)} ov)',
                  style: const TextStyle(
                    color: CricketColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                (innings.status ?? '').replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'vs ${innings.bowlingTeam}',
            style: const TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          _BattingTable(batting: innings.batting),
          const SizedBox(height: 12),
          _BowlingTable(bowling: innings.bowling),
          if (extras != null) ...[
            const SizedBox(height: 10),
            Text(
              'Extras: WD ${extras['wides'] ?? 0} · NB ${extras['no_balls'] ?? 0} '
              '· B ${extras['byes'] ?? 0} · LB ${extras['leg_byes'] ?? 0} '
              '(total ${extras['total'] ?? 0})',
              style: const TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
          if (fow.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: fow.map((f) {
                final wicket = f['wicket_number'] as int? ?? 0;
                final runs = f['runs'] as int? ?? 0;
                final overs = (f['overs'] as num?)?.toDouble() ?? 0;
                final name = f['player_out_name'] as String?;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: CricketColors.wicket.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'W$wicket $runs/$wicket (${overs.toStringAsFixed(1)} ov)'
                    '${name != null ? ' · $name' : ''}',
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
        ],
      ),
    );
  }
}

class _BattingTable extends StatelessWidget {
  final List<PlayerStats> batting;

  const _BattingTable({required this.batting});

  @override
  Widget build(BuildContext context) {
    if (batting.isEmpty) {
      return const Text(
        'No batting data yet.',
        style: TextStyle(color: CricketColors.textSecondary, fontSize: 12),
      );
    }

    return _TableFrame(
      header: const _TableRow(
        isHeader: true,
        cells: ['Batter', 'R', 'B', '4s', '6s', 'SR'],
      ),
      children: batting.map((b) {
        final dismissal = b.dismissed ? 'c ${b.dismissal ?? 'out'}' : 'not out';
        return _TableRow(
          cells: [
            '${b.name} · $dismissal',
            '${b.runs}',
            '${b.balls}',
            '${b.fours}',
            '${b.sixes}',
            b.strikeRate.toStringAsFixed(1),
          ],
        );
      }).toList(),
    );
  }
}

class _BowlingTable extends StatelessWidget {
  final List<BowlerStats> bowling;

  const _BowlingTable({required this.bowling});

  @override
  Widget build(BuildContext context) {
    if (bowling.isEmpty) {
      return const Text(
        'No bowling data yet.',
        style: TextStyle(color: CricketColors.textSecondary, fontSize: 12),
      );
    }

    return _TableFrame(
      header: const _TableRow(
        isHeader: true,
        cells: ['Bowler', 'O', 'M', 'R', 'W', 'Econ'],
      ),
      children: bowling.map((b) {
        return _TableRow(
          cells: [
            b.name,
            b.overs.toStringAsFixed(1),
            '${b.maidens}',
            '${b.runs}',
            '${b.wickets}',
            b.economy.toStringAsFixed(2),
          ],
        );
      }).toList(),
    );
  }
}

class _TableFrame extends StatelessWidget {
  final _TableRow header;
  final List<_TableRow> children;

  const _TableFrame({required this.header, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CricketColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          header,
          ...children.map(
            (row) => Column(
              children: [
                const Divider(color: CricketColors.textTertiary, height: 1),
                row,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final List<String> cells;
  final bool isHeader;

  const _TableRow({required this.cells, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? const TextStyle(
            color: CricketColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          )
        : TextStyle(
            color: isHeader ? null : CricketColors.textPrimary,
            fontSize: 12,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            Expanded(
              flex: i == 0 ? 5 : 1,
              child: Text(
                cells[i],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
