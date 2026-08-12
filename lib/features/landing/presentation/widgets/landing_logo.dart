// Landing Logo Widget
//
// Renders the Trace Odd "T-Odd" brand mark (same SVG asset used across
// the Super Admin panel branding). Falls back to a brand icon if the SVG
// asset is unavailable.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../landing_palette.dart';

class LandingLogo extends StatelessWidget {
  /// Asset path from landing JSON meta (e.g. assets/logo/traceodd_logo.svg).
  final String assetPath;

  /// Displayed size (width == height).
  final double size;

  /// Whether to show the brand wordmark next to the logo mark.
  final bool showWordmark;

  /// Wordmark text from landing JSON meta.
  final String? wordmark;

  const LandingLogo({
    super.key,
    required this.assetPath,
    this.size = 40,
    this.showWordmark = true,
    this.wordmark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.08),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: assetPath.isEmpty
              ? Icon(
                  Icons.blur_circular,
                  color: LandingPalette.accent,
                  size: size * 0.7,
                )
              : SvgPicture.asset(
                  assetPath,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => Icon(
                    Icons.blur_circular,
                    color: LandingPalette.accent,
                    size: size * 0.7,
                  ),
                ),
        ),
        if (showWordmark && wordmark != null && wordmark!.isNotEmpty) ...[
          SizedBox(width: size * 0.3),
          Text(
            wordmark!,
            style: TextStyle(
              color: LandingPalette.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: size * 0.42,
            ),
          ),
        ],
      ],
    );
  }
}
