import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/player_career/player_career_bloc.dart';

class PlayerProfilePage extends StatefulWidget {
  final String playerId;
  final String playerName;
  const PlayerProfilePage({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<PlayerCareerBloc>().add(LoadPlayerCareer(widget.playerId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        title: Text(widget.playerName),
        backgroundColor: CricketColors.inputFill,
        foregroundColor: CricketColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: CricketColors.textPrimary,
          unselectedLabelColor: CricketColors.textSecondary,
          tabs: const [
            Tab(text: 'Batting'),
            Tab(text: 'Bowling'),
            Tab(text: 'Fielding'),
          ],
        ),
      ),
      body: BlocBuilder<PlayerCareerBloc, PlayerCareerState>(
        builder: (ctx, state) => switch (state) {
          PlayerCareerLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          PlayerCareerLoaded(:final career) => TabBarView(
            controller: _tabController,
            children: [
              _BattingTab(
                batting: career.batting,
                recentForm: career.recentForm,
                highestScoreDisplay: career.highestScoreDisplay,
              ),
              _BowlingTab(bowling: career.bowling),
              _FieldingTab(fielding: career.fielding),
            ],
          ),
          PlayerCareerError(:final message) => Center(
            child: Text(
              message,
              style: const TextStyle(color: CricketColors.wicket),
            ),
          ),
          _ => const Center(
            child: Text(
              'Select a player',
              style: TextStyle(color: CricketColors.textSecondary),
            ),
          ),
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CricketColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: CricketColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class _BattingTab extends StatelessWidget {
  final BattingCareer batting;
  final List<RecentFormEntry> recentForm;
  final String highestScoreDisplay;
  const _BattingTab({
    required this.batting,
    required this.recentForm,
    required this.highestScoreDisplay,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _StatRow(label: 'Total Runs', value: '${batting.totalRuns}'),
      _StatRow(label: 'Matches', value: '${batting.totalMatches}'),
      _StatRow(label: 'Innings', value: '${batting.totalInnings}'),
      _StatRow(
        label: 'Average',
        value: batting.average?.toStringAsFixed(2) ?? '—',
      ),
      _StatRow(label: 'Highest Score', value: highestScoreDisplay),
      _StatRow(
        label: 'Strike Rate',
        value: batting.strikeRate.toStringAsFixed(1),
      ),
      _StatRow(
        label: '100s / 50s',
        value: '${batting.centuries} / ${batting.halfCenturies}',
      ),
      _StatRow(label: '4s / 6s', value: '${batting.fours} / ${batting.sixes}'),
      const SizedBox(height: 24),
      const Text(
        'Recent Form',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: recentForm.map((f) => _FormBadge(entry: f)).toList(),
      ),
    ],
  );
}

class _BowlingTab extends StatelessWidget {
  final BowlingCareer bowling;
  const _BowlingTab({required this.bowling});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _StatRow(label: 'Total Wickets', value: '${bowling.totalWickets}'),
      _StatRow(
        label: 'Average',
        value: bowling.average?.toStringAsFixed(2) ?? '—',
      ),
      _StatRow(label: 'Best Figures', value: bowling.bestFigures ?? '—'),
      _StatRow(
        label: 'Economy Rate',
        value: bowling.economyRate.toStringAsFixed(2),
      ),
      _StatRow(
        label: 'Overs Bowled',
        value: bowling.oversBowled.toStringAsFixed(1),
      ),
      _StatRow(label: 'Maidens', value: '${bowling.maidens}'),
      _StatRow(label: '5-Wicket Hauls', value: '${bowling.fiveWicketHauls}'),
    ],
  );
}

class _FieldingTab extends StatelessWidget {
  final FieldingCareer fielding;
  const _FieldingTab({required this.fielding});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _StatRow(label: 'Catches', value: '${fielding.catches}'),
      _StatRow(label: 'Run Outs', value: '${fielding.runOuts}'),
      _StatRow(label: 'Stumpings', value: '${fielding.stumpings}'),
    ],
  );
}

class _FormBadge extends StatelessWidget {
  final RecentFormEntry entry;
  const _FormBadge({required this.entry});
  @override
  Widget build(BuildContext context) {
    Color color;
    if (entry.runs >= 50)
      color = AppColors.secondary;
    else if (entry.runs >= 25)
      color = AppColors.accent;
    else if (entry.runs == 0)
      color = CricketColors.wicket;
    else
      color = Colors.blueGrey;
    return Chip(
      backgroundColor: color.withOpacity(0.2),
      label: Text(
        entry.display,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      side: BorderSide(color: color.withOpacity(0.5)),
    );
  }
}
