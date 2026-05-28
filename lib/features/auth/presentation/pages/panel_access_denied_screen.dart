import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/core/navigation/route_guard_middleware.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_event.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class PanelAccessDeniedScreen extends StatelessWidget {
  const PanelAccessDeniedScreen({super.key});

  static final _rowStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
  );
  static final _valStyle = TextStyle(fontSize: 14.sp, color: AppColors.gray800);

  Widget _row(IconData i, String l, String v) => Row(
    children: [
      Icon(i, size: 18.sp, color: AppColors.gray600),
      Gap(8.w),
      Text('$l: ', style: _rowStyle),
      Expanded(child: Text(v, style: _valStyle)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final p = PanelAccessGuard.deniedPanel ?? UserPanel.factory;
    final a = PanelAccessGuard.actualDriverType ?? 'unknown';
    final r = PanelAccessGuard.requiredDriverType ?? 'unknown';
    final b = BrandingConfig.forPanel(p);
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.error.withValues(alpha: 0.06), Colors.white],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Gap(16.h),
                    Text(
                      b.enterpriseTitle,
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      'Access Denied',
                      style: tt.titleLarge?.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _row(Icons.badge_outlined, 'Your role', a),
                          Gap(8.h),
                          _row(Icons.lock_outline, 'Required', r),
                          Gap(8.h),
                          _row(Icons.domain, 'Panel', p.label),
                        ],
                      ),
                    ),
                    Gap(32.h),
                    Text(
                      'Your credentials do not permit access to the ${p.label} '
                      'panel. Please sign out and log in with the correct account type.',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(color: AppColors.gray600),
                    ),
                    Gap(24.h),
                    PrimaryButton(
                      text: 'Sign Out & Return to Login',
                      backgroundColor: AppColors.error,
                      onPressed: () {
                        PanelAccessGuard.clear();
                        context.read<PanelAuthBloc>().add(
                          PanelLogoutRequested(panel: p),
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          switch (p) {
                            UserPanel.superAdmin => '/login',
                            UserPanel.factory => '/factory/login',
                            UserPanel.marketplace => '/reseller/login',
                            UserPanel.truckFleet ||
                            UserPanel.busFleet => '/driver/login',
                            UserPanel.customer => '/login',
                          },
                          (_) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
