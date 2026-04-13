// File: lib/features/nexa_admin/presentation/widgets/dashboard/company_growth_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:nexatrace_system/shared/models/dashboard/dashboard_models.dart';

/// Company Growth Chart Widget
/// Displays company growth analytics with simple bar chart and summary statistics
class CompanyGrowthChart extends StatelessWidget {
  final CompanyGrowthAnalytics companyGrowthAnalytics;
  final VoidCallback? onViewDetails;
  final bool isLoading;

  const CompanyGrowthChart({
    super.key,
    required this.companyGrowthAnalytics,
    this.onViewDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Company Growth',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onViewDetails != null)
                  IconButton(
                    icon: Icon(Icons.more_horiz, size: 20.w),
                    onPressed: onViewDetails,
                    tooltip: 'View details',
                  ),
              ],
            ),
            Gap(8.h),

            if (isLoading)
              _buildLoadingState()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total growth
                  Text(
                    '+${companyGrowthAnalytics.totalGrowth}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                  ),
                  Text(
                    'Total Companies Added',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Gap(16.h),

                  // Simple bar chart
                  SizedBox(
                    height: 150.h,
                    child: _buildSimpleBarChart(),
                  ),
                  Gap(12.h),

                  // Monthly breakdown
                  _buildMonthlyBreakdown(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Build simple bar chart using CustomPaint
  Widget _buildSimpleBarChart() {
    final monthlyData = companyGrowthAnalytics.monthlyData;
    if (monthlyData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
        ),
      );
    }

    final maxValue = monthlyData.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Chart bars
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              monthlyData.length,
              (index) {
                final value = monthlyData[index];
                final heightPercentage = maxValue > 0 ? value / maxValue : 0;
                final isCurrentMonth = index == DateTime.now().month - 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Column(
                      children: [
                        // Bar
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrentMonth
                                    ? Colors.blue
                                    : Colors.blue.withOpacity(0.6),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4.r),
                                ),
                              ),
                              height: heightPercentage * 100,
                            ),
                          ),
                        ),
                        // Month label
                        Text(
                          _getMonthAbbreviation(index),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                            fontWeight: isCurrentMonth
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        // Value label
                        Text(
                          '+$value',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Gap(8.h),
        // Chart legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap(4.w),
            Text(
              'Previous Months',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
            Gap(12.w),
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap(4.w),
            Text(
              'Current Month',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build monthly breakdown
  Widget _buildMonthlyBreakdown() {
    final monthlyData = companyGrowthAnalytics.monthlyData;
    if (monthlyData.isEmpty) {
      return SizedBox();
    }

    final currentMonth = DateTime.now().month - 1;
    final lastMonth = currentMonth > 0 ? currentMonth - 1 : 11;

    final currentGrowth = monthlyData[currentMonth];
    final lastGrowth = monthlyData[lastMonth];
    final growthChange = currentGrowth - lastGrowth;
    final growthPercentage =
        lastGrowth > 0 ? (growthChange / lastGrowth * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Breakdown',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Gap(8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Month',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '+$currentGrowth',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      growthChange >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: growthChange >= 0 ? Colors.green : Colors.red,
                      size: 14.w,
                    ),
                    Gap(4.w),
                    Text(
                      '${growthChange >= 0 ? '+' : ''}${growthPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: growthChange >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'vs Last Month',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        Gap(8.h),
        _buildGrowthTrendIndicator(monthlyData),
      ],
    );
  }

  /// Build growth trend indicator
  Widget _buildGrowthTrendIndicator(List<int> monthlyData) {
    final last3Months = monthlyData.sublist(
      monthlyData.length - 3 > 0 ? monthlyData.length - 3 : 0,
      monthlyData.length,
    );

    bool isGrowing = false;
    bool isStable = false;

    if (last3Months.length >= 2) {
      final sum = last3Months.reduce((a, b) => a + b);
      final avg = sum / last3Months.length;
      final variance = last3Months
              .map((x) => (x - avg) * (x - avg))
              .reduce((a, b) => a + b) /
          last3Months.length;
      isStable = variance < 5; // Low variance indicates stability
      isGrowing = last3Months.last > last3Months.first && !isStable;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isGrowing
            ? Colors.green.withOpacity(0.1)
            : isStable
                ? Colors.blue.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            isGrowing
                ? Icons.trending_up
                : isStable
                    ? Icons.trending_flat
                    : Icons.trending_down,
            color: isGrowing
                ? Colors.green
                : isStable
                    ? Colors.blue
                    : Colors.orange,
            size: 16.w,
          ),
          Gap(8.w),
          Expanded(
            child: Text(
              isGrowing
                  ? 'Growth trend: Positive'
                  : isStable
                      ? 'Growth trend: Stable'
                      : 'Growth trend: Declining',
              style: TextStyle(
                fontSize: 11.sp,
                color: isGrowing
                    ? Colors.green
                    : isStable
                        ? Colors.blue
                        : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total growth skeleton
        Container(
          width: 100.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        Gap(4.h),
        Container(
          width: 120.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        Gap(16.h),

        // Chart skeleton
        Container(
          height: 150.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(12.h),

        // Monthly breakdown skeleton
        Container(
          width: 100.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        Gap(8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Gap(4.h),
                Container(
                  width: 80.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 70.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Gap(4.h),
                Container(
                  width: 60.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ],
        ),
        Gap(8.h),
        Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ],
    );
  }

  /// Get month abbreviation from index (0-11)
  String _getMonthAbbreviation(int index) {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return months[index % 12];
  }
}
