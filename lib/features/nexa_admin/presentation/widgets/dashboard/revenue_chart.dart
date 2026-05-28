// File: lib/features/nexa_admin/presentation/widgets/dashboard/revenue_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:trace_odd/shared/models/dashboard/dashboard_models.dart';

/// Revenue Chart Widget
/// Displays revenue analytics with simple bar chart and summary statistics
class RevenueChart extends StatelessWidget {
  final RevenueAnalytics revenueAnalytics;
  final VoidCallback? onViewDetails;
  final bool isLoading;

  const RevenueChart({
    super.key,
    required this.revenueAnalytics,
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
                  'Revenue Analytics',
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
                  // Total revenue
                  Text(
                    '\$${revenueAnalytics.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                  Text(
                    'Total Revenue',
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
    final monthlyData = revenueAnalytics.monthlyData;
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = 36.w;
              final neededWidth = barWidth * monthlyData.length;

              Widget barAt(int index) {
                final value = monthlyData[index];
                final heightPercentage = maxValue > 0 ? value / maxValue : 0;
                final isCurrentMonth = index == DateTime.now().month - 1;

                return SizedBox(
                  width: barWidth,
                  child: LayoutBuilder(
                    builder: (context, barConstraints) {
                      final isVeryCompact = barConstraints.maxHeight < 90;
                      final isCompact = barConstraints.maxHeight < 120;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(bottom: isVeryCompact ? 0 : 6.h),
                                child: FractionallySizedBox(
                                  alignment: Alignment.bottomCenter,
                                  heightFactor: heightPercentage
                                      .clamp(0.0, 1.0)
                                      .toDouble(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isCurrentMonth
                                          ? Colors.green
                                          : Colors.green.withOpacity(0.6),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(4.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (!isVeryCompact) ...[
                              SizedBox(height: 2.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _getMonthAbbreviation(index),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[600],
                                    fontWeight: isCurrentMonth
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                            if (!isCompact) ...[
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '\$${value.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                );
              }

              final row = Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(monthlyData.length, barAt),
              );

              if (neededWidth > constraints.maxWidth) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: neededWidth, child: row),
                );
              }

              return row;
            },
          ),
        ),
        Gap(8.h),
        // Chart legend
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.6),
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
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.green,
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
    final monthlyData = revenueAnalytics.monthlyData;
    if (monthlyData.isEmpty) {
      return SizedBox();
    }

    final currentMonth = DateTime.now().month - 1;
    final lastMonth = currentMonth > 0 ? currentMonth - 1 : 11;

    final currentRevenue = monthlyData[currentMonth];
    final lastRevenue = monthlyData[lastMonth];
    final growth = currentRevenue - lastRevenue;
    final growthPercentage = lastRevenue > 0 ? (growth / lastRevenue * 100) : 0;

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
                  '\$${currentRevenue.toStringAsFixed(2)}',
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
                      growth >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: growth >= 0 ? Colors.green : Colors.red,
                      size: 14.w,
                    ),
                    Gap(4.w),
                    Text(
                      '${growth >= 0 ? '+' : ''}${growthPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: growth >= 0 ? Colors.green : Colors.red,
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
        _buildRevenueTrendIndicator(monthlyData),
      ],
    );
  }

  /// Build revenue trend indicator
  Widget _buildRevenueTrendIndicator(List<double> monthlyData) {
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
      isStable = variance < (avg * 0.1); // Low variance indicates stability
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
                  ? 'Revenue trend: Positive'
                  : isStable
                      ? 'Revenue trend: Stable'
                      : 'Revenue trend: Declining',
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
        // Total revenue skeleton
        Container(
          width: 120.w,
          height: 32.h,
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
