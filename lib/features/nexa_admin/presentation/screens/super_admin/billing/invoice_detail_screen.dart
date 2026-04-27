import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/core/utils/file_saver.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/invoice_model.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/invoices/invoice_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/billing/invoice_status_badge.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/billing/payment_timeline_widget.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart' as shared;
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/typography.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<InvoiceBloc>().add(LoadInvoiceDetail(invoiceId: widget.invoiceId));
    context.read<InvoiceBloc>().add(LoadInvoicePayments(invoiceId: widget.invoiceId));
  }

  double _n(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0.0;
  }

  String _s(dynamic value, {String fallback = ''}) {
    final v = value?.toString().trim() ?? '';
    return v.isEmpty ? fallback : v;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            context.go('/billing/invoices');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const LoadingIndicator(),
            processing: () => const LoadingIndicator(),
            invoiceDetailLoaded: (invoice, payments, message) {
              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(invoice, dateFormat, money),
                      const SizedBox(height: 16),
                      _billingBreakdown(invoice, money),
                      const SizedBox(height: 16),
                      _lineItems(invoice, money),
                      const SizedBox(height: 16),
                      _usageBreakdown(invoice),
                      const SizedBox(height: 16),
                      _payments(invoice, payments),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
            error: (message, error) => ErrorState.generic(
              title: 'Error',
              message: message,
              onRetry: _load,
            ),
            orElse: () => const LoadingIndicator(),
          );
        },
      ),
    );
  }

  Widget _header(AdminInvoice invoice, DateFormat dateFormat, NumberFormat money) {
    final statusText = invoice.status.toString().split('.').last;
    final currency = invoice.currency.isEmpty ? 'USD' : invoice.currency;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    invoice.invoiceNumber,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InvoiceStatusBadge(status: statusText),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _downloadPdf(invoice),
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _kv('Company', invoice.companyName),
                _kv('Plan', invoice.subscriptionName),
                _kv('Issue', dateFormat.format(invoice.issueDate)),
                _kv('Due', dateFormat.format(invoice.dueDate)),
                _kv(
                  'Period',
                  '${dateFormat.format(invoice.periodStart)} - ${dateFormat.format(invoice.periodEnd)}',
                ),
                _kv('Total', '${money.format(invoice.totalAmount)} $currency'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(AdminInvoice invoice) async {
    try {
      final bytes = await context
          .read<ApiClient>()
          .getBytes('/admin/billing/invoices/${invoice.id}/pdf');

      final safeNumber = invoice.invoiceNumber.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      await saveBytesToDownload(
        bytes,
        filename: 'invoice_$safeNumber.pdf',
        mimeType: 'application/pdf',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice PDF downloaded')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
    }
  }

  Widget _billingBreakdown(AdminInvoice invoice, NumberFormat money) {
    final AdminInvoiceItem? publishItem = invoice.items
        .cast<AdminInvoiceItem?>()
        .firstWhere(
          (i) => i != null && _s(i.metadata?['source']) == 'publish_codes',
          orElse: () => null,
        );
    if (publishItem == null) return const SizedBox.shrink();

    final meta = publishItem.metadata ?? const <String, dynamic>{};
    final monthlyFee = _n(meta['monthly_fee']);
    final rate = _n(meta['rate']) == 0.0 ? publishItem.unitPrice : _n(meta['rate']);
    final billedCodes = _n(meta['billable_count']) == 0.0
        ? publishItem.quantity
        : _n(meta['billable_count']);
    final freeApplied = _n(meta['free_applied']);
    final published = (publishItem.codeCount ?? 0).toDouble();
    final usageCharge = billedCodes * rate;
    final monthlyTotal = monthlyFee + usageCharge;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Breakdown',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _row2('Codes Published', published.toStringAsFixed(0)),
            _row2('Free Applied', freeApplied.toStringAsFixed(0)),
            _row2('Billed Codes', billedCodes.toStringAsFixed(0)),
            _row2('Rate', money.format(rate)),
            const Divider(height: 24),
            _row2('Monthly Fee', money.format(monthlyFee)),
            _row2('Usage Charge', money.format(usageCharge)),
            const Divider(height: 24),
            _row2(
              'Monthly Total (Fee + Usage)',
              money.format(monthlyTotal),
              valueStyle: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineItems(AdminInvoice invoice, NumberFormat money) {
    final currency = invoice.currency.isEmpty ? 'USD' : invoice.currency;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Line Items',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Total')),
                      ],
                      rows: invoice.items.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item.description)),
                            DataCell(Text(item.quantity.toStringAsFixed(2))),
                            DataCell(Text(money.format(item.unitPrice))),
                            DataCell(Text('${money.format(item.total)} $currency')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageBreakdown(AdminInvoice invoice) {
    final isPublishCodes = invoice.items.any(
      (i) => _s(i.metadata?['source']) == 'publish_codes',
    );
    if (!isPublishCodes) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Usage Breakdown',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            FutureBuilder<dynamic>(
              future: context
                  .read<ApiClient>()
                  .get('/admin/billing/invoices/${invoice.id}/usage-breakdown'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Text('No usage data');
                }

                final data = snapshot.data;
                final rows = (data is Map ? (data['data']?['rows'] as List?) : null) ??
                    const [];
                if (rows.isEmpty) {
                  return const Text('No usage data');
                }

                final parsed = rows
                    .whereType<Map>()
                    .map((r) => r.cast<String, dynamic>())
                    .toList();

                final hasUnit = parsed.any((r) => _s(r['code_type']).toLowerCase() == 'unit');
                final totalsByDay = <String, int>{};
                var totalUnits = 0;

                for (final r in parsed) {
                  final day = _s(r['day']);
                  final codeType = _s(r['code_type']).toLowerCase();
                  final count = int.tryParse(_s(r['count'], fallback: '0')) ?? 0;
                  if (hasUnit && codeType != 'unit') continue;
                  totalsByDay[day] = (totalsByDay[day] ?? 0) + count;
                  totalUnits += count;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Units (${DateFormat('MMM dd, yyyy').format(invoice.periodStart)} - '
                      '${DateFormat('MMM dd, yyyy').format(invoice.periodEnd)}): $totalUnits',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Units')),
                              ],
                              rows: totalsByDay.entries.map<DataRow>((e) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(e.key)),
                                    DataCell(Text(e.value.toString())),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _payments(AdminInvoice invoice, List<shared.Payment> payments) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payments',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              const Text('No payments recorded')
            else
              PaymentTimelineWidget(
                payments: payments,
                invoiceTotal: invoice.totalAmount,
                invoiceDueDate: invoice.dueDate,
              ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          k,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          v,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _row2(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: valueStyle ?? AppTypography.bodyMedium),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

