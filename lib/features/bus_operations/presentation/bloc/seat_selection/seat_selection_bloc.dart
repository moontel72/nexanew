// NEXATRACE — SEAT SELECTION BLOC v2
// =================================
// BLoC managing the passenger seat Hold → Pay → Confirm lifecycle.
// Phase 2: 8-min hold timer, WebSocket realtime sync, release-on-dispose.
//
// MODULE: 8V — Interactive Seat Selection (Customer App)

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/services/websocket_hub.dart';
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

/// Phase 2: Reserve the currently selected seat via POST /hold.
class TryHoldSeat extends SeatSelectionEvent {
  const TryHoldSeat();
}

/// Phase 2: Finalize payment for the held seat via POST /confirm.
class ConfirmPayment extends SeatSelectionEvent {
  const ConfirmPayment();
}

/// Phase 2: User cancels the hold via DELETE /release.
class ReleaseHold extends SeatSelectionEvent {
  const ReleaseHold();
}

/// Phase 2: Internal — fired when local countdown reaches zero.
class _HoldExpired extends SeatSelectionEvent {
  const _HoldExpired();
}

/// Phase 2: WebSocket push — seat states changed on another session.
class UpdateSeatStateRealtime extends SeatSelectionEvent {
  final List<int> heldSeatNumbers;
  final List<int> bookedSeatNumbers;
  final int availableSeats;
  const UpdateSeatStateRealtime({
    required this.heldSeatNumbers,
    required this.bookedSeatNumbers,
    required this.availableSeats,
  });
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
  holdingSeat, // Phase 2: POST /hold in flight
  seatHeld, // Phase 2: hold active, countdown running
  holdFailed, // Phase 2: hold rejected (409 conflict, 48h lockout)
  holdExpired, // Phase 2: timer elapsed, seat auto-released
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
  final List<int> heldSeatNumbers; // Phase 2: seats held by ANY user
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

  // Phase 2: hold state
  final String? holdToken;
  final int holdSecondsRemaining; // live countdown display
  final int holdTotalSeconds; // original TTL for progress bar

  const SeatSelectionState({
    this.status = SeatSelectionStatus.initial,
    this.layoutId = '',
    this.tripId,
    this.busDisplayName = '',
    this.seats = const [],
    this.selectedSeat,
    this.bookedSeatNumbers = const [],
    this.heldSeatNumbers = const [],
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
    this.holdToken,
    this.holdSecondsRemaining = 0,
    this.holdTotalSeconds = 0,
  });

  bool get hasSelection => selectedSeat != null;
  bool get isHolding => holdToken != null && holdSecondsRemaining > 0;
  String get holdCountdownDisplay {
    if (holdSecondsRemaining <= 0) return '';
    final m = holdSecondsRemaining ~/ 60;
    final s = holdSecondsRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  SeatSelectionState copyWith({
    SeatSelectionStatus? status,
    String? layoutId,
    String? tripId,
    String? busDisplayName,
    List<PassengerSeatModel>? seats,
    PassengerSeatModel? selectedSeat,
    bool clearSelected = false,
    List<int>? bookedSeatNumbers,
    List<int>? heldSeatNumbers,
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
    String? holdToken,
    bool clearHold = false,
    int? holdSecondsRemaining,
    int? holdTotalSeconds,
  }) {
    return SeatSelectionState(
      status: status ?? this.status,
      layoutId: layoutId ?? this.layoutId,
      tripId: tripId ?? this.tripId,
      busDisplayName: busDisplayName ?? this.busDisplayName,
      seats: seats ?? this.seats,
      selectedSeat: clearSelected ? null : (selectedSeat ?? this.selectedSeat),
      bookedSeatNumbers: bookedSeatNumbers ?? this.bookedSeatNumbers,
      heldSeatNumbers: heldSeatNumbers ?? this.heldSeatNumbers,
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
      holdToken: clearHold ? null : (holdToken ?? this.holdToken),
      holdSecondsRemaining: holdSecondsRemaining ?? this.holdSecondsRemaining,
      holdTotalSeconds: holdTotalSeconds ?? this.holdTotalSeconds,
    );
  }
}

// ── BLoC ──────────────────────────────────────────────

class SeatSelectionBloc extends Bloc<SeatSelectionEvent, SeatSelectionState> {
  final SeatBookingRepository _repo;
  Timer? _refreshTimer;
  Timer? _holdCountdown;
  StreamSubscription<dynamic>? _wsSubscription;

  SeatSelectionBloc({SeatBookingRepository? repo})
    : _repo = repo ?? SeatBookingRepository(),
      super(const SeatSelectionState()) {
    on<LoadBusLayout>(_onLoadLayout);
    on<SelectSeat>(_onSelectSeat);
    on<DeselectSeat>(_onDeselectSeat);
    on<TryHoldSeat>(_onTryHoldSeat);
    on<ConfirmPayment>(_onConfirmPayment);
    on<ReleaseHold>(_onReleaseHold);
    on<_HoldExpired>(_onHoldExpired);
    on<UpdateSeatStateRealtime>(_onRealtimeUpdate);
    on<ChangePaymentMethod>(_onChangePayment);
    on<SetVoucherCode>(_onSetVoucher);
    on<ConfirmBooking>(_onConfirmBooking);
    on<RefreshBookings>(_onRefresh);
    on<SetGenderFilter>(_onGenderFilter);
    on<ToggleShowOnlyAvailable>(_onToggleAvailable);
  }

  // ═══════════════════════════════════════════════════════
  // LOAD LAYOUT
  // ═══════════════════════════════════════════════════════

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

      // Fetch held seats in parallel
      List<int> heldNums = [];
      if (event.tripId != null && event.tripId!.isNotEmpty) {
        final held = await _repo.fetchHeldSeats(event.tripId!);
        heldNums = held.seatNumbers;
      }

      final seats = parsePassengerSeats(
        result.snapshot,
        bookedSeatNumbers: result.bookedSeatNumbers,
        heldSeatNumbers: heldNums,
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
          heldSeatNumbers: heldNums,
          totalSeats: result.totalSeats,
          availableSeats: result.availableSeats - heldNums.length,
          canvasWidth: cw,
          canvasHeight: ch,
          clearError: true,
        ),
      );
      _startAutoRefresh();
      _listenToWebSocket(event.tripId);
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

  // ═══════════════════════════════════════════════════════
  // SELECT / DESELECT
  // ═══════════════════════════════════════════════════════

  void _onSelectSeat(SelectSeat event, Emitter<SeatSelectionState> emit) {
    if (!event.seat.isTappable &&
        event.seat.availability != SeatAvailability.held)
      return;
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
    // If a hold is active, release it first
    if (state.isHolding) {
      add(const ReleaseHold());
    }
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

  // ═══════════════════════════════════════════════════════
  // HOLD SEAT (Phase 2)
  // ═══════════════════════════════════════════════════════

  Future<void> _onTryHoldSeat(
    TryHoldSeat event,
    Emitter<SeatSelectionState> emit,
  ) async {
    final seat = state.selectedSeat;
    if (seat == null || state.tripId == null) return;

    emit(state.copyWith(status: SeatSelectionStatus.holdingSeat));

    final result = await _repo.holdSeat(
      busId: state.layoutId,
      tripId: state.tripId!,
      seatNumber: seat.seatNumber ?? 0,
    );

    if (result.success && result.holdToken != null) {
      // Mark seat as held locally
      final updatedSeats = state.seats.map((s) {
        if (s.componentId == seat.componentId) {
          return s.copyWith(availability: SeatAvailability.held);
        }
        return s;
      }).toList();

      emit(
        state.copyWith(
          status: SeatSelectionStatus.seatHeld,
          seats: updatedSeats,
          holdToken: result.holdToken,
          holdSecondsRemaining: result.expiresInSeconds,
          holdTotalSeconds: result.expiresInSeconds,
          heldSeatNumbers: [...state.heldSeatNumbers, seat.seatNumber ?? 0],
          clearError: true,
        ),
      );

      _startHoldCountdown();
    } else {
      emit(
        state.copyWith(
          status: SeatSelectionStatus.holdFailed,
          errorMessage:
              result.errorMessage ?? 'Failed to hold seat. Please try again.',
        ),
      );
      // Auto-clear error after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed && state.status == SeatSelectionStatus.holdFailed) {
          add(const DeselectSeat());
        }
      });
    }
  }

  void _startHoldCountdown() {
    _holdCountdown?.cancel();
    _holdCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      final remaining = state.holdSecondsRemaining - 1;
      if (remaining <= 0) {
        add(const _HoldExpired());
      } else {
        emit(state.copyWith(holdSecondsRemaining: remaining));
      }
    });
  }

  void _onHoldExpired(_HoldExpired event, Emitter<SeatSelectionState> emit) {
    _holdCountdown?.cancel();
    _releaseHoldSilent();
    emit(
      state.copyWith(
        status: SeatSelectionStatus.holdExpired,
        clearHold: true,
        holdSecondsRemaining: 0,
        clearSelected: true,
        errorMessage: 'Your hold has expired. Please select a seat again.',
      ),
    );
    // Auto-clear after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (!isClosed && state.status == SeatSelectionStatus.holdExpired) {
        emit(
          state.copyWith(
            status: SeatSelectionStatus.layoutReady,
            clearError: true,
          ),
        );
      }
    });
  }

  // ═══════════════════════════════════════════════════════
  // CONFIRM PAYMENT (Phase 2)
  // ═══════════════════════════════════════════════════════

  Future<void> _onConfirmPayment(
    ConfirmPayment event,
    Emitter<SeatSelectionState> emit,
  ) async {
    if (state.holdToken == null) return;

    emit(state.copyWith(status: SeatSelectionStatus.bookingInProgress));

    final result = await _repo.confirmHold(
      holdToken: state.holdToken!,
      paymentMethod: state.paymentMethod.name,
      ticketPrice: state.baseTicketPrice,
      voucherCode: state.voucherCode,
    );

    _holdCountdown?.cancel();

    if (result.success) {
      final seat = state.selectedSeat;
      final updatedSeats = state.seats.map((s) {
        if (s.componentId == seat?.componentId) {
          return s.copyWith(availability: SeatAvailability.booked);
        }
        return s;
      }).toList();
      emit(
        state.copyWith(
          status: SeatSelectionStatus.bookingSuccess,
          seats: updatedSeats,
          bookedSeatNumbers: [
            ...state.bookedSeatNumbers,
            seat?.seatNumber ?? 0,
          ],
          bookingResult: result,
          clearHold: true,
          clearSelected: true,
          clearError: true,
        ),
      );
    } else {
      // Payment failed, but hold may still be active
      final isExpired = result.errorMessage?.contains('expired') ?? false;
      emit(
        state.copyWith(
          status: isExpired
              ? SeatSelectionStatus.holdExpired
              : SeatSelectionStatus.bookingFailure,
          bookingResult: result,
          errorMessage: result.errorMessage,
          clearHold: isExpired,
          clearSelected: isExpired,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  // RELEASE HOLD (Phase 2)
  // ═══════════════════════════════════════════════════════

  Future<void> _onReleaseHold(
    ReleaseHold event,
    Emitter<SeatSelectionState> emit,
  ) async {
    _holdCountdown?.cancel();
    _releaseHoldSilent();

    final seat = state.selectedSeat;
    final updatedSeats = state.seats.map((s) {
      if (s.componentId == seat?.componentId &&
          s.availability == SeatAvailability.held) {
        return s.copyWith(availability: SeatAvailability.available);
      }
      return s;
    }).toList();

    emit(
      state.copyWith(
        status: SeatSelectionStatus.layoutReady,
        seats: updatedSeats,
        clearHold: true,
        clearSelected: true,
      ),
    );
  }

  /// Fire-and-forget release to the server. Non-blocking.
  void _releaseHoldSilent() {
    final token = state.holdToken;
    if (token == null) return;
    _repo.releaseHold(token); // no await — best-effort
  }

  // ═══════════════════════════════════════════════════════
  // WEBSOCKET REALTIME UPDATES (Phase 2)
  // ═══════════════════════════════════════════════════════

  void _listenToWebSocket(String? tripId) {
    _wsSubscription?.cancel();
    if (tripId == null || tripId.isEmpty) return;

    try {
      final hub = WebSocketHub.instance;
      _wsSubscription = hub.events
          .where(
            (e) =>
                e.channel == 'bus.$tripId.seats' &&
                e.event == 'SeatHeldUpdated',
          )
          .listen((event) {
            if (isClosed) return;
            final payload = event.payload is Map
                ? Map<String, dynamic>.from(event.payload as Map)
                : <String, dynamic>{};
            final heldRaw = payload['held_seats'] ?? [];
            final bookedRaw = payload['booked_seats'] ?? [];
            final avail = (payload['available_seats'] ?? 0) as int;

            final held = (heldRaw is List)
                ? heldRaw
                      .map(
                        (b) => b is int ? b : int.tryParse(b.toString()) ?? 0,
                      )
                      .where((n) => n > 0)
                      .toList()
                : <int>[];
            final booked = (bookedRaw is List)
                ? bookedRaw
                      .map(
                        (b) => b is int ? b : int.tryParse(b.toString()) ?? 0,
                      )
                      .where((n) => n > 0)
                      .toList()
                : <int>[];

            add(
              UpdateSeatStateRealtime(
                heldSeatNumbers: held,
                bookedSeatNumbers: booked,
                availableSeats: avail,
              ),
            );
          });
    } catch (_) {
      // WebSocket unavailable — polling fallback is active
    }
  }

  void _onRealtimeUpdate(
    UpdateSeatStateRealtime event,
    Emitter<SeatSelectionState> emit,
  ) {
    // Don't overwrite our own held seat
    final ourSeatNum = state.selectedSeat?.seatNumber;
    final updatedSeats = state.seats.map((s) {
      if (s.isStructural) return s;
      // Don't touch our own held seat
      if (ourSeatNum != null &&
          s.seatNumber == ourSeatNum &&
          s.availability == SeatAvailability.held) {
        return s;
      }
      final num = s.seatNumber;
      if (num != null && event.bookedSeatNumbers.contains(num)) {
        return s.copyWith(availability: SeatAvailability.booked);
      }
      if (num != null && event.heldSeatNumbers.contains(num)) {
        return s.copyWith(availability: SeatAvailability.held);
      }
      // Was held/booked but now freed
      if (s.availability == SeatAvailability.held ||
          s.availability == SeatAvailability.booked) {
        return s.copyWith(availability: SeatAvailability.available);
      }
      return s;
    }).toList();

    emit(
      state.copyWith(
        seats: updatedSeats,
        bookedSeatNumbers: event.bookedSeatNumbers,
        heldSeatNumbers: event.heldSeatNumbers,
        availableSeats: event.availableSeats,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // PAYMENT / BOOKING (existing, refactored)
  // ═══════════════════════════════════════════════════════

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
    // Phase 2: If hold is active, confirm payment instead
    if (state.isHolding) {
      add(const ConfirmPayment());
      return;
    }

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

  // ═══════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════

  Future<void> _onRefresh(
    RefreshBookings event,
    Emitter<SeatSelectionState> emit,
  ) async {
    if (state.layoutId.isEmpty) return;
    emit(state.copyWith(status: SeatSelectionStatus.refreshing));

    // Fetch booked + held concurrently
    final results = await Future.wait([
      _repo.fetchBookedSeats(state.layoutId, tripId: state.tripId),
      if (state.tripId != null && state.tripId!.isNotEmpty)
        _repo.fetchHeldSeats(state.tripId!)
      else
        Future.value(
          const HeldSeatsSnapshot(
            seatNumbers: [],
            remainingSeconds: [],
            holdsAllowed: false,
            holdTtlMinutes: 8,
          ),
        ),
    ]);

    final booked = results[0] as List<int>;
    final heldSnap = results[1] as HeldSeatsSnapshot;
    final held = heldSnap.seatNumbers;
    final ourSeatNum = state.selectedSeat?.seatNumber;

    final updatedSeats = state.seats.map((s) {
      if (s.isStructural) return s;
      // Don't overwrite our own held/selected seat
      if (ourSeatNum != null && s.seatNumber == ourSeatNum) {
        if (s.availability == SeatAvailability.selected ||
            s.availability == SeatAvailability.held)
          return s;
      }
      final num = s.seatNumber;
      if (num != null && booked.contains(num)) {
        return s.copyWith(availability: SeatAvailability.booked);
      }
      if (num != null && held.contains(num)) {
        return s.copyWith(availability: SeatAvailability.held);
      }
      if (s.availability == SeatAvailability.held ||
          s.availability == SeatAvailability.booked) {
        return s.copyWith(availability: SeatAvailability.available);
      }
      return s;
    }).toList();

    emit(
      state.copyWith(
        status: SeatSelectionStatus.layoutReady,
        seats: updatedSeats,
        bookedSeatNumbers: booked,
        heldSeatNumbers: held,
        availableSeats: state.totalSeats - booked.length - held.length,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!isClosed) add(const RefreshBookings());
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    _holdCountdown?.cancel();
    _wsSubscription?.cancel();
    // Release any active hold immediately
    if (state.isHolding) {
      _releaseHoldSilent();
    }
    return super.close();
  }
}
