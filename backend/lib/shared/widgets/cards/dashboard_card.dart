import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';

/// A reusable dashboard card widget for displaying KPI metrics.
///
/// Features:
/// - Icon in a tinted circular container
/// - Title and value display
/// - Optional trend indicator with up/down arrow
/// - Optional subtitle for additional context
/// - Tap handling via InkWell
/// - Responsive layout using flutter_screenutil
///
/// Used in GridView layouts with crossAxisCount: 2 and childAspectRatio: 1.5
class DashboardCard extends StatelessWidget {
  /// The title label for the metric
  final String title;

  /// The value to display (should be pre-formatted)
  final String value;

  /// The icon to display in the tinted circle
  final IconData icon;

  /// The color theme for the card (icon, trend indicators)
  final Color color;

  /// Optional numeric trend percentage (positive = up, negative = down)
  final double? trend;

  /// Optional label describing the trend (e.g., 'vs last period')
  final String? trendLabel;

  /// Optional subtitle text for additional context
  final String? subtitle;

  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendLabel,
    this.subtitle,
    this.onTap,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon in tinted circle
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20.w),
                  ),
                  // Trend indicator (if provided)
                  if (trend != null) _buildTrendIndicator(),
                ],
              ),
              // Value and title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    title,
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary.withAlpha(153),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Subtitle (if provided)
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: TextStyles.caption.copyWith(
                        color: AppColors.textPrimary.withAlpha(102),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final bool isPositive = trend! > 0;
    final bool isNeutral = trend == 0;
    final Color trendColor = isNeutral
        ? AppColors.textPrimary.withAlpha(153)
        : isPositive
        ? AppColors.success
        : AppColors.error;
    final IconData trendIcon = isNeutral
        ? Icons.remove
        : isPositive
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trendIcon, color: trendColor, size: 14.w),
        SizedBox(width: 2.w),
        Text(
          '${trend!.abs().toStringAsFixed(1)}%',
          style: TextStyles.caption.copyWith(
            color: trendColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trendLabel != null) ...[
          SizedBox(width: 4.w),
          Text(
            trendLabel!,
            style: TextStyles.caption.copyWith(
              color: AppColors.textPrimary.withAlpha(102),
            ),
          ),
        ],
      ],
    );
  }
}
