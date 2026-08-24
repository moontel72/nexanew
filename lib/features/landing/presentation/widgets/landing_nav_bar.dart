// Landing Top Nav Bar
//
// Fully responsive:
//   * width >= 768px: logo + horizontal nav links (wrapped, can never
//     overflow the right edge).
//   * width <  768px: logo + hamburger button that opens the Scaffold
//     endDrawer (LandingNavDrawer).
//
// Nav links render dynamically from LandingContent.nav. Anchor clicks
// scroll to their registered section keys. Stateless, no setState.

import 'package:flutter/material.dart';

import '../../../../shared/widgets/brand/traceodd_brand.dart';
import '../../data/models/landing_content.dart';
import '../landing_palette.dart';
import 'landing_anchors.dart';

class LandingNavBar extends StatelessWidget {
  final LandingMeta meta;
  final List<LandingNavLink> links;

  const LandingNavBar({super.key, required this.meta, required this.links});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LandingPalette.background.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 768;
          return Row(
            children: [
              TraceOddBrand(
                assetPath: meta.logoAsset,
                badgeSize: isCompact ? 40 : 44,
                nameSize: isCompact ? 16 : 18,
                direction: Axis.horizontal,
                gap: 10,
                nameSpacing: 4,
              ),
              const Spacer(),
              if (isCompact)
                IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(
                    Icons.menu,
                    color: LandingPalette.textPrimary,
                    size: 28,
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                )
              else
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final link in links)
                      TextButton(
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
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
