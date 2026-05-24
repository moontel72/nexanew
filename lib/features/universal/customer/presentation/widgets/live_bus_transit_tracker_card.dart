import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nexatrace_system/core/navigation/panel_routes.dart';
import 'package:nexatrace_system/core/theme/branding_config.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

/// Live bus progress card with driver name, ETA, and progress bar from
/// WebSocket busFleetGps stream.  Under 100 lines.
class LiveBusTransitTrackerCard extends StatelessWidget {
  final String? operatorName;
  final String? driverName;
  final String? nextStop;
  final int? etaMinutes;
  final double? progressPercent;
  final double? speedKmph;

  const LiveBusTransitTrackerCard({
    super.key,
    this.operatorName,
    this.driverName,
    this.nextStop,
    this.etaMinutes,
    this.progressPercent,
    this.speedKmph,
  });

  @override
  Widget build(BuildContext context) {
    final brand = BrandingConfig.forPanel(UserPanel.customer);
    final tt = Theme.of(context).textTheme;
    final progress = (progressPercent ?? 0).clamp(0, 100);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: brand.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: brand.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: brand.primaryColor,
                size: 20.sp,
              ),
              Gap(8.w),
              Text(
                operatorName ?? 'Live Transit',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (speedKmph != null)
                Text(
                  '${speedKmph!.toInt()} km/h',
                  style: tt.labelSmall?.copyWith(color: AppColors.gray600),
                ),
            ],
          ),
          Gap(10.h),
          if (driverName != null) _row('Driver', driverName!, tt),
          if (nextStop != null) _row('Next Stop', nextStop!, tt),
          if (etaMinutes != null) _row('ETA', '$etaMinutes min', tt),
          Gap(8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6.h,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 70 ? AppColors.success : brand.primaryColor,
              ),
            ),
          ),
          Gap(4.h),
          Text(
            '${progress.toInt()}% complete',
            style: tt.labelSmall?.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, TextTheme tt) => Padding(
    padding: EdgeInsets.only(bottom: 3.h),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: tt.bodySmall?.copyWith(
            color: AppColors.gray600,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(value, style: tt.bodySmall?.copyWith(color: AppColors.gray800)),
      ],
    ),
  );
}
