import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';

class ClubHomePage extends StatelessWidget {
  final ClubModel club;
  const ClubHomePage({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: CricketColors.background,
        appBar: AppBar(
          title: Text(club.name),
          backgroundColor: CricketColors.inputFill,
          foregroundColor: CricketColors.textPrimary,
          bottom: const TabBar(
            indicatorColor: AppColors.secondary,
            labelColor: CricketColors.textPrimary,
            unselectedLabelColor: CricketColors.textSecondary,
            tabs: [
              Tab(text: 'Matches'),
              Tab(text: 'Tournaments'),
              Tab(text: 'Statistics'),
              Tab(text: 'Teams'),
              Tab(text: 'Info'),
            ],
          ),
        ),
        body: Column(
          children: [
            _ClubHeader(club: club),
            const SizedBox(height: 8),
            _ClubStats(club: club),
            const Divider(color: Colors.white12),
            Expanded(
              child: TabBarView(
                children: [
                  _ClubMatchesTab(club: club),
                  _ClubTournamentsTab(club: club),
                  _ClubStatisticsTab(club: club),
                  _ClubTeamsTab(club: club),
                  _ClubInfo(club: club),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Matches Tab ─────────────────────────────────────────────
class _ClubMatchesTab extends StatelessWidget {
  final ClubModel club;
  const _ClubMatchesTab({required this.club});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<MatchModel>>(
    future: CricketRepository().getAllMatches(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError) {
        return Center(
          child: Text(
            'Failed to load matches',
            style: TextStyle(color: CricketColors.wicket),
          ),
        );
      }
      final matches = snap.data ?? [];
      if (matches.isEmpty) {
        return Center(
          child: Text(
            'No matches scheduled',
            style: TextStyle(color: CricketColors.textSecondary),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (_, i) => Card(
          color: CricketColors.inputFill,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(
                Icons.sports_cricket,
                color: CricketColors.textPrimary,
              ),
            ),
            title: Text(
              '${matches[i].teamAShort ?? 'T1'} vs ${matches[i].teamBShort ?? 'T2'}',
              style: const TextStyle(
                color: CricketColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              matches[i].status,
              style: TextStyle(
                color: matches[i].isLive
                    ? CricketColors.live
                    : CricketColors.textSecondary,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: CricketColors.textSecondary,
            ),
          ),
        ),
      );
    },
  );
}

// ─── Tournaments Tab ─────────────────────────────────────────
class _ClubTournamentsTab extends StatelessWidget {
  final ClubModel club;
  const _ClubTournamentsTab({required this.club});

  @override
  Widget build(BuildContext context) => FutureBuilder<TournamentModel?>(
    future: CricketRepository().getActiveTournament(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final tournament = snap.data;
      if (tournament == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No active tournaments',
              style: TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: CricketColors.inputFill,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: const Icon(
                  Icons.emoji_events,
                  color: CricketColors.textPrimary,
                ),
              ),
              title: Text(
                tournament.name,
                style: const TextStyle(
                  color: CricketColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${_formatDate(tournament.startDate)} – ${_formatDate(tournament.endDate)}',
                style: const TextStyle(color: CricketColors.textSecondary),
              ),
              trailing: Icon(
                tournament.status == 'live'
                    ? Icons.fiber_manual_record
                    : Icons.schedule,
                color: tournament.status == 'live'
                    ? CricketColors.live
                    : CricketColors.textSecondary,
                size: 12,
              ),
            ),
          ),
        ],
      );
    },
  );

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ─── Statistics Tab ──────────────────────────────────────────
class _ClubStatisticsTab extends StatelessWidget {
  final ClubModel club;
  const _ClubStatisticsTab({required this.club});

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Map<String, List<TopPerformer>>>(
        future: _fetchTopPerformers(),
        builder: (ctx, snap) {
          final performers = snap.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle('Club Overview'),
              _StatCard(
                icon: Icons.sports_cricket,
                label: 'Matches Hosted',
                value: '${club.totalMatchesHosted}',
              ),
              _StatCard(
                icon: Icons.emoji_events,
                label: 'Tournaments Hosted',
                value: '${club.totalTournamentsHosted}',
              ),
              _StatCard(
                icon: Icons.people,
                label: 'Followers',
                value: '${club.followerCount}',
              ),
              _StatCard(
                icon: Icons.visibility,
                label: 'Total Views',
                value: '${club.clubViews}',
              ),
              if (performers != null &&
                  performers['most_runs'] != null &&
                  performers['most_runs']!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionTitle('Top Run Scorers'),
                ...performers['most_runs']!
                    .take(3)
                    .map(
                      (p) =>
                          _PerformerRow(name: p.name, value: '${p.runs} runs'),
                    ),
              ],
              if (performers != null &&
                  performers['most_wickets'] != null &&
                  performers['most_wickets']!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionTitle('Top Wicket Takers'),
                ...performers['most_wickets']!
                    .take(3)
                    .map(
                      (p) => _PerformerRow(
                        name: p.name,
                        value: '${p.wickets} wkts',
                      ),
                    ),
              ],
              if (performers == null)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'No performance data available yet.',
                    style: TextStyle(color: CricketColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      );

  Future<Map<String, List<TopPerformer>>> _fetchTopPerformers() async {
    try {
      final activeTournament = await CricketRepository().getActiveTournament();
      if (activeTournament != null) {
        return await CricketRepository().getTopPerformers(activeTournament.id);
      }
    } catch (_) {}
    return {};
  }
}

// ─── Teams Tab ───────────────────────────────────────────────
class _ClubTeamsTab extends StatelessWidget {
  final ClubModel club;
  const _ClubTeamsTab({required this.club});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<TeamModel>>(
    future: CricketRepository().getTeams(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError) {
        return Center(
          child: Text(
            'Failed to load teams',
            style: TextStyle(color: CricketColors.wicket),
          ),
        );
      }
      final teams = snap.data ?? [];
      if (teams.isEmpty) {
        return Center(
          child: Text(
            'No teams registered',
            style: TextStyle(color: CricketColors.textSecondary),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teams.length,
        itemBuilder: (_, i) => Card(
          color: CricketColors.inputFill,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Text(
                teams[i].name[0].toUpperCase(),
                style: const TextStyle(
                  color: CricketColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              teams[i].name,
              style: const TextStyle(
                color: CricketColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              teams[i].shortCode,
              style: const TextStyle(color: CricketColors.textSecondary),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: CricketColors.textSecondary,
            ),
          ),
        ),
      );
    },
  );
}

// ─── Shared helpers ──────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        color: AppColors.secondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Card(
    color: CricketColors.inputFill,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(
        label,
        style: const TextStyle(
          color: CricketColors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          color: CricketColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),
  );
}

class _PerformerRow extends StatelessWidget {
  final String name;
  final String value;
  const _PerformerRow({required this.name, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: CricketColors.textPrimary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

// ─── Original club widgets (colors updated) ──────────────────

class _ClubHeader extends StatelessWidget {
  final ClubModel club;
  const _ClubHeader({required this.club});

  @override
  Widget build(BuildContext context) => Container(
    height: 160,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          CricketColors.inputFill,
          CricketColors.background.withOpacity(0.5),
        ],
      ),
    ),
    child: Row(
      children: [
        const SizedBox(width: 20),
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.secondary,
          child: Text(
            club.name[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              color: CricketColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                club.name,
                style: const TextStyle(
                  color: CricketColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (club.location != null)
                Text(
                  club.location!,
                  style: const TextStyle(
                    color: CricketColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              if (club.establishedYear != null)
                Text(
                  'Est. ${club.establishedYear}',
                  style: const TextStyle(
                    color: CricketColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ClubStats extends StatelessWidget {
  final ClubModel club;
  const _ClubStats({required this.club});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.people,
          value: '${club.followerCount}',
          label: 'Followers',
        ),
        _StatItem(
          icon: Icons.visibility,
          value: '${club.clubViews}',
          label: 'Views',
        ),
        _StatItem(
          icon: Icons.sports_cricket,
          value: '${club.totalMatchesHosted}',
          label: 'Matches',
        ),
        _StatItem(
          icon: Icons.emoji_events,
          value: '${club.totalTournamentsHosted}',
          label: 'Tournaments',
        ),
      ],
    ),
  );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: AppColors.secondary, size: 20),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: CricketColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: CricketColors.textSecondary,
          fontSize: 10,
        ),
      ),
    ],
  );
}

class _ClubInfo extends StatelessWidget {
  final ClubModel club;
  const _ClubInfo({required this.club});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      club.description ?? 'No description available.',
      style: const TextStyle(color: CricketColors.textSecondary),
    ),
  );
}
