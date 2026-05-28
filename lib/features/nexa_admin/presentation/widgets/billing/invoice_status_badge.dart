import 'package:flutter/material.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

/// Invoice Status Badge Widget
/// Displays invoice status with appropriate colors and icons
class InvoiceStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;
  final bool showIcon;
  final double? size;

  const InvoiceStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.showIcon = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);
    final badgeSize = size ?? (compact ? 24.0 : 32.0);
    final fontSize = compact ? 10.0 : 12.0;
    final iconSize = compact ? 12.0 : 16.0;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusConfig.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusConfig.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon)
              Icon(
                statusConfig.icon,
                size: iconSize,
                color: statusConfig.color,
              ),
            if (showIcon) const SizedBox(width: 4),
            Text(
              statusConfig.label,
              style: TextStyles.caption.copyWith(
                color: statusConfig.color,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusConfig.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(statusConfig.icon, size: iconSize, color: statusConfig.color),
          if (showIcon) const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statusConfig.label,
                style: TextStyles.bodySmall.copyWith(
                  color: statusConfig.color,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
              if (statusConfig.description != null)
                Text(
                  statusConfig.description!,
                  style: TextStyles.caption.copyWith(
                    color: statusConfig.color.withOpacity(0.8),
                    fontSize: fontSize - 2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns configuration for different invoice statuses
  StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return StatusConfig(
          label: 'Draft',
          description: 'Not yet sent',
          color: AppColors.textSecondary,
          icon: Icons.edit,
        );
      case 'pending':
        return StatusConfig(
          label: 'Pending',
          description: 'Awaiting payment',
          color: AppColors.warning,
          icon: Icons.pending,
        );
      case 'paid':
        return StatusConfig(
          label: 'Paid',
          description: 'Payment received',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case 'overdue':
        return StatusConfig(
          label: 'Overdue',
          description: 'Payment late',
          color: AppColors.error,
          icon: Icons.warning,
        );
      case 'cancelled':
        return StatusConfig(
          label: 'Cancelled',
          description: 'Invoice cancelled',
          color: AppColors.error,
          icon: Icons.cancel,
        );
      case 'refunded':
        return StatusConfig(
          label: 'Refunded',
          description: 'Payment refunded',
          color: AppColors.info,
          icon: Icons.refresh,
        );
      case 'partially_paid':
        return StatusConfig(
          label: 'Partial',
          description: 'Partially paid',
          color: AppColors.warning,
          icon: Icons.payments,
        );
      case 'in_dispute':
        return StatusConfig(
          label: 'In Dispute',
          description: 'Under review',
          color: AppColors.warning,
          icon: Icons.gavel,
        );
      case 'requires_review':
        return StatusConfig(
          label: 'Review',
          description: 'Needs attention',
          color: AppColors.warning,
          icon: Icons.visibility,
        );
      default:
        return StatusConfig(
          label: 'Unknown',
          description: 'Status not recognized',
          color: AppColors.textSecondary,
          icon: Icons.help,
        );
    }
  }

  /// Helper method to get status color directly
  static Color getStatusColor(String status) {
    final config = InvoiceStatusBadge(status: status)._getStatusConfig(status);
    return config.color;
  }

  /// Helper method to get status icon directly
  static IconData getStatusIcon(String status) {
    final config = InvoiceStatusBadge(status: status)._getStatusConfig(status);
    return config.icon;
  }

  /// Helper method to get status label directly
  static String getStatusLabel(String status) {
    final config = InvoiceStatusBadge(status: status)._getStatusConfig(status);
    return config.label;
  }
}

/// Configuration for invoice status display
class StatusConfig {
  final String label;
  final String? description;
  final Color color;
  final IconData icon;

  const StatusConfig({
    required this.label,
    this.description,
    required this.color,
    required this.icon,
  });
}

/// Status badge for use in data tables
class TableStatusBadge extends StatelessWidget {
  final String status;
  final double? width;

  const TableStatusBadge({super.key, required this.status, this.width});

  @override
  Widget build(BuildContext context) {
    final config = InvoiceStatusBadge(status: status)._getStatusConfig(status);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyles.caption.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Status indicator dot for lists
class StatusIndicator extends StatelessWidget {
  final String status;
  final double size;

  const StatusIndicator({super.key, required this.status, this.size = 8.0});

  @override
  Widget build(BuildContext context) {
    final color = InvoiceStatusBadge.getStatusColor(status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Status filter chips for filtering invoices by status
class StatusFilterChip extends StatelessWidget {
  final String status;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const StatusFilterChip({
    super.key,
    required this.status,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final config = InvoiceStatusBadge(status: status)._getStatusConfig(status);

    return FilterChip(
      label: Text(
        config.label,
        style: TextStyles.bodySmall.copyWith(
          color: selected ? config.color : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: selected ? config.color.withOpacity(0.2) : null,
      selectedColor: config.color.withOpacity(0.2),
      checkmarkColor: config.color,
      avatar: Icon(
        config.icon,
        size: 16,
        color: selected ? config.color : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? config.color : AppColors.border,
          width: 1,
        ),
      ),
    );
  }
}
