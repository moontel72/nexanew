// Landing Hero Section
//
// Full-viewport brand hero: announcement badge, headline, subheadline,
// countdown, and dual CTAs. All copy from LandingHero in the JSON.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';
import 'countdown_chip.dart';
import 'landing_anchors.dart';
import 'landing_logo.dart';

class HeroSection extends StatelessWidget {
  final LandingHero hero;
  final String announcementBadge;
  final String logoAsset;

  const HeroSection({
    super.key,
    required this.hero,
    required this.announcementBadge,
    required this.logoAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: LandingPalette.heroGradient,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LandingLogo(assetPath: logoAsset, width: 260),
          const SizedBox(height: 28),
          _Badge(text: announcementBadge),
          const SizedBox(height: 28),
          Text(
            hero.eyebrow,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPalette.accent,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            hero.headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPalette.textPrimary,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              hero.subheadline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LandingPalette.textSecondary,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 36),
          CountdownChip(label: hero.countdownLabel),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: LandingPalette.accent,
                  foregroundColor: LandingPalette.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                onPressed: () => LandingAnchors.scrollTo(LandingAnchors.signup),
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(hero.primaryCta),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: LandingPalette.textPrimary,
                  side: const BorderSide(color: LandingPalette.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                onPressed: () =>
                    LandingAnchors.scrollTo(LandingAnchors.verticals),
                icon: const Icon(Icons.arrow_downward),
                label: Text(hero.secondaryCta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: LandingPalette.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LandingPalette.accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.rocket_launch,
            color: LandingPalette.accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: LandingPalette.accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
