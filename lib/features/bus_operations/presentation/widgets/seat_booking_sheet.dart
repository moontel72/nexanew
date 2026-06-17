// NEXATRACE — SEAT BOOKING BOTTOM SHEET
// =======================================
// Modal bottom sheet for confirming seat booking with
// payment method selection, voucher entry, and price
// breakdown.
//
// MODULE: 8V — Interactive Seat Selection

import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/data/models/passenger_seat_model.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/seat_selection/seat_selection_bloc.dart';

/// Bottom sheet for confirming a seat booking.
class SeatBookingSheet extends StatefulWidget {
  final PassengerSeatModel seat;
  final PaymentMethod currentMethod;
  final double basePrice;
  final String? voucherCode;
  final VoidCallback onConfirm;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final ValueChanged<String> onVoucherChanged;
  final VoidCallback onCancel;

  const SeatBookingSheet({
    super.key,
    required this.seat,
    required this.currentMethod,
    this.basePrice = 500,
    this.voucherCode,
    required this.onConfirm,
    required this.onMethodChanged,
    required this.onVoucherChanged,
    required this.onCancel,
  });

  @override
  State<SeatBookingSheet> createState() => _SeatBookingSheetState();
}

class _SeatBookingSheetState extends State<SeatBookingSheet> {
  final _voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.voucherCode != null) {
      _voucherController.text = widget.voucherCode!;
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SeatInfoHeader(seat: widget.seat, basePrice: widget.basePrice),
              const SizedBox(height: 24),
              Text('Payment Method',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _PaymentMethodSelector(
                current: widget.currentMethod,
                onChanged: widget.onMethodChanged,
              ),
              const SizedBox(height: 20),
              if (widget.currentMethod == PaymentMethod.voucher) ...[
                TextField(
                  controller: _voucherController,
                  decoration: InputDecoration(
                    labelText: 'Voucher Code',
                    hintText: 'Enter 8-digit voucher code',
                    prefixIcon: const Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: widget.onVoucherChanged,
                ),
                const SizedBox(height: 20),
              ],
              _PriceBreakdown(
                basePrice: widget.basePrice,
                method: widget.currentMethod,
                voucherCode: widget.voucherCode,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: widget.onConfirm,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Confirm Booking — Rs. ${widget.basePrice.toInt()}'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatInfoHeader extends StatelessWidget {
  final PassengerSeatModel seat;
  final double basePrice;
  const _SeatInfoHeader({required this.seat, required this.basePrice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = switch (seat.category) {
      PassengerSeatCategory.businessClass => 'Business Class',
      PassengerSeatCategory.sleeper => 'Sleeper Berth',
      PassengerSeatCategory.folding => 'Folding Seat',
      _ => 'Standard Seat',
    };

    return Row(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(seat.displayLabel,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF3B82F6))),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seat ${seat.displayLabel}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('$typeLabel · Rs. ${basePrice.toInt()}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod current;
  final ValueChanged<PaymentMethod> onChanged;
  const _PaymentMethodSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PaymentMethod.values.map((method) {
        final isSelected = method == current;
        final (icon, label) = switch (method) {
          PaymentMethod.wallet => (Icons.account_balance_wallet, 'Wallet'),
          PaymentMethod.card => (Icons.credit_card, 'Card'),
          PaymentMethod.voucher => (Icons.card_giftcard, 'Voucher'),
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: method != PaymentMethod.values.last ? 8 : 0),
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: Icon(icon, size: 18),
              label: Text(label),
              onSelected: (_) => onChanged(method),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final double basePrice;
  final PaymentMethod method;
  final String? voucherCode;
  const _PriceBreakdown({required this.basePrice, required this.method, this.voucherCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fee = method == PaymentMethod.card ? basePrice * 0.03 : 0.0;
    final total = basePrice + fee;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _PriceRow('Ticket price', 'Rs. ${basePrice.toInt()}'),
          if (fee > 0) _PriceRow('Card fee (3%)', 'Rs. ${fee.toInt()}'),
          const Divider(height: 20),
          _PriceRow('Total', 'Rs. ${total.toInt()}', isBold: true),
          if (method == PaymentMethod.voucher && voucherCode != null) ...[
            const SizedBox(height: 8),
            Text('Change returned to wallet automatically',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: const Color(0xFF16A34A), fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _PriceRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value,
              style: (isBold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)
                  ?.copyWith(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
