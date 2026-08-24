// Landing Footer
//
// Dynamic footer rendered from LandingFooter in the JSON.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/brand/traceodd_brand.dart';
import '../../data/models/landing_content.dart' as models;
import '../landing_palette.dart';

class LandingFooterSection extends StatelessWidget {
  final models.LandingFooter footer;
  final String logoAsset;

  const LandingFooterSection({
    super.key,
    required this.footer,
    required this.logoAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LandingPalette.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          TraceOddBrand(
            assetPath: logoAsset,
            badgeSize: 120,
            nameSize: 24,
            gap: 14,
          ),
          const SizedBox(height: 18),
          Text(
            footer.tagline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPalette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _open('mailto:${footer.contactEmail}'),
                icon: const Icon(
                  Icons.mail_outline,
                  size: 16,
                  color: LandingPalette.accent,
                ),
                label: Text(
                  '${footer.contactLabel} — ${footer.contactEmail}',
                  style: const TextStyle(
                    color: LandingPalette.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              ...footer.links.map(
                (l) => TextButton(
                  onPressed: () => _open(l.url),
                  child: Text(
                    l.label,
                    style: const TextStyle(
                      color: LandingPalette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: LandingPalette.border),
          const SizedBox(height: 18),
          Text(
            footer.copyright,
            style: const TextStyle(
              color: LandingPalette.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Non-web platforms without url handling — ignore.
    }
  }
}
