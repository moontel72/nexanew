import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/match_list/match_list_bloc.dart';
import '../../blocs/live_score/live_score_bloc.dart';
import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../widgets/match_card.dart';
import '../../widgets/scoreboard_header.dart';

/// Public-facing tournament home page — shows all matches.
class TournamentHomePage extends StatefulWidget {
  const TournamentHomePage({super.key});

  @override
  State<TournamentHomePage> createState() => _TournamentHomePageState();
}

class _TournamentHomePageState extends State<TournamentHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<MatchListBloc>().add(LoadMatches());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Valley Soon Cricket'),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<MatchListBloc>().add(RefreshMatches()),
          ),
        ],
      ),
      body: BlocBuilder<MatchListBloc, MatchListState>(
        builder: (context, state) => switch (state) {
          MatchListLoading() => const Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
          MatchListLoaded(:final liveMatches, :final allMatches) =>
            _buildMatchList(liveMatches, allMatches),
          MatchListError(:final message) => _buildError(message),
          _ => const Center(child: Text('Loading...')),
        },
      ),
    );
  }

  Widget _buildMatchList(
    List<MatchModel> liveMatches,
    List<MatchModel> allMatches,
  ) {
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: () async {
        context.read<MatchListBloc>().add(RefreshMatches());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (liveMatches.isNotEmpty) ...[
            const _SectionHeader(
              title: 'LIVE NOW',
              icon: Icons.live_tv,
              color: Colors.red,
            ),
            ...liveMatches.map((m) => MatchCard(match: m)),
            const SizedBox(height: 24),
          ],
          const _SectionHeader(
            title: 'ALL MATCHES',
            icon: Icons.sports_cricket,
            color: Colors.green,
          ),
          ...allMatches
              .where((m) => !liveMatches.any((l) => l.id == m.id))
              .map((m) => MatchCard(match: m)),
        ],
      ),
    );
  }

  Widget _buildError(String message) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.read<MatchListBloc>().add(LoadMatches()),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ),
  );
}
