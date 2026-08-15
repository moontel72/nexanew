import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/squad_setup/squad_setup_bloc.dart';
import '../../../data/models/cricket_models.dart';

/// Pre-match lineup builder: select the playing XI and arrange the
/// batting order per team. Fully BLoC-driven — no local state.
class SquadSetupPage extends StatelessWidget {
  final String matchId;

  const SquadSetupPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SquadSetupBloc, SquadSetupState>(
      listener: (context, state) {
        if (state is SquadSetupError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: CricketColors.wicket,
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: CricketColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Lineup Setup'),
          backgroundColor: CricketColors.surface,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<SquadSetupBloc, SquadSetupState>(
          builder: (context, state) => switch (state) {
            SquadSetupInitial() || SquadSetupLoading() => const Center(
              child: CircularProgressIndicator(color: CricketColors.complete),
            ),
            SquadSetupError(:final message) => _LoadError(
              message: message,
              onRetry: () =>
                  context.read<SquadSetupBloc>().add(LoadSquadSetup(matchId)),
            ),
            SquadSetupSaved(:final teamName) => _SavedView(
              teamName: teamName,
              onDone: () => Navigator.pop(context),
            ),
            SquadSetupLoaded() => _buildEditor(context, state),
          },
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context, SquadSetupLoaded s) {
    final match = s.match;
    final teamAId = match?.teamAId;
    final teamBId = match?.teamBId;
    final teamAName = match?.teamAName ?? match?.teamAShort ?? 'Team A';
    final teamBName = match?.teamBName ?? match?.teamBShort ?? 'Team B';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (teamAId != null && teamBId != null) ...[
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text(teamAName, style: const TextStyle(fontSize: 12)),
                  selected: s.selectedTeamId == teamAId,
                  backgroundColor: CricketColors.inputFill,
                  selectedColor: CricketColors.complete,
                  labelStyle: const TextStyle(color: Colors.white),
                  onSelected: (_) => context.read<SquadSetupBloc>().add(
                    SelectSquadTeam(teamAId),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Text(teamBName, style: const TextStyle(fontSize: 12)),
                  selected: s.selectedTeamId == teamBId,
                  backgroundColor: CricketColors.inputFill,
                  selectedColor: CricketColors.complete,
                  labelStyle: const TextStyle(color: Colors.white),
                  onSelected: (_) => context.read<SquadSetupBloc>().add(
                    SelectSquadTeam(teamBId),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _SectionHeader(title: 'Playing XI (${s.xi.length}/11) — batting order'),
        const SizedBox(height: 8),
        if (s.xi.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CricketColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'No players in the XI yet. Add players from the bench below — the top of the list opens the batting.',
              style: TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 13,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: CricketColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (var i = 0; i < s.xi.length; i++)
                  _XiRow(
                    index: i,
                    player: s.xi[i],
                    isLast: i == s.xi.length - 1,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        _SectionHeader(title: 'Bench — add to XI'),
        const SizedBox(height: 8),
        if (s.bench.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CricketColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'No other registered players for this team.',
              style: TextStyle(
                color: CricketColors.textSecondary,
                fontSize: 13,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: CricketColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (final p in s.bench)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: CricketColors.inputFill,
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: CricketColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        color: CricketColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${p.roleDisplay} · ${p.jerseyNumber ?? '—'}',
                      style: const TextStyle(
                        color: CricketColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: CricketColors.complete,
                      ),
                      tooltip: 'Add to XI',
                      onPressed: s.xi.length >= 11
                          ? null
                          : () => context.read<SquadSetupBloc>().add(
                              AddToXi(p.id),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: s.saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(s.saving ? 'SAVING…' : 'SAVE LINEUP'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: (s.saving || s.xi.isEmpty)
              ? null
              : () => context.read<SquadSetupBloc>().add(SaveSquad()),
        ),
      ],
    );
  }
}

class _XiRow extends StatelessWidget {
  final int index;
  final PlayerModel player;
  final bool isLast;

  const _XiRow({
    required this.index,
    required this.player,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SquadSetupBloc>();
    return ListTile(
      dense: true,
      leading: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: index < 2
              ? CricketColors.complete.withOpacity(0.25)
              : CricketColors.inputFill,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: CricketColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        player.name,
        style: const TextStyle(color: CricketColors.textPrimary, fontSize: 13),
      ),
      subtitle: Text(
        '${player.roleDisplay} · ${player.jerseyNumber ?? '—'}'
        '${index < 2 ? ' · OPENER' : ''}',
        style: const TextStyle(
          color: CricketColors.textSecondary,
          fontSize: 11,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_upward,
              size: 18,
              color: CricketColors.textSecondary,
            ),
            tooltip: 'Move up',
            onPressed: index == 0 ? null : () => bloc.add(MoveXiUp(index)),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_downward,
              size: 18,
              color: CricketColors.textSecondary,
            ),
            tooltip: 'Move down',
            onPressed: isLast ? null : () => bloc.add(MoveXiDown(index)),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              size: 18,
              color: CricketColors.wicket,
            ),
            tooltip: 'Remove from XI',
            onPressed: () => bloc.add(RemoveFromXi(player.id)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: CricketColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: CricketColors.wicket),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _SavedView extends StatelessWidget {
  final String teamName;
  final VoidCallback onDone;

  const _SavedView({required this.teamName, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: CricketColors.complete,
          ),
          const SizedBox(height: 16),
          Text(
            'Lineup saved for $teamName',
            style: const TextStyle(
              color: CricketColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('DONE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            onPressed: onDone,
          ),
        ],
      ),
    );
  }
}
