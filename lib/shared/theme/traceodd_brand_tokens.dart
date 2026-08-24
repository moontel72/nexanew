// Trace Odd — SINGLE source of truth for brand assets and colours.
//
// Every app / panel / widget must read the logo path, company name and
// brand palette from here — never hardcode them inline. The golden badge
// asset carries NO wordmark; the name is rendered by `TraceOddBrand`
// (shared/widgets/brand/traceodd_brand.dart).

import 'package:flutter/material.dart';

abstract final class TraceOddBrandTokens {
  /// Canonical badge asset (logo-only, square viewBox).
  static const String logoAsset = 'assets/logo/traceodd_logo.svg';

  /// Company name rendered OUTSIDE the logo.
  static const String companyName = 'TRACE ODD';

  /// Badge gold: rgb(137, 101, 18).
  static const Color gold = Color(0xFF896512);

  /// Lighter gold for use on dark surfaces.
  static const Color goldLight = Color(0xFFC9A24B);

  /// Badge cream / off-white: rgb(253, 252, 249).
  static const Color cream = Color(0xFFFDFCF9);

  /// Brand dark surface: rgb(10, 14, 33).
  static const Color dark = Color(0xFF0A0E21);
}
