import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/buttons/secondary_button.dart';
import 'package:nexatrace_system/shared/theme/typography.dart';
import 'package:nexatrace_system/shared/widgets/cards/info_card.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/billing/billing_bloc.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load invoice details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingBloc>().add(
        BillingEvent.loadInvoice(invoiceId: widget.invoiceId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              context.read<BillingBloc>().add(
                BillingEvent.downloadInvoice(invoiceId: widget.invoiceId),
              );
            },
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () {
              _showSendEmailDialog();
            },
            tooltip: 'Send via Email',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BillingBloc>().add(
                BillingEvent.loadInvoice(invoiceId: widget.invoiceId),
              );
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          // Handle download success
          if (state is BillingInvoiceDownloadSuccess) {
            if (state.invoiceId == widget.invoiceId) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice downloaded successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          }

          // Handle email sent success
          if (state is BillingInvoiceEmailSent) {
            if (state.invoiceId == widget.invoiceId) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice sent via email'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          }

          // Handle payment success
          if (state is BillingPaymentSuccess) {
            if (state.updatedInvoice.id == widget.invoiceId) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment of \$${state.payment.amount.toStringAsFixed(2)} successful',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(BillingState state) {
    if (state is BillingLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (state is BillingError) {
      return ErrorState(
        title: 'Invoice Error',
        message: state.message,
        onRetry: () {
          if (state.retryEvent != null) {
            context.read<BillingBloc>().add(state.retryEvent!);
          } else {
            context.read<BillingBloc>().add(
              BillingEvent.loadInvoice(invoiceId: widget.invoiceId),
            );
          }
        },
      );
    }

    if (state is BillingEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'Invoice Not Found',
        description: state.message,
        actionButton: PrimaryButton(
          text: 'Go Back',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }

    if (state is BillingInvoiceDetailLoaded) {
      return _buildInvoiceDetail(state);
    }

    if (state is BillingInvoiceDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(),
            const SizedBox(height: 16),
            Text(
              'Downloading invoice...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is BillingInvoiceEmailSending) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(),
            const SizedBox(height: 16),
            Text(
              'Sending invoice email...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is BillingPaymentProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(),
            const SizedBox(height: 16),
            Text(
              'Processing payment...',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Initial state
    return const Center(child: LoadingIndicator());
  }

  Widget _buildInvoiceDetail(BillingInvoiceDetailLoaded state) {
    final invoice = state.invoice;
    final payments = state.payments;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice Header
          _buildInvoiceHeader(invoice),

          const SizedBox(height: 24),

          // Invoice Status & Actions
          _buildStatusAndActions(invoice),

          const SizedBox(height: 24),

          // Invoice Items
          _buildInvoiceItems(invoice),

          const SizedBox(height: 24),

          // Payment Summary
          _buildPaymentSummary(invoice),

          const SizedBox(height: 24),

          // Payment History (if paid)
          if (invoice.status == InvoiceStatus.paid && payments != null)
            _buildPaymentHistory(payments),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader(Invoice invoice) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice #${invoice.invoiceNumber}',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Period: ${_formatDate(invoice.periodStart)} - ${_formatDate(invoice.periodEnd)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(invoice.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(invoice.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(invoice.status),
                  style: AppTypography.bodyMedium.copyWith(
                    color: _getStatusColor(invoice.status),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issue Date',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(invoice.issueDate),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Due Date',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(invoice.dueDate),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: invoice.status == InvoiceStatus.overdue
                          ? AppColors.error
                          : null,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${invoice.totalAmount.toStringAsFixed(2)} ${invoice.currency}',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAndActions(Invoice invoice) {
    return InfoCard(
      title: 'Invoice Actions',
      child: Column(
        children: [
          if (invoice.status == InvoiceStatus.pending ||
              invoice.status == InvoiceStatus.overdue) ...[
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Pay Now',
                    icon: Icons.payment,
                    onPressed: () {
                      _showPaymentDialog(invoice);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SecondaryButton(
                    text: 'Request Extension',
                    icon: Icons.calendar_today,
                    onPressed: () {
                      _showExtensionDialog(invoice);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: invoice.status == InvoiceStatus.paid
                    ? PrimaryButton(
                        text: 'Download PDF',
                        icon: Icons.download,
                        onPressed: () {
                          context.read<BillingBloc>().add(
                            BillingEvent.downloadInvoice(invoiceId: invoice.id),
                          );
                        },
                      )
                    : SecondaryButton(
                        text: 'Download PDF',
                        icon: Icons.download,
                        onPressed: () {
                          _showLockedDialog(invoice);
                        },
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  text: 'Send Email',
                  icon: Icons.email,
                  onPressed: () {
                    _showSendEmailDialog();
                  },
                ),
              ),
            ],
          ),
          if (invoice.status != InvoiceStatus.paid) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.lock, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invoice must be paid before downloading PDF',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceItems(Invoice invoice) {
    return InfoCard(
      title: 'Invoice Items',
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Unit Price',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Items list
          ...invoice.items.map((item) => _buildInvoiceItemRow(item)),
          const SizedBox(height: 16),
          _buildBillingBreakdown(invoice),
          const SizedBox(height: 16),
          // Totals
          _buildInvoiceTotals(invoice),
        ],
      ),
    );
  }

  Widget _buildInvoiceItemRow(InvoiceItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description, style: AppTypography.bodyMedium),
                if (item.codeType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${item.codeType} • Count: ${item.codeCount ?? 0}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (item.periodStart != null && item.periodEnd != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Period: ${_formatDate(item.periodStart!)} - ${_formatDate(item.periodEnd!)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Text(
              item.quantity.toStringAsFixed(0),
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '\$${item.unitPrice.toStringAsFixed(2)}',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              '\$${item.total.toStringAsFixed(2)}',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingBreakdown(Invoice invoice) {
    final publishItem = invoice.items.cast<InvoiceItem?>().firstWhere(
          (i) => (i?.metadata?['source']?.toString() ?? '') == 'publish_codes',
          orElse: () => null,
        );
    if (publishItem == null) return const SizedBox.shrink();

    final monthlyFee =
        (publishItem.metadata?['monthly_fee'] as num?)?.toDouble() ?? 0.0;
    final rate =
        (publishItem.metadata?['rate'] as num?)?.toDouble() ?? publishItem.unitPrice;
    final billableCount =
        (publishItem.metadata?['billable_count'] as num?)?.toDouble() ??
        publishItem.quantity;
    final freeApplied =
        (publishItem.metadata?['free_applied'] as num?)?.toDouble() ?? 0.0;
    final codeCount = (publishItem.codeCount ?? 0).toDouble();

    final usageCharge = billableCount * rate;
    final monthlyTotal = monthlyFee + usageCharge;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing Breakdown',
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _buildTotalRow('Monthly Fee', monthlyFee),
          _buildTotalRow('Codes Published', codeCount),
          _buildTotalRow('Free Codes Applied', freeApplied),
          _buildTotalRow('Billed Codes', billableCount),
          _buildTotalRow('Per-Unit Rate', rate),
          const Divider(),
          _buildTotalRow('Usage Charge (Billed × Rate)', usageCharge),
          _buildTotalRow('Monthly Total (Fee + Usage)', monthlyTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildInvoiceTotals(Invoice invoice) {
    return Column(
      children: [
        _buildTotalRow('Subtotal', invoice.subtotal),
        _buildTotalRow('Tax', invoice.taxAmount),
        if (invoice.discountAmount > 0)
          _buildTotalRow('Discount', -invoice.discountAmount),
        const Divider(),
        _buildTotalRow('Total Amount', invoice.totalAmount, isTotal: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                : AppTypography.bodyMedium,
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? AppTypography.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  )
                : AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(Invoice invoice) {
    return InfoCard(
      title: 'Payment Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (invoice.paymentDate != null) ...[
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  'Paid on ${_formatDate(invoice.paymentDate!)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (invoice.paymentMethod != null) ...[
            Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(invoice.paymentMethod!),
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Paid via ${_getMethodText(invoice.paymentMethod!)}',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (invoice.paymentReference != null) ...[
            Row(
              children: [
                Icon(Icons.receipt, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Reference: ${invoice.paymentReference!}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (invoice.notes != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notes: ${invoice.notes!}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(List<Payment> payments) {
    return InfoCard(
      title: 'Payment History',
      child: Column(
        children: payments
            .map((payment) => _buildPaymentItem(payment))
            .toList(),
      ),
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment #${payment.id.substring(0, 8)}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getMethodColor(payment.method).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getMethodText(payment.method),
                  style: AppTypography.caption.copyWith(
                    color: _getMethodColor(payment.method),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount: \$${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatDate(payment.paymentDate),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (payment.reference != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reference: ${payment.reference!}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (payment.transactionId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Transaction: ${payment.transactionId!}',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Payment'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Invoice #${invoice.invoiceNumber}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount Due: \$${invoice.totalAmount.toStringAsFixed(2)}',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select payment method:',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 12),
              // Payment method options would go here
              // For now, show a simple message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Payment integration will be implemented based on available payment gateways.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Proceed to Payment',
            onPressed: () {
              Navigator.pop(context);
              // In a real implementation, this would navigate to payment screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment gateway integration required'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showExtensionDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Extension'),
        content: const Text(
          'You can request an extension for this invoice. '
          'An extension request will be sent to the billing department for approval.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Request Extension',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Extension request sent for approval'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLockedDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice Locked'),
        content: Text(
          'This invoice is currently ${_getStatusText(invoice.status).toLowerCase()}. '
          'You must pay the invoice before downloading the PDF.\n\n'
          'Amount due: \$${invoice.totalAmount.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Pay Now',
            onPressed: () {
              Navigator.pop(context);
              _showPaymentDialog(invoice);
            },
          ),
        ],
      ),
    );
  }

  void _showSendEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Invoice via Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the email address where you want to send the invoice:',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'example@company.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Send Invoice',
            onPressed: () {
              Navigator.pop(context);
              context.read<BillingBloc>().add(
                BillingEvent.sendInvoiceEmail(invoiceId: widget.invoiceId),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.pending:
        return AppColors.warning;
      case InvoiceStatus.overdue:
        return AppColors.error;
      case InvoiceStatus.draft:
        return AppColors.textSecondary;
      case InvoiceStatus.cancelled:
        return AppColors.textDisabled;
      case InvoiceStatus.refunded:
        return AppColors.info;
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.refunded:
        return 'Refunded';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.other:
        return Icons.payment;
    }
  }

  Color _getMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return AppColors.primary;
      case PaymentMethod.creditCard:
        return AppColors.info;
      case PaymentMethod.bankTransfer:
        return AppColors.success;
      case PaymentMethod.cash:
        return AppColors.warning;
      case PaymentMethod.other:
        return AppColors.textSecondary;
    }
  }

  String _getMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
