import 'package:flutter/material.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver_earnings.dart';

/// Earnings Summary Card Widget - Displays driver earnings summary in a card format
class EarningsSummaryCard extends StatelessWidget {
  final DriverEarnings earnings;

  const EarningsSummaryCard({
    super.key,
    required this.earnings,
  });

  @override
  Widget build(BuildContext context) {
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
                  'Earnings Summary',
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
                    color: earnings.isPaid
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    earnings.isPaid ? 'Paid' : 'Pending',
                    style: TextStyles.captionBold.copyWith(
                      color: earnings.isPaid
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Earnings breakdown
            _buildEarningsBreakdown(),

            const SizedBox(height: 16),

            // Payment status and details
            _buildPaymentDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdown() {
    return Column(
      children: [
        // Total earnings
        _buildEarningsRow(
          label: 'Total Earnings',
          value:
              '${earnings.currency} ${earnings.totalEarnings.toStringAsFixed(2)}',
          isTotal: true,
        ),
        const SizedBox(height: 12),

        // Breakdown
        _buildEarningsRow(
          label: 'Base Pay',
          value: '${earnings.currency} ${earnings.basePay.toStringAsFixed(2)}',
          isTotal: false,
        ),
        _buildEarningsRow(
          label: 'Commission',
          value:
              '${earnings.currency} ${earnings.commission.toStringAsFixed(2)}',
          isTotal: false,
        ),
        _buildEarningsRow(
          label: 'Bonuses',
          value: '${earnings.currency} ${earnings.bonuses.toStringAsFixed(2)}',
          isTotal: false,
        ),
        _buildEarningsRow(
          label: 'Deductions',
          value:
              '-${earnings.currency} ${earnings.deductions.toStringAsFixed(2)}',
          isTotal: false,
          isNegative: true,
        ),

        const Divider(height: 24, thickness: 1),

        // Net pay
        _buildEarningsRow(
          label: 'Net Pay',
          value: '${earnings.currency} ${earnings.netPay.toStringAsFixed(2)}',
          isTotal: true,
          isNetPay: true,
        ),
      ],
    );
  }

  Widget _buildEarningsRow({
    required String label,
    required String value,
    required bool isTotal,
    bool isNegative = false,
    bool isNetPay = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )
              : TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
        Text(
          value,
          style: (isTotal || isNetPay)
              ? TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isNetPay
                      ? AppColors.success
                      : isNegative
                          ? AppColors.error
                          : AppColors.textPrimary,
                )
              : TextStyles.bodySmall.copyWith(
                  color: isNegative ? AppColors.error : AppColors.textPrimary,
                  fontWeight: isNegative ? FontWeight.w600 : FontWeight.normal,
                ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Period: ${_formatDate(earnings.periodStart)} - ${_formatDate(earnings.periodEnd)}',
                style: TextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Deliveries summary
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Deliveries: ${earnings.successfulDeliveries}/${earnings.totalDeliveries} successful',
                style: TextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Success rate
          Row(
            children: [
              Icon(
                Icons.percent,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Success Rate: ${earnings.successRate.toStringAsFixed(1)}%',
                style: TextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Payment date (if paid)
          if (earnings.isPaid && earnings.paymentDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Paid on: ${_formatDate(earnings.paymentDate!)}',
                  style: TextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // Payment method (if available)
          if (earnings.paymentMethod != null &&
              earnings.paymentMethod!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Method: ${earnings.paymentMethod!}',
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
