import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/cricket_auth/cricket_auth_bloc.dart';
import '../../blocs/match_list/match_list_bloc.dart';
import '../../blocs/tournament_hub/tournament_hub_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';
import 'manager_login_page.dart';
import 'manager_score_page.dart';
import 'camera_switcher_page.dart';
import 'voice_score_page.dart';
import 'sponsor_manage_page.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Manager Dashboard — full management hub with tabbed navigation.
class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<MatchListBloc>().add(LoadMatches());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CricketAuthBloc, CricketAuthState>(
      builder: (context, state) {
        final manager = state is CricketAuthLoggedIn ? state.manager : null;
        return Scaffold(
          backgroundColor: CricketColors.background,
          appBar: AppBar(
            title: Text(
              manager?.name ?? 'Cricket Manager',
              style: TextStyle(color: CricketColors.textPrimary),
            ),
            backgroundColor: CricketColors.surface,
            foregroundColor: CricketColors.textPrimary,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: CricketColors.textSecondary),
                tooltip: 'Logout',
                onPressed: () {
                  context.read<CricketAuthBloc>().add(CricketLogout());
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ManagerLoginPage()),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondary,
              labelColor: CricketColors.textPrimary,
              unselectedLabelColor: CricketColors.textSecondary,
              isScrollable: false,
              tabs: const [
                Tab(icon: Icon(Icons.live_tv, size: 20), text: 'Live Console'),
                Tab(icon: Icon(Icons.groups, size: 20), text: 'Team Manager'),
                Tab(
                  icon: Icon(Icons.emoji_events, size: 20),
                  text: 'Tournament',
                ),
                Tab(icon: Icon(Icons.analytics, size: 20), text: 'Analytics'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _LiveConsoleTab(),
              _TeamManagerTab(),
              _TournamentTab(),
              _AnalyticsTab(),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tab 1: Studio & Live Console ──────────────────────────

class _LiveConsoleTab extends StatefulWidget {
  @override
  State<_LiveConsoleTab> createState() => _LiveConsoleTabState();
}

class _LiveConsoleTabState extends State<_LiveConsoleTab> {
  String? _selectedMatchId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchListBloc, MatchListState>(
      builder: (ctx, state) {
        final matches = state is MatchListLoaded
            ? [...state.liveMatches, ...state.allMatches]
            : <MatchModel>[];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: _selectedMatchId,
                dropdownColor: CricketColors.surface,
                style: TextStyle(color: CricketColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Select Match',
                  labelStyle: TextStyle(color: CricketColors.placeholder),
                  filled: true,
                  fillColor: CricketColors.inputFill,
                  border: const OutlineInputBorder(),
                ),
                hint: Text(
                  'Choose a match to manage',
                  style: TextStyle(color: CricketColors.placeholder),
                ),
                items: matches.map((m) {
                  final teamA = m.teamAShort ?? m.teamAName ?? 'T1';
                  final teamB = m.teamBShort ?? m.teamBName ?? 'T2';
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(
                      '$teamA vs $teamB (${m.status})',
                      style: TextStyle(
                        color: m.isLive
                            ? CricketColors.live
                            : CricketColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedMatchId = v),
              ),
            ),
            if (_selectedMatchId != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionChip(
                      icon: Icons.scoreboard,
                      label: 'Scoring',
                      color: Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ManagerScorePage(matchId: _selectedMatchId!),
                        ),
                      ),
                    ),
                    _ActionChip(
                      icon: Icons.videocam,
                      label: 'Cameras',
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CameraSwitcherPage(matchId: _selectedMatchId!),
                        ),
                      ),
                    ),
                    _ActionChip(
                      icon: Icons.mic,
                      label: 'Voice',
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VoiceScorePage(matchId: _selectedMatchId!),
                        ),
                      ),
                    ),
                    _ActionChip(
                      icon: Icons.campaign,
                      label: 'Sponsors',
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SponsorManagePage(matchId: _selectedMatchId!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Match $_selectedMatchId selected.\nTap an action above to manage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CricketColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_cricket,
                        size: 64,
                        color: CricketColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a match to begin',
                        style: TextStyle(color: CricketColors.textSecondary),
                      ),
                      Text(
                        'You can manage scoring, cameras, voice input, and sponsors',
                        style: TextStyle(
                          color: CricketColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    ),
  );
}

// ─── Tab 2: Team Manager ───────────────────────────────────

class _TeamManagerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ModuleTile(
          icon: Icons.upload_file,
          title: 'Roster Upload',
          subtitle: 'Import team rosters from CSV/JSON',
          onTap: () => _showComingSoon(context, 'Roster Upload'),
        ),
        _ModuleTile(
          icon: Icons.person_add,
          title: 'Player Management',
          subtitle: 'Add, edit, or remove players from teams',
          onTap: () => _showComingSoon(context, 'Player Management'),
        ),
        _ModuleTile(
          icon: Icons.assignment_ind,
          title: 'Captain & Wicket-Keeper',
          subtitle: 'Assign team captains and wicket-keepers',
          onTap: () => _showCaptainDialog(context),
        ),
        _ModuleTile(
          icon: Icons.badge,
          title: 'Jersey Numbers',
          subtitle: 'Assign jersey numbers to players',
          onTap: () => _showJerseyDialog(context),
        ),
        _ModuleTile(
          icon: Icons.image,
          title: 'Team Logos & Photos',
          subtitle: 'Upload team logos and player photos',
          onTap: () => _showComingSoon(context, 'Team Logos'),
        ),
      ],
    );
  }

  void _showCaptainDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CricketColors.surface,
        title: Text(
          'Captain & Wicket-Keeper',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        content: Text(
          'Use the Sub-Admin panel to assign captains and wicket-keepers.\n\nNavigate to Admin → Players to manage roles.',
          style: TextStyle(color: CricketColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showJerseyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CricketColors.surface,
        title: Text(
          'Jersey Numbers',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        content: Text(
          'Use the Sub-Admin panel to assign jersey numbers.\n\nNavigate to Admin → Players → Edit to set jersey numbers.',
          style: TextStyle(color: CricketColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming in next release'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}

// ─── Tab 3: Tournament Hub ─────────────────────────────────

class _TournamentTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ModuleTile(
          icon: Icons.calendar_month,
          title: 'Fixture Scheduler',
          subtitle: 'Create, edit, and schedule matches',
          onTap: () => _showFixtureScheduler(context),
        ),
        _ModuleTile(
          icon: Icons.leaderboard,
          title: 'Points Table',
          subtitle: 'View and recalculate tournament standings',
          onTap: () => _showPointsTable(context),
        ),
        _ModuleTile(
          icon: Icons.calculate,
          title: 'NRR Calculator',
          subtitle: 'View net run rate for all teams',
          onTap: () => _showNRRCalculator(context),
        ),
        _ModuleTile(
          icon: Icons.stars,
          title: 'Top Performers',
          subtitle: 'Most runs and most wickets leaderboard',
          onTap: () => _showTopPerformers(context),
        ),
        _ModuleTile(
          icon: Icons.grid_view,
          title: 'Group / Round-Robin Brackets',
          subtitle: 'Create tournament group stages',
          onTap: () => _showComingSoonSnack(context, 'Group Brackets'),
        ),
      ],
    );
  }

  void _showFixtureScheduler(BuildContext context) {
    final repo = RepositoryProvider.of<CricketRepository>(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: CricketColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fixture Scheduler',
              style: TextStyle(
                color: CricketColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Use the Sub-Admin panel to create and schedule matches.\n\nNavigate to Admin → Tournaments → Matches.',
              style: TextStyle(color: CricketColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPointsTable(BuildContext context) {
    final matchState = context.read<MatchListBloc>().state;
    final tournamentId = matchState is MatchListLoaded
        ? matchState.tournament?.id
        : null;
    if (tournamentId == null) return;

    final hubBloc = context.read<TournamentHubBloc>();
    hubBloc.add(LoadTournamentHub(tournamentId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CricketColors.background,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => BlocProvider.value(
          value: hubBloc,
          child: BlocBuilder<TournamentHubBloc, TournamentHubState>(
            builder: (bctx, state) => switch (state) {
              TournamentHubLoaded(:final standings) => ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Points Table',
                    style: TextStyle(
                      color: CricketColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...standings.map(
                    (e) => Card(
                      color: CricketColors.surface,
                      child: ListTile(
                        title: Text(
                          e.teamName,
                          style: TextStyle(color: CricketColors.textPrimary),
                        ),
                        subtitle: Text(
                          'P:${e.played} W:${e.won} L:${e.lost} Pts:${e.points} NRR:${e.nrrDisplay}',
                          style: TextStyle(color: CricketColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }

  void _showNRRCalculator(BuildContext context) {
    final matchState = context.read<MatchListBloc>().state;
    final tournamentId = matchState is MatchListLoaded
        ? matchState.tournament?.id
        : null;
    if (tournamentId == null) return;

    final hubBloc = context.read<TournamentHubBloc>();
    hubBloc.add(LoadTournamentHub(tournamentId));

    showModalBottomSheet(
      context: context,
      backgroundColor: CricketColors.surface,
      builder: (ctx) => BlocProvider.value(
        value: hubBloc,
        child: BlocBuilder<TournamentHubBloc, TournamentHubState>(
          builder: (bctx, state) => switch (state) {
            TournamentHubLoaded(:final standings) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NRR Calculator',
                    style: TextStyle(
                      color: CricketColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...standings.map(
                    (e) => ListTile(
                      title: Text(
                        e.teamName,
                        style: TextStyle(color: CricketColors.textPrimary),
                      ),
                      trailing: Text(
                        e.nrrDisplay,
                        style: TextStyle(
                          color: e.nrr >= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  void _showTopPerformers(BuildContext context) {
    final matchState = context.read<MatchListBloc>().state;
    final tournamentId = matchState is MatchListLoaded
        ? matchState.tournament?.id
        : null;
    if (tournamentId == null) return;

    final hubBloc = context.read<TournamentHubBloc>();
    hubBloc.add(LoadTournamentHub(tournamentId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CricketColors.background,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => BlocProvider.value(
          value: hubBloc,
          child: BlocBuilder<TournamentHubBloc, TournamentHubState>(
            builder: (bctx, state) => switch (state) {
              TournamentHubLoaded(:final mostRuns, :final mostWickets) =>
                ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Top Performers',
                      style: TextStyle(
                        color: CricketColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Most Runs',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...mostRuns
                        .take(3)
                        .map(
                          (p) => ListTile(
                            title: Text(
                              p.name,
                              style: TextStyle(
                                color: CricketColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              p.teamShort ?? '',
                              style: TextStyle(
                                color: CricketColors.textSecondary,
                              ),
                            ),
                            trailing: Text(
                              '${p.runs} runs',
                              style: TextStyle(color: AppColors.secondary),
                            ),
                          ),
                        ),
                    const Divider(color: Colors.white12),
                    Text(
                      'Most Wickets',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...mostWickets
                        .take(3)
                        .map(
                          (p) => ListTile(
                            title: Text(
                              p.name,
                              style: TextStyle(
                                color: CricketColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              p.teamShort ?? '',
                              style: TextStyle(
                                color: CricketColors.textSecondary,
                              ),
                            ),
                            trailing: Text(
                              '${p.wickets} wkts',
                              style: TextStyle(color: AppColors.warning),
                            ),
                          ),
                        ),
                  ],
                ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnack(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}

// ─── Tab 4: Match Analytics ────────────────────────────────

class _AnalyticsTab extends StatefulWidget {
  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  String? _analyticsMatchId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchListBloc, MatchListState>(
      builder: (ctx, state) {
        final matches = state is MatchListLoaded
            ? [...state.liveMatches, ...state.allMatches]
            : <MatchModel>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Match selector for analytics
            DropdownButtonFormField<String>(
              value: _analyticsMatchId,
              dropdownColor: CricketColors.surface,
              style: TextStyle(color: CricketColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Select Match for Analytics',
                labelStyle: TextStyle(color: CricketColors.placeholder),
                filled: true,
                fillColor: CricketColors.inputFill,
                border: const OutlineInputBorder(),
              ),
              hint: Text(
                'Choose a match',
                style: TextStyle(color: CricketColors.placeholder),
              ),
              items: matches.map((m) {
                final ta = m.teamAShort ?? m.teamAName ?? 'T1';
                final tb = m.teamBShort ?? m.teamBName ?? 'T2';
                return DropdownMenuItem(
                  value: m.id,
                  child: Text(
                    '$ta vs $tb',
                    style: TextStyle(color: CricketColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _analyticsMatchId = v),
            ),
            const SizedBox(height: 16),
            _ModuleTile(
              icon: Icons.pie_chart,
              title: 'Wagon Wheel',
              subtitle: 'View 360° shot direction analysis',
              onTap: () => _navigateToAnalytics(context, 'wagon'),
            ),
            _ModuleTile(
              icon: Icons.bar_chart,
              title: 'Run Distribution',
              subtitle: 'Breakdown of runs scored per type',
              onTap: () => _navigateToAnalytics(context, 'dist'),
            ),
            _ModuleTile(
              icon: Icons.donut_large,
              title: 'Conceded Runs',
              subtitle: 'Pie chart of runs conceded by bowler',
              onTap: () => _navigateToAnalytics(context, 'conceded'),
            ),
            _ModuleTile(
              icon: Icons.link,
              title: 'Partnerships',
              subtitle: 'View batting partnerships per innings',
              onTap: () => _navigateToAnalytics(context, 'partner'),
            ),
            _ModuleTile(
              icon: Icons.person_search,
              title: 'Player Career Stats',
              subtitle: 'Aggregated career stats per player',
              onTap: () => _showPlayerSelector(context),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAnalytics(BuildContext context, String section) {
    if (_analyticsMatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a match first',
            style: TextStyle(color: CricketColors.textPrimary),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final mid = _analyticsMatchId!;
    final matchState = context.read<MatchListBloc>().state;
    String title = 'Match';
    if (matchState is MatchListLoaded) {
      final m = [...matchState.liveMatches, ...matchState.allMatches]
          .firstWhere(
            (m) => m.id == mid,
            orElse: () => MatchModel(id: '', status: ''),
          );
      final ta = m.teamAShort ?? m.teamAName ?? 'T1';
      final tb = m.teamBShort ?? m.teamBName ?? 'T2';
      title = '$ta vs $tb';
    }

    context.goNamed(
      'cricket_match_analytics',
      pathParameters: {'matchId': mid},
      queryParameters: {'title': title},
    );
  }

  void _showPlayerSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CricketColors.surface,
        title: Text(
          'Player Career Stats',
          style: TextStyle(color: CricketColors.textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            style: TextStyle(color: CricketColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter Player ID',
              hintStyle: TextStyle(color: CricketColors.placeholder),
              filled: true,
              fillColor: CricketColors.inputFill,
            ),
            onSubmitted: (playerId) {
              Navigator.pop(ctx);
              if (playerId.isNotEmpty) {
                context.goNamed(
                  'cricket_player_profile',
                  pathParameters: {'playerId': playerId},
                  queryParameters: {'name': 'Player'},
                );
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Tile ───────────────────────────────────────────

class _ModuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CricketColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withOpacity(0.2),
          child: Icon(icon, color: AppColors.secondary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: CricketColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: CricketColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
