// Trace Odd — canonical brand lockup (golden badge + company name).
//
// The canonical badge asset carries NO wordmark, so this widget renders
// the "TRACE ODD" name OUTSIDE the logo in the brand's own palette. All
// defaults come from `TraceOddBrandTokens` (single source of truth) and
// every value can be overridden per context — nothing is hardcoded at the
// call site.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace_odd/shared/theme/traceodd_brand_tokens.dart';

class TraceOddBrand extends StatelessWidget {
  const TraceOddBrand({
    super.key,
    this.assetPath = TraceOddBrandTokens.logoAsset,
    this.name = TraceOddBrandTokens.companyName,
    this.badgeSize = 120,
    this.nameSize = 30,
    this.nameColor = TraceOddBrandTokens.gold,
    this.direction = Axis.vertical,
    this.gap = 14,
    this.nameSpacing = 8,
  });

  /// Badge asset (defaults to the canonical golden badge).
  final String assetPath;

  /// Company name shown next to / below the badge.
  final String name;

  /// Badge width/height (the badge is square).
  final double badgeSize;

  /// Font size for the wordmark.
  final double nameSize;

  /// Wordmark colour (defaults to the badge's own gold).
  final Color nameColor;

  /// Stacked (vertical) or side-by-side (horizontal) layout.
  final Axis direction;

  /// Spacing between badge and name.
  final double gap;

  /// Letter spacing for the wordmark.
  final double nameSpacing;

  @override
  Widget build(BuildContext context) {
    final badge = SvgPicture.asset(
      assetPath,
      width: badgeSize,
      height: badgeSize,
    );
    final nameText = Text(
      name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: nameSize,
        fontWeight: FontWeight.w900,
        letterSpacing: nameSpacing,
        height: 1.1,
        color: nameColor,
      ),
    );

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          SizedBox(width: gap),
          nameText,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        SizedBox(height: gap),
        nameText,
      ],
    );
  }
}
