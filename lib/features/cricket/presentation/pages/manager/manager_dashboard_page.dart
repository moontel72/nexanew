import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cricket_auth/cricket_auth_bloc.dart';
import '../../blocs/match_list/match_list_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';
import 'manager_login_page.dart';
import 'manager_score_page.dart';
import 'camera_switcher_page.dart';
import 'voice_score_page.dart';
import 'sponsor_manage_page.dart';

/// Manager Dashboard — full management hub with tabbed navigation.
///
/// Replaces the sparse 4-card grid with comprehensive modules:
///   1. Studio & Live Console (scoring + cameras)
///   2. Team Manager (roster, players)
///   3. Tournament Hub (fixtures, points table)
///   4. Match Analytics (wagon wheel, stats)
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
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            title: Text(manager?.name ?? 'Cricket Manager'),
            backgroundColor: const Color(0xFF1A1E31),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
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
              indicatorColor: Colors.green,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
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
            // Match selector dropdown
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: _selectedMatchId,
                dropdownColor: const Color(0xFF1A1E31),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Select Match',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xFF1A1E31),
                  border: OutlineInputBorder(),
                ),
                hint: const Text(
                  'Choose a match to manage',
                  style: TextStyle(color: Colors.grey),
                ),
                items: matches.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(
                      '${m.teamAShort ?? 'T1'} vs ${m.teamBShort ?? 'T2'} (${m.status})',
                      style: TextStyle(
                        color: m.isLive ? Colors.green : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedMatchId = v),
              ),
            ),

            if (_selectedMatchId != null) ...[
              // Quick action row
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

              // Match state summary
              Expanded(
                child: Center(
                  child: Text(
                    'Match $_selectedMatchId selected.\nTap an action above to manage.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_cricket, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Select a match to begin',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'You can manage scoring, cameras, voice input, and sponsors',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.person_add,
          title: 'Player Management',
          subtitle: 'Add, edit, or remove players from teams',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.assignment_ind,
          title: 'Captain & Wicket-Keeper',
          subtitle: 'Assign team captains and wicket-keepers',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.badge,
          title: 'Jersey Numbers',
          subtitle: 'Assign jersey numbers to players',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.image,
          title: 'Team Logos & Photos',
          subtitle: 'Upload team logos and player photos',
          onTap: () {},
        ),
      ],
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
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.leaderboard,
          title: 'Points Table',
          subtitle: 'View and recalculate tournament standings',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.calculate,
          title: 'NRR Calculator',
          subtitle: 'View net run rate for all teams',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.stars,
          title: 'Top Performers',
          subtitle: 'Most runs and most wickets leaderboard',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.grid_view,
          title: 'Group / Round-Robin Brackets',
          subtitle: 'Create tournament group stages',
          onTap: () {},
        ),
      ],
    );
  }
}

// ─── Tab 4: Match Analytics ────────────────────────────────

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ModuleTile(
          icon: Icons.pie_chart,
          title: 'Wagon Wheel',
          subtitle: 'View 360° shot direction analysis',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.bar_chart,
          title: 'Run Distribution',
          subtitle: 'Breakdown of runs scored per type',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.donut_large,
          title: 'Conceded Runs',
          subtitle: 'Pie chart of runs conceded by bowler',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.link,
          title: 'Partnerships',
          subtitle: 'View batting partnerships per innings',
          onTap: () {},
        ),
        _ModuleTile(
          icon: Icons.person_search,
          title: 'Player Career Stats',
          subtitle: 'Aggregated career stats per player',
          onTap: () {},
        ),
      ],
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
      color: const Color(0xFF1A1E31),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.2),
          child: Icon(icon, color: Colors.green, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
