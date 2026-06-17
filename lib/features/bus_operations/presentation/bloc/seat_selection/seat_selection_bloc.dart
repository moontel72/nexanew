// NEXATRACE — SEAT SELECTION BLOC
// =================================
// BLoC managing the passenger seat selection flow:
//   Load layout → Browse seats → Select → Pay → Confirm
//
// Events defined in:  seat_selection_event.dart
// State defined in:   seat_selection_state.dart
//
// MODULE: 8V — Interactive Seat Selection (Customer App)

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/data/models/passenger_seat_model.dart';
import 'package:trace_odd/features/bus_operations/data/repositories/seat_booking_repository.dart';

part 'seat_selection_event.dart';
part 'seat_selection_state.dart';

// ── BLoC ──────────────────────────────────────────────

class SeatSelectionBloc extends Bloc<SeatSelectionEvent, SeatSelectionState> {
  final SeatBookingRepository _repo;
  Timer? _refreshTimer;

  SeatSelectionBloc({SeatBookingRepository? repo})
    : _repo = repo ?? SeatBookingRepository(),
      super(const SeatSelectionState()) {
    on<LoadBusLayout>(_onLoadLayout);
    on<SelectSeat>(_onSelectSeat);
    on<DeselectSeat>(_onDeselectSeat);
    on<ChangePaymentMethod>(_onChangePayment);
    on<SetVoucherCode>(_onSetVoucher);
    on<ConfirmBooking>(_onConfirmBooking);
    on<RefreshBookings>(_onRefresh);
    on<SetGenderFilter>(_onGenderFilter);
    on<ToggleShowOnlyAvailable>(_onToggleAvailable);
  }

  // ── LOAD ────────────────────────────────────────────

  Future<void> _onLoadLayout(
    LoadBusLayout event,
    Emitter<SeatSelectionState> emit,
  ) async {
    emit(state.copyWith(status: SeatSelectionStatus.loadingLayout));

    try {
      final result = await _repo.fetchLayout(
        event.layoutId,
        tripId: event.tripId,
      );
      final seats = parsePassengerSeats(
        result.snapshot,
        bookedSeatNumbers: result.bookedSeatNumbers,
      );

      final canvas = result.snapshot['canvas'] as Map<String, dynamic>? ?? {};
      final cw = (canvas['width'] ?? 280).toDouble();
      final ch = (canvas['height'] ?? 728).toDouble();

      emit(
        state.copyWith(
          status: SeatSelectionStatus.layoutReady,
          layoutId: event.layoutId,
          tripId: event.tripId,
          busDisplayName: result.displayName,
          seats: seats,
          bookedSeatNumbers: result.bookedSeatNumbers,
          totalSeats: result.totalSeats,
          availableSeats: result.availableSeats,
          canvasWidth: cw,
          canvasHeight: ch,
          clearError: true,
        ),
      );

      _startAutoRefresh();
    } catch (e) {
      emit(
        state.copyWith(
          status: SeatSelectionStatus.bookingFailure,
          errorMessage:
              'Failed to load layout: ${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
    }
  }

  // ── SELECT / DESELECT ───────────────────────────────

  void _onSelectSeat(SelectSeat event, Emitter<SeatSelectionState> emit) {
    if (!event.seat.isTappable) return;

    final updatedSeats = state.seats.map((s) {
      if (s.componentId == event.seat.componentId) {
        return s.copyWith(availability: SeatAvailability.selected);
      }
      if (s.availability == SeatAvailability.selected) {
        return s.copyWith(availability: SeatAvailability.available);
      }
      return s;
    }).toList();

    emit(
      state.copyWith(
        status: SeatSelectionStatus.selectingSeat,
        seats: updatedSeats,
        selectedSeat: event.seat,
        clearError: true,
      ),
    );
  }

  void _onDeselectSeat(DeselectSeat event, Emitter<SeatSelectionState> emit) {
    final updatedSeats = state.seats.map((s) {
      if (s.availability == SeatAvailability.selected) {
        return s.copyWith(availability: SeatAvailability.available);
      }
      return s;
    }).toList();

    emit(
      state.copyWith(
        status: SeatSelectionStatus.layoutReady,
        seats: updatedSeats,
        clearSelected: true,
      ),
    );
  }

  // ── PAYMENT ─────────────────────────────────────────

  void _onChangePayment(
    ChangePaymentMethod event,
    Emitter<SeatSelectionState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.method));
  }

  void _onSetVoucher(SetVoucherCode event, Emitter<SeatSelectionState> emit) {
    emit(state.copyWith(voucherCode: event.code));
  }

  // ── CONFIRM ─────────────────────────────────────────

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<SeatSelectionState> emit,
  ) async {
    final seat = state.selectedSeat;
    if (seat == null) return;

    emit(state.copyWith(status: SeatSelectionStatus.bookingInProgress));

    final result = await _repo.bookSeat(
      busId: state.layoutId,
      tripId: state.tripId ?? '',
      seatNumber: seat.seatNumber ?? 0,
      paymentMethod: state.paymentMethod.name,
      ticketPrice: state.baseTicketPrice,
      voucherCode: state.voucherCode,
    );

    if (result.success) {
      final updatedSeats = state.seats.map((s) {
        if (s.componentId == seat.componentId) {
          return s.copyWith(availability: SeatAvailability.booked);
        }
        return s;
      }).toList();

      emit(
        state.copyWith(
          status: SeatSelectionStatus.bookingSuccess,
          seats: updatedSeats,
          bookedSeatNumbers: [...state.bookedSeatNumbers, seat.seatNumber ?? 0],
          bookingResult: result,
          clearSelected: true,
          clearError: true,
        ),
      );
    } else {
      final revertedSeats = state.seats.map((s) {
        if (s.componentId == seat.componentId) {
          return s.copyWith(availability: SeatAvailability.available);
        }
        return s;
      }).toList();

      emit(
        state.copyWith(
          status: SeatSelectionStatus.bookingFailure,
          seats: revertedSeats,
          bookingResult: result,
          errorMessage: result.errorMessage,
          clearSelected: true,
        ),
      );
    }
  }

  // ── REFRESH ─────────────────────────────────────────

  Future<void> _onRefresh(
    RefreshBookings event,
    Emitter<SeatSelectionState> emit,
  ) async {
    if (state.layoutId.isEmpty) return;
    emit(state.copyWith(status: SeatSelectionStatus.refreshing));

    final booked = await _repo.fetchBookedSeats(
      state.layoutId,
      tripId: state.tripId,
    );

    final updatedSeats = state.seats.map((s) {
      if (s.isStructural) return s;
      if (s.availability == SeatAvailability.selected) return s;
      final isNowBooked = s.seatNumber != null && booked.contains(s.seatNumber);
      return s.copyWith(
        availability: isNowBooked
            ? SeatAvailability.booked
            : SeatAvailability.available,
      );
    }).toList();

    emit(
      state.copyWith(
        status: SeatSelectionStatus.layoutReady,
        seats: updatedSeats,
        bookedSeatNumbers: booked,
        availableSeats: state.totalSeats - booked.length,
      ),
    );
  }

  // ── FILTERS ─────────────────────────────────────────

  void _onGenderFilter(
    SetGenderFilter event,
    Emitter<SeatSelectionState> emit,
  ) {
    emit(state.copyWith(genderFilter: event.filter));
  }

  void _onToggleAvailable(
    ToggleShowOnlyAvailable event,
    Emitter<SeatSelectionState> emit,
  ) {
    emit(state.copyWith(showOnlyAvailable: !state.showOnlyAvailable));
  }

  // ── AUTO-REFRESH ────────────────────────────────────

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!isClosed) add(const RefreshBookings());
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
