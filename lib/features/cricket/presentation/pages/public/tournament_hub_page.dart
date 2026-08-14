import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
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
  bool _isGridView = false;

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

  // ── Match creation modal ─────────────────────────────────
  void _openCreateMatchModal() {
    final teamACtrl = TextEditingController();
    final teamBCtrl = TextEditingController();
    final venueCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CricketColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Match',
              style: TextStyle(
                color: CricketColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: teamACtrl,
              decoration: const InputDecoration(
                labelText: 'Team A',
                labelStyle: TextStyle(color: CricketColors.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: CricketColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
              style: const TextStyle(color: CricketColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: teamBCtrl,
              decoration: const InputDecoration(
                labelText: 'Team B',
                labelStyle: TextStyle(color: CricketColors.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: CricketColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
              style: const TextStyle(color: CricketColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: venueCtrl,
              decoration: const InputDecoration(
                labelText: 'Venue (optional)',
                labelStyle: TextStyle(color: CricketColors.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: CricketColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
              style: const TextStyle(color: CricketColors.textPrimary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: CricketColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: Dispatch match creation event to repository
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Match ${teamACtrl.text} vs ${teamBCtrl.text} creation initiated',
                    ),
                    backgroundColor: CricketColors.surface,
                  ),
                );
              },
              child: const Text('Create Match', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        title: Text(widget.tournamentName),
        backgroundColor: CricketColors.inputFill,
        foregroundColor: CricketColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: CricketColors.textPrimary,
          unselectedLabelColor: CricketColors.textSecondary,
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
          _MatchesTab(isGridView: _isGridView),
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
            onPressed: _openCreateMatchModal,
            child: const Icon(Icons.add, color: CricketColors.textPrimary),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'group',
            backgroundColor: AppColors.accent,
            onPressed: () => setState(() => _isGridView = !_isGridView),
            child: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: CricketColors.textPrimary,
            ),
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
          child: Text(
            'Loading...',
            style: TextStyle(color: CricketColors.textSecondary),
          ),
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
    color: CricketColors.inputFill,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.secondary,
        child: Icon(icon, color: CricketColors.textPrimary),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: CricketColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        team,
        style: const TextStyle(color: CricketColors.textSecondary),
      ),
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

// ─── Teams Tab — loads teams from MatchListBloc ──────────────
class _TeamsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MatchListBloc, MatchListState>(
        builder: (ctx, state) => switch (state) {
          MatchListLoaded(:final allMatches) => _buildTeamsList(allMatches),
          MatchListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          _ => const Center(
            child: Text(
              'Teams list — loading...',
              style: TextStyle(color: CricketColors.textSecondary),
            ),
          ),
        },
      );

  Widget _buildTeamsList(List<MatchModel> matches) {
    // Extract unique team names from matches
    final teams = <String>{};
    for (final m in matches) {
      if (m.teamAShort != null) teams.add(m.teamAShort!);
      if (m.teamBShort != null) teams.add(m.teamBShort!);
      if (m.teamAName != null) teams.add(m.teamAName!);
      if (m.teamBName != null) teams.add(m.teamBName!);
    }

    if (teams.isEmpty) {
      return const Center(
        child: Text(
          'No teams found',
          style: TextStyle(color: CricketColors.textSecondary),
        ),
      );
    }

    final sorted = teams.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (_, i) => Card(
        color: CricketColors.inputFill,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Text(
              sorted[i][0].toUpperCase(),
              style: const TextStyle(
                color: CricketColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            sorted[i],
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: CricketColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Matches Tab — with grid/list toggle and onTap navigation ─
class _MatchesTab extends StatelessWidget {
  final bool isGridView;
  const _MatchesTab({required this.isGridView});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MatchListBloc, MatchListState>(
        builder: (ctx, state) => switch (state) {
          MatchListLoaded(:final allMatches) =>
            isGridView
                ? _buildGrid(allMatches, context)
                : _buildList(allMatches, context),
          _ => const Center(child: CircularProgressIndicator()),
        },
      );

  Widget _buildList(List<MatchModel> matches, BuildContext context) =>
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (_, i) => _MatchTile(
          match: matches[i],
          onTap: () => _navigateToAnalytics(context, matches[i]),
        ),
      );

  Widget _buildGrid(List<MatchModel> matches, BuildContext context) =>
      GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: matches.length,
        itemBuilder: (_, i) => _MatchGridTile(
          match: matches[i],
          onTap: () => _navigateToAnalytics(context, matches[i]),
        ),
      );

  /// Live matches open the live-stream page (score + video + sponsors);
  /// scheduled / completed matches open the analytics page.
  void _navigateToAnalytics(BuildContext context, MatchModel match) {
    if (match.isLive) {
      context.go('/cricket/match/${match.id}', extra: match);
      return;
    }
    context.go(
      '/cricket/match/${match.id}/analytics'
      '?title=${Uri.encodeComponent(match.teamAShort ?? 'T1')}'
      '%20vs%20${Uri.encodeComponent(match.teamBShort ?? 'T2')}',
    );
  }
}

class _MatchTile extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;
  const _MatchTile({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    color: CricketColors.inputFill,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: onTap,
      title: Text(
        '${match.teamAShort ?? 'T1'} vs ${match.teamBShort ?? 'T2'}',
        style: const TextStyle(color: CricketColors.textPrimary),
      ),
      subtitle: Text(
        match.status,
        style: TextStyle(
          color: match.isLive
              ? CricketColors.live
              : CricketColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: CricketColors.textSecondary,
      ),
    ),
  );
}

class _MatchGridTile extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;
  const _MatchGridTile({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: CricketColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CricketColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${match.teamAShort ?? 'T1'}\nvs\n${match.teamBShort ?? 'T2'}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            match.status,
            style: TextStyle(
              color: match.isLive
                  ? CricketColors.live
                  : CricketColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Points Tab ──────────────────────────────────────────────
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

// ─── Stats Tab — shows top performers from TournamentHubBloc ──
class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TournamentHubBloc, TournamentHubState>(
        builder: (ctx, state) => switch (state) {
          TournamentHubLoaded(:final mostRuns, :final mostWickets) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle('Most Runs'),
              if (mostRuns.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'No run data available yet.',
                    style: TextStyle(color: CricketColors.textSecondary),
                  ),
                )
              else
                ...mostRuns
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => _TopPerformerRow(
                        rank: e.key + 1,
                        name: e.value.name,
                        team: e.value.teamShort ?? '',
                        value: '${e.value.runs} runs',
                      ),
                    ),
              const SizedBox(height: 12),
              const _SectionTitle('Most Wickets'),
              if (mostWickets.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'No wicket data available yet.',
                    style: TextStyle(color: CricketColors.textSecondary),
                  ),
                )
              else
                ...mostWickets
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => _TopPerformerRow(
                        rank: e.key + 1,
                        name: e.value.name,
                        team: e.value.teamShort ?? '',
                        value: '${e.value.wickets} wkts',
                      ),
                    ),
              const SizedBox(height: 24),
              const _SectionTitle('Top Partnerships'),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Partnership data coming soon.',
                  style: TextStyle(color: CricketColors.textSecondary),
                ),
              ),
            ],
          ),
          TournamentHubLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          _ => const Center(
            child: Text(
              'Advanced Statistics — loading...',
              style: TextStyle(color: CricketColors.textSecondary),
            ),
          ),
        },
      );
}

class _TopPerformerRow extends StatelessWidget {
  final int rank;
  final String name;
  final String team;
  final String value;
  const _TopPerformerRow({
    required this.rank,
    required this.name,
    required this.team,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: CricketColors.inputFill,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: rank == 1
            ? AppColors.secondary
            : rank == 2
            ? AppColors.accent
            : CricketColors.textTertiary,
        child: Text(
          '$rank',
          style: const TextStyle(
            color: CricketColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: CricketColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        team,
        style: const TextStyle(
          color: CricketColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}
