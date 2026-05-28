import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Batch status grid with BrandingConfig accents.  Tag states: Processing,
/// Dispatched, Mismatched.  Under 100 lines.
class ProductionThroughputWidget extends StatelessWidget {
  final int activeBatches;
  final int pendingBatches;
  final int dispatchedBatches;
  final int mismatchedBatches;
  final double throughputRate;

  const ProductionThroughputWidget({
    super.key,
    required this.activeBatches,
    required this.pendingBatches,
    required this.dispatchedBatches,
    required this.mismatchedBatches,
    required this.throughputRate,
  });

  @override
  Widget build(BuildContext context) {
    final brand = BrandingConfig.forPanel(UserPanel.factory);
    final tt = Theme.of(context).textTheme;
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
              Icon(Icons.speed, color: brand.primaryColor, size: 20.sp),
              Gap(8.w),
              Text(
                'Production Throughput',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${throughputRate.toStringAsFixed(0)} u/h',
                style: tt.labelMedium?.copyWith(
                  color: brand.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            children: [
              _statCell('Processing', activeBatches, brand.primaryColor, tt),
              Gap(8.w),
              _statCell('Pending', pendingBatches, AppColors.warning, tt),
              Gap(8.w),
              _statCell('Dispatched', dispatchedBatches, AppColors.success, tt),
              Gap(8.w),
              _statCell(
                'Mismatched',
                mismatchedBatches,
                mismatchedBatches > 0 ? AppColors.error : AppColors.gray400,
                tt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, int value, Color color, TextTheme tt) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(
                '$value',
                style: tt.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Gap(2.h),
              Text(label, style: tt.labelSmall?.copyWith(color: color)),
            ],
          ),
        ),
      );
}
