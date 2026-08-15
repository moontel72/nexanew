import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/dls_calculator/dls_calculator_bloc.dart';

/// Phase 5 — DLS calculator tool (manager panel).
///
/// Simplified Duckworth-Lewis-Stern style target adjustments for
/// rain-interrupted matches. Fully BLoC-driven — every input is a bloc
/// event and the result is derived from state (no setState).
class DlsCalculatorPage extends StatelessWidget {
  const DlsCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('DLS Calculator'),
        backgroundColor: CricketColors.surface,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DlsCalculatorBloc, DlsCalculatorState>(
        builder: (context, state) {
          final s = state as DlsCalculatorReady;
          final result = s.result;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CricketColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Advisory simplified DLS (exponential resource model). '
                  'Does not include the proprietary ICC tables or '
                  'wicket-resource adjustments.',
                  style: TextStyle(
                    color: CricketColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _OversDropdown(
                label: 'Format (overs per side)',
                value: s.oversPerSide,
                max: 50,
                onChanged: (v) =>
                    context.read<DlsCalculatorBloc>().add(SetOversPerSide(v)),
              ),
              const SizedBox(height: 12),
              _NumberField(
                label: 'Team 1 score',
                value: s.team1Score,
                onChanged: (v) =>
                    context.read<DlsCalculatorBloc>().add(SetTeam1Score(v)),
              ),
              const SizedBox(height: 20),
              const Text(
                'TEAM 1 INNINGS INTERRUPTION (optional)',
                style: TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _OversDropdown(
                      label: 'Overs left at rain',
                      value: s.team1StopOversRemaining,
                      max: s.oversPerSide,
                      onChanged: (v) => context.read<DlsCalculatorBloc>().add(
                        SetTeam1Stop(v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OversDropdown(
                      label: 'Overs left at resume',
                      value: s.team1ResumeOversRemaining,
                      max: s.team1StopOversRemaining,
                      onChanged: (v) => context.read<DlsCalculatorBloc>().add(
                        SetTeam1Resume(v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'TEAM 2 INNINGS INTERRUPTION (optional)',
                style: TextStyle(
                  color: CricketColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _OversDropdown(
                      label: 'Overs left at rain',
                      value: s.team2StopOversRemaining,
                      max: s.oversPerSide,
                      onChanged: (v) => context.read<DlsCalculatorBloc>().add(
                        SetTeam2Stop(v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OversDropdown(
                      label: 'Overs left at resume',
                      value: s.team2ResumeOversRemaining,
                      max: s.team2StopOversRemaining,
                      onChanged: (v) => context.read<DlsCalculatorBloc>().add(
                        SetTeam2Resume(v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CricketColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CricketColors.textAccent.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultStat(
                          label: 'TEAM 1 RESOURCES',
                          value:
                              '${result.team1ResourcesPercent.toStringAsFixed(1)}%',
                        ),
                        _ResultStat(
                          label: 'TEAM 2 RESOURCES',
                          value:
                              '${result.team2ResourcesPercent.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultStat(
                          label: 'PAR SCORE',
                          value: '${result.parScore}',
                          color: CricketColors.textAccent,
                        ),
                        _ResultStat(
                          label: 'TARGET',
                          value: '${result.target}',
                          color: CricketColors.complete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OversDropdown extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final void Function(int) onChanged;

  const _OversDropdown({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: const Color(0xFF0F2936),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFBDD8DB)),
        filled: true,
        fillColor: const Color(0xFF0F2936),
      ),
      items: [
        for (var v = 0; v <= max; v++)
          DropdownMenuItem(value: v, child: Text('$v overs')),
      ],
      onChanged: (v) => onChanged(v ?? 0),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final void Function(int) onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: '$value',
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFBDD8DB)),
        filled: true,
        fillColor: const Color(0xFF0F2936),
      ),
      onChanged: (v) {
        final parsed = int.tryParse(v.trim());
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _ResultStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CricketColors.textSecondary,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? CricketColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
