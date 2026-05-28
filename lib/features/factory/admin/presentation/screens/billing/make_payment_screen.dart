import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:trace_odd/shared/models/billing/invoice_model.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/cards/info_card.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<Invoice> _invoices = const [];
  Invoice? _selected;
  PaymentMethod _method = PaymentMethod.bankTransfer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingBloc>().add(
        const BillingEvent.loadInvoices(
          filter: BillingFilter(
            statuses: [InvoiceStatus.pending, InvoiceStatus.overdue],
            sortBy: 'dueDate',
            sortDesc: false,
            limit: 50,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _d(String s) {
    final v = double.tryParse(s.trim());
    return v == null ? 0.0 : v;
  }

  double _n(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0.0;
  }

  void _selectInvoice(Invoice invoice) {
    setState(() {
      _selected = invoice;
      _amountCtrl.text = invoice.totalAmount.toStringAsFixed(2);
    });
  }

  void _pay() {
    final invoice = _selected;
    if (invoice == null) return;

    final amount = _d(_amountCtrl.text);
    if (amount <= 0) return;

    context.read<BillingBloc>().add(
      BillingEvent.makePayment(
        invoiceId: invoice.id,
        amount: amount,
        paymentMethod: _method,
        reference: _referenceCtrl.text.trim().isEmpty
            ? null
            : _referenceCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BillingBloc>().add(
                const BillingEvent.loadInvoices(
                  filter: BillingFilter(
                    statuses: [InvoiceStatus.pending, InvoiceStatus.overdue],
                    sortBy: 'dueDate',
                    sortDesc: false,
                    limit: 50,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state is BillingInvoicesLoaded) {
            setState(() {
              _invoices = state.invoices;
              if (_selected == null && _invoices.isNotEmpty) {
                _selectInvoice(_invoices.first);
              } else if (_selected != null) {
                final match = _invoices
                    .where((i) => i.id == _selected!.id)
                    .toList();
                if (match.isNotEmpty) {
                  _selectInvoice(match.first);
                }
              }
            });
          }

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
          final isLoading = state is BillingLoading;
          final isPaying = state is BillingPaymentProcessing;

          if (isLoading && _invoices.isEmpty) {
            return const Center(child: LoadingIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  title: 'Outstanding Invoices',
                  child: _invoices.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No pending invoices found',
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          initialValue: _selected?.id,
                          decoration: const InputDecoration(
                            labelText: 'Select Invoice',
                            border: OutlineInputBorder(),
                          ),
                          items: _invoices
                              .map(
                                (inv) => DropdownMenuItem<String>(
                                  value: inv.id,
                                  child: Text(
                                    '${inv.invoiceNumber}  (\$${inv.totalAmount.toStringAsFixed(2)})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            final inv = _invoices
                                .where((i) => i.id == id)
                                .toList();
                            if (inv.isNotEmpty) _selectInvoice(inv.first);
                          },
                        ),
                ),
                const SizedBox(height: 16),
                if (_selected != null) ...[
                  _billingBreakdown(_selected!),
                  const SizedBox(height: 16),
                  _paymentForm(_selected!, isPaying: isPaying),
                ],
                if (isPaying) ...[
                  const SizedBox(height: 16),
                  const Center(child: LoadingIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _billingBreakdown(Invoice invoice) {
    final publishItem = invoice.items.cast<InvoiceItem?>().firstWhere(
      (i) => (i?.metadata?['source']?.toString() ?? '') == 'publish_codes',
      orElse: () => null,
    );

    if (publishItem == null) {
      return InfoCard(
        title: 'Billing Breakdown',
        child: Text(
          'No usage breakdown available for this invoice.',
          style: TextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final monthlyFee = _n(publishItem.metadata?['monthly_fee']);
    final rate = _n(publishItem.metadata?['rate']) == 0.0
        ? publishItem.unitPrice
        : _n(publishItem.metadata?['rate']);
    final billed = _n(publishItem.metadata?['billable_count']) == 0.0
        ? publishItem.quantity
        : _n(publishItem.metadata?['billable_count']);
    final freeApplied = _n(publishItem.metadata?['free_applied']);
    final totalUnits = (publishItem.codeCount ?? 0).toDouble();

    final usageCharge = billed * rate;
    final monthlyTotal = monthlyFee + usageCharge;

    return InfoCard(
      title: 'Billing Breakdown',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Total Units', totalUnits.toStringAsFixed(0)),
          _row('Free Applied', freeApplied.toStringAsFixed(0)),
          _row('Billed Codes', billed.toStringAsFixed(0)),
          _row('Rate', '\$${rate.toStringAsFixed(6)}'),
          const Divider(height: 24),
          _row('Monthly Fee', '\$${monthlyFee.toStringAsFixed(2)}'),
          _row(
            'Billed Amount (Billed × Rate)',
            '\$${usageCharge.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          _row(
            'Monthly Total (Fee + Usage)',
            '\$${monthlyTotal.toStringAsFixed(2)}',
            valueStyle: TextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentForm(Invoice invoice, {required bool isPaying}) {
    final amount = _d(_amountCtrl.text);
    final canPay = !isPaying && amount > 0;
    return InfoCard(
      title: 'Payment',
      child: Column(
        children: [
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
            items: PaymentMethod.values
                .map(
                  (m) =>
                      DropdownMenuItem(value: m, child: Text(_methodText(m))),
                )
                .toList(),
            onChanged: isPaying
                ? null
                : (v) {
                    if (v == null) return;
                    setState(() {
                      _method = v;
                    });
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _referenceCtrl,
            decoration: const InputDecoration(
              labelText: 'Reference (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'Pay Now',
              icon: Icons.check_circle,
              onPressed: _pay,
              isEnabled: canPay,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(value, style: valueStyle ?? TextStyles.bodyMedium),
        ],
      ),
    );
  }

  String _methodText(PaymentMethod method) {
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
}
