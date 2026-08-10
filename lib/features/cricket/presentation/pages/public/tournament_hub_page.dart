import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/tournament_hub/tournament_hub_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/blocs/match_list/match_list_bloc.dart';
import 'package:trace_odd/features/cricket/presentation/widgets/points_table_widget.dart';

class TournamentHubPage extends StatefulWidget {
  final String tournamentId;
  final String tournamentName;
  const TournamentHubPage({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<TournamentHubPage> createState() => _TournamentHubPageState();
}

class _TournamentHubPageState extends State<TournamentHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final _ = RepositoryProvider.of<CricketRepository>(context);
    context.read<TournamentHubBloc>().add(
      LoadTournamentHub(widget.tournamentId),
    );
    context.read<MatchListBloc>().add(LoadMatches());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(widget.tournamentName),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Home', icon: Icon(Icons.home, size: 18)),
            Tab(text: 'Teams', icon: Icon(Icons.groups, size: 18)),
            Tab(text: 'Matches', icon: Icon(Icons.sports_cricket, size: 18)),
            Tab(text: 'Points', icon: Icon(Icons.leaderboard, size: 18)),
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HomeTab(),
          _TeamsTab(),
          _MatchesTab(),
          _PointsTab(),
          _StatsTab(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'schedule',
            backgroundColor: AppColors.secondary,
            onPressed: () {},
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'group',
            backgroundColor: AppColors.accent,
            onPressed: () {},
            child: const Icon(Icons.grid_view, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentHubBloc, TournamentHubState>(
      builder: (ctx, state) => switch (state) {
        TournamentHubLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        TournamentHubLoaded(:final mostRuns, :final mostWickets) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle('Most Runs'),
            ...mostRuns
                .take(3)
                .map(
                  (p) => _PerformerCard(
                    name: p.name,
                    team: p.teamShort ?? '',
                    value: '${p.runs} runs',
                    icon: Icons.sports_cricket,
                  ),
                ),
            const SizedBox(height: 20),
            _SectionTitle('Most Wickets'),
            ...mostWickets
                .take(3)
                .map(
                  (p) => _PerformerCard(
                    name: p.name,
                    team: p.teamShort ?? '',
                    value: '${p.wickets} wkts',
                    icon: Icons.catching_pokemon,
                  ),
                ),
          ],
        ),
        _ => const Center(
          child: Text('Loading...', style: TextStyle(color: Colors.grey)),
        ),
      },
    );
  }
}

class _PerformerCard extends StatelessWidget {
  final String name, team, value;
  final IconData icon;
  const _PerformerCard({
    required this.name,
    required this.team,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF1A1E31),
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.secondary,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(team, style: const TextStyle(color: Colors.grey)),
      trailing: Text(
        value,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        color: AppColors.secondary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _TeamsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Teams list — coming soon',
      style: TextStyle(color: Colors.grey),
    ),
  );
}

class _MatchesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MatchListBloc, MatchListState>(
        builder: (ctx, state) => switch (state) {
          MatchListLoaded(:final allMatches) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allMatches.length,
            itemBuilder: (_, i) => _MatchTile(match: allMatches[i]),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      );
}

class _MatchTile extends StatelessWidget {
  final MatchModel match;
  const _MatchTile({required this.match});
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFF1A1E31),
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      title: Text(
        '${match.teamAShort ?? 'T1'} vs ${match.teamBShort ?? 'T2'}',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        match.status,
        style: TextStyle(color: match.isLive ? Colors.red : Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    ),
  );
}

class _PointsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TournamentHubBloc, TournamentHubState>(
        builder: (ctx, state) => switch (state) {
          TournamentHubLoaded(:final standings) => PointsTableWidget(
            entries: standings,
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      );
}

class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Advanced Statistics — coming soon',
      style: TextStyle(color: Colors.grey),
    ),
  );
}
