// Roadmap Section
//
// Launch phases rendered dynamically from LandingRoadmap.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';

class RoadmapSection extends StatelessWidget {
  final LandingRoadmap roadmap;

  const RoadmapSection({super.key, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LandingPalette.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Column(
        children: [
          Text(
            roadmap.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPalette.accent,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            roadmap.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPalette.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              for (var i = 0; i < roadmap.phases.length; i++) ...[
                _PhaseRow(index: i, phase: roadmap.phases[i]),
                if (i < roadmap.phases.length - 1)
                  Container(width: 2, height: 34, color: LandingPalette.border),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseRow extends StatelessWidget {
  final int index;
  final LandingRoadmapPhase phase;

  const _PhaseRow({required this.index, required this.phase});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LandingPalette.surfaceElevated,
            border: Border.all(color: LandingPalette.accent),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: LandingPalette.accent,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: LandingPalette.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LandingPalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.phase.toUpperCase(),
                  style: const TextStyle(
                    color: LandingPalette.textTertiary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phase.title,
                  style: const TextStyle(
                    color: LandingPalette.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  phase.detail,
                  style: const TextStyle(
                    color: LandingPalette.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
