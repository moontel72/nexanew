import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/trip.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

class FactoryDriverDashboardScreen extends StatelessWidget {
  const FactoryDriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Driver Dashboard',
      actions: [
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card (4T - Trip Lifecycle)
          _statusCard(context),
          SizedBox(height: 16.h),

          // Core Delivery Flow
          _sectionHeader('Delivery Flow'),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Receive Product (Scan)',
            subtitle: '4A - Scan at factory pickup',
            icon: Icons.qr_code_scanner,
            route: '/scan-receive',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Map Tracking & Navigation',
            subtitle: '4F - Live GPS tracking with geofence',
            icon: Icons.map,
            route: '/map-tracking',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Delivery Scan',
            subtitle: '4B-4C - Unlock within 100m',
            icon: Icons.location_on_outlined,
            route: '/delivery-scan',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Location Confirm',
            subtitle: '4D - Recipient override flow',
            icon: Icons.verified_user_outlined,
            route: '/location-confirm',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Proof of Delivery',
            subtitle: '4E, 4R - PIN / Photo / Signature',
            icon: Icons.assignment_turned_in_outlined,
            route: '/pod',
          ),

          SizedBox(height: 16.h),
          _sectionHeader('Finances'),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Earnings',
            subtitle: '4G - Salary, commission, bonus, trip fees',
            icon: Icons.payments_outlined,
            route: '/earnings',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Payment History',
            subtitle: '4H - Past payments & invoices',
            icon: Icons.receipt_long,
            route: '/payment-history',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Expenses',
            subtitle: '4K-4O - Fuel, food, mechanic receipts',
            icon: Icons.receipt,
            route: '/expenses',
          ),

          SizedBox(height: 16.h),
          _sectionHeader('Vehicle & Compliance'),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Vehicle Info',
            subtitle: '4I-4J - Plate number & meter readings',
            icon: Icons.local_shipping_outlined,
            route: '/vehicle',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Maintenance Log',
            subtitle: '4Q - Service dates & reminders',
            icon: Icons.build_outlined,
            route: '/maintenance',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Compliance & Documents',
            subtitle: '4Y - License, insurance, registration',
            icon: Icons.fact_check_outlined,
            route: '/compliance',
          ),

          SizedBox(height: 16.h),
          _sectionHeader('Communication & More'),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Chat & Messages',
            subtitle: '4P, 4X - Contact admin & clients',
            icon: Icons.chat_outlined,
            route: '/chat',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Performance',
            subtitle: '4AA - KPIs, tier & bonus',
            icon: Icons.trending_up,
            route: '/performance',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Disputes',
            subtitle: '4AB - View & respond to disputes',
            icon: Icons.gavel_outlined,
            route: '/disputes',
          ),
          SizedBox(height: 8.h),
          _tile(
            context,
            title: 'Settings',
            subtitle: '4S, 4Z, 4AC - GPS, offline, fatigue',
            icon: Icons.settings_outlined,
            route: '/settings',
          ),

          SizedBox(height: 18.h),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _statusCard(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        String statusText = 'No active trip';
        Color statusColor = AppColors.textSecondary;
        int step = 0;

        if (state is TripsLoaded && state.currentTrip != null) {
          statusText = state.currentTrip!.status.displayName;
          step = state.currentTrip!.status.stepIndex;
          statusColor = step >= 4 ? AppColors.success : AppColors.primary;
        } else if (state is DriverProfileLoaded) {
          statusText = 'Ready - ${state.driver.tier.displayName} Tier';
          statusColor = AppColors.success;
        }

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trip Status (4T)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Trip step indicators
              Row(
                children: TripStatus.values.map((s) {
                  final isActive = s.stepIndex <= step;
                  final isCurrent = s.stepIndex == step;
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: isCurrent ? 14.w : 10.w,
                          height: isCurrent ? 14.w : 10.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            border: isCurrent
                                ? Border.all(color: AppColors.accent, width: 2)
                                : null,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          s.displayName.split(' ').first,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
