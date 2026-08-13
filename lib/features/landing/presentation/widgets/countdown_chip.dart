// Countdown Chip
//
// Renders the launch countdown from CountdownBloc state. Purely
// presentation — unidirectional data flow only.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/countdown/countdown_bloc.dart';
import '../landing_palette.dart';

class CountdownChip extends StatelessWidget {
  final String label;

  const CountdownChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountdownBloc, CountdownState>(
      builder: (context, state) {
        if (state.isLive) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: LandingPalette.textTertiary,
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Cell(value: state.days, unit: 'DAYS'),
                  _Dot(),
                  _Cell(value: state.hours, unit: 'HRS'),
                  _Dot(),
                  _Cell(value: state.minutes, unit: 'MIN'),
                  _Dot(),
                  _Cell(value: state.seconds, unit: 'SEC'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  final int value;
  final String unit;

  const _Cell({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: LandingPalette.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LandingPalette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: LandingPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: LandingPalette.textTertiary,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text(
      ':',
      style: TextStyle(
        color: LandingPalette.accent,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
