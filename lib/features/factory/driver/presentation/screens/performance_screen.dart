import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:trace_odd/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class DriverPerformanceScreen extends StatefulWidget {
  const DriverPerformanceScreen({super.key});

  @override
  State<DriverPerformanceScreen> createState() =>
      _DriverPerformanceScreenState();
}

class _DriverPerformanceScreenState extends State<DriverPerformanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadPerformance());
  }

  Color _tierColor(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.gray500;
    }
  }

  IconData _tierIcon(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'gold':
        return Icons.workspace_premium;
      case 'silver':
        return Icons.star;
      case 'bronze':
        return Icons.emoji_events;
      default:
        return Icons.person;
    }
  }

  double _bonusPercent(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'gold':
        return 5.0;
      case 'silver':
        return 3.0;
      case 'bronze':
        return 1.5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Performance',
      child: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          if (state is DriverLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is DriverError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  state.message,
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            );
          }

          if (state is! DriverKpisLoaded) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final tier = state.tier;
          final onTime = state.onTimePct;
          final rating = state.rating;
          final scansPerDay = state.scansPerDay;
          final photoScore = state.photoQualityScore;
          final totalTrips = 0;
          final completed = 0;
          final onTimeTrips = 0;
          final lateTrips = 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tier badge
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _tierColor(tier).withOpacity(0.2),
                      _tierColor(tier).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _tierColor(tier).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: _tierColor(tier).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _tierIcon(tier),
                        color: _tierColor(tier),
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.toUpperCase(),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: _tierColor(tier),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '+${_bonusPercent(tier)}% bonus on all completed deliveries',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // KPI Section
              Text(
                'Key Performance Indicators',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              _kpiCard(
                label: 'On-Time Delivery',
                value: '${onTime.toStringAsFixed(1)}%',
                progress: onTime / 100,
                color: onTime >= 90
                    ? AppColors.success
                    : onTime >= 75
                    ? AppColors.warning
                    : AppColors.error,
                icon: Icons.access_time,
              ),
              SizedBox(height: 10.h),
              _kpiCard(
                label: 'Customer Rating',
                value: '${rating.toStringAsFixed(1)} / 5.0',
                progress: rating / 5,
                color: rating >= 4.5
                    ? AppColors.success
                    : rating >= 3.5
                    ? AppColors.warning
                    : AppColors.error,
                icon: Icons.star_rate_rounded,
              ),
              SizedBox(height: 10.h),
              _kpiCard(
                label: 'Scans per Day',
                value: scansPerDay.toStringAsFixed(0),
                progress: (scansPerDay / 30).clamp(0.0, 1.0),
                color: scansPerDay >= 20
                    ? AppColors.success
                    : scansPerDay >= 10
                    ? AppColors.warning
                    : AppColors.error,
                icon: Icons.qr_code_scanner,
              ),
              SizedBox(height: 10.h),
              _kpiCard(
                label: 'Photo Quality Score',
                value: '${photoScore.toStringAsFixed(0)}%',
                progress: photoScore / 100,
                color: photoScore >= 80
                    ? AppColors.success
                    : photoScore >= 60
                    ? AppColors.warning
                    : AppColors.error,
                icon: Icons.photo_camera,
              ),
              SizedBox(height: 20.h),
              // Trip statistics
              Text(
                'Trip Statistics',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _tripStat('Total', '$totalTrips', AppColors.primary),
                        SizedBox(width: 12.w),
                        _tripStat('Completed', '$completed', AppColors.success),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _tripStat(
                          'On-Time',
                          '$onTimeTrips',
                          AppColors.secondary,
                        ),
                        SizedBox(width: 12.w),
                        _tripStat('Late', '$lateTrips', AppColors.error),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    // Completion ratio bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: SizedBox(
                        height: 8.h,
                        child: Row(
                          children: [
                            Expanded(
                              flex: onTimeTrips,
                              child: Container(color: AppColors.secondary),
                            ),
                            Expanded(
                              flex: lateTrips,
                              child: Container(color: AppColors.error),
                            ),
                            if (totalTrips > (onTimeTrips + lateTrips))
                              Expanded(
                                flex: totalTrips - (onTimeTrips + lateTrips),
                                child: Container(color: AppColors.gray300),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _legendDot(AppColors.secondary, 'On-Time'),
                        SizedBox(width: 16.w),
                        _legendDot(AppColors.error, 'Late'),
                        SizedBox(width: 16.w),
                        _legendDot(AppColors.gray300, 'Other'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Bonus info
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: _tierColor(tier).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: _tierColor(tier).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: _tierColor(tier),
                      size: 28,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tier[0].toUpperCase()}${tier.substring(1)} Tier Bonus',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'You earn +${_bonusPercent(tier)}% bonus on every completed delivery. Maintain your performance to keep this tier (4AA).',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              PrimaryButton(
                text: 'Refresh KPIs',
                onPressed: () {
                  context.read<DriverBloc>().add(const LoadPerformance());
                },
                height: 44.h,
                borderRadius: 10.r,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.r),
                  child: SizedBox(
                    height: 6.h,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.gray100,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
