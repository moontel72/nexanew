import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/tournament_setup/tournament_setup_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../widgets/cricket_lookups.dart';
import '../../widgets/match_card.dart';

/// Tournament lifecycle screen for the Cricket Manager panel:
/// create tournaments and activate the one the Fixture Scheduler
/// and public portal should use.
class TournamentSetupPage extends StatelessWidget {
  const TournamentSetupPage({super.key});

  void _showForm(BuildContext context, {TournamentModel? existing}) {
    // The sheet opens in the navigator overlay, above the page's
    // BlocProvider — re-provide the bloc so the form can find it.
    final bloc = context.read<TournamentSetupBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F2936),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: TournamentFormSheet(existing: existing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TournamentSetupBloc, TournamentSetupState>(
      listener: (context, state) {
        if (state is TournamentSetupNotice) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: state.success
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
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
            'Tournament Setup',
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
        body: BlocBuilder<TournamentSetupBloc, TournamentSetupState>(
          builder: (context, state) {
            if (state is TournamentSetupLoading ||
                state is TournamentSetupInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TournamentSetupError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
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
                        onPressed: () => context
                            .read<TournamentSetupBloc>()
                            .add(const RefreshTournaments()),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is TournamentSetupLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Tournament'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _showForm(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.tournaments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events_outlined,
                                  size: 64,
                                  color: Color(0xFF6B7280),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No tournaments yet. Create one, then '
                                  'activate it for the Fixture Scheduler.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFBDD8DB),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<TournamentSetupBloc>().add(
                                const RefreshTournaments(),
                              );
                            },
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                for (final t in state.tournaments)
                                  _TournamentCard(
                                    tournament: t,
                                    onActivate: () => context
                                        .read<TournamentSetupBloc>()
                                        .add(ActivateTournamentRequested(t.id)),
                                    onEdit: () =>
                                        _showForm(context, existing: t),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final VoidCallback onActivate;
  final VoidCallback onEdit;

  const _TournamentCard({
    required this.tournament,
    required this.onActivate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = cricketTournamentStatusColor(tournament.status);

    return Card(
      color: const Color(0xFF0F2936),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tournament.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    cricketTournamentStatusLabel(tournament.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (tournament.isActive) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (tournament.location != null &&
                    tournament.location!.isNotEmpty)
                  _MetaLine(
                    icon: Icons.location_on,
                    text: tournament.location!,
                  ),
                _MetaLine(
                  icon: Icons.event,
                  text:
                      '${formatMatchDate(tournament.startDate)} → '
                      '${formatMatchDate(tournament.endDate)}',
                ),
                _MetaLine(
                  icon: Icons.groups,
                  text:
                      '${tournament.teamsCount} teams · '
                      '${tournament.matchesCount} matches',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!tournament.isActive)
                  TextButton.icon(
                    icon: const Icon(Icons.play_circle_outline, size: 16),
                    label: const Text('Activate'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                    ),
                    onPressed: onActivate,
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                  ),
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFFBDD8DB)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 12),
        ),
      ],
    );
  }
}

/// Create / edit tournament form. All reactive state via ValueNotifiers
/// and the shared bloc (no setState).
class TournamentFormSheet extends StatefulWidget {
  final TournamentModel? existing;
  const TournamentFormSheet({super.key, this.existing});

  @override
  State<TournamentFormSheet> createState() => _TournamentFormSheetState();
}

class _TournamentFormSheetState extends State<TournamentFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  final _startDate = ValueNotifier<DateTime?>(null);
  final _endDate = ValueNotifier<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _startDate.value = e?.startDate;
    _endDate.value = e?.endDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  Future<void> _pickDate(ValueNotifier<DateTime?> target) async {
    final date = await showDatePicker(
      context: context,
      initialDate: target.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date != null) {
      target.value = date;
    }
  }

  void _submit() {
    final bloc = context.read<TournamentSetupBloc>();
    final name = _nameCtrl.text.trim();
    final start = _startDate.value;
    final end = _endDate.value;

    if (name.isEmpty || start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name, start date, and end date are required.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before the start date.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final location = _locationCtrl.text.trim();
    final description = _descCtrl.text.trim();

    if (widget.existing == null) {
      bloc.add(
        CreateTournamentRequested(
          name: name,
          location: location.isEmpty ? null : location,
          startDate: start,
          endDate: end,
          description: description.isEmpty ? null : description,
        ),
      );
    } else {
      bloc.add(
        UpdateTournamentRequested(
          tournamentId: widget.existing!.id,
          name: name,
          location: location.isEmpty ? null : location,
          startDate: start,
          endDate: end,
          description: description.isEmpty ? null : description,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TournamentSetupBloc, TournamentSetupState>(
      listenWhen: (_, state) =>
          state is TournamentSetupNotice && state.action == 'saveTournament',
      listener: (context, state) {
        if (!context.mounted) return;
        if ((state as TournamentSetupNotice).success) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? 'Create Tournament'
                    : 'Edit Tournament',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Tournament name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Location / city'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _startDate,
                      builder: (context, value, _) => OutlinedButton.icon(
                        icon: const Icon(Icons.event, size: 16),
                        label: Text(
                          value != null
                              ? 'Start: ${formatMatchDate(value)}'
                              : 'Start date *',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _pickDate(_startDate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<DateTime?>(
                      valueListenable: _endDate,
                      builder: (context, value, _) => OutlinedButton.icon(
                        icon: const Icon(Icons.event, size: 16),
                        label: Text(
                          value != null
                              ? 'End: ${formatMatchDate(value)}'
                              : 'End date *',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _pickDate(_endDate),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Description'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                  widget.existing == null
                      ? 'CREATE TOURNAMENT'
                      : 'SAVE CHANGES',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
