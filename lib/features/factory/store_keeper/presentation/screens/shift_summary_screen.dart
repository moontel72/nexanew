import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';
import 'package:trace_odd/shared/widgets/cards/dashboard_card.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class ShiftSummaryScreen extends StatefulWidget {
  const ShiftSummaryScreen({super.key});
  @override
  State<ShiftSummaryScreen> createState() => _ShiftSummaryScreenState();
}

class _ShiftSummaryScreenState extends State<ShiftSummaryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StoreKeeperBloc>().add(RefreshDashboardStats());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Shift Summary'),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.home), onPressed: () => context.go('/factory/store-keeper/dashboard')),
    ),
    body: BlocBuilder<StoreKeeperBloc, StoreKeeperState>(
      builder: (context, state) {
        if (state is! StoreKeeperAuthenticated)
          return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                color: AppColors.accent,
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_turned_in,
                        size: 48.w,
                        color: Colors.white,
                      ),
                      Gap(12.h),
                      Text(
                        'Shift Summary',
                        style: TextStyles.heading5.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(24.h),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.5,
                children: [
                  DashboardCard(
                    title: 'Total Scans',
                    value: state.todayScans.toString(),
                    icon: Icons.qr_code_scanner,
                    color: AppColors.primary,
                  ),
                  DashboardCard(
                    title: 'Items Linked',
                    value: state.linkedItems.toString(),
                    icon: Icons.link,
                    color: AppColors.secondary,
                  ),
                  DashboardCard(
                    title: 'Pending Sync',
                    value: state.pendingSyncs.toString(),
                    icon: Icons.sync_problem,
                    color: state.pendingSyncs > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  DashboardCard(
                    title: 'Status',
                    value: state.isOnline ? 'Online' : 'Offline',
                    icon: state.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: state.isOnline ? AppColors.success : AppColors.error,
                  ),
                ],
              ),
              Gap(24.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Info', style: TextStyles.heading6),
                      Gap(12.h),
                      _row('Store Keeper', state.storeKeeperName, Icons.person),
                      _row(
                        'Session ID',
                        state.sessionId?.substring(0, 8) ?? '---',
                        Icons.fingerprint,
                      ),
                      _row(
                        'Network',
                        state.isOnline ? 'Online' : 'Offline',
                        state.isOnline ? Icons.wifi : Icons.wifi_off,
                      ),
                    ],
                  ),
                ),
              ),
              Gap(24.h),
              if (state.pendingSyncs > 0) ...[
                PrimaryButton(
                  text: 'Sync All Data',
                  onPressed: () =>
                      context.read<StoreKeeperBloc>().add(SyncNow()),
                  backgroundColor: AppColors.accent,
                  icon: Icons.sync,
                ),
                Gap(12.h),
              ],
              PrimaryButton(
                text: 'End Shift & Return',
                onPressed: () {
                  context.read<StoreKeeperBloc>().add(StoreKeeperLogout());
                  context.go('/factory/store-keeper/login');
                },
                backgroundColor: AppColors.secondary,
                icon: Icons.logout,
              ),
              Gap(16.h),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Continue Shift',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
  Widget _row(String label, String value, IconData icon) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      children: [
        Icon(icon, size: 18.w, color: AppColors.textSecondary),
        Gap(8.w),
        Text(
          '$label: ',
          style: TextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
