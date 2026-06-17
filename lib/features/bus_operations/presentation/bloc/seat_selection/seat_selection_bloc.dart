// NEXATRACE — SEAT SELECTION BLOC
// =================================
// BLoC managing the passenger seat selection flow:
//   Load layout → Browse seats → Select → Pay → Confirm
//
// MODULE: 8V — Interactive Seat Selection (Customer App)

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/data/models/passenger_seat_model.dart';
import 'package:trace_odd/features/bus_operations/data/repositories/seat_booking_repository.dart';

// ── EVENTS ────────────────────────────────────────────

sealed class SeatSelectionEvent {
  const SeatSelectionEvent();
}

class LoadBusLayout extends SeatSelectionEvent {
  final String layoutId;
  final String? tripId;
  const LoadBusLayout(this.layoutId, {this.tripId});
}

class SelectSeat extends SeatSelectionEvent {
  final PassengerSeatModel seat;
  const SelectSeat(this.seat);
}

class DeselectSeat extends SeatSelectionEvent {
  const DeselectSeat();
}

class ChangePaymentMethod extends SeatSelectionEvent {
  final PaymentMethod method;
  const ChangePaymentMethod(this.method);
}

class SetVoucherCode extends SeatSelectionEvent {
  final String code;
  const SetVoucherCode(this.code);
}

class ConfirmBooking extends SeatSelectionEvent {
  const ConfirmBooking();
}

class RefreshBookings extends SeatSelectionEvent {
  const RefreshBookings();
}

class SetGenderFilter extends SeatSelectionEvent {
  final String filter;
  const SetGenderFilter(this.filter);
}

class ToggleShowOnlyAvailable extends SeatSelectionEvent {
  const ToggleShowOnlyAvailable();
}

// ── STATE ─────────────────────────────────────────────

enum PaymentMethod { wallet, card, voucher }

enum SeatSelectionStatus {
  initial,
  loadingLayout,
  layoutReady,
  selectingSeat,
  confirmingBooking,
  bookingInProgress,
  bookingSuccess,
  bookingFailure,
  refreshing,
}

class SeatSelectionState {
  final SeatSelectionStatus status;
  final String layoutId;
  final String? tripId;
  final String busDisplayName;
  final List<PassengerSeatModel> seats;
  final PassengerSeatModel? selectedSeat;
  final List<int> bookedSeatNumbers;
  final int totalSeats;
  final int availableSeats;
  final PaymentMethod paymentMethod;
  final double baseTicketPrice;
  final String? voucherCode;
  final SeatBookingResult? bookingResult;
  final String? errorMessage;
  final String genderFilter;
  final bool showOnlyAvailable;
  final double canvasWidth;
  final double canvasHeight;

  const SeatSelectionState({
    this.status = SeatSelectionStatus.initial,
    this.layoutId = '',
    this.tripId,
    this.busDisplayName = '',
    this.seats = const [],
    this.selectedSeat,
    this.bookedSeatNumbers = const [],
    this.totalSeats = 0,
    this.availableSeats = 0,
    this.paymentMethod = PaymentMethod.wallet,
    this.baseTicketPrice = 0,
    this.voucherCode,
    this.bookingResult,
    this.errorMessage,
    this.genderFilter = '',
    this.showOnlyAvailable = false,
    this.canvasWidth = 280,
    this.canvasHeight = 728,
  });

  bool get hasSelection => selectedSeat != null;

  SeatSelectionState copyWith({
    SeatSelectionStatus? status,
    String? layoutId,
    String? tripId,
    String? busDisplayName,
    List<PassengerSeatModel>? seats,
    PassengerSeatModel? selectedSeat,
    bool clearSelected = false,
    List<int>? bookedSeatNumbers,
    int? totalSeats,
    int? availableSeats,
    PaymentMethod? paymentMethod,
    double? baseTicketPrice,
    String? voucherCode,
    bool clearVoucher = false,
    SeatBookingResult? bookingResult,
    String? errorMessage,
    bool clearError = false,
    String? genderFilter,
    bool? showOnlyAvailable,
    double? canvasWidth,
    double? canvasHeight,
  }) {
    return SeatSelectionState(
      status: status ?? this.status,
      layoutId: layoutId ?? this.layoutId,
      tripId: tripId ?? this.tripId,
      busDisplayName: busDisplayName ?? this.busDisplayName,
      seats: seats ?? this.seats,
      selectedSeat: clearSelected ? null : (selectedSeat ?? this.selectedSeat),
      bookedSeatNumbers: bookedSeatNumbers ?? this.bookedSeatNumbers,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      baseTicketPrice: baseTicketPrice ?? this.baseTicketPrice,
      voucherCode: clearVoucher ? null : (voucherCode ?? this.voucherCode),
      bookingResult: bookingResult ?? this.bookingResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      genderFilter: genderFilter ?? this.genderFilter,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
    );
  }
}

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
              'Failed to load layout: '
              '${e.toString().replaceAll("Exception: ", "")}',
        ),
      );
    }
  }

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

  void _onChangePayment(
    ChangePaymentMethod event,
    Emitter<SeatSelectionState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.method));
  }

  void _onSetVoucher(SetVoucherCode event, Emitter<SeatSelectionState> emit) {
    emit(state.copyWith(voucherCode: event.code));
  }

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
