import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/config/api_config.dart';

import '../../blocs/match_list/match_list_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../widgets/match_card.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Public-facing tournament home page — shows all matches.
/// Tournament name is dynamic from active tournament data.
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
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        leadingWidth: 64,
        leading: BlocBuilder<MatchListBloc, MatchListState>(
          builder: (context, state) {
            final logo = state is MatchListLoaded
                ? state.tournament?.logoUrl
                : null;
            final resolved = _resolveLogo(logo);
            return Padding(
              padding: const EdgeInsets.all(10),
              child: resolved != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        resolved,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.sports_cricket,
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.sports_cricket,
                      color: AppColors.secondary,
                    ),
            );
          },
        ),
        title: BlocBuilder<MatchListBloc, MatchListState>(
          builder: (context, state) {
            final name = state is MatchListLoaded
                ? state.tournament?.name ?? 'Cricket'
                : 'Cricket';
            return Text(name);
          },
        ),
        backgroundColor: CricketColors.surface,
        foregroundColor: CricketColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: CricketColors.textSecondary),
            onPressed: () =>
                context.read<MatchListBloc>().add(RefreshMatches()),
          ),
        ],
      ),
      body: BlocBuilder<MatchListBloc, MatchListState>(
        builder: (context, state) => switch (state) {
          MatchListLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
          MatchListLoaded(:final liveMatches, :final allMatches) =>
            _buildMatchList(liveMatches, allMatches),
          MatchListError(:final message) => _buildError(message),
          _ => Center(
            child: Text(
              'Loading...',
              style: TextStyle(color: CricketColors.textSecondary),
            ),
          ),
        },
      ),
    );
  }

  Widget _buildMatchList(
    List<MatchModel> liveMatches,
    List<MatchModel> allMatches,
  ) {
    return RefreshIndicator(
      color: AppColors.secondary,
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
            ...liveMatches.map(
              (m) => MatchCard(
                match: m,
                onTap: () => context.push('/cricket/match/${m.id}', extra: m),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const _SectionHeader(
            title: 'ALL MATCHES',
            icon: Icons.sports_cricket,
            color: Colors.green,
          ),
          ...allMatches
              .where((m) => !liveMatches.any((l) => l.id == m.id))
              .map(
                (m) => MatchCard(
                  match: m,
                  onTap: () => context.push('/cricket/match/${m.id}', extra: m),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildError(String message) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off, size: 64, color: CricketColors.textTertiary),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(color: CricketColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.read<MatchListBloc>().add(LoadMatches()),
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  /// Resolves a relative /storage/… logo URL against the API origin.
  String? _resolveLogo(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${ApiConfig.baseUrl}$url';
  }
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
