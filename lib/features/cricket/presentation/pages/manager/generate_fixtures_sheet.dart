import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/fixture/fixture_bloc.dart';
import '../../widgets/cricket_lookups.dart';
import '../../widgets/ground_picker.dart';
import '../../widgets/match_card.dart';

/// Round-robin auto-generation sheet. All state via ValueNotifiers and
/// the shared FixtureBloc (no setState).
class GenerateFixturesSheet extends StatefulWidget {
  const GenerateFixturesSheet({super.key});

  @override
  State<GenerateFixturesSheet> createState() => _GenerateFixturesSheetState();
}

class _GenerateFixturesSheetState extends State<GenerateFixturesSheet> {
  final _format = ValueNotifier<String>('single_round_robin');
  final _selectedTeams = ValueNotifier<Set<String>>({});
  final _startDate = ValueNotifier<DateTime?>(null);
  final _kickoff = ValueNotifier<TimeOfDay>(
    const TimeOfDay(hour: 9, minute: 0),
  );
  final _matchType = ValueNotifier<String>('t20');
  final _ground = ValueNotifier<String?>(null);
  final _stage = ValueNotifier<String>('group_stage');
  final _intervalCtrl = TextEditingController(text: '1');
  final _gapCtrl = TextEditingController(text: '3');
  final _oversCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();

  /// Teams selection is initialized to "all teams" the first time the
  /// team list becomes available.
  bool _teamsInitialized = false;

  @override
  void dispose() {
    _format.dispose();
    _selectedTeams.dispose();
    _startDate.dispose();
    _kickoff.dispose();
    _matchType.dispose();
    _ground.dispose();
    _stage.dispose();
    _intervalCtrl.dispose();
    _gapCtrl.dispose();
    _oversCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date != null) {
      _startDate.value = date;
    }
  }

  Future<void> _pickKickoff() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _kickoff.value,
    );
    if (time != null) {
      _kickoff.value = time;
    }
  }

  void _toggleTeam(String id, Set<String> allIds) {
    final next = Set<String>.from(_selectedTeams.value);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    // Normalize: selecting every team equals "all teams".
    _selectedTeams.value = next.containsAll(allIds) ? <String>{} : next;
  }

  void _submit() {
    final bloc = context.read<FixtureBloc>();
    final s = bloc.state;
    if (s is! FixtureLoaded) return;

    final start = _startDate.value;
    if (start == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick a start date.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final interval = int.tryParse(_intervalCtrl.text.trim()) ?? 1;
    final gap = int.tryParse(_gapCtrl.text.trim());
    final overs = int.tryParse(_oversCtrl.text.trim());
    final venue = _venueCtrl.text.trim();
    final t = _kickoff.value;
    final kickoff =
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';

    bloc.add(
      GenerateFixturesRequested(
        tournamentId: s.tournamentId,
        format: _format.value,
        teamIds: _selectedTeams.value.toList(),
        startDate: start,
        matchIntervalDays: interval,
        kickoffTime: kickoff,
        matchGapHours: gap,
        matchType: _matchType.value,
        oversPerSide: overs,
        venue: venue.isEmpty ? null : venue,
        groundId: _ground.value,
        stage: _stage.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FixtureBloc, FixtureState>(
      listenWhen: (_, state) =>
          state is FixtureNotice && state.action == 'generate',
      listener: (context, state) {
        if ((state as FixtureNotice).success) {
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
              const Text(
                'Generate Round-Robin Fixtures',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<FixtureBloc, FixtureState>(
                builder: (context, state) {
                  if (state is! FixtureLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildFields(state);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields(FixtureLoaded state) {
    final bloc = context.read<FixtureBloc>();
    final teams = state.teams;

    if (!_teamsInitialized) {
      _teamsInitialized = true;
      _selectedTeams.value = Set.of(teams.map((t) => t.id));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<String>(
          valueListenable: _format,
          builder: (context, value, _) => Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Single Round-Robin'),
                  selected: value == 'single_round_robin',
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: const Color(0xFF0C1D2C),
                  labelStyle: TextStyle(
                    color: value == 'single_round_robin'
                        ? Colors.white
                        : const Color(0xFFBDD8DB),
                    fontSize: 12,
                  ),
                  onSelected: (_) => _format.value = 'single_round_robin',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Double Round-Robin'),
                  selected: value == 'double_round_robin',
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: const Color(0xFF0C1D2C),
                  labelStyle: TextStyle(
                    color: value == 'double_round_robin'
                        ? Colors.white
                        : const Color(0xFFBDD8DB),
                    fontSize: 12,
                  ),
                  onSelected: (_) => _format.value = 'double_round_robin',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Teams',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<Set<String>>(
          valueListenable: _selectedTeams,
          builder: (context, selected, _) {
            final allIds = teams.map((t) => t.id).toSet();
            final effective = selected.isEmpty ? allIds : selected;
            return Wrap(
              spacing: 6,
              runSpacing: 4,
              children: teams.map((t) {
                return FilterChip(
                  label: Text(t.name),
                  selected: effective.contains(t.id),
                  selectedColor: const Color(0xFF10B981).withOpacity(0.3),
                  backgroundColor: const Color(0xFF0C1D2C),
                  labelStyle: TextStyle(
                    color: effective.contains(t.id)
                        ? Colors.white
                        : const Color(0xFFBDD8DB),
                    fontSize: 12,
                  ),
                  onSelected: (_) => _toggleTeam(t.id, allIds),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<DateTime?>(
          valueListenable: _startDate,
          builder: (context, value, _) => OutlinedButton.icon(
            icon: const Icon(Icons.event, size: 18),
            label: Text(
              value != null
                  ? 'Start date: ${formatMatchDate(value)}'
                  : 'Pick start date *',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.centerLeft,
            ),
            onPressed: _pickStartDate,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _intervalCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Days between rounds'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ValueListenableBuilder<TimeOfDay>(
                valueListenable: _kickoff,
                builder: (context, value, _) => OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(
                    '${value.hour.toString().padLeft(2, '0')}:'
                    '${value.minute.toString().padLeft(2, '0')}',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _pickKickoff,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _gapCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: cricketFieldDecoration('Hours between kickoffs'),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<String>(
          valueListenable: _matchType,
          builder: (context, value, _) => DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: cricketFieldDecoration('Default match type'),
            dropdownColor: const Color(0xFF0F2936),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: cricketMatchTypes
                .map(
                  (t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(
                      cricketMatchTypeLabel(t),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => _matchType.value = v ?? 't20',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _oversCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: cricketFieldDecoration('Default overs (auto if empty)'),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<String>(
          valueListenable: _stage,
          builder: (context, value, _) => DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: cricketFieldDecoration('Stage'),
            dropdownColor: const Color(0xFF0F2936),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: cricketStages
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(
                      cricketStageLabel(s),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => _stage.value = v ?? 'group_stage',
          ),
        ),
        const SizedBox(height: 12),
        GroundPickerField(
          grounds: state.grounds,
          selected: _ground,
          bloc: bloc,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _venueCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: cricketFieldDecoration('Default venue (free text)'),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.auto_awesome),
          label: const Text('GENERATE FIXTURES'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: const Color(0xFF0C1D2C),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _submit,
        ),
      ],
    );
  }
}
