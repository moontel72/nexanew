// Landing Stats Strip
//
// Horizontal key-figure strip rendered from LandingContent.stats.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';

class StatsStrip extends StatelessWidget {
  final List<LandingStat> stats;

  const StatsStrip({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LandingPalette.surface,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 48,
        runSpacing: 24,
        children: stats
            .map(
              (s) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.value,
                    style: const TextStyle(
                      color: LandingPalette.accent,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    style: const TextStyle(
                      color: LandingPalette.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
