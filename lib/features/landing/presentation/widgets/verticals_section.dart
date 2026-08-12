// Verticals Section
//
// Renders all 7 ecosystem verticals as accent-coded feature cards.
// Every field (tag, title, headline, copy, features, icon, accent color)
// comes from the LandingVertical models parsed out of the JSON.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';
import 'landing_icons.dart';

class VerticalsSection extends StatelessWidget {
  final List<LandingVertical> verticals;

  const VerticalsSection({super.key, required this.verticals});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      color: LandingPalette.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 2 : 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: wide ? 1.55 : 1.05,
            ),
            itemCount: verticals.length,
            itemBuilder: (context, i) => _VerticalCard(v: verticals[i]),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          Expanded(
            child: Text(
              v.copy,
              style: const TextStyle(
                color: LandingPalette.textSecondary,
                fontSize: 12.5,
                height: 1.55,
              ),
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
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: LandingPalette.surfaceElevated,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: v.accent, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          f,
                          style: const TextStyle(
                            color: LandingPalette.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
