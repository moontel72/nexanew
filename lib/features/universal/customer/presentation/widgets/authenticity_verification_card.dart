import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// Premium scan result card — emerald shield for authentic, red alert for fake.
/// Under 100 lines.
class AuthenticityVerificationCard extends StatelessWidget {
  final bool isAuthentic;
  final String? serialNumber;
  final int rewardPoints;
  final int totalScans;

  const AuthenticityVerificationCard({
    super.key,
    required this.isAuthentic,
    this.serialNumber,
    required this.rewardPoints,
    required this.totalScans,
  });

  @override
  Widget build(BuildContext context) {
    final brand = BrandingConfig.forPanel(UserPanel.customer);
    final tt = Theme.of(context).textTheme;
    final color = isAuthentic ? AppColors.success : AppColors.error;
    final icon = isAuthentic ? Icons.verified_user : Icons.gpp_maybe;
    final title = isAuthentic ? 'AUTHENTIC PRODUCT' : 'COUNTERFEIT DETECTED';
    final subtitle = isAuthentic
        ? 'Verified by NexaTrace Vault'
        : 'This product is not registered in the NexaTrace system';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 44.sp, color: color),
          Gap(8.h),
          Text(
            title,
            style: tt.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Gap(4.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: AppColors.gray600),
          ),
          if (serialNumber != null) ...[
            Gap(8.h),
            Text(
              'Serial: ${serialNumber!.length > 24 ? '${serialNumber!.substring(0, 24)}...' : serialNumber!}',
              style: tt.labelSmall?.copyWith(
                color: AppColors.gray500,
                fontFamily: 'monospace',
              ),
            ),
          ],
          Gap(10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _badge('⭐ $rewardPoints pts', brand.primaryColor, tt),
              Gap(10.w),
              _badge('🔍 $totalScans scans', AppColors.gray600, tt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color, TextTheme tt) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      text,
      style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
    ),
  );
}
