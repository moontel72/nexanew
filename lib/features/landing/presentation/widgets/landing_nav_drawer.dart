// Landing Nav Drawer
//
// Collapsible mobile navigation (hamburger menu) rendered from the same
// JSON nav links as the desktop bar. Used as the Scaffold endDrawer on
// compact viewports (<768px). All labels come from LandingContent.nav.

import 'package:flutter/material.dart';

import '../../data/models/landing_content.dart';
import '../landing_palette.dart';
import 'landing_anchors.dart';
import 'landing_logo.dart';

class LandingNavDrawer extends StatelessWidget {
  final LandingMeta meta;
  final List<LandingNavLink> nav;
  final String ctaLabel;

  const LandingNavDrawer({
    super.key,
    required this.meta,
    required this.nav,
    required this.ctaLabel,
  });

  void _goTo(BuildContext context, String anchor) {
    Navigator.of(context).pop();
    LandingAnchors.scrollTo(LandingAnchors.forName(anchor));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: LandingPalette.surface,
      width: 300,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                children: [
                  LandingLogo(assetPath: meta.logoAsset, width: 108),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close menu',
                    icon: const Icon(
                      Icons.close,
                      color: LandingPalette.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: LandingPalette.border, height: 1),
            const SizedBox(height: 8),
            for (final link in nav)
              ListTile(
                leading: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: LandingPalette.accent,
                ),
                title: Text(
                  link.label,
                  style: const TextStyle(
                    color: LandingPalette.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () => _goTo(context, link.anchor),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: LandingPalette.accent,
                  foregroundColor: LandingPalette.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                onPressed: () => _goTo(context, 'signup'),
                child: Text(ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
