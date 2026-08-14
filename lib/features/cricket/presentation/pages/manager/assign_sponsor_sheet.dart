import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../widgets/cricket_lookups.dart';
import '../../widgets/cricket_top_sheet.dart';
import '../../widgets/sponsor_lookups.dart';

/// Assign a library sponsor to a match at a specific placement.
/// Sponsors already assigned to this match are excluded from the list.
class AssignSponsorSheet extends StatefulWidget {
  final String matchId;
  const AssignSponsorSheet({super.key, required this.matchId});

  @override
  State<AssignSponsorSheet> createState() => _AssignSponsorSheetState();
}

class _AssignSponsorSheetState extends State<AssignSponsorSheet> {
  final _sponsor = ValueNotifier<String?>(null);
  final _placement = ValueNotifier<String>('scoreboard_top');
  late final TextEditingController _orderCtrl;

  @override
  void initState() {
    super.initState();
    _orderCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _sponsor.dispose();
    _placement.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final sponsorId = _sponsor.value;
    if (sponsorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a sponsor.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    context.read<SponsorBloc>().add(
      AssignSponsorRequested(
        matchId: widget.matchId,
        sponsorId: sponsorId,
        placement: _placement.value,
        displayOrder: int.tryParse(_orderCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SponsorBloc, SponsorState>(
      listenWhen: (_, state) =>
          state is SponsorNotice &&
          state.action == 'assignSponsor' &&
          state.success,
      listener: (context, state) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: BlocBuilder<SponsorBloc, SponsorState>(
            builder: (context, state) {
              if (state is! SponsorLoaded) {
                return const Center(child: CircularProgressIndicator());
              }
              final assignedIds = state.sponsors.map((s) => s.id).toSet();
              final available = state.library
                  .where((s) => !assignedIds.contains(s.id))
                  .toList();

              final selectedValid = available.any(
                (s) => s.id == _sponsor.value,
              );
              final effective = selectedValid ? _sponsor.value : null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CricketSheetHeader(title: 'Assign Sponsor'),
                  const SizedBox(height: 8),
                  if (available.isEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Every sponsor in your library is already assigned to '
                      'this match. Add more sponsors first.',
                      style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CLOSE'),
                    ),
                  ] else ...[
                    ValueListenableBuilder<String?>(
                      valueListenable: _sponsor,
                      builder: (context, value, _) =>
                          DropdownButtonFormField<String?>(
                            value: effective,
                            isExpanded: true,
                            decoration: cricketFieldDecoration('Sponsor *'),
                            dropdownColor: const Color(0xFF0F2936),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Select sponsor',
                                  style: TextStyle(color: Color(0xFF6B7280)),
                                ),
                              ),
                              ...available.map(
                                (s) => DropdownMenuItem<String?>(
                                  value: s.id,
                                  child: Text(
                                    '${sponsorTierLabel(s.tier)} · ${s.name}',
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) => _sponsor.value = v,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<String>(
                      valueListenable: _placement,
                      builder: (context, value, _) =>
                          DropdownButtonFormField<String>(
                            value: value,
                            isExpanded: true,
                            decoration: cricketFieldDecoration('Placement'),
                            dropdownColor: const Color(0xFF0F2936),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            items: sponsorPlacements
                                .map(
                                  (p) => DropdownMenuItem<String>(
                                    value: p,
                                    child: Text(
                                      sponsorPlacementLabel(p),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                _placement.value = v ?? 'scoreboard_top',
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _orderCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: cricketFieldDecoration(
                        'Display order (0 = first)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.campaign),
                      label: const Text('ASSIGN TO MATCH'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submit,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
