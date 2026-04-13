import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;

/// Payment Timeline Widget
/// Displays payment history and timeline for an invoice
class PaymentTimelineWidget extends StatelessWidget {
  final List<shared.Payment> payments;
  final double invoiceTotal;
  final DateTime invoiceDueDate;
  final bool showStatus;
  final bool interactive;

  const PaymentTimelineWidget({
    super.key,
    required this.payments,
    required this.invoiceTotal,
    required this.invoiceDueDate,
    this.showStatus = true,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final sortedPayments = List<shared.Payment>.from(payments)
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    final totalPaid = payments.fold(
      0.0,
      (sum, payment) => sum + payment.amount,
    );
    final remainingBalance = invoiceTotal - totalPaid;
    final isFullyPaid = totalPaid >= invoiceTotal;
    final isOverdue = !isFullyPaid && invoiceDueDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with payment summary
            _buildPaymentSummary(totalPaid, remainingBalance, isFullyPaid),
            const SizedBox(height: 16),

            // Timeline
            if (sortedPayments.isNotEmpty) ...[
              Text(
                'Payment History',
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...sortedPayments.map((payment) {
                return _buildPaymentItem(payment);
              }),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.payments, size: 48, color: AppColors.gray400),
                      const SizedBox(height: 16),
                      Text(
                        'No payments recorded',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payments will appear here once received',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Due date warning
            if (isOverdue && showStatus) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice Overdue',
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due date was ${DateFormat('MMM dd, yyyy').format(invoiceDueDate)}',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(
    double totalPaid,
    double remainingBalance,
    bool isFullyPaid,
  ) {
    final progress = invoiceTotal > 0 ? totalPaid / invoiceTotal : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Summary',
              style: TextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isFullyPaid
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFullyPaid
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFullyPaid ? Icons.check_circle : Icons.pending,
                    size: 14,
                    color: isFullyPaid ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFullyPaid ? 'Paid in Full' : 'Partial Payment',
                    style: TextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isFullyPaid
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid: \$${totalPaid.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'Total: \$${invoiceTotal.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.gray300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : AppColors.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% paid',
              style: TextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        if (remainingBalance > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance Due: \$${remainingBalance.toStringAsFixed(2)}',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due date: ${DateFormat('MMM dd, yyyy').format(invoiceDueDate)}',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentItem(shared.Payment payment) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getPaymentMethodColor(payment.method).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(payment.method),
              size: 20,
              color: _getPaymentMethodColor(payment.method),
            ),
          ),
          const SizedBox(width: 12),

          // Payment details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${payment.amount.toStringAsFixed(2)}',
                      style: TextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      dateFormat.format(payment.paymentDate),
                      style: TextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getPaymentMethodLabel(payment.method),
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (payment.reference != null &&
                    payment.reference!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Reference: ${payment.reference}',
                    style: TextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.notes!,
                    style: TextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${timeFormat.format(payment.paymentDate)} • ${payment.currency}',
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentMethodColor(shared.PaymentMethod method) {
    switch (method) {
      case shared.PaymentMethod.creditCard:
        return AppColors.primary;
      case shared.PaymentMethod.bankTransfer:
        return AppColors.info;
      case shared.PaymentMethod.wallet:
        return AppColors.success;
      case shared.PaymentMethod.cash:
        return AppColors.warning;
      case shared.PaymentMethod.other:
        return AppColors.textSecondary;
    }
  }

  IconData _getPaymentMethodIcon(shared.PaymentMethod method) {
    switch (method) {
      case shared.PaymentMethod.creditCard:
        return Icons.credit_card;
      case shared.PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case shared.PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case shared.PaymentMethod.cash:
        return Icons.money;
      case shared.PaymentMethod.other:
        return Icons.payments;
    }
  }

  String _getPaymentMethodLabel(shared.PaymentMethod method) {
    switch (method) {
      case shared.PaymentMethod.creditCard:
        return 'Credit Card Payment';
      case shared.PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case shared.PaymentMethod.wallet:
        return 'Wallet Payment';
      case shared.PaymentMethod.cash:
        return 'Cash Payment';
      case shared.PaymentMethod.other:
        return 'Other Payment Method';
    }
  }
}
