// NEXATRACE — PASSENGER SEAT SELECTION SCREEN
// ==============================================
// Full interactive seat booking experience for the
// Customer App (Module 8V). Displays the bus floor-plan
// with color-coded tappable seats, payment flow, and
// booking confirmation. Auto-saves tickets to Hive vault.
//
// MODULE: 8V — Unified Bus Transit Terminal

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/data/models/passenger_seat_model.dart';
import 'package:trace_odd/features/bus_operations/data/services/ticket_vault_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/seat_selection/seat_selection_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/passenger_seat_painter.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/seat_booking_sheet.dart';

class PassengerSeatSelectionScreen extends StatefulWidget {
  final String layoutId;
  final String? tripId;
  const PassengerSeatSelectionScreen({
    super.key,
    required this.layoutId,
    this.tripId,
  });
  @override
  State<PassengerSeatSelectionScreen> createState() =>
      _PassengerSeatSelectionScreenState();
}

class _PassengerSeatSelectionScreenState
    extends State<PassengerSeatSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final SeatSelectionBloc _bloc;
  final TransformationController _transformCtrl = TransformationController();
  late AnimationController _pulseCtrl;
  final TicketVaultService _vault = TicketVaultService();

  @override
  void initState() {
    super.initState();
    _bloc = SeatSelectionBloc();
    _bloc.add(LoadBusLayout(widget.layoutId, tripId: widget.tripId));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _vault.init();
  }

  @override
  void dispose() {
    _bloc.close();
    _transformCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: BlocConsumer<SeatSelectionBloc, SeatSelectionState>(
          listener: _onStateChanged,
          builder: (context, state) {
            if (state.status == SeatSelectionStatus.initial ||
                state.status == SeatSelectionStatus.loadingLayout) {
              return _buildLoading();
            }
            return _buildSeatGrid(context, state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Back to Home',
        onPressed: () => context.go('/customer/home'),
      ),
      title: BlocBuilder<SeatSelectionBloc, SeatSelectionState>(
        builder: (_, state) {
          final name = state.busDisplayName.isNotEmpty
              ? state.busDisplayName
              : 'Select Seat';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (state.status != SeatSelectionStatus.initial &&
                  state.status != SeatSelectionStatus.loadingLayout)
                Text(
                  '${state.availableSeats} of ${state.totalSeats} available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<SeatSelectionBloc, SeatSelectionState>(
          builder: (_, state) => IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh',
            onPressed:
                state.status == SeatSelectionStatus.loadingLayout ||
                    state.status == SeatSelectionStatus.bookingInProgress
                ? null
                : () => _bloc.add(const RefreshBookings()),
          ),
        ),
        _buildFilterMenu(),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildLoading() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(strokeWidth: 2.5),
        Gap(16),
        Text(
          'Loading bus layout...',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ],
    ),
  );

  Widget _buildSeatGrid(BuildContext context, SeatSelectionState state) =>
      Column(
        children: [
          _buildLegend(context),
          Expanded(child: _buildInteractiveCanvas(context, state)),
          if (state.hasSelection) _buildSelectionBar(context, state),
        ],
      );

  Widget _buildLegend(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    color: Colors.white,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _legendDot(const Color(0xFF2563EB), 'Available'),
          const Gap(16),
          _legendDot(const Color(0xFF059669), 'Selected'),
          const Gap(16),
          _legendDot(const Color(0xFF9CA3AF), 'Booked'),
          const Gap(16),
          _legendDot(const Color(0xFF7C3AED), 'Business'),
          const Gap(16),
          _legendDot(const Color(0xFFD97706), 'Sleeper'),
        ],
      ),
    ),
  );

  Widget _legendDot(Color c, String l) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: c.withValues(alpha: 0.7)),
        ),
      ),
      const Gap(6),
      Text(l, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
    ],
  );

  Widget _buildInteractiveCanvas(
    BuildContext context,
    SeatSelectionState state,
  ) {
    final pw = state.canvasWidth;
    final ph = state.canvasHeight;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Auto-fit: scale the bus to fill the available viewport height
        // so the entire layout is visible without manual zooming.
        final maxW = constraints.maxWidth - 24; // horizontal padding
        final maxH = constraints.maxHeight - 24;
        final autoScale = math.min(maxW / pw, maxH / ph).clamp(0.35, 1.2);
        final displayW = pw * autoScale;
        final displayH = ph * autoScale;

        return InteractiveViewer(
          transformationController: _transformCtrl,
          boundaryMargin: const EdgeInsets.all(60),
          minScale: autoScale * 0.6,
          maxScale: autoScale * 3.5,
          constrained: false,
          child: GestureDetector(
            onTapUp: (d) => _handleTap(d, state, autoScale),
            child: Container(
              width: math.max(displayW, constraints.maxWidth),
              height: math.max(displayH, constraints.maxHeight),
              padding: const EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: displayW,
                  height: displayH,
                  child: CustomPaint(
                    painter: PassengerSeatPainter(
                      seats: state.seats,
                      canvasWidth: pw,
                      canvasHeight: ph,
                      selectedSeat: state.selectedSeat,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapUpDetails d, SeatSelectionState s, double scale) {
    final rb = context.findRenderObject() as RenderBox?;
    if (rb == null) return;
    final lp = rb.globalToLocal(d.globalPosition);
    final inv = Matrix4.inverted(_transformCtrl.value);
    final cp = MatrixUtils.transformPoint(inv, lp);
    final cx = cp.dx / scale;
    final cy = cp.dy / scale;
    for (final seat in s.seats.reversed) {
      if (seat.containsPoint(cx, cy)) {
        if (seat.isTappable) {
          _bloc.add(SelectSeat(seat));
        } else if (seat.availability == SeatAvailability.booked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seat ${seat.displayLabel} is already booked'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
  }

  Widget _buildFilterMenu() => PopupMenuButton<String>(
    icon: const Icon(Icons.filter_list, size: 20),
    tooltip: 'Filter',
    onSelected: (v) {
      switch (v) {
        case 'all':
          _bloc.add(const SetGenderFilter(''));
          break;
        case 'male':
          _bloc.add(const SetGenderFilter('male'));
          break;
        case 'female':
          _bloc.add(const SetGenderFilter('female'));
          break;
        case 'family':
          _bloc.add(const SetGenderFilter('family'));
          break;
        case 'available':
          _bloc.add(const ToggleShowOnlyAvailable());
          break;
      }
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'all', child: Text('All Seats')),
      PopupMenuItem(value: 'male', child: Text('Male Section')),
      PopupMenuItem(value: 'female', child: Text('Female Section')),
      PopupMenuItem(value: 'family', child: Text('Family Section')),
      PopupMenuDivider(),
      PopupMenuItem(value: 'available', child: Text('Available Only')),
    ],
  );

  Widget _buildSelectionBar(BuildContext context, SeatSelectionState state) {
    final seat = state.selectedSeat!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  seat.displayLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Seat ${seat.displayLabel} selected',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Tap continue to book',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            TextButton(
              onPressed: () => _bloc.add(const DeselectSeat()),
              child: const Text('Cancel'),
            ),
            const Gap(4),
            FilledButton(
              onPressed: state.status == SeatSelectionStatus.bookingInProgress
                  ? null
                  : () => _showBookingSheet(context, state),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context, SeatSelectionState state) {
    final seat = state.selectedSeat;
    if (seat == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SeatBookingSheet(
        seat: seat,
        currentMethod: state.paymentMethod,
        basePrice: seat.price ?? 500,
        voucherCode: state.voucherCode,
        onConfirm: () {
          Navigator.pop(context);
          _bloc.add(const ConfirmBooking());
        },
        onMethodChanged: (m) => _bloc.add(ChangePaymentMethod(m)),
        onVoucherChanged: (c) => _bloc.add(SetVoucherCode(c)),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _onStateChanged(BuildContext context, SeatSelectionState state) {
    if (state.status == SeatSelectionStatus.bookingSuccess &&
        state.bookingResult != null) {
      _saveAndShowSuccess(state);
    } else if (state.status == SeatSelectionStatus.bookingFailure &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> _saveAndShowSuccess(SeatSelectionState state) async {
    final result = state.bookingResult!;
    // Auto-save ticket to Hive vault for offline access
    await _vault.saveTicket(
      CachedBusTicket(
        bookingId: result.bookingId ?? '',
        busId: state.layoutId,
        layoutId: state.layoutId,
        tripId: state.tripId ?? '',
        seatNumber: result.seatNumber,
        seatLabel:
            state.selectedSeat?.displayLabel ?? result.seatNumber.toString(),
        busDisplayName: state.busDisplayName,
        ticketPrice: result.ticketPrice,
        paymentMethod: state.paymentMethod.name,
        bookedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF16A34A),
          size: 56,
        ),
        title: const Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seat ${result.seatNumber} has been booked.'),
            const Gap(8),
            Text(
              'Booking ID: ${result.bookingId ?? 'N/A'}',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const Gap(4),
            Text(
              'Amount paid: Rs. ${result.ticketPrice.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            const Text(
              'Ticket saved for offline access',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF16A34A),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
