// NEXATRACE — PASSENGER SEAT SELECTION SCREEN
// ==============================================
// Full interactive seat booking experience for the
// Customer App (Module 8V). Displays the bus floor-plan
// with color-coded tappable seats, payment flow, and
// booking confirmation.
//
// ROUTE:  /bus-fleet/seat-selection?layout=:id&trip=:tripId
//
// MODULE: 8V — Unified Bus Transit Terminal

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/data/models/passenger_seat_model.dart';
import 'package:trace_odd/features/bus_operations/data/repositories/seat_booking_repository.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/seat_selection/seat_selection_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/passenger_seat_painter.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/seat_booking_sheet.dart';

/// Main passenger seat selection screen.
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

  @override
  void initState() {
    super.initState();
    _bloc = SeatSelectionBloc();
    _bloc.add(LoadBusLayout(widget.layoutId, tripId: widget.tripId));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
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

  // ── APP BAR ──────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: BlocBuilder<SeatSelectionBloc, SeatSelectionState>(
        builder: (_, state) {
          final name = state.busDisplayName.isNotEmpty
              ? state.busDisplayName
              : 'Select Seat';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (state.status != SeatSelectionStatus.initial &&
                  state.status != SeatSelectionStatus.loadingLayout)
                Text(
                  '${state.availableSeats} of ${state.totalSeats} available',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<SeatSelectionBloc, SeatSelectionState>(
          builder: (_, state) => IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh availability',
            onPressed: state.status == SeatSelectionStatus.loadingLayout ||
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

  // ── LOADING ──────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(strokeWidth: 2.5),
          Gap(16),
          Text('Loading bus layout...', style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  // ── SEAT GRID ────────────────────────────────────────

  Widget _buildSeatGrid(BuildContext context, SeatSelectionState state) {
    return Column(
      children: [
        _buildLegend(context),
        Expanded(child: _buildInteractiveCanvas(context, state)),
        if (state.hasSelection) _buildSelectionBar(context, state),
      ],
    );
  }

  // ── LEGEND ───────────────────────────────────────────

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _legendDot(const Color(0xFF22C55E), 'Available'),
            const Gap(16),
            _legendDot(const Color(0xFF3B82F6), 'Selected'),
            const Gap(16),
            _legendDot(const Color(0xFFEF4444), 'Booked'),
            const Gap(16),
            _legendDot(const Color(0xFFA855F7), 'Business'),
            const Gap(16),
            _legendDot(const Color(0xFFF59E0B), 'Sleeper'),
            const Gap(16),
            _legendDot(const Color(0xFF9CA3AF), 'Structural'),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 0.5),
          ),
        ),
        const Gap(6),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
      ],
    );
  }

  // ── INTERACTIVE CANVAS ───────────────────────────────

  Widget _buildInteractiveCanvas(BuildContext context, SeatSelectionState state) {
    final pw = state.canvasWidth;
    final ph = state.canvasHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fitScale = constraints.maxWidth / pw;
        final fittedHeight = ph * fitScale;

        return InteractiveViewer(
          transformationController: _transformCtrl,
          boundaryMargin: const EdgeInsets.all(80),
          minScale: 0.5,
          maxScale: 4.0,
          constrained: false,
          child: GestureDetector(
            onTapUp: (details) => _handleTap(details, state, fitScale),
            child: Container(
              width: constraints.maxWidth,
              height: math.max(fittedHeight, constraints.maxHeight),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: AspectRatio(
                  aspectRatio: pw / ph,
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

  void _handleTap(TapUpDetails details, SeatSelectionState state, double scale) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = renderBox.globalToLocal(details.globalPosition);
    final matrix = _transformCtrl.value;
    final inv = Matrix4.inverted(matrix);
    final canvasPoint = MatrixUtils.transformPoint(inv, localPos);
    final cx = canvasPoint.dx / scale;
    final cy = canvasPoint.dy / scale;

    for (final seat in state.seats.reversed) {
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

  // ── FILTER MENU ──────────────────────────────────────

  Widget _buildFilterMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, size: 20),
      tooltip: 'Filter seats',
      onSelected: (value) {
        switch (value) {
          case 'all':    _bloc.add(const SetGenderFilter('')); break;
          case 'male':   _bloc.add(const SetGenderFilter('male')); break;
          case 'female': _bloc.add(const SetGenderFilter('female')); break;
          case 'family': _bloc.add(const SetGenderFilter('family')); break;
          case 'available': _bloc.add(const ToggleShowOnlyAvailable()); break;
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
  }

  // ── SELECTION BAR ────────────────────────────────────

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
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(seat.displayLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Seat ${seat.displayLabel} selected',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text('Tap continue to book',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            const Gap(8),
            TextButton(onPressed: () => _bloc.add(const DeselectSeat()), child: const Text('Cancel')),
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

  // ── BOOKING SHEET ────────────────────────────────────

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

  // ── STATE LISTENER ───────────────────────────────────

  void _onStateChanged(BuildContext context, SeatSelectionState state) {
    if (state.status == SeatSelectionStatus.bookingSuccess && state.bookingResult != null) {
      _showBookingSuccess(state.bookingResult!);
    } else if (state.status == SeatSelectionStatus.bookingFailure && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Dismiss', textColor: Colors.white, onPressed: () {}),
        ),
      );
    }
  }

  void _showBookingSuccess(SeatBookingResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 56),
        title: const Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seat ${result.seatNumber} has been booked.'),
            const Gap(8),
            Text('Booking ID: ${result.bookingId ?? 'N/A'}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
            const Gap(4),
            Text('Amount paid: Rs. ${result.ticketPrice.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
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
