import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/cricket_auth/cricket_auth_bloc.dart';
import '../../blocs/live_score/live_score_bloc.dart';
import '../../blocs/match_list/match_list_bloc.dart';
import '../../blocs/tournament_hub/tournament_hub_bloc.dart';
import '../../blocs/camera_switcher/camera_switcher_bloc.dart';
import '../../blocs/voice_score/voice_score_bloc.dart';
import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../blocs/team/team_bloc.dart';
import '../../blocs/fixture/fixture_bloc.dart';
import '../../blocs/tournament_setup/tournament_setup_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../../data/repositories/cricket_repository.dart';
import 'manager_login_page.dart';
import 'manager_score_page.dart';
import 'camera_switcher_page.dart';
import 'voice_score_page.dart';
import 'sponsor_manage_page.dart';
import 'team_register_page.dart';
import 'teams_list_page.dart';
import 'player_register_page.dart';
import 'players_list_page.dart';
import 'fixture_scheduler_page.dart';
import 'tournament_setup_page.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/missile_3d_button.dart';

/// Manager Dashboard — 3D Pencil Sidebar layout.

const _tabs = [
  _TabInfo(Icons.live_tv, 'Live Console', 'Scoring, cameras, voice, sponsors'),
  _TabInfo(Icons.groups, 'Team Manager', 'Roster, players, captains, jerseys'),
  _TabInfo(
    Icons.emoji_events,
    'Tournament',
    'Fixtures, points, NRR, performers',
  ),
  _TabInfo(Icons.analytics, 'Analytics', 'Wagon wheel, runs, partnerships'),
];

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});
  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<MatchListBloc>().add(LoadMatches());
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;
    return BlocBuilder<CricketAuthBloc, CricketAuthState>(
      builder: (context, state) {
        final manager = state is CricketAuthLoggedIn ? state.manager : null;
        final name = manager?.name ?? 'Cricket Manager';
        return Scaffold(
          backgroundColor: const Color(0xFF0C1D2C),
          body: Row(
            children: [
              if (wide)
                _PencilSidebar(
                  selectedTab: _selectedTab,
                  onTabSelected: (i) => setState(() => _selectedTab = i),
                ),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      managerName: name,
                      selectedTab: _selectedTab,
                      onLogout: () async {
                        await context.read<CricketRepository>().clearToken();
                        if (!context.mounted) return;
                        // Use pushAndRemoveUntil for reliable navigation
                        // after token clear (GoRouter context.go can render blank)
                        final repo = CricketRepository();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => RepositoryProvider.value(
                              value: repo,
                              child: BlocProvider(
                                create: (_) => CricketAuthBloc(repo: repo),
                                child: const ManagerLoginPage(),
                              ),
                            ),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    if (!wide)
                      _MobileTabBar(
                        selectedTab: _selectedTab,
                        onTabSelected: (i) => setState(() => _selectedTab = i),
                      ),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return const _LiveConsoleTab();
      case 1:
        return const _TeamManagerTab();
      case 2:
        return const _TournamentTab();
      case 3:
        return const _AnalyticsTab();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Top Bar ──────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String managerName;
  final int selectedTab;
  final VoidCallback onLogout;
  const _TopBar({
    required this.managerName,
    required this.selectedTab,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: const BoxDecoration(
      color: Color(0xFF0F2936),
      border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF10B981),
          child: Icon(
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          managerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          _tabs[selectedTab].title,
          style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 12),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.logout, color: Color(0xFFBDD8DB), size: 20),
          tooltip: 'Logout',
          onPressed: onLogout,
        ),
      ],
    ),
  );
}

// ─── Mobile Tab Bar ───────────────────────────────────────────

class _MobileTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  const _MobileTabBar({required this.selectedTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    color: const Color(0xFF0F2936),
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: List.generate(_tabs.length, (i) {
        final t = _tabs[i];
        final active = i == selectedTab;
        return GestureDetector(
          onTap: () => onTabSelected(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active ? const Color(0xFF10B981) : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  t.icon,
                  size: 16,
                  color: active
                      ? const Color(0xFF10B981)
                      : const Color(0xFFBDD8DB),
                ),
                const SizedBox(width: 6),
                Text(
                  t.title,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFFBDD8DB),
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

// ─── Pencil Sidebar ───────────────────────────────────────────

class _PencilSidebar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  const _PencilSidebar({
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 280,
    color: const Color(0xFF09161E),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sports_cricket,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CRICKET',
                      style: TextStyle(
                        color: Color(0xFFBDD8DB),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Manager Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: List.generate(_tabs.length, (i) {
              final t = _tabs[i];
              final active = i == selectedTab;
              return Missile3DButton(
                label: t.title,
                icon: t.icon,
                color: active
                    ? const Color(0xFF10B981)
                    : const Color(0xFF1A3A4A),
                height: 72,
                subtitle: t.subtitle,
                onTap: () => onTabSelected(i),
              );
            }),
          ),
        ),
      ],
    ),
  );
}

// ─── Tab Info ─────────────────────────────────────────────────

class _TabInfo {
  final IconData icon;
  final String title;
  final String subtitle;
  const _TabInfo(this.icon, this.title, this.subtitle);
}

// ═══════════════════════════════════════════════════════════════
// TAB 1 — Live Console
// ═══════════════════════════════════════════════════════════════

class _LiveConsoleTab extends StatefulWidget {
  const _LiveConsoleTab();
  @override
  State<_LiveConsoleTab> createState() => _LiveConsoleTabState();
}

class _LiveConsoleTabState extends State<_LiveConsoleTab> {
  String? _selectedMatchId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchListBloc, MatchListState>(
      builder: (ctx, state) {
        if (state is MatchListLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF10B981)),
          );
        }
        if (state is MatchListError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Color(0xFFEF4444)),
                const SizedBox(height: 12),
                Text(
                  state.message.replaceFirst('Exception: ', ''),
                  style: const TextStyle(color: Color(0xFFBDD8DB)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                  onPressed: () =>
                      context.read<MatchListBloc>().add(LoadMatches()),
                ),
              ],
            ),
          );
        }
        final matches = state is MatchListLoaded
            ? [...state.liveMatches, ...state.allMatches]
            : <MatchModel>[];
        final selectedMatch = _selectedMatchId == null
            ? null
            : matches.where((m) => m.id == _selectedMatchId).firstOrNull;
        return BlocListener<MatchListBloc, MatchListState>(
          listener: (context, state) {
            final notice = state is MatchListLoaded ? state.notice : null;
            if (notice == null || notice.isEmpty) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(notice),
                  backgroundColor: notice.contains('LIVE')
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              );
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _GradientHeader(
                icon: Icons.live_tv,
                title: 'Live Console',
                subtitle:
                    'Manage live scoring, camera feeds, voice input, and sponsor banners.',
                colors: const [Color(0xFF10B981), Color(0xFF059669)],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedMatchId,
                dropdownColor: const Color(0xFF0F2936),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Select Match',
                  labelStyle: TextStyle(color: Color(0xFFBDD8DB)),
                  filled: true,
                  fillColor: Color(0xFF0F2936),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x20FFFFFF)),
                  ),
                ),
                hint: const Text(
                  'Choose a match to manage',
                  style: TextStyle(color: Color(0xFFBDD8DB)),
                ),
                items: matches.map((m) {
                  final ta = m.teamAShort ?? m.teamAName ?? 'T1';
                  final tb = m.teamBShort ?? m.teamBName ?? 'T2';
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(
                      '$ta vs $tb (${m.status})',
                      style: TextStyle(
                        color: m.isLive
                            ? const Color(0xFFEF4444)
                            : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedMatchId = v),
              ),
              if (_selectedMatchId != null) ...[
                const SizedBox(height: 20),
                if (selectedMatch != null) ...[
                  _GoLivePanel(match: selectedMatch),
                  const SizedBox(height: 16),
                ],
                Missile3DButton(
                  label: 'Scoring Console',
                  icon: Icons.scoreboard,
                  color: const Color(0xFF10B981),
                  subtitle: 'Ball-by-ball run & wicket input',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RepositoryProvider.value(
                        value: RepositoryProvider.of<CricketRepository>(
                          context,
                        ),
                        child: BlocProvider(
                          create: (_) => LiveScoreBloc(
                            repo: RepositoryProvider.of<CricketRepository>(
                              context,
                            ),
                          ),
                          child: ManagerScorePage(matchId: _selectedMatchId!),
                        ),
                      ),
                    ),
                  ),
                ),
                Missile3DButton(
                  label: 'Camera Switcher',
                  icon: Icons.videocam,
                  color: const Color(0xFF2563EB),
                  subtitle: 'Toggle & manage camera feeds',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => CameraSwitcherBloc(
                          repo: RepositoryProvider.of<CricketRepository>(
                            context,
                          ),
                        ),
                        child: CameraSwitcherPage(matchId: _selectedMatchId!),
                      ),
                    ),
                  ),
                ),
                Missile3DButton(
                  label: 'Voice-to-Score',
                  icon: Icons.mic,
                  color: const Color(0xFFF59E0B),
                  subtitle: 'Speak or type score updates',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => VoiceScoreBloc(
                          repo: RepositoryProvider.of<CricketRepository>(
                            context,
                          ),
                        ),
                        child: VoiceScorePage(matchId: _selectedMatchId!),
                      ),
                    ),
                  ),
                ),
                Missile3DButton(
                  label: 'Sponsor Management',
                  icon: Icons.campaign,
                  color: const Color(0xFF8B5CF6),
                  subtitle: 'Sponsor library & match banners',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => SponsorBloc(
                          repo: RepositoryProvider.of<CricketRepository>(
                            context,
                          ),
                        ),
                        child: SponsorManagePage(matchId: _selectedMatchId!),
                      ),
                    ),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.sports_cricket,
                          size: 64,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a match to begin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Manage scoring, cameras, voice input, and sponsors',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Prominent GO LIVE / END MATCH control for the selected match.
class _GoLivePanel extends StatelessWidget {
  final MatchModel match;
  const _GoLivePanel({required this.match});

  @override
  Widget build(BuildContext context) {
    final live = match.isLive;
    final readyForLive = match.status == 'toss_done';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: live
              ? const [Color(0xFF065F46), Color(0xFF047857)]
              : const [Color(0xFF7F1D1D), Color(0xFFB91C1C)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                live ? Icons.sensors : Icons.radio_button_checked,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                live ? 'MATCH IS LIVE' : 'MATCH NOT LIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            live
                ? 'Public viewers on cricket.traceodd.com are receiving this match.'
                : readyForLive
                ? 'Toss recorded — activate the public live stream now.'
                : 'Toss not recorded yet. Record it in the Scoring Console, then GO LIVE.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (!live)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.live_tv, color: Colors.white),
                label: const Text(
                  'GO LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => context.read<MatchListBloc>().add(
                  UpdateMatchStatus(match.id, 'live'),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.pause_circle_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'BREAK',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    ),
                    onPressed: () => context.read<MatchListBloc>().add(
                      UpdateMatchStatus(match.id, 'innings_break'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'END MATCH',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    ),
                    onPressed: () => _confirmEndMatch(context),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmEndMatch(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2936),
        title: const Text('End match?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This marks the match as completed and stops the public live stream.',
          style: TextStyle(color: Color(0xFFBDD8DB)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Color(0xFFBDD8DB)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('END MATCH'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<MatchListBloc>().add(UpdateMatchStatus(match.id, 'completed'));
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 2 — Team Manager
// ═══════════════════════════════════════════════════════════════

class _TeamManagerTab extends StatelessWidget {
  const _TeamManagerTab();

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<CricketRepository>(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _GradientHeader(
          icon: Icons.groups,
          title: 'Team Manager',
          subtitle:
              'Register teams, manage players, assign captains, and set jersey numbers.',
          colors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        const SizedBox(height: 20),
        Missile3DButton(
          label: 'Register New Team',
          icon: Icons.group_add,
          color: const Color(0xFF2563EB),
          subtitle: 'Create a team with auto-generated 3-digit code',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: repo,
                child: BlocProvider(
                  create: (_) => TeamBloc(repo: repo),
                  child: const TeamRegisterPage(),
                ),
              ),
            ),
          ),
        ),
        Missile3DButton(
          label: 'View All Teams',
          icon: Icons.list_alt,
          color: const Color(0xFF3B82F6),
          subtitle: 'Browse, search, and manage teams',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: repo,
                child: const TeamsListPage(),
              ),
            ),
          ),
        ),
        Missile3DButton(
          label: 'Register New Player',
          icon: Icons.person_add,
          color: const Color(0xFF6366F1),
          subtitle: 'Add a player with auto-generated 3-digit code',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: repo,
                child: const PlayerRegisterPage(),
              ),
            ),
          ),
        ),
        Missile3DButton(
          label: 'View All Players',
          icon: Icons.people,
          color: const Color(0xFF8B5CF6),
          subtitle: 'Browse players by team',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: repo,
                child: const PlayersListPage(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 3 — Tournament
// ═══════════════════════════════════════════════════════════════

class _TournamentTab extends StatelessWidget {
  const _TournamentTab();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _GradientHeader(
        icon: Icons.emoji_events,
        title: 'Tournament Hub',
        subtitle:
            'Schedule fixtures, view points table, check NRR, and track top performers.',
        colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
      ),
      const SizedBox(height: 20),
      Missile3DButton(
        label: 'Tournament Setup',
        icon: Icons.emoji_events,
        color: const Color(0xFF10B981),
        subtitle: 'Create and activate tournaments',
        onTap: () {
          final repo = RepositoryProvider.of<CricketRepository>(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: repo,
                child: BlocProvider(
                  create: (_) =>
                      TournamentSetupBloc(repo: repo)
                        ..add(const LoadTournaments()),
                  child: const TournamentSetupPage(),
                ),
              ),
            ),
          );
        },
      ),
      Missile3DButton(
        label: 'Fixture Scheduler',
        icon: Icons.calendar_month,
        color: const Color(0xFFF59E0B),
        subtitle: 'Create, edit, and schedule matches',
        onTap: () {
          final repo = RepositoryProvider.of<CricketRepository>(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: repo,
                child: BlocProvider(
                  create: (_) =>
                      FixtureBloc(repo: repo)..add(const LoadFixtures()),
                  child: const FixtureSchedulerPage(),
                ),
              ),
            ),
          );
        },
      ),
      Missile3DButton(
        label: 'Points Table',
        icon: Icons.leaderboard,
        color: const Color(0xFFEAB308),
        subtitle: 'View and recalculate tournament standings',
        onTap: () => _showPointsTable(context),
      ),
      Missile3DButton(
        label: 'NRR Calculator',
        icon: Icons.calculate,
        color: const Color(0xFFCA8A04),
        subtitle: 'View net run rate for all teams',
        onTap: () => _showNRRCalculator(context),
      ),
      Missile3DButton(
        label: 'Top Performers',
        icon: Icons.stars,
        color: const Color(0xFFA16207),
        subtitle: 'Most runs and most wickets leaderboard',
        onTap: () => _showTopPerformers(context),
      ),
      Missile3DButton(
        label: 'Group / Round-Robin Brackets',
        icon: Icons.grid_view,
        color: const Color(0xFF854D0E),
        subtitle: 'Create tournament group stages',
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group Brackets — coming soon'),
            backgroundColor: Color(0xFFF59E0B),
          ),
        ),
      ),
    ],
  );

  void _showPointsTable(BuildContext c) {
    final matchState = c.read<MatchListBloc>().state;
    final tid = matchState is MatchListLoaded
        ? matchState.tournament?.id
        : null;
    if (tid == null) return;
    final hubBloc = c.read<TournamentHubBloc>();
    hubBloc.add(LoadTournamentHub(tid));
    showModalBottomSheet(
      context: c,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C1D2C),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => BlocProvider.value(
          value: hubBloc,
          child: BlocBuilder<TournamentHubBloc, TournamentHubState>(
            builder: (bctx, hubState) {
              if (hubState is TournamentHubLoaded) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Points Table',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...hubState.standings.map(
                      (e) => Card(
                        color: const Color(0xFF0F2936),
                        child: ListTile(
                          title: Text(
                            e.teamName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'P:${e.played} W:${e.won} L:${e.lost} Pts:${e.points} NRR:${e.nrrDisplay}',
                            style: const TextStyle(color: Color(0xFFBDD8DB)),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _showNRRCalculator(BuildContext c) {
    final matchState = c.read<MatchListBloc>().state;
    final tid = matchState is MatchListLoaded
        ? matchState.tournament?.id
        : null;
    if (tid == null) return;
    final hubBloc = c.read<TournamentHubBloc>();
    hubBloc.add(LoadTournamentHub(tid));
    showModalBottomSheet(
      context: c,
      backgroundColor: const Color(0xFF0F2936),
      builder: (_) => BlocProvider.value(
        value: hubBloc,
        child: BlocBuilder<TournamentHubBloc, TournamentHubState>(
          builder: (bctx, hubState) {
            if (hubState is TournamentHubLoaded) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'NRR Calculator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...hubState.standings.map(
                      (e) => ListTile(
                        title: Text(
                          e.teamName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          e.nrrDisplay,
                          style: TextStyle(
                            color: e.nrr >= 0
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showTopPerformers(BuildContext c) {
    final matchState = c.read<MatchListBloc>().state;
    final tid = matchState is MatchListLoaded
        ? matchState.tournament?.id
        : null;
    if (tid == null) return;
    final hubBloc = c.read<TournamentHubBloc>();
    hubBloc.add(LoadTournamentHub(tid));
    showModalBottomSheet(
      context: c,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C1D2C),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => BlocProvider.value(
          value: hubBloc,
          child: BlocBuilder<TournamentHubBloc, TournamentHubState>(
            builder: (bctx, hubState) {
              if (hubState is TournamentHubLoaded) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Top Performers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Most Runs',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...hubState.mostRuns
                        .take(3)
                        .map(
                          (p) => ListTile(
                            title: Text(
                              p.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              p.teamShort ?? '',
                              style: const TextStyle(color: Color(0xFFBDD8DB)),
                            ),
                            trailing: Text(
                              '${p.runs} runs',
                              style: const TextStyle(color: Color(0xFF10B981)),
                            ),
                          ),
                        ),
                    const Divider(color: Color(0x20FFFFFF)),
                    const Text(
                      'Most Wickets',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...hubState.mostWickets
                        .take(3)
                        .map(
                          (p) => ListTile(
                            title: Text(
                              p.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              p.teamShort ?? '',
                              style: const TextStyle(color: Color(0xFFBDD8DB)),
                            ),
                            trailing: Text(
                              '${p.wickets} wkts',
                              style: const TextStyle(color: Color(0xFFF59E0B)),
                            ),
                          ),
                        ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB 4 — Analytics
// ═══════════════════════════════════════════════════════════════

class _AnalyticsTab extends StatefulWidget {
  const _AnalyticsTab();
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
          padding: const EdgeInsets.all(20),
          children: [
            _GradientHeader(
              icon: Icons.analytics,
              title: 'Match Analytics',
              subtitle:
                  'Analyze match data with wagon wheel, run distribution, conceded runs, and partnerships.',
              colors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _analyticsMatchId,
              dropdownColor: const Color(0xFF0F2936),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Select Match for Analytics',
                labelStyle: TextStyle(color: Color(0xFFBDD8DB)),
                filled: true,
                fillColor: Color(0xFF0F2936),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0x20FFFFFF)),
                ),
              ),
              hint: const Text(
                'Choose a match',
                style: TextStyle(color: Color(0xFFBDD8DB)),
              ),
              items: matches.map((m) {
                final ta = m.teamAShort ?? m.teamAName ?? 'T1';
                final tb = m.teamBShort ?? m.teamBName ?? 'T2';
                return DropdownMenuItem(
                  value: m.id,
                  child: Text(
                    '$ta vs $tb',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _analyticsMatchId = v),
            ),
            const SizedBox(height: 16),
            Missile3DButton(
              label: 'Wagon Wheel',
              icon: Icons.pie_chart,
              color: const Color(0xFF8B5CF6),
              subtitle: 'View 360° shot direction analysis',
              onTap: () => _nav(context),
            ),
            Missile3DButton(
              label: 'Run Distribution',
              icon: Icons.bar_chart,
              color: const Color(0xFF7C3AED),
              subtitle: 'Breakdown of runs scored per type',
              onTap: () => _nav(context),
            ),
            Missile3DButton(
              label: 'Conceded Runs',
              icon: Icons.donut_large,
              color: const Color(0xFF6D28D9),
              subtitle: 'Pie chart of runs conceded by bowler',
              onTap: () => _nav(context),
            ),
            Missile3DButton(
              label: 'Partnerships',
              icon: Icons.link,
              color: const Color(0xFF5B21B6),
              subtitle: 'View batting partnerships per innings',
              onTap: () => _nav(context),
            ),
            Missile3DButton(
              label: 'Player Career Stats',
              icon: Icons.person_search,
              color: const Color(0xFF4C1D95),
              subtitle: 'Aggregated career stats per player',
              onTap: () => _playerSelector(context),
            ),
          ],
        );
      },
    );
  }

  void _nav(BuildContext c) {
    if (_analyticsMatchId == null) {
      ScaffoldMessenger.of(c).showSnackBar(
        const SnackBar(
          content: Text('Please select a match first'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }
    final mid = _analyticsMatchId!;
    final s = c.read<MatchListBloc>().state;
    String title = 'Match';
    if (s is MatchListLoaded) {
      final m = [...s.liveMatches, ...s.allMatches].firstWhere(
        (m) => m.id == mid,
        orElse: () => MatchModel(id: '', status: ''),
      );
      title = '${m.teamAShort ?? 'T1'} vs ${m.teamBShort ?? 'T2'}';
    }
    c.goNamed(
      'cricket_match_analytics',
      pathParameters: {'matchId': mid},
      queryParameters: {'title': title},
    );
  }

  void _playerSelector(BuildContext c) => showDialog(
    context: c,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF0F2936),
      title: const Text(
        'Player Career Stats',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter Player ID',
            hintStyle: TextStyle(color: Color(0xFFBDD8DB)),
            filled: true,
            fillColor: Color(0xFF1A2E3E),
          ),
          onSubmitted: (pid) {
            Navigator.pop(ctx);
            if (pid.isNotEmpty)
              c.goNamed(
                'cricket_player_profile',
                pathParameters: {'playerId': pid},
                queryParameters: {'name': 'Player'},
              );
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

// ─── Shared Gradient Header ──────────────────────────────────

class _GradientHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  const _GradientHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    ),
  );
}
