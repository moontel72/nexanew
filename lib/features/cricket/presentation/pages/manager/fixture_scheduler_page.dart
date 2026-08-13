import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../blocs/fixture/fixture_bloc.dart';
import '../../widgets/cricket_lookups.dart';
import '../../widgets/match_card.dart';
import 'generate_fixtures_sheet.dart';
import 'match_form_sheet.dart';

/// Group fixtures by local date for sectioned listing. Unscheduled
/// fixtures are grouped under 'Unscheduled' and sorted last.
Map<String, List<MatchModel>> groupFixturesByDate(List<MatchModel> matches) {
  final map = <String, List<MatchModel>>{};
  for (final m in matches) {
    final dt = m.scheduledAt?.toLocal();
    final key = dt != null ? formatMatchDate(dt) : 'Unscheduled';
    map.putIfAbsent(key, () => []).add(m);
  }
  for (final list in map.values) {
    list.sort(
      (a, b) => (a.scheduledAt ?? DateTime(2100)).compareTo(
        b.scheduledAt ?? DateTime(2100),
      ),
    );
  }
  final keys = map.keys.toList()..sort();
  final sorted = <String, List<MatchModel>>{};
  for (final k in keys) {
    sorted[k] = map[k]!;
  }
  return sorted;
}

class FixtureSchedulerPage extends StatelessWidget {
  const FixtureSchedulerPage({super.key});

  void _showMatchForm(BuildContext context, {MatchModel? existing}) {
    // The sheet opens in the navigator overlay, above the page's
    // BlocProvider — re-provide the bloc so the form can find it.
    final bloc = context.read<FixtureBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F2936),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: MatchFormSheet(existing: existing),
      ),
    );
  }

  void _showGenerator(BuildContext context) {
    // Same overlay-provider caveat as _showMatchForm.
    final bloc = context.read<FixtureBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F2936),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          BlocProvider.value(value: bloc, child: const GenerateFixturesSheet()),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MatchModel match) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2936),
        title: const Text(
          'Delete Fixture?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '"${match.teamAName ?? 'TBD'} vs ${match.teamBName ?? 'TBD'}" '
          'will be removed from the schedule.',
          style: const TextStyle(color: Color(0xFFBDD8DB)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<FixtureBloc>().add(DeleteMatchRequested(match.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FixtureBloc, FixtureState>(
      listener: (context, state) {
        if (state is FixtureNotice && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: state.success
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              duration: Duration(seconds: state.success ? 3 : 10),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1D2C),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Fixture Scheduler',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0F2936),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Color(0xFF10B981)),
              tooltip: 'Back to Dashboard',
              onPressed: () {
                try {
                  Navigator.of(context).popUntil(
                    (route) =>
                        route.settings.name == 'cricket_manager_dashboard' ||
                        route.isFirst,
                  );
                } catch (_) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<FixtureBloc, FixtureState>(
          builder: (context, state) {
            if (state is FixtureLoading ||
                state is FixtureInitial ||
                state is FixtureNotice) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FixtureError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFBDD8DB),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                        onPressed: () => context.read<FixtureBloc>().add(
                          const RefreshFixtures(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is FixtureLoaded) {
              return _FixtureContent(
                state: state,
                onEdit: (m) => _showMatchForm(context, existing: m),
                onDelete: (m) => _confirmDelete(context, m),
                onToggleStatus: (m) => context.read<FixtureBloc>().add(
                  ChangeMatchStatusRequested(
                    m.id,
                    m.status == 'cancelled' ? 'scheduled' : 'cancelled',
                  ),
                ),
                onAddMatch: () => _showMatchForm(context),
                onGenerate: () => _showGenerator(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _FixtureContent extends StatelessWidget {
  final FixtureLoaded state;
  final void Function(MatchModel) onEdit;
  final void Function(MatchModel) onDelete;
  final void Function(MatchModel) onToggleStatus;
  final VoidCallback onAddMatch;
  final VoidCallback onGenerate;

  const _FixtureContent({
    required this.state,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    required this.onAddMatch,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final visible = state.matches
        .where((m) => state.stageFilter == null || m.stage == state.stageFilter)
        .toList();
    final grouped = groupFixturesByDate(visible);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Match'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onAddMatch,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Fixtures'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onGenerate,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChip(
                label: 'All',
                selected: state.stageFilter == null,
                onSelected: () =>
                    context.read<FixtureBloc>().add(const SetStageFilter(null)),
              ),
              ...cricketStages.map(
                (s) => _FilterChip(
                  label: cricketStageLabel(s),
                  selected: state.stageFilter == s,
                  onSelected: () =>
                      context.read<FixtureBloc>().add(SetStageFilter(s)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: grouped.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 64,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.stageFilter == null
                            ? 'No fixtures yet. Add a match or generate a round-robin.'
                            : 'No fixtures in this stage.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFBDD8DB),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<FixtureBloc>().add(const RefreshFixtures());
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event,
                                size: 15,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(${entry.value.length})',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value.map(
                          (m) => MatchCard(
                            match: m,
                            onEdit: () => onEdit(m),
                            onDelete: () => onDelete(m),
                            onToggleStatus: () => onToggleStatus(m),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: const Color(0xFF0F2936),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFFBDD8DB),
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? const Color(0xFF2563EB) : const Color(0x20FFFFFF),
        ),
      ),
    );
  }
}
