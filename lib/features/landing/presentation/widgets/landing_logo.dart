// Landing Logo Widget
//
// Renders the Trace Odd golden badge — the SINGLE canonical brand asset
// (`assets/logo/traceodd_logo.svg`), shared by the Super Admin login,
// the admin sidebar and the landing hero. Falls back to a brand icon if
// the SVG asset is unavailable.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../landing_palette.dart';

class LandingLogo extends StatelessWidget {
  /// Asset path from landing JSON meta
  /// (e.g. assets/logo/traceodd_logo.svg).
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
