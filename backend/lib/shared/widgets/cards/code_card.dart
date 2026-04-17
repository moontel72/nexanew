import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

/// Card widget for displaying code information (Bundle, Carton, Packet, Unit)
class CodeCard extends StatelessWidget {
  final String code;
  final String codeType;
  final String status;
  final String? batchNumber;
  final String? productName;
  final DateTime? generatedDate;
  final DateTime? publishedDate;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectedChanged;

  const CodeCard({
    super.key,
    required this.code,
    required this.codeType,
    required this.status,
    this.batchNumber,
    this.productName,
    this.generatedDate,
    this.publishedDate,
    this.onTap,
    this.actions,
    this.isSelected = false,
    this.onSelectedChanged,
  });

  Color _getStatusColor(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'published':
        return AppColors.success;
      case 'pending':
      case 'generated':
        return AppColors.warning;
      case 'inactive':
      case 'deactivated':
        return AppColors.error;
      case 'linked':
        return AppColors.info;
      default:
        return AppColors.grey;
    }
  }

  Color _getCodeTypeColor(BuildContext context) {
    switch (codeType.toLowerCase()) {
      case 'bundle':
        return AppColors.primary.withValues(alpha: 0.9);
      case 'carton':
        return AppColors.secondary.withValues(alpha: 0.9);
      case 'packet':
        return AppColors.accent.withValues(alpha: 0.9);
      case 'unit':
        return AppColors.success.withValues(alpha: 0.9);
      default:
        return AppColors.primary.withValues(alpha: 0.9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.primaryColor
              : isDark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
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
              // Header row with code and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (onSelectedChanged != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Checkbox(
                              value: isSelected,
                              onChanged: onSelectedChanged,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            code,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'RobotoMono',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(context),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Code type chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCodeTypeColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getCodeTypeColor(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      codeType.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _getCodeTypeColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Details section
              if (batchNumber != null || productName != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (batchNumber != null)
                      _buildDetailRow(
                        context,
                        Icons.layers,
                        'Batch: $batchNumber',
                      ),
                    if (productName != null)
                      _buildDetailRow(
                        context,
                        Icons.inventory_2,
                        'Product: $productName',
                      ),
                    const SizedBox(height: 8),
                  ],
                ),

              // Dates row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (generatedDate != null)
                    _buildDateInfo(
                      context,
                      'Generated',
                      generatedDate!,
                    ),
                  if (publishedDate != null)
                    _buildDateInfo(
                      context,
                      'Published',
                      publishedDate!,
                    ),
                ],
              ),

              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.8),
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context, String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.6),
              ),
        ),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
