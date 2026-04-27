import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/buttons/secondary_button.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';
import 'package:nexatrace_system/shared/widgets/cards/info_card.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/billing/invoice_detail_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/billing/invoices_list_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/billing/make_payment_screen.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/screens/billing/payment_history_screen.dart';

class BillingDashboardScreen extends StatefulWidget {
  const BillingDashboardScreen({super.key});

  @override
  State<BillingDashboardScreen> createState() => _BillingDashboardScreenState();
}

class _BillingDashboardScreenState extends State<BillingDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load billing summary when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingBloc>().add(const BillingEvent.loadBillingSummary());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistoryScreen(),
                ),
              );
            },
            tooltip: 'Payment History',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BillingBloc>().add(const BillingEvent.refresh());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          // Handle payment success
          if (state is BillingPaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment of \$${state.payment.amount.toStringAsFixed(2)} successful',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }

          // Handle invoice download success
          if (state is BillingInvoiceDownloadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invoice downloaded successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }

          // Handle invoice email sent
          if (state is BillingInvoiceEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invoice sent via email'),
                backgroundColor: AppColors.success,
              ),
            );
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
        title: 'Billing Error',
        message: state.message,
        onRetry: () {
          if (state.retryEvent != null) {
            context.read<BillingBloc>().add(state.retryEvent!);
          } else {
            context.read<BillingBloc>().add(
              const BillingEvent.loadBillingSummary(),
            );
          }
        },
      );
    }

    if (state is BillingEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No Billing Data',
        description: state.message,
        actionButton: PrimaryButton(
          text: 'Refresh',
          onPressed: () {
            context.read<BillingBloc>().add(
              const BillingEvent.loadBillingSummary(),
            );
          },
        ),
      );
    }

    if (state is BillingSummaryLoaded) {
      return _buildDashboard(state);
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
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
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
              style: TextStyles.bodyMedium.copyWith(
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
              style: TextStyles.bodyMedium.copyWith(
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

  Widget _buildDashboard(BillingSummaryLoaded state) {
    final summary = state.summary;
    final recentInvoices = state.recentInvoices;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Overview Section
          _buildBalanceOverview(summary),

          const SizedBox(height: 24),

          // Quick Actions Section
          _buildQuickActions(),

          const SizedBox(height: 24),

          // Recent Invoices Section
          _buildRecentInvoices(recentInvoices, state.hasMoreInvoices),

          const SizedBox(height: 24),

          // Usage Summary Section (if available)
          if (summary.usageSummary != null && summary.usageSummary!.isNotEmpty)
            _buildUsageSummary(summary.usageSummary!),
        ],
      ),
    );
  }

  Widget _buildBalanceOverview(BillingSummary summary) {
    return InfoCard(
      title: 'Balance Overview',
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
                    'Total Owed',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${summary.totalOwed.toStringAsFixed(2)}',
                    style: TextStyles.headlineMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Paid',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${summary.totalPaid.toStringAsFixed(2)}',
                    style: TextStyles.headlineMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Pending',
                summary.pendingInvoices.toString(),
                Icons.pending,
                AppColors.warning,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Paid',
                summary.paidInvoices.toString(),
                Icons.check_circle,
                AppColors.success,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Overdue',
                summary.overdueInvoices.toString(),
                Icons.warning,
                AppColors.error,
              ),
            ],
          ),
          if (summary.nextPaymentDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Next payment: \$${summary.nextPaymentAmount?.toStringAsFixed(2) ?? '0.00'} '
                      'due on ${_formatDate(summary.nextPaymentDate!)}',
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha((0.2 * 255).round())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return InfoCard(
      title: 'Quick Actions',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SecondaryButton(
            text: 'View All Invoices',
            icon: Icons.list,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoicesListScreen(
                    initialFilter: BillingFilter(
                      sortBy: 'issueDate',
                      sortDesc: true,
                      statuses: [
                        InvoiceStatus.pending,
                        InvoiceStatus.overdue,
                        InvoiceStatus.paid,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          PrimaryButton(
            text: 'Make Payment',
            icon: Icons.payment,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MakePaymentScreen(),
                ),
              );
            },
          ),
          SecondaryButton(
            text: 'Download Reports',
            icon: Icons.download,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoicesListScreen(
                    initialFilter: BillingFilter(
                      sortBy: 'issueDate',
                      sortDesc: true,
                      statuses: [
                        InvoiceStatus.pending,
                        InvoiceStatus.overdue,
                        InvoiceStatus.paid,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInvoices(List<Invoice> invoices, bool hasMore) {
    return InfoCard(
      title: 'Recent Invoices',
      action: hasMore
          ? TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoicesListScreen(
                      initialFilter: BillingFilter(
                        sortBy: 'issueDate',
                        sortDesc: true,
                        statuses: [
                          InvoiceStatus.pending,
                          InvoiceStatus.overdue,
                          InvoiceStatus.paid,
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Text('View All'),
            )
          : null,
      child: invoices.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No invoices found',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : Column(
              children: invoices
                  .map((invoice) => _buildInvoiceItem(invoice))
                  .toList(),
            ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailScreen(invoiceId: invoice.id),
            ),
          );
        },
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(invoice.status),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // Invoice details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${invoice.totalAmount.toStringAsFixed(2)}',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Issued: ${_formatDate(invoice.issueDate)}',
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            invoice.status,
                          ).withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(invoice.status),
                          style: TextStyles.caption.copyWith(
                            color: _getStatusColor(invoice.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action button
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InvoiceDetailScreen(invoiceId: invoice.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSummary(Map<String, dynamic> usageSummary) {
    return InfoCard(
      title: 'Usage Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (usageSummary['unit_codes'] != null)
            _buildUsageItem(
              'Unit Codes',
              '${usageSummary['unit_codes']['used']} / ${usageSummary['unit_codes']['limit']}',
              usageSummary['unit_codes']['used'] /
                  (usageSummary['unit_codes']['limit'] ?? 1),
            ),
          if (usageSummary['packet_codes'] != null)
            _buildUsageItem(
              'Packet Codes',
              '${usageSummary['packet_codes']['used']} / ${usageSummary['packet_codes']['limit']}',
              usageSummary['packet_codes']['used'] /
                  (usageSummary['packet_codes']['limit'] ?? 1),
            ),
          if (usageSummary['carton_codes'] != null)
            _buildUsageItem(
              'Carton Codes',
              '${usageSummary['carton_codes']['used']} / ${usageSummary['carton_codes']['limit']}',
              usageSummary['carton_codes']['used'] /
                  (usageSummary['carton_codes']['limit'] ?? 1),
            ),
          if (usageSummary['bundle_codes'] != null)
            _buildUsageItem(
              'Bundle Codes',
              '${usageSummary['bundle_codes']['used']} / ${usageSummary['bundle_codes']['limit']}',
              usageSummary['bundle_codes']['used'] /
                  (usageSummary['bundle_codes']['limit'] ?? 1),
            ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String label, String value, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyles.bodyMedium),
              Text(
                value,
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            color: percentage >= 0.9
                ? AppColors.error
                : percentage >= 0.7
                ? AppColors.warning
                : AppColors.success,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
