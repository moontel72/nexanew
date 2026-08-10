import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';

class ClubHomePage extends StatelessWidget {
  final ClubModel club;
  const ClubHomePage({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        appBar: AppBar(
          title: Text(club.name),
          backgroundColor: const Color(0xFF1A1E31),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: AppColors.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
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
                  _TabPlaceholder('Scheduled matches feed'),
                  _TabPlaceholder('Tournaments hosted'),
                  _TabPlaceholder('Top performance spotlights'),
                  _TabPlaceholder('Teams roster'),
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

class _ClubHeader extends StatelessWidget {
  final ClubModel club;
  const _ClubHeader({required this.club});

  @override
  Widget build(BuildContext context) => Container(
    height: 160,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF1A1E31),
          const Color(0xFF0A0E21).withOpacity(0.5),
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
            style: const TextStyle(fontSize: 32, color: Colors.white),
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
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (club.location != null)
                Text(
                  club.location!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              if (club.establishedYear != null)
                Text(
                  'Est. ${club.establishedYear}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
      style: const TextStyle(color: Colors.grey),
    ),
  );
}

class _TabPlaceholder extends StatelessWidget {
  final String text;
  const _TabPlaceholder(this.text);
  @override
  Widget build(BuildContext context) => Center(
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );
}
