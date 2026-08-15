import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../data/models/cricket_models.dart';
import 'ball_by_ball_ticker.dart';
import 'scoreboard_header.dart';

/// Phase 3 — public fan portal 3-partition layout below the video player:
///
///   LEFT   — Bowlers: the two most recent bowlers (overs, runs conceded,
///            wickets, economy), with the active bowler highlighted.
///   CENTER — Batters: the two batters at the crease (runs, balls, fours,
///            sixes, strike rate) — auto-increments with every realtime
///            snapshot push.
///   RIGHT  — Match summary: team score, wickets, current over, CRR and
///            the recent-ball timeline.
///
/// Side-by-side on wide screens; stacks (summary first) on narrow screens.
/// Pure function of the live snapshot — all state flows through
/// LiveScoreBloc, so no widget-local state exists here.
class MatchThreeColumnLayout extends StatelessWidget {
  final LiveScoreSnapshot score;

  const MatchThreeColumnLayout({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _scrollable(BowlersColumn(score: score))),
              const VerticalDivider(
                width: 1,
                color: CricketColors.textTertiary,
              ),
              Expanded(child: _scrollable(BattersColumn(score: score))),
              const VerticalDivider(
                width: 1,
                color: CricketColors.textTertiary,
              ),
              Expanded(child: _scrollable(MatchSummaryColumn(score: score))),
            ],
          );
        }

        // Mobile / narrow — stack with the match summary first.
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            MatchSummaryColumn(score: score),
            const SizedBox(height: 12),
            BattersColumn(score: score),
            const SizedBox(height: 12),
            BowlersColumn(score: score),
          ],
        );
      },
    );
  }

  Widget _scrollable(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

/// Left column — the two most recent bowlers.
class BowlersColumn extends StatelessWidget {
  final LiveScoreSnapshot score;

  const BowlersColumn({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final activeId = score.currentPlayers?.bowler?.playerId;

    // The two most recently used bowlers from the scorecard, with the
    // active bowler first when known.
    final recent = score.bowlers.length > 2
        ? score.bowlers.sublist(score.bowlers.length - 2)
        : score.bowlers;

    final entries = <BowlerStats>[];
    final active = score.currentPlayers?.bowler;
    if (active != null && !recent.any((b) => b.playerId == active.playerId)) {
      entries.add(active);
    }
    entries.addAll(recent);
    final visible = entries.take(2).toList();

    return _ColumnCard(
      icon: Icons.sports_cricket,
      iconColor: const Color(0xFF3B82F6),
      title: 'BOWLERS',
      child: visible.isEmpty
          ? const _EmptyHint('No bowlers yet.')
          : Column(
              children: [
                for (final b in visible) ...[
                  _BowlerTile(bowler: b, active: b.playerId == activeId),
                  if (b != visible.last) const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _BowlerTile extends StatelessWidget {
  final BowlerStats bowler;
  final bool active;

  const _BowlerTile({required this.bowler, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF3B82F6).withOpacity(0.15)
            : CricketColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? const Color(0xFF3B82F6).withOpacity(0.6)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bowler.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CricketColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (active)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatTile(label: 'OVERS', value: bowler.overs.toStringAsFixed(1)),
              _StatTile(label: 'RUNS', value: '${bowler.runs}'),
              _StatTile(label: 'WKTS', value: '${bowler.wickets}'),
              _StatTile(
                label: 'ECON',
                value: bowler.economy.toStringAsFixed(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Center column — the two batters at the crease.
class BattersColumn extends StatelessWidget {
  final LiveScoreSnapshot score;

  const BattersColumn({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final striker = score.currentPlayers?.striker;
    final nonStriker = score.currentPlayers?.nonStriker;

    return _ColumnCard(
      icon: Icons.sports_baseball,
      iconColor: CricketColors.complete,
      title: 'BATTERS',
      child: (striker == null && nonStriker == null)
          ? const _EmptyHint('Awaiting batters…')
          : Column(
              children: [
                if (striker != null) ...[
                  _BatterTile(batter: striker, label: 'STRIKER*'),
                  const SizedBox(height: 10),
                ],
                if (nonStriker != null)
                  _BatterTile(batter: nonStriker, label: 'NON-STRIKER'),
              ],
            ),
    );
  }
}

class _BatterTile extends StatelessWidget {
  final PlayerStats batter;
  final String label;

  const _BatterTile({required this.batter, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CricketColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: batter.dismissed
              ? CricketColors.wicket.withOpacity(0.5)
              : CricketColors.complete.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  batter.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CricketColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatTile(label: 'RUNS', value: '${batter.runs}'),
              _StatTile(label: 'BALLS', value: '${batter.balls}'),
              _StatTile(label: '4s', value: '${batter.fours}'),
              _StatTile(label: '6s', value: '${batter.sixes}'),
              _StatTile(
                label: 'SR',
                value: batter.strikeRate.toStringAsFixed(1),
              ),
            ],
          ),
          if (batter.dismissed) ...[
            const SizedBox(height: 6),
            Text(
              batter.dismissal != null
                  ? 'OUT — ${batter.dismissal!.replaceAll('_', ' ').toUpperCase()}'
                  : 'OUT',
              style: const TextStyle(
                color: CricketColors.wicket,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Right column — match summary + recent-ball timeline.
class MatchSummaryColumn extends StatelessWidget {
  final LiveScoreSnapshot score;

  const MatchSummaryColumn({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return _ColumnCard(
      icon: Icons.scoreboard,
      iconColor: CricketColors.textAccent,
      title: 'MATCH SUMMARY',
      child: Column(
        children: [
          // Shared scoreboard: score, wickets, overs, CRR/RRR, partnership.
          CricketScoreboard(score: score),
          const SizedBox(height: 8),
          // Shared recent-ball timeline.
          BallByBallTicker(score: score),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared building blocks
// ─────────────────────────────────────────────────────────────

class _ColumnCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _ColumnCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CricketColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CricketColors.textTertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CricketColors.textSecondary,
              fontSize: 9,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: CricketColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
