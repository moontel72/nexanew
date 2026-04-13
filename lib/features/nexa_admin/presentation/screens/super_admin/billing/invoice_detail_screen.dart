import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/typography.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/invoices/invoice_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/billing/invoice_status_badge.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/billing/payment_timeline_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/cards/data_card.dart';

/// Invoice Detail Screen
/// Displays detailed information about a specific invoice
class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInvoiceDetail();
  }

  void _loadInvoiceDetail() {
    context.read<InvoiceBloc>().add(
          LoadInvoiceDetail(invoiceId: widget.invoiceId),
        );
  }

  void _loadInvoicePayments() {
    context.read<InvoiceBloc>().add(
          LoadInvoicePayments(invoiceId: widget.invoiceId),
        );
  }

  void _handleRefresh() {
    _loadInvoiceDetail();
    _loadInvoicePayments();
  }

  void _navigateToCompanyInvoices(String companyId) {
    context.go('/super-admin/billing/companies/$companyId/invoices');
  }

  void _navigateToRecordPayment() {
    context.go('/super-admin/billing/invoices/${widget.invoiceId}/record-payment');
  }

  void _navigateToEditInvoice() {
    context.go('/super-admin/billing/invoices/${widget.invoiceId}/edit');
  }

  void _sendInvoiceReminder() {
    context.read<InvoiceBloc>().add(
          SendInvoiceReminder(invoiceId: widget.invoiceId),
        );
  }

  void _exportInvoice() {
    context.read<InvoiceBloc>().add(
          ExportInvoiceDetail(invoiceId: widget.invoiceId),
        );
  }

  void _validateInvoice() {
    context.read<InvoiceBloc>().add(
          ValidateInvoice(invoiceId: widget.invoiceId),
        );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildActionMenu(),
    );
  }

  Widget _buildActionMenu() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Invoice'),
            onTap: () {
              Navigator.pop(context);
              _navigateToEditInvoice();
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Record Payment'),
            onTap: () {
              Navigator.pop(context);
              _navigateToRecordPayment();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Send Reminder'),
            onTap: () {
              Navigator.pop(context);
              _sendInvoiceReminder();
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Invoice'),
            onTap: () {
              Navigator.pop(context);
              _exportInvoice();
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('Validate Invoice'),
            onTap: () {
              Navigator.pop(context);
              _validateInvoice();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showActionMenu,
            tooltip: 'More Actions',
          ),
        ],
      ),
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          state.maybeWhen(
            invoiceReminderSent: (invoiceId, reminderType, message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            invoiceExported: (invoiceId, format, exportData, message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            invoiceValidated: (invoiceId, isValid, message, warnings) {
              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            error: (message, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            invoiceDetailLoaded: (invoice, payments, message) =>
                _buildInvoiceDetail(invoice, payments),
            loading: () => const LoadingIndicator(),
            processing: () => const LoadingIndicator(),
            error: (message, error) => ErrorState.generic(
              title: 'Error',
              message: message,
              onRetry: _handleRefresh,
            ),
            orElse: () => const LoadingIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceDetail(dynamic invoice, List<dynamic> payments) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header
            _buildInvoiceHeader(invoice, dateFormat),
            const SizedBox(height: 24),

            // Company Information
            _buildCompanyInfo(invoice),
            const SizedBox(height: 24),

            // Invoice Items
            _buildInvoiceItems(invoice, currencyFormat),
            const SizedBox(height: 24),

            // Totals Summary
            _buildTotalsSummary(invoice, currencyFormat),
            const SizedBox(height: 24),

            // Payment Timeline
            if (payments.isNotEmpty)
              PaymentTimelineWidget(
                payments: payments.cast(),
                invoiceTotal: invoice['totalAmount'] ?? 0.0,
                invoiceDueDate: DateTime.parse(invoice['dueDate']),
              ),
            const SizedBox(height: 24),

            // Notes
            if (invoice['notes'] != null && invoice['notes'].isNotEmpty)
              _buildNotesSection(invoice),
            const SizedBox(height: 24),

            // Admin Notes
            if (invoice['adminNotes'] != null && invoice['adminNotes'].isNotEmpty)
              _buildAdminNotesSection(invoice),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader(dynamic invoice, DateFormat dateFormat) {
    final invoiceNumber = invoice['invoiceNumber'] ?? '';
    final status = invoice['status'] ?? 'pending';
    final issueDate = invoice['issueDate'] != null
        ? DateTime.parse(invoice['issueDate']).toLocal()
        : null;
    final dueDate = invoice['dueDate'] != null
        ? DateTime.parse(invoice['dueDate']).toLocal()
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoiceNumber,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invoice',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                InvoiceStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
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
                        issueDate != null
                            ? dateFormat.format(issueDate)
                            : 'Not set',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dueDate != null
                            ? dateFormat.format(dueDate)
                            : 'Not set',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dueDate != null && dueDate.isBefore(DateTime.now())
                              ? AppColors.error
                              : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(dynamic invoice) {
    final companyName = invoice['companyName'] ?? 'Unknown';
    final companyId = invoice['companyId'] ?? '';

    return DataCard(
      title: 'Company Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                companyName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              companyName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'ID: $companyId',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _navigateToCompanyInvoices(companyId),
              iconSize: 16,
            ),
            onTap: () => _navigateToCompanyInvoices(companyId),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItems(dynamic invoice, NumberFormat currencyFormat) {
    final items = invoice['items'] ?? [];
    if (items.isEmpty) {
      return DataCard(
        title: 'Invoice Items',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No items found',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return DataCard(
      title: 'Invoice Items (${items.length})',
      child: Column(
        children: [
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _buildInvoiceItem(item, currencyFormat),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(dynamic item, NumberFormat currencyFormat) {
    final description = item['description'] ?? '';
    final quantity = item['quantity'] ?? 0.0;
    final unitPrice = item['unitPrice'] ?? 0.0;
    final total = item['total'] ?? 0.0;
    final codeType = item['codeType'];
    final codeCount = item['codeCount'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                currencyFormat.format(total),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quantity.toStringAsFixed(2)} × ${currencyFormat.format(unitPrice)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (codeType != null && codeCount != null)
                Chip(
                  label: Text(
                    '$codeCount ${codeType.replaceAll('_', ' ')}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSummary(dynamic invoice, NumberFormat currencyFormat) {
    final subtotal = invoice['subtotal'] ?? 0.0;
    final taxAmount = invoice['taxAmount'] ?? 0.0;
    final discountAmount = invoice['discountAmount'] ?? 0.0;
    final totalAmount = invoice['totalAmount'] ?? 0.0;
    final currency = invoice['currency'] ?? 'USD';

    return DataCard(
      title: 'Totals Summary',
      child: Column(
        children: [
          _buildTotalRow('Subtotal', subtotal, currencyFormat),
          _buildTotalRow('Tax', taxAmount, currencyFormat),
          if (discountAmount > 0)
            _buildTotalRow('Discount', -discountAmount, currencyFormat,
                isDiscount: true),
          const Divider(height: 24),
          _buildTotalRow(
            'Total',
            totalAmount,
            currencyFormat,
            isTotal: true,
          ),
          const SizedBox(height: 8),
          Text(
            'Amount in $currency',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount,
    NumberFormat currencyFormat, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
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
            isDiscount
                ? '-${currencyFormat.format(amount.abs())}'
                : currencyFormat.format(amount),
            style: (isTotal
                ? AppTypography.headlineSmall
                : AppTypography.bodyMedium).copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isDiscount ? AppColors.error : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(dynamic invoice) {
    return DataCard(
      title: 'Notes',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          invoice['notes'],
          style: AppTypography.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildAdminNotesSection(dynamic invoice) {
    return DataCard(
      title: 'Admin Notes',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice['adminNotes'],
              style: AppTypography.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            if (invoice['requiresFollowUp'] == true)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Requires follow-up',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (invoice['followUpDate'] != null) const SizedBox(height: 8),
            if (invoice['followUpDate'] != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Follow-up date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(invoice['followUpDate']))}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    )
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
