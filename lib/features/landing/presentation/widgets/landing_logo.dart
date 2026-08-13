// Landing Logo Widget
//
// Renders the Trace Odd golden brand lockup (logo + company name) — the
// SAME asset the Super Admin panel login uses
// (`assets/logo/logo-company-name.svg`). Falls back to a brand icon if
// the SVG asset is unavailable.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../landing_palette.dart';

class LandingLogo extends StatelessWidget {
  /// Asset path from landing JSON meta
  /// (e.g. assets/logo/logo-company-name.svg).
  final String assetPath;

  /// Displayed width; height follows the asset's intrinsic aspect ratio.
  final double width;

  const LandingLogo({super.key, required this.assetPath, this.width = 140});

  @override
  Widget build(BuildContext context) {
    if (assetPath.isEmpty) {
      return Icon(
        Icons.blur_circular,
        color: LandingPalette.accent,
        size: width * 0.6,
      );
    }
    return SvgPicture.asset(
      assetPath,
      width: width,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => Icon(
        Icons.blur_circular,
        color: LandingPalette.accent,
        size: width * 0.6,
      ),
    );
  }
}
