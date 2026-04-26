import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/invoice_model.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/screens/super_admin/billing/invoice_detail_screen.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/billing/invoice_status_badge.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart' as shared;
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/typography.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class PlatformInvoicesScreen extends StatefulWidget {
  const PlatformInvoicesScreen({super.key});

  @override
  State<PlatformInvoicesScreen> createState() => _PlatformInvoicesScreenState();
}

class _PlatformInvoicesScreenState extends State<PlatformInvoicesScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        _hasMore) {
      _page++;
      _load();
    }
  }

  void _load({bool reset = false}) {
    if (reset) {
      _page = 1;
      _hasMore = true;
    }

    context.read<BillingBloc>().add(
          BillingEvent.loadPlatformInvoices(
            page: _page,
            limit: _limit,
            searchQuery: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
          ),
        );
  }

  Future<void> _finalize(AdminInvoice invoice) async {
    if (invoice.status != shared.InvoiceStatus.draft) return;
    context.read<BillingBloc>().add(
          BillingEvent.updateInvoiceStatus(
            invoiceId: invoice.id,
            status: shared.InvoiceStatus.pending,
          ),
        );
  }

  Future<void> _markPaid(AdminInvoice invoice) async {
    if (invoice.status == shared.InvoiceStatus.paid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice is already paid')),
      );
      return;
    }
    if (invoice.status == shared.InvoiceStatus.draft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finalize invoice before marking paid')),
      );
      return;
    }

    final method = await showDialog<shared.PaymentMethod>(
      context: context,
      builder: (context) => const _MarkPaidDialog(),
    );
    if (method == null) return;

    await context.read<ApiClient>().post(
          '/admin/billing/invoices/${invoice.id}/mark-paid',
          body: {
            'payment_method': method == shared.PaymentMethod.cash
                ? 'cash'
                : 'bank_transfer',
            'payment_date': DateTime.now().toIso8601String(),
          },
        );

    if (!mounted) return;
    _load(reset: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice marked as paid')),
    );
  }

  Future<void> _addExtraCharge(AdminInvoice invoice) async {
    if (invoice.status == shared.InvoiceStatus.draft ||
        invoice.status == shared.InvoiceStatus.paid) {
      return;
    }

    final input = await showDialog<_ExtraChargeInput>(
      context: context,
      builder: (context) => const _ExtraChargeDialog(),
    );
    if (input == null) return;

    await context.read<ApiClient>().post(
          '/admin/billing/invoices/${invoice.id}/extra-charges',
          body: {
            'description': input.description,
            'unit_price': input.unitPrice,
            'quantity': input.quantity,
          },
        );

    if (!mounted) return;
    _load(reset: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Extra charge added')),
    );
  }

  void _openDetail(AdminInvoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(invoiceId: invoice.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Invoices'),
        actions: [
          IconButton(
            onPressed: () => _load(reset: true),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search invoice # or company...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(reset: true),
            ),
          ),
        ),
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          state.maybeWhen(
            platformInvoicesLoaded: (invoices, hasMore, currentPage) {
              setState(() {
                _hasMore = hasMore;
                _page = currentPage;
              });
            },
            invoiceStatusUpdated: (invoice, message) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
              _load(reset: true);
            },
            error: (message, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message), backgroundColor: AppColors.error),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const LoadingIndicator(),
            processing: () => const LoadingIndicator(),
            platformInvoicesLoaded: (invoices, hasMore, currentPage) {
              if (invoices.isEmpty) {
                return const Center(child: Text('No invoices found'));
              }

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Company Invoices',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _table(invoices),
                      if (hasMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
            orElse: () => const LoadingIndicator(),
          );
        },
      ),
    );
  }

  Widget _table(List<AdminInvoice> invoices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Company Name')),
                DataColumn(label: Text('Invoice #')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: invoices.map((inv) {
                final statusText = inv.status.toString().split('.').last;
                return DataRow(
                  cells: [
                    DataCell(Text(inv.companyName)),
                    DataCell(
                      Text(inv.invoiceNumber),
                      onTap: () => _openDetail(inv),
                    ),
                    DataCell(Text('\$${inv.totalAmount.toStringAsFixed(2)}')),
                    DataCell(InvoiceStatusBadge(status: statusText)),
                    DataCell(
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'view') {
                            _openDetail(inv);
                            return;
                          }
                          if (value == 'finalize') {
                            await _finalize(inv);
                            return;
                          }
                          if (value == 'paid') {
                            await _markPaid(inv);
                            return;
                          }
                          if (value == 'charge') {
                            await _addExtraCharge(inv);
                            return;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'view', child: Text('View Detail')),
                          PopupMenuItem(
                            value: 'finalize',
                            enabled: inv.status == shared.InvoiceStatus.draft,
                            child: const Text('Finalize (Draft -> Pending)'),
                          ),
                          PopupMenuItem(
                            value: 'paid',
                            enabled: inv.status == shared.InvoiceStatus.pending ||
                                inv.status == shared.InvoiceStatus.overdue,
                            child: const Text('Mark as Paid (Cash/Bank)'),
                          ),
                          PopupMenuItem(
                            value: 'charge',
                            enabled: inv.status == shared.InvoiceStatus.pending ||
                                inv.status == shared.InvoiceStatus.overdue,
                            child: const Text('Add Extra Charge'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class _MarkPaidDialog extends StatefulWidget {
  const _MarkPaidDialog();

  @override
  State<_MarkPaidDialog> createState() => _MarkPaidDialogState();
}

class _MarkPaidDialogState extends State<_MarkPaidDialog> {
  shared.PaymentMethod _method = shared.PaymentMethod.bankTransfer;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark as Paid'),
      content: DropdownButtonFormField<shared.PaymentMethod>(
        initialValue: _method,
        items: const [
          DropdownMenuItem(
            value: shared.PaymentMethod.bankTransfer,
            child: Text('Bank Transfer'),
          ),
          DropdownMenuItem(
            value: shared.PaymentMethod.cash,
            child: Text('Cash'),
          ),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() => _method = v);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _method),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class _ExtraChargeInput {
  final String description;
  final double unitPrice;
  final double quantity;

  const _ExtraChargeInput({
    required this.description,
    required this.unitPrice,
    required this.quantity,
  });
}

class _ExtraChargeDialog extends StatefulWidget {
  const _ExtraChargeDialog();

  @override
  State<_ExtraChargeDialog> createState() => _ExtraChargeDialogState();
}

class _ExtraChargeDialogState extends State<_ExtraChargeDialog> {
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');

  double _d(String s) => double.tryParse(s.trim()) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Extra Charge'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
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
        TextButton(
          onPressed: () {
            final description = _descCtrl.text.trim();
            if (description.isEmpty) return;
            Navigator.pop(
              context,
              _ExtraChargeInput(
                description: description,
                unitPrice: _d(_priceCtrl.text),
                quantity: _d(_qtyCtrl.text),
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }
}

