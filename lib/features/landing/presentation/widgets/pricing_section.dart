// Pricing Section
//
// IoT subscription tiers rendered dynamically from LandingPricing.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';

class PricingSection extends StatelessWidget {
  final LandingPricing pricing;

  const PricingSection({super.key, required this.pricing});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      color: LandingPalette.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Column(
        children: [
          Text(
            pricing.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPalette.accent,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              pricing.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LandingPalette.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 3 : 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: wide ? 0.95 : 1.35,
            ),
            itemCount: pricing.tiers.length,
            itemBuilder: (context, i) => _TierCard(tier: pricing.tiers[i]),
          ),
          const SizedBox(height: 20),
          Text(
            pricing.note,
            style: const TextStyle(
              color: LandingPalette.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final LandingPricingTier tier;

  const _TierCard({required this.tier});

  @override
  Widget build(BuildContext context) {
    final highlight = tier.highlight;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: highlight
            ? LandingPalette.surfaceElevated
            : LandingPalette.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? LandingPalette.accent : LandingPalette.border,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tier.name,
                style: const TextStyle(
                  color: LandingPalette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (highlight)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: LandingPalette.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: LandingPalette.background,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tier.device,
            style: const TextStyle(
              color: LandingPalette.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tier.price,
            style: const TextStyle(
              color: LandingPalette.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            tier.period,
            style: const TextStyle(
              color: LandingPalette.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ...tier.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: LandingPalette.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        color: LandingPalette.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
