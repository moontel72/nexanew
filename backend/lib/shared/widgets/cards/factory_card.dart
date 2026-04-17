// Factory Card Widget for NexaTrace System
// This file contains the factory card widget used to display factory information

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class FactoryCard extends StatelessWidget {
  final String factoryName;
  final String factoryId;
  final String? logoUrl;
  final String subscriptionPlan;
  final String status;
  final int codeUsage;
  final int codeLimit;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onViewDetails;
  final bool isSelected;
  final bool showActions;

  const FactoryCard({
    super.key,
    required this.factoryName,
    required this.factoryId,
    this.logoUrl,
    required this.subscriptionPlan,
    required this.status,
    required this.codeUsage,
    required this.codeLimit,
    this.onTap,
    this.onEdit,
    this.onViewDetails,
    this.isSelected = false,
    this.showActions = true,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      case 'pending':
        return AppColors.accent;
      default:
        return AppColors.gray500;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'suspended':
        return 'Suspended';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  double getUsagePercentage() {
    if (codeLimit == 0) return 0.0;
    return (codeUsage / codeLimit).clamp(0.0, 1.0);
  }

  Color getUsageColor(double percentage) {
    if (percentage < 0.5) return AppColors.success;
    if (percentage < 0.8) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final usagePercentage = getUsagePercentage();
    final usageColor = getUsageColor(usagePercentage);
    final statusColor = getStatusColor(status);
    final statusText = getStatusText(status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with logo, name, and status
              Row(
                children: [
                  // Factory logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.gray100,
                      image: logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: logoUrl == null
                        ? Icon(
                            Icons.factory,
                            size: 24,
                            color: AppColors.gray500,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Factory name and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          factoryName,
                          style: TextStyles.heading6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: $factoryId',
                          style: TextStyles.caption.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyles.captionBold.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Subscription plan
              Row(
                children: [
                  Icon(Icons.credit_card, size: 16, color: AppColors.gray500),
                  const SizedBox(width: 8),
                  Text(
                    'Plan: ',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  Text(
                    subscriptionPlan,
                    style: TextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Code usage progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Code Usage',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                      Text(
                        '$codeUsage / $codeLimit',
                        style: TextStyles.captionBold.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: usagePercentage,
                    backgroundColor: AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(usageColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(usagePercentage * 100).toStringAsFixed(1)}% used',
                    style: TextStyles.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action buttons
              if (showActions)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewDetails,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyles.buttonSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Compact Factory Card for lists
class CompactFactoryCard extends StatelessWidget {
  final String factoryName;
  final String factoryId;
  final String? logoUrl;
  final String status;
  final VoidCallback? onTap;
  final bool isSelected;

  const CompactFactoryCard({
    super.key,
    required this.factoryName,
    required this.factoryId,
    this.logoUrl,
    required this.status,
    this.onTap,
    this.isSelected = false,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      case 'pending':
        return AppColors.accent;
      default:
        return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(status);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Factory logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.gray100,
                  image: logoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: logoUrl == null
                    ? Icon(Icons.factory, size: 20, color: AppColors.gray500)
                    : null,
              ),
              const SizedBox(width: 12),
              // Factory info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factoryName,
                      style: TextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: $factoryId',
                      style: TextStyles.caption.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Factory Card with statistics
class FactoryStatsCard extends StatelessWidget {
  final String factoryName;
  final String factoryId;
  final String? logoUrl;
  final Map<String, int> codeStats;
  final int totalProducts;
  final int activeEmployees;
  final VoidCallback? onTap;

  const FactoryStatsCard({
    super.key,
    required this.factoryName,
    required this.factoryId,
    this.logoUrl,
    required this.codeStats,
    required this.totalProducts,
    required this.activeEmployees,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.gray100,
                      image: logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: logoUrl == null
                        ? Icon(
                            Icons.factory,
                            size: 20,
                            color: AppColors.gray500,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          factoryName,
                          style: TextStyles.heading6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: $factoryId',
                          style: TextStyles.caption.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Statistics grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  // Bundle codes
                  _buildStatItem(
                    icon: Icons.inventory_2,
                    label: 'Bundle Codes',
                    value: codeStats['bundle']?.toString() ?? '0',
                    color: AppColors.primary,
                  ),
                  // Carton codes
                  _buildStatItem(
                    icon: Icons.inventory,
                    label: 'Carton Codes',
                    value: codeStats['carton']?.toString() ?? '0',
                    color: AppColors.secondary,
                  ),
                  // Packet codes
                  _buildStatItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Packet Codes',
                    value: codeStats['packet']?.toString() ?? '0',
                    color: AppColors.accent,
                  ),
                  // Unit codes
                  _buildStatItem(
                    icon: Icons.qr_code,
                    label: 'Unit Codes',
                    value: codeStats['unit']?.toString() ?? '0',
                    color: AppColors.info,
                  ),
                  // Products
                  _buildStatItem(
                    icon: Icons.shopping_bag,
                    label: 'Products',
                    value: totalProducts.toString(),
                    color: AppColors.success,
                  ),
                  // Employees
                  _buildStatItem(
                    icon: Icons.people,
                    label: 'Employees',
                    value: activeEmployees.toString(),
                    color: AppColors.warning,
                  ),
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyles.heading6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyles.caption.copyWith(color: AppColors.gray600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
