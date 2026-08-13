// Verticals Section
//
// Renders all 7 ecosystem verticals as accent-coded feature cards.
// Every field (tag, title, headline, copy, features, icon, accent color)
// comes from the LandingVertical models parsed out of the JSON.
//
// Layout: fluid — cards size to their natural content height inside a
// Wrap with explicit run spacing, so stacked cards can NEVER overlap or
// clip each other on any viewport.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';
import 'landing_icons.dart';

class VerticalsSection extends StatelessWidget {
  final List<LandingVertical> verticals;

  const VerticalsSection({super.key, required this.verticals});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LandingPalette.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THE ECOSYSTEM',
            style: TextStyle(
              color: LandingPalette.accent,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Seven Verticals. One Trace Odd.',
            style: TextStyle(
              color: LandingPalette.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              final cardWidth = wide
                  ? (constraints.maxWidth - 24) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 24,
                runSpacing: 28,
                children: [
                  for (final v in verticals)
                    SizedBox(
                      width: cardWidth,
                      child: _VerticalCard(v: v),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VerticalCard extends StatelessWidget {
  final LandingVertical v;

  const _VerticalCard({required this.v});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LandingPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LandingPalette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: v.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LandingIcons.forKey(v.icon),
                  color: v.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.tag,
                      style: TextStyle(
                        color: v.accent,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      v.title,
                      style: const TextStyle(
                        color: LandingPalette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            v.headline,
            style: const TextStyle(
              color: LandingPalette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            v.copy,
            style: const TextStyle(
              color: LandingPalette.textSecondary,
              fontSize: 12.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: v.features
                .map(
                  (f) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: LandingPalette.surfaceElevated,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1.5),
                          child: Icon(
                            Icons.check_circle,
                            color: v.accent,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            f,
                            softWrap: true,
                            style: const TextStyle(
                              color: LandingPalette.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
