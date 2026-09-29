import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Marketplace public site — its own brand palette.
///
/// Deliberately separate from the panels' `AppColors`: this is a customer-facing
/// storefront, not an admin console. Deep ink for text, vivid indigo as the
/// brand, coral for prices/CTAs and teal as the secondary highlight.
class MpColors {
  MpColors._();

  // Text
  static const ink = Color(0xFF0B1220);
  static const inkSoft = Color(0xFF55657A);
  static const inkFaint = Color(0xFF8C99A8);

  // Brand
  static const indigo = Color(0xFF4F46E5);
  static const indigoDark = Color(0xFF312E81);
  static const teal = Color(0xFF0FB5A6);
  static const coral = Color(0xFFFF5230);
  static const amber = Color(0xFFFFB020);

  // Surfaces
  static const bg = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF2F9);
  static const border = Color(0xFFE3E9F2);

  /// Hero / header gradient.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF0FB5A6)],
  );

  /// Subtle gradient used behind product images that have no photo yet.
  static const placeholderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8ECFB), Color(0xFFE3F6F4)],
  );
}

/// Theme for the standalone public marketplace app.
ThemeData marketplaceTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MpColors.indigo,
      primary: MpColors.indigo,
      secondary: MpColors.teal,
      surface: MpColors.surface,
    ),
    scaffoldBackgroundColor: MpColors.bg,
  );

  return base.copyWith(
    // A modern geometric sans reads as "newer than Alibaba" on a storefront.
    // google_fonts falls back to the platform font if the CDN is unreachable.
    textTheme: GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: MpColors.ink, displayColor: MpColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: MpColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
