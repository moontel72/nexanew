// Company Card Widget for NexaTrace System
// Displays company information in a card format

import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';
import 'package:trace_odd/core/utils/date_utils.dart';
import 'package:trace_odd/core/utils/string_utils.dart';

class CompanyCard extends StatelessWidget {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String status;
  final String? verificationStatus;
  final String? industry;
  final int? employeeCount;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool showActions;

  const CompanyCard({
    super.key,
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.status,
    this.verificationStatus,
    this.industry,
    this.employeeCount,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.showActions = true,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      case 'verified':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  String _getStatusText() {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      case 'suspended':
        return Icons.block;
      case 'verified':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Header row with logo and name
              Row(
                children: [
                  // Company Logo
                  _buildLogo(),
                  const SizedBox(width: 12),
                  // Company Name and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(),
                            if (verificationStatus != null &&
                                verificationStatus!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _buildVerificationChip(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions menu
                  if (showActions) _buildActionsMenu(),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              if (description != null && description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    description!,
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // Details row
              _buildDetailsRow(),
              // Footer with dates
              if (createdAt != null || updatedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildFooter(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        image: logoUrl != null && logoUrl!.isNotEmpty
            ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: logoUrl == null || logoUrl!.isEmpty
          ? Center(
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: TextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusChip() {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyles.caption.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getVerificationColor() {
    switch (verificationStatus?.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'submitted':
      case 'underreview':
      case 'under_review':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      case 'notsubmitted':
      case 'not_submitted':
      default:
        return AppColors.gray500;
    }
  }

  String _getVerificationText() {
    switch (verificationStatus?.toLowerCase()) {
      case 'verified':
        return '✓ Verified';
      case 'submitted':
        return 'Submitted';
      case 'underreview':
      case 'under_review':
        return 'Under Review';
      case 'rejected':
        return 'Rejected';
      case 'notsubmitted':
      case 'not_submitted':
        return 'Not Submitted';
      case 'requiresadditional':
      case 'requires_additional':
        return 'Requires Additional';
      default:
        return 'Not Submitted';
    }
  }

  IconData _getVerificationIcon() {
    switch (verificationStatus?.toLowerCase()) {
      case 'verified':
        return Icons.verified;
      case 'submitted':
        return Icons.file_present;
      case 'underreview':
      case 'under_review':
        return Icons.rate_review;
      case 'rejected':
        return Icons.cancel;
      case 'notsubmitted':
      case 'not_submitted':
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildVerificationChip() {
    final vColor = _getVerificationColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: vColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getVerificationIcon(), size: 12, color: vColor),
          const SizedBox(width: 4),
          Text(
            _getVerificationText(),
            style: TextStyles.caption.copyWith(
              color: vColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textTertiary),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: AppColors.error),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      children: [
        // Industry
        if (industry != null && industry!.isNotEmpty)
          Expanded(
            child: _buildDetailItem(
              icon: Icons.business,
              label: 'Industry',
              value: industry!,
            ),
          ),
        // Employee Count
        if (employeeCount != null)
          Expanded(
            child: _buildDetailItem(
              icon: Icons.people,
              label: 'Employees',
              value: StringUtils.formatNumberWithSeparator(employeeCount!),
            ),
          ),
        // Location
        if (location != null && location!.isNotEmpty)
          Expanded(
            child: _buildDetailItem(
              icon: Icons.location_on,
              label: 'Location',
              value: location!,
            ),
          ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (createdAt != null)
          Text(
            'Created: ${createdAt!.formatDate()}',
            style: TextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        if (updatedAt != null)
          Text(
            'Updated: ${updatedAt!.formatDate()}',
            style: TextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
      ],
    );
  }
}

// Compact Company Card for lists
class CompactCompanyCard extends StatelessWidget {
  final String id;
  final String name;
  final String? logoUrl;
  final String status;
  final String? industry;
  final VoidCallback? onTap;

  const CompactCompanyCard({
    super.key,
    required this.id,
    required this.name,
    this.logoUrl,
    required this.status,
    this.industry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  image: logoUrl != null && logoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: logoUrl == null || logoUrl!.isEmpty
                    ? Center(
                        child: Text(
                          name.substring(0, 1).toUpperCase(),
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (industry != null && industry!.isNotEmpty)
                      Text(
                        industry!,
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      case 'suspended':
        return AppColors.error;
      case 'verified':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }
}

// Company Card with Statistics
class CompanyStatisticsCard extends StatelessWidget {
  final String companyId;
  final String companyName;
  final int totalUsers;
  final int activeUsers;
  final int totalProducts;
  final int activeProducts;
  final int totalCodes;
  final int generatedCodes;
  final int publishedCodes;
  final int scannedCodes;
  final DateTime? lastActivity;
  final VoidCallback? onTap;
  final bool showDetails;

  const CompanyStatisticsCard({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalProducts,
    required this.activeProducts,
    required this.totalCodes,
    required this.generatedCodes,
    this.publishedCodes = 0,
    this.scannedCodes = 0,
    this.lastActivity,
    this.onTap,
    this.showDetails = true,
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
              // Header with company name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      companyName,
                      style: TextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: 16),

              // Statistics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildStatItem(
                    label: 'Users',
                    value: '$activeUsers/$totalUsers',
                    icon: Icons.people,
                    color: AppColors.primary,
                    progress: totalUsers > 0 ? activeUsers / totalUsers : 0,
                  ),
                  _buildStatItem(
                    label: 'Products',
                    value: '$activeProducts/$totalProducts',
                    icon: Icons.inventory,
                    color: AppColors.success,
                    progress: totalProducts > 0
                        ? activeProducts / totalProducts
                        : 0,
                  ),
                  _buildStatItem(
                    label: 'Codes Generated',
                    value: StringUtils.formatNumberWithSeparator(
                      generatedCodes,
                    ),
                    icon: Icons.qr_code,
                    color: AppColors.info,
                  ),
                  _buildStatItem(
                    label: 'Total Codes',
                    value: StringUtils.formatNumberWithSeparator(totalCodes),
                    icon: Icons.numbers,
                    color: AppColors.warning,
                  ),
                ],
              ),

              // Additional details if showDetails is true
              if (showDetails) ...[
                const SizedBox(height: 16),
                Divider(color: AppColors.outline, height: 1),
                const SizedBox(height: 16),

                // Additional statistics
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildStatItem(
                      label: 'Published',
                      value: StringUtils.formatNumberWithSeparator(
                        publishedCodes,
                      ),
                      icon: Icons.publish,
                      color: AppColors.success,
                    ),
                    _buildStatItem(
                      label: 'Scanned',
                      value: StringUtils.formatNumberWithSeparator(
                        scannedCodes,
                      ),
                      icon: Icons.scanner,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],

              // Last activity
              if (lastActivity != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Last activity: ${lastActivity!.relativeTime}',
                          style: TextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    double progress = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Progress bar for ratio items
                if (progress > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Compact version for lists
class CompactCompanyStatisticsCard extends StatelessWidget {
  final String companyName;
  final int totalUsers;
  final int activeUsers;
  final int totalProducts;
  final int totalCodes;
  final VoidCallback? onTap;

  const CompactCompanyStatisticsCard({
    super.key,
    required this.companyName,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalProducts,
    required this.totalCodes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company name
              Text(
                companyName,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Statistics in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCompactStatItem(
                    label: 'Users',
                    value: StringUtils.formatNumberWithSeparator(activeUsers),
                    color: AppColors.primary,
                  ),
                  _buildCompactStatItem(
                    label: 'Products',
                    value: StringUtils.formatNumberWithSeparator(totalProducts),
                    color: AppColors.success,
                  ),
                  _buildCompactStatItem(
                    label: 'Codes',
                    value: StringUtils.formatNumberWithSeparator(totalCodes),
                    color: AppColors.info,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

// Statistics card for dashboard (KPI card)
class DashboardStatisticsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int value;
  final int? previousValue;
  final String? unit;
  final VoidCallback? onTap;

  const DashboardStatisticsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    this.previousValue,
    this.unit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentageChange = previousValue != null && previousValue! > 0
        ? ((value - previousValue!) / previousValue! * 100)
        : 0.0;
    final isPositive = percentageChange >= 0;

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
              // Header with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (previousValue != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 12,
                            color: isPositive
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${percentageChange.abs().toStringAsFixed(1)}%',
                            style: TextStyles.caption.copyWith(
                              color: isPositive
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Value
              Text(
                '${StringUtils.formatNumberWithSeparator(value)}${unit ?? ''}',
                style: TextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              // Title
              Text(
                title,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              // Previous value comparison
              if (previousValue != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'From ${StringUtils.formatNumberWithSeparator(previousValue!)}${unit ?? ''} last period',
                    style: TextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Statistics summary card
class StatisticsSummaryCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final VoidCallback? onViewDetails;

  const StatisticsSummaryCard({
    super.key,
    required this.statistics,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statistics Summary',
                  style: TextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('View Details'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryItem(
                  label: 'Total Companies',
                  value: statistics['total_companies']?.toString() ?? '0',
                  color: AppColors.primary,
                ),
                _buildSummaryItem(
                  label: 'Active Companies',
                  value: statistics['active_companies']?.toString() ?? '0',
                  color: AppColors.success,
                ),
                _buildSummaryItem(
                  label: 'Total Users',
                  value: statistics['total_users']?.toString() ?? '0',
                  color: AppColors.info,
                ),
                _buildSummaryItem(
                  label: 'Total Products',
                  value: statistics['total_products']?.toString() ?? '0',
                  color: AppColors.warning,
                ),
                _buildSummaryItem(
                  label: 'Total Codes',
                  value: statistics['total_codes']?.toString() ?? '0',
                  color: AppColors.secondary,
                ),
                _buildSummaryItem(
                  label: 'Scanned Today',
                  value: statistics['scanned_today']?.toString() ?? '0',
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyles.caption.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
