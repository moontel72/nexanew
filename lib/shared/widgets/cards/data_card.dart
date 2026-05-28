import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

/// A reusable data card widget for displaying statistics and metrics.
///
/// Features:
/// - Icon displayed in a color-tinted container with 0.1 alpha background
/// - Title label for the metric name
/// - Value prominently displayed in bold headline style
/// - Optional subtitle for additional context
/// - Tap handling via InkWell with ripple effect
/// - Responsive layout using flutter_screenutil
///
/// Used in super admin panel for displaying data/statistics cards.
class DataCard extends StatelessWidget {
  /// The title label for the data metric
  final String title;

  /// The value to display (should be pre-formatted)
  final String value;

  /// The icon to display in the tinted container
  final IconData icon;

  /// The color theme for the card (icon and tinted background)
  final Color color;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  /// Optional subtitle text for additional context
  final String? subtitle;

  const DataCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon in tinted container
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 22.w),
              ),
              SizedBox(height: 12.h),

              // Value - prominently displayed
              Text(
                value,
                style: TextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),

              // Title
              Text(
                title,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Subtitle (optional)
              if (subtitle != null) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle!,
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
