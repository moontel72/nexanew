import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver_statistics.dart';

/// Driver Stats Card Widget - Displays driver statistics in a card format
class DriverStatsCard extends StatelessWidget {
  final DriverStatistics? statistics;
  final Driver? driver;

  const DriverStatsCard({
    super.key,
    this.statistics,
    this.driver,
  });

  @override
  Widget build(BuildContext context) {
    if (statistics == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Statistics',
                style: TextStyles.heading6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No statistics available',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Driver Statistics',
                  style: TextStyles.heading6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${statistics!.rating.toStringAsFixed(1)}/5.0',
                        style: TextStyles.captionBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Completed',
                  value: statistics!.completedDeliveries.toString(),
                  color: AppColors.success,
                ),
                _buildStatItem(
                  icon: Icons.pending,
                  label: 'Pending',
                  value: statistics!.pendingDeliveries.toString(),
                  color: AppColors.warning,
                ),
                _buildStatItem(
                  icon: Icons.timelapse,
                  label: 'Active',
                  value: statistics!.activeDeliveries.toString(),
                  color: AppColors.primary,
                ),
                _buildStatItem(
                  icon: Icons.percent,
                  label: 'Success Rate',
                  value: '${statistics!.successRate.toStringAsFixed(1)}%',
                  color: AppColors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Performance indicator
            _buildPerformanceIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.heading5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator() {
    if (statistics == null) {
      return const SizedBox.shrink();
    }

    final performanceLevel = statistics!.successRate >= 90
        ? 'Excellent'
        : statistics!.successRate >= 75
            ? 'Good'
            : statistics!.successRate >= 60
                ? 'Average'
                : 'Needs Improvement';

    Color performanceColor = AppColors.success;
    if (statistics!.successRate < 60) {
      performanceColor = AppColors.error;
    } else if (statistics!.successRate < 75) {
      performanceColor = AppColors.warning;
    } else if (statistics!.successRate < 90) {
      performanceColor = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: performanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assessment,
            color: performanceColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance: $performanceLevel',
                  style: TextStyles.captionBold.copyWith(
                    color: performanceColor,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: statistics!.successRate / 100,
                  backgroundColor: performanceColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(performanceColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${statistics!.successRate.toStringAsFixed(1)}%',
            style: TextStyles.captionBold.copyWith(
              color: performanceColor,
            ),
          ),
        ],
      ),
    );
  }
}
