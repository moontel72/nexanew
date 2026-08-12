// Landing Page Palette
//
// Dark premium brand palette for the www.traceodd.com single-page site.
// Base tokens are borrowed from the shared theme (AppColors.secondary mint
// accent); landing-specific tokens live here so shared theme files stay
// untouched.

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class LandingPalette {
  LandingPalette._();

  // Backgrounds
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF141829);
  static const Color surfaceElevated = Color(0xFF1E2238);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0AAB8);
  static const Color textTertiary = Color(0xFF6B7280);

  // Accents (shared brand)
  static const Color accent = AppColors.secondary; // Mint #00C49F
  static const Color accentDark = AppColors.secondaryDark;
  static const Color highlight = AppColors.accent; // Orange #FF9900

  // Borders / inputs
  static const Color border = Color(0xFF2A2E41);
  static const Color inputFill = Color(0xFF1A1E31);

  static const List<Color> heroGradient = [
    Color(0xFF0A0E21),
    Color(0xFF0F2A33),
    Color(0xFF0A0E21),
  ];
}
