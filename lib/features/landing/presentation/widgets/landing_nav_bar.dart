// Landing Top Nav Bar
//
// Renders nav links dynamically from LandingContent.nav. Anchor clicks
// scroll to their registered section keys. No state, no setState.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';
import 'landing_anchors.dart';
import 'landing_logo.dart';

class LandingNavBar extends StatelessWidget {
  final LandingMeta meta;
  final List<LandingNavLink> links;

  const LandingNavBar({super.key, required this.meta, required this.links});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LandingPalette.background.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          LandingLogo(
            assetPath: meta.logoAsset,
            size: 34,
            wordmark: meta.logoText,
          ),
          const Spacer(),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                onPressed: () => LandingAnchors.scrollTo(
                  LandingAnchors.forName(link.anchor),
                ),
                child: Text(
                  link.label,
                  style: const TextStyle(
                    color: LandingPalette.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
