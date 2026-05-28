import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/screens/billing/invoice_detail_screen.dart';
import 'package:trace_odd/shared/models/billing/invoice_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

class InvoicesListScreen extends StatefulWidget {
  final BillingFilter initialFilter;

  const InvoicesListScreen({super.key, required this.initialFilter});

  @override
  State<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen> {
  BillingFilter _filter = const BillingFilter();
  List<Invoice> _cachedInvoices = const [];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingBloc>().add(BillingEvent.loadInvoices(filter: _filter));
    });
  }

  void _refresh() {
    context.read<BillingBloc>().add(BillingEvent.loadInvoices(filter: _filter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state is BillingInvoiceDownloadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invoice downloaded successfully'),
                backgroundColor: AppColors.success,
              ),
            );

            _refresh();
          }
          if (state is BillingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BillingInvoicesLoaded) {
            _cachedInvoices = state.invoices;
          }

          if (state is BillingLoading || state is BillingInitial) {
            return const LoadingIndicator();
          }

          if (state is BillingEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long, size: 48, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(state.message, style: TextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          if (state is BillingInvoicesLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.invoices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final inv = state.invoices[index];
                final status = inv.status.toString().split('.').last;
                return Card(
                  child: ListTile(
                    title: Text(
                      inv.invoiceNumber,
                      style: TextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Status: $status',
                      style: TextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${inv.totalAmount.toStringAsFixed(2)}',
                          style: TextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: inv.status == InvoiceStatus.draft
                              ? null
                              : () {
                                  context.read<BillingBloc>().add(
                                        BillingEvent.downloadInvoice(invoiceId: inv.id),
                                      );
                                },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InvoiceDetailScreen(invoiceId: inv.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceDetailScreen(invoiceId: inv.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          if (_cachedInvoices.isNotEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _cachedInvoices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final inv = _cachedInvoices[index];
                final status = inv.status.toString().split('.').last;
                final isDownloading =
                    state is BillingInvoiceDownloading && state.invoiceId == inv.id;

                return Card(
                  child: ListTile(
                    title: Text(
                      inv.invoiceNumber,
                      style: TextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      isDownloading ? 'Downloading...' : 'Status: $status',
                      style: TextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${inv.totalAmount.toStringAsFixed(2)}',
                          style: TextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: inv.status == InvoiceStatus.draft
                              ? null
                              : () {
                                  context.read<BillingBloc>().add(
                                        BillingEvent.downloadInvoice(invoiceId: inv.id),
                                      );
                                },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InvoiceDetailScreen(invoiceId: inv.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceDetailScreen(invoiceId: inv.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const LoadingIndicator();
        },
      ),
    );
  }
}

