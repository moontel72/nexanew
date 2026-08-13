import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../blocs/fixture/fixture_bloc.dart';
import '../../widgets/cricket_lookups.dart';
import '../../widgets/cricket_top_sheet.dart';
import '../../widgets/ground_picker.dart';
import '../../widgets/match_card.dart';

/// Add / edit fixture form. All reactive state lives in [FixtureBloc];
/// form selections use ValueNotifiers (no setState).
class MatchFormSheet extends StatefulWidget {
  final MatchModel? existing;
  const MatchFormSheet({super.key, this.existing});

  @override
  State<MatchFormSheet> createState() => _MatchFormSheetState();
}

class _MatchFormSheetState extends State<MatchFormSheet> {
  late final TextEditingController _venueCtrl;
  late final TextEditingController _oversCtrl;
  final _teamA = ValueNotifier<String?>(null);
  final _teamB = ValueNotifier<String?>(null);
  final _ground = ValueNotifier<String?>(null);
  final _stage = ValueNotifier<String>('group_stage');
  final _matchType = ValueNotifier<String>('t20');
  final _scheduled = ValueNotifier<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _venueCtrl = TextEditingController(text: m?.venue ?? '');
    _oversCtrl = TextEditingController(
      text: m != null ? '${m.oversPerSide}' : '',
    );
    _teamA.value = m?.teamAId;
    _teamB.value = m?.teamBId;
    _ground.value = m?.groundId;
    if (m?.stage != null && m!.stage!.isNotEmpty) _stage.value = m.stage!;
    if (m?.matchType != null && m!.matchType!.isNotEmpty) {
      _matchType.value = m.matchType!;
    }
    _scheduled.value = m?.scheduledAt?.toLocal();
  }

  @override
  void dispose() {
    _venueCtrl.dispose();
    _oversCtrl.dispose();
    _teamA.dispose();
    _teamB.dispose();
    _ground.dispose();
    _stage.dispose();
    _matchType.dispose();
    _scheduled.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final base = _scheduled.value ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    _scheduled.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  void _submit() {
    final bloc = context.read<FixtureBloc>();
    final s = bloc.state;
    if (s is! FixtureLoaded) return;

    final teamA = _teamA.value;
    final teamB = _teamB.value;
    final scheduled = _scheduled.value;

    if (teamA == null || teamB == null || scheduled == null) {
      _showMessage('Select both teams and a date/time.');
      return;
    }
    if (teamA == teamB) {
      _showMessage('Team A and Team B must be different.');
      return;
    }

    final venue = _venueCtrl.text.trim();
    final overs = int.tryParse(_oversCtrl.text.trim());

    if (widget.existing == null) {
      bloc.add(
        CreateMatchRequested(
          tournamentId: s.tournamentId,
          teamAId: teamA,
          teamBId: teamB,
          scheduledAt: scheduled,
          matchType: _matchType.value,
          venue: venue.isEmpty ? null : venue,
          groundId: _ground.value,
          oversPerSide: overs,
          stage: _stage.value,
        ),
      );
    } else {
      bloc.add(
        UpdateMatchRequested(
          matchId: widget.existing!.id,
          teamAId: teamA,
          teamBId: teamB,
          scheduledAt: scheduled,
          matchType: _matchType.value,
          venue: venue.isEmpty ? null : venue,
          groundId: _ground.value,
          oversPerSide: overs,
          stage: _stage.value,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FixtureBloc, FixtureState>(
      listenWhen: (_, state) =>
          state is FixtureNotice && state.action == 'saveMatch',
      listener: (context, state) {
        if (!context.mounted) return;
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
              CricketSheetHeader(
                title: widget.existing == null ? 'Add Fixture' : 'Edit Fixture',
              ),
              const SizedBox(height: 8),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<String?>(
          valueListenable: _teamA,
          builder: (context, value, _) => DropdownButtonFormField<String?>(
            value: value,
            isExpanded: true,
            decoration: cricketFieldDecoration('Team A *'),
            dropdownColor: const Color(0xFF0F2936),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'Select team',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              ...teams
                  .where((t) => t.id != _teamB.value)
                  .map(
                    (t) => DropdownMenuItem<String?>(
                      value: t.id,
                      child: Text(
                        t.name,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
            ],
            onChanged: (v) {
              _teamA.value = v;
              if (_teamB.value == v) _teamB.value = null;
            },
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<String?>(
          valueListenable: _teamB,
          builder: (context, value, _) => DropdownButtonFormField<String?>(
            value: value,
            isExpanded: true,
            decoration: cricketFieldDecoration('Team B *'),
            dropdownColor: const Color(0xFF0F2936),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'Select team',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              ...teams
                  .where((t) => t.id != _teamA.value)
                  .map(
                    (t) => DropdownMenuItem<String?>(
                      value: t.id,
                      child: Text(
                        t.name,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
            ],
            onChanged: (v) {
              _teamB.value = v;
              if (_teamA.value == v) _teamA.value = null;
            },
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<DateTime?>(
          valueListenable: _scheduled,
          builder: (context, value, _) => OutlinedButton.icon(
            icon: const Icon(Icons.event, size: 18),
            label: Text(
              value != null
                  ? '${formatMatchDate(value)} · ${formatMatchTime(value)}'
                  : 'Pick date & time *',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.centerLeft,
            ),
            onPressed: _pickDateTime,
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<String>(
          valueListenable: _matchType,
          builder: (context, value, _) => DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: cricketFieldDecoration('Match Type'),
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
          decoration: cricketFieldDecoration('Overs per side (auto if empty)'),
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
          decoration: cricketFieldDecoration('Venue (free text, optional)'),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(
            widget.existing == null ? 'SAVE FIXTURE' : 'UPDATE FIXTURE',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: _submit,
        ),
      ],
    );
  }
}
