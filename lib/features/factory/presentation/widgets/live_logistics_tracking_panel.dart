import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Compact card showing active inbound trucks, progress, and ETA countdowns.
/// Under 100 lines.
class LiveLogisticsTrackingPanel extends StatelessWidget {
  final int activeTrucks;
  final int arrivingWithin30Min;
  final List<Map<String, dynamic>> shippingLanes;

  const LiveLogisticsTrackingPanel({
    super.key,
    required this.activeTrucks,
    required this.arrivingWithin30Min,
    required this.shippingLanes,
  });

  @override
  Widget build(BuildContext context) {
    final brand = BrandingConfig.forPanel(UserPanel.factory);
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: brand.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: brand.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.local_shipping, color: brand.primaryColor, size: 20.sp),
          Gap(8.w),
          Text('Live Logistics', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          _badge('$activeTrucks active', brand.primaryColor, tt),
          Gap(6.w),
          _badge('$arrivingWithin30Min in 30m', AppColors.success, tt),
        ]),
        Gap(10.h),
        if (shippingLanes.isEmpty)
          Text('No active shipments', style: tt.bodySmall?.copyWith(color: AppColors.gray500))
        else
          ...shippingLanes.take(3).map((lane) => _laneRow(lane, tt)),
      ]),
    );
  }

  Widget _laneRow(Map<String, dynamic> lane, TextTheme tt) {
    final dest = lane['destination']?.toString() ?? '—';
    final driver = lane['driver_name']?.toString() ?? '—';
    final progress = (lane['progress_percent'] as num?)?.toDouble() ?? 0;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(dest, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
          Text('${progress.toInt()}%', style: tt.labelSmall?.copyWith(color: AppColors.gray600)),
        ]),
        Gap(2.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(value: progress / 100, minHeight: 4.h,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(progress > 80 ? AppColors.success : AppColors.warning)),
        ),
        Gap(2.h),
        Text('Driver: $driver', style: tt.labelSmall?.copyWith(color: AppColors.gray500)),
      ]),
    );
  }

  Widget _badge(String text, Color color, TextTheme tt) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6.r)),
    child: Text(text, style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
  );
}
