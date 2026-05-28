import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

/// Dunning Alert Widget
/// Displays alerts for overdue invoices and payment collection issues
class DunningAlertWidget extends StatelessWidget {
  final List<DunningAlert> alerts;
  final bool showActions;
  final ValueChanged<DunningAlert>? onAcknowledge;
  final ValueChanged<DunningAlert>? onResolve;
  final ValueChanged<DunningAlert>? onEscalate;

  const DunningAlertWidget({
    super.key,
    required this.alerts,
    this.showActions = true,
    this.onAcknowledge,
    this.onResolve,
    this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final activeAlerts = alerts.where((alert) => alert.isActive).toList();
    final resolvedAlerts = alerts.where((alert) => !alert.isActive).toList();

    if (alerts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeAlerts.isNotEmpty) ...[
          _buildAlertSection('Active Alerts', activeAlerts),
          const SizedBox(height: 24),
        ],
        if (resolvedAlerts.isNotEmpty) ...[
          _buildAlertSection('Resolved Alerts', resolvedAlerts),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 48, color: AppColors.success),
            const SizedBox(height: 16),
            Text(
              'No Active Alerts',
              style: TextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All invoices are up to date',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection(String title, List<DunningAlert> sectionAlerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Chip(
              label: Text(
                sectionAlerts.length.toString(),
                style: TextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: title.contains('Active')
                  ? AppColors.warning
                  : AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sectionAlerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(DunningAlert alert) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final severityColor = _getSeverityColor(alert.severity);
    final statusColor = alert.isActive ? AppColors.warning : AppColors.success;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: severityColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          _getSeverityIcon(alert.severity),
                          size: 16,
                          color: severityColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    alert.isActive ? 'ACTIVE' : 'RESOLVED',
                    style: TextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              alert.description,
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Details
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (alert.invoiceNumber != null)
                  _buildDetailItem(
                    Icons.receipt,
                    'Invoice: ${alert.invoiceNumber}',
                  ),
                if (alert.companyName != null)
                  _buildDetailItem(
                    Icons.business,
                    'Company: ${alert.companyName}',
                  ),
                if (alert.dueDate != null)
                  _buildDetailItem(
                    Icons.calendar_today,
                    'Due: ${dateFormat.format(alert.dueDate!)}',
                  ),
                if (alert.amount != null)
                  _buildDetailItem(
                    Icons.attach_money,
                    'Amount: \$${alert.amount!.toStringAsFixed(2)}',
                  ),
                if (alert.daysOverdue != null)
                  _buildDetailItem(
                    Icons.timer,
                    'Overdue: ${alert.daysOverdue} days',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Actions
            if (showActions && alert.isActive)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAcknowledge != null
                          ? () => onAcknowledge!(alert)
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Acknowledge'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onResolve != null
                          ? () => onResolve!(alert)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Resolve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onEscalate != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onEscalate!(alert),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Escalate'),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Color _getSeverityColor(DunningSeverity severity) {
    switch (severity) {
      case DunningSeverity.low:
        return AppColors.info;
      case DunningSeverity.medium:
        return AppColors.warning;
      case DunningSeverity.high:
        return AppColors.error;
      case DunningSeverity.critical:
        return AppColors.error;
    }
  }

  IconData _getSeverityIcon(DunningSeverity severity) {
    switch (severity) {
      case DunningSeverity.low:
        return Icons.info;
      case DunningSeverity.medium:
        return Icons.warning;
      case DunningSeverity.high:
        return Icons.error;
      case DunningSeverity.critical:
        return Icons.error_outline;
    }
  }
}

/// Dunning Alert Model
class DunningAlert {
  final String id;
  final String title;
  final String description;
  final DunningSeverity severity;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? invoiceNumber;
  final String? companyName;
  final DateTime? dueDate;
  final double? amount;
  final int? daysOverdue;
  final Map<String, dynamic>? metadata;

  const DunningAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.isActive,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.invoiceNumber,
    this.companyName,
    this.dueDate,
    this.amount,
    this.daysOverdue,
    this.metadata,
  });

  factory DunningAlert.fromJson(Map<String, dynamic> json) {
    return DunningAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: _parseSeverity(json['severity'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolvedBy: json['resolved_by'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      companyName: json['company_name'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      amount: (json['amount'] as num?)?.toDouble(),
      daysOverdue: json['days_overdue'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity.toString().split('.').last,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'invoice_number': invoiceNumber,
      'company_name': companyName,
      'due_date': dueDate?.toIso8601String(),
      'amount': amount,
      'days_overdue': daysOverdue,
      'metadata': metadata,
    };
  }

  static DunningSeverity _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return DunningSeverity.low;
      case 'medium':
        return DunningSeverity.medium;
      case 'high':
        return DunningSeverity.high;
      case 'critical':
        return DunningSeverity.critical;
      default:
        return DunningSeverity.medium;
    }
  }
}

/// Dunning Severity Levels
enum DunningSeverity { low, medium, high, critical }

/// Dunning Alert Statistics
class DunningStatistics {
  final int totalAlerts;
  final int activeAlerts;
  final int resolvedAlerts;
  final Map<DunningSeverity, int> severityCounts;
  final double totalAmountAtRisk;
  final int averageDaysOverdue;
  final DateTime? lastAlertDate;

  const DunningStatistics({
    required this.totalAlerts,
    required this.activeAlerts,
    required this.resolvedAlerts,
    required this.severityCounts,
    required this.totalAmountAtRisk,
    required this.averageDaysOverdue,
    this.lastAlertDate,
  });

  factory DunningStatistics.fromAlerts(List<DunningAlert> alerts) {
    final activeAlerts = alerts.where((a) => a.isActive).toList();
    final resolvedAlerts = alerts.where((a) => !a.isActive).toList();

    final severityCounts = <DunningSeverity, int>{};
    for (final severity in DunningSeverity.values) {
      severityCounts[severity] = activeAlerts
          .where((a) => a.severity == severity)
          .length;
    }

    final totalAmountAtRisk = activeAlerts
        .where((a) => a.amount != null)
        .fold(0.0, (sum, a) => sum + a.amount!);

    final totalDaysOverdue = activeAlerts
        .where((a) => a.daysOverdue != null)
        .fold(0, (sum, a) => sum + a.daysOverdue!);
    final averageDaysOverdue =
        activeAlerts.where((a) => a.daysOverdue != null).isNotEmpty
        ? totalDaysOverdue ~/
              activeAlerts.where((a) => a.daysOverdue != null).length
        : 0;

    final lastAlertDate = alerts.isNotEmpty
        ? alerts.map((a) => a.createdAt).reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    return DunningStatistics(
      totalAlerts: alerts.length,
      activeAlerts: activeAlerts.length,
      resolvedAlerts: resolvedAlerts.length,
      severityCounts: severityCounts,
      totalAmountAtRisk: totalAmountAtRisk,
      averageDaysOverdue: averageDaysOverdue,
      lastAlertDate: lastAlertDate,
    );
  }
}
