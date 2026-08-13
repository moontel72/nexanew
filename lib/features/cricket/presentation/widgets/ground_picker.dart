import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cricket_models.dart';
import '../blocs/fixture/fixture_bloc.dart';
import 'cricket_lookups.dart';

/// Ground dropdown with an inline "add ground" action, shared by the
/// match form and the fixture generator sheet.
class GroundPickerField extends StatelessWidget {
  final List<GroundModel> grounds;
  final ValueNotifier<String?> selected;
  final FixtureBloc bloc;

  const GroundPickerField({
    super.key,
    required this.grounds,
    required this.selected,
    required this.bloc,
  });

  Future<void> _openAddGround(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AddGroundDialog(bloc: bloc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: selected,
            builder: (context, value, _) => DropdownButtonFormField<String?>(
              value: value,
              isExpanded: true,
              decoration: cricketFieldDecoration('Ground (optional)'),
              dropdownColor: const Color(0xFF0F2936),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    '— None —',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ...grounds.map(
                  (g) => DropdownMenuItem<String?>(
                    value: g.id,
                    child: Text(
                      g.location != null && g.location!.isNotEmpty
                          ? '${g.name} · ${g.location}'
                          : g.name,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (v) => selected.value = v,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_location_alt, color: Color(0xFF10B981)),
          tooltip: 'Add Ground',
          onPressed: () => _openAddGround(context),
        ),
      ],
    );
  }
}

/// Small dialog to register a new ground/venue.
class AddGroundDialog extends StatefulWidget {
  final FixtureBloc bloc;
  const AddGroundDialog({super.key, required this.bloc});

  @override
  State<AddGroundDialog> createState() => _AddGroundDialogState();
}

class _AddGroundDialogState extends State<AddGroundDialog> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    widget.bloc.add(
      CreateGroundRequested(
        name: name,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FixtureBloc, FixtureState>(
      bloc: widget.bloc,
      listenWhen: (_, state) =>
          state is FixtureNotice && state.action == 'groundCreated',
      listener: (context, state) {
        if ((state as FixtureNotice).success) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        backgroundColor: const Color(0xFF0F2936),
        title: const Text(
          'Add Ground',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: cricketFieldDecoration('Ground name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: cricketFieldDecoration('Stadium location / city'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            onPressed: _submit,
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
