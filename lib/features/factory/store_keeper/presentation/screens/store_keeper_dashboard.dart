import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:nexatrace_system/features/factory/store_keeper/presentation/widgets/sync_status_badge.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/cards/dashboard_card.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class StoreKeeperDashboard extends StatefulWidget {
  const StoreKeeperDashboard({super.key});
  @override
  State<StoreKeeperDashboard> createState() => _StoreKeeperDashboardState();
}

class _StoreKeeperDashboardState extends State<StoreKeeperDashboard> {
  Timer? _shiftTimer;
  Duration _shiftElapsed = Duration.zero;
  final Duration _shiftDuration = const Duration(hours: 8);
  @override
  void initState() {
    super.initState();
    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _shiftElapsed += const Duration(seconds: 1));
    });
    context.read<StoreKeeperBloc>().add(RefreshDashboardStats());
  }

  @override
  void dispose() {
    _shiftTimer?.cancel();
    super.dispose();
  }

  Duration get _remaining {
    final r = _shiftDuration - _shiftElapsed;
    return r.isNegative ? Duration.zero : r;
  }

  String _fmt(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Keeper'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<StoreKeeperBloc>().add(RefreshDashboardStats()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<StoreKeeperBloc>().add(StoreKeeperLogout());
              context.go('/factory/store-keeper/login');
            },
          ),
        ],
      ),
      body: BlocConsumer<StoreKeeperBloc, StoreKeeperState>(
        listener: (context, state) {
          if (state is ErrorState)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.isNetworkError
                    ? AppColors.warning
                    : AppColors.error,
              ),
            );
          if (state is SyncingState && state.lastResult != null) {
            final r = state.lastResult!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sync: ${r.syncedCount} synced, ${r.failedCount} failed, ${r.conflictCount} conflicts',
                ),
                backgroundColor: r.isFullySuccessful
                    ? AppColors.success
                    : AppColors.warning,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StoreKeeperAuthenticated)
            return RefreshIndicator(
              onRefresh: () async {
                context.read<StoreKeeperBloc>().add(RefreshDashboardStats());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: AppColors.accent.withOpacity(0.2),
                          child: Text(
                            state.storeKeeperName.isNotEmpty
                                ? state.storeKeeperName[0].toUpperCase()
                                : 'S',
                            style: TextStyles.heading6.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Gap(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${state.storeKeeperName}',
                                style: TextStyles.heading5,
                              ),
                              Gap(4.h),
                              Row(
                                children: [
                                  const SyncStatusBadge(),
                                  Gap(8.w),
                                  Text(
                                    'Session: ${state.sessionId?.substring(0, 8) ?? '---'}',
                                    style: TextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.5,
                      children: [
                        DashboardCard(
                          title: "Today's Scans",
                          value: state.todayScans.toString(),
                          icon: Icons.qr_code_scanner,
                          color: AppColors.primary,
                        ),
                        DashboardCard(
                          title: 'Pending Syncs',
                          value: state.pendingSyncs.toString(),
                          icon: Icons.sync,
                          color: state.pendingSyncs > 0
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        DashboardCard(
                          title: 'Items Linked',
                          value: state.linkedItems.toString(),
                          icon: Icons.link,
                          color: AppColors.secondary,
                        ),
                        DashboardCard(
                          title: 'Status',
                          value: state.isOnline ? 'Online' : 'Offline',
                          icon: state.isOnline ? Icons.wifi : Icons.wifi_off,
                          color: state.isOnline
                              ? AppColors.success
                              : AppColors.error,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Shift Timer', style: TextStyles.heading6),
                                Icon(
                                  Icons.timer,
                                  color: _remaining.inHours < 1
                                      ? AppColors.error
                                      : AppColors.accent,
                                ),
                              ],
                            ),
                            Gap(12.h),
                            LinearProgressIndicator(
                              value: _shiftDuration.inSeconds > 0
                                  ? 1.0 -
                                        (_remaining.inSeconds /
                                            _shiftDuration.inSeconds)
                                  : 1.0,
                              backgroundColor: AppColors.gray100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _remaining.inHours < 1
                                    ? AppColors.error
                                    : AppColors.accent,
                              ),
                              minHeight: 8.h,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            Gap(8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Elapsed: ${_fmt(_shiftElapsed)}',
                                  style: TextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Remaining: ${_fmt(_remaining)}',
                                  style: TextStyles.captionBold.copyWith(
                                    color: _remaining.inHours < 1
                                        ? AppColors.error
                                        : AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(24.h),
                    Text('Quick Actions', style: TextStyles.heading6),
                    Gap(12.h),
                    Row(
                      children: [
                        _qa(
                          context,
                          'Scan Codes',
                          Icons.qr_code_scanner,
                          AppColors.primary,
                          '/factory/store-keeper/scanner',
                        ),
                        Gap(12.w),
                        _qa(
                          context,
                          'Inventory',
                          Icons.inventory,
                          AppColors.secondary,
                          '/factory/store-keeper/inventory',
                        ),
                        Gap(12.w),
                        _qa(
                          context,
                          'Sync',
                          Icons.sync,
                          AppColors.accent,
                          null,
                          onTap: () =>
                              context.read<StoreKeeperBloc>().add(SyncNow()),
                        ),
                      ],
                    ),
                    Gap(12.h),
                    Row(
                      children: [
                        _qa(
                          context,
                          'Link Items',
                          Icons.link,
                          AppColors.secondaryDark,
                          '/factory/store-keeper/orders',
                        ),
                        Gap(12.w),
                        _qa(
                          context,
                          'Rack',
                          Icons.warehouse,
                          AppColors.primaryDark,
                          '/factory/store-keeper/rack',
                        ),
                        Gap(12.w),
                        _qa(
                          context,
                          'Summary',
                          Icons.summarize,
                          AppColors.accentDark,
                          '/factory/store-keeper/shift-summary',
                        ),
                      ],
                    ),
                    Gap(12.h),
                    Row(
                      children: [
                        _qa(
                          context,
                          'QR Test Panel',
                          Icons.qr_code_2,
                          Colors.amber.shade700,
                          '/factory/store-keeper/qr-test-panel',
                        ),
                      ],
                    ),
                    Gap(24.h),
                    if (state.pendingSyncs > 0)
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: AppColors.warning,
                              size: 20.w,
                            ),
                            Gap(8.w),
                            Expanded(
                              child: Text(
                                '${state.pendingSyncs} item(s) waiting to sync',
                                style: TextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                            PrimaryButton(
                              text: 'Sync Now',
                              onPressed: () => context
                                  .read<StoreKeeperBloc>()
                                  .add(SyncNow()),
                              backgroundColor: AppColors.accent,
                              height: 36.h,
                              width: 120.w,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          if (state is SyncingState)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isSyncing)
                    const CircularProgressIndicator(color: AppColors.accent),
                  Gap(16.h),
                  Text(
                    state.isSyncing ? 'Syncing...' : 'Sync Complete',
                    style: TextStyles.heading6,
                  ),
                ],
              ),
            );
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _qa(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String? route, {
    VoidCallback? onTap,
  }) => Expanded(
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap ?? (() => context.go(route!)),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22.w),
              ),
              Gap(8.h),
              Text(
                title,
                style: TextStyles.captionBold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
