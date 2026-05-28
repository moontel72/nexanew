import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/shared/theme/colors.dart';

/// High-visibility alert terminal for counterfeit scans or geo-diversions
/// inside the factory tenant perimeter.  Under 100 lines.
class IsolatedFactoryAlertTerminal extends StatelessWidget {
  final bool hasCounterfeitAlert;
  final Map<String, dynamic>? counterfeitPayload;
  final bool hasGeoDiversionAlert;
  final Map<String, dynamic>? geoDiversionPayload;
  final VoidCallback? onDismiss;

  const IsolatedFactoryAlertTerminal({
    super.key,
    this.hasCounterfeitAlert = false,
    this.counterfeitPayload,
    this.hasGeoDiversionAlert = false,
    this.geoDiversionPayload,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasCounterfeitAlert && !hasGeoDiversionAlert)
      return const SizedBox.shrink();
    final brand = BrandingConfig.forPanel(UserPanel.factory);
    final tt = Theme.of(context).textTheme;
    final isCounterfeit = hasCounterfeitAlert;
    final alertColor = isCounterfeit ? AppColors.error : AppColors.warning;
    final title = isCounterfeit
        ? '⚠ COUNTERFEIT SCAN DETECTED'
        : '⚠ GEO-DIVERSION ALERT';
    String serial;
    if (isCounterfeit) {
      serial = counterfeitPayload?['serial']?.toString() ?? '—';
    } else {
      serial = geoDiversionPayload?['driver_id']?.toString() ?? '—';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: alertColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: alertColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gpp_maybe, color: alertColor, size: 22.sp),
              Gap(8.w),
              Expanded(
                child: Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    color: alertColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: AppColors.gray500,
                  ),
                ),
            ],
          ),
          Gap(8.h),
          Text(
            'Tenant: ${brand.enterpriseTitle}',
            style: tt.bodySmall?.copyWith(color: AppColors.gray600),
          ),
          Gap(4.h),
          Text(
            isCounterfeit ? 'Fake Serial: $serial' : 'Driver: $serial',
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray800,
            ),
          ),
          Gap(4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Routed via Secure WebSocket Grid',
              style: tt.labelSmall?.copyWith(
                color: alertColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
