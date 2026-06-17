// NEXATRACE — SEAT SELECTION STATE
// ==================================
// Immutable state for the passenger seat selection BLoC.
// Holds the full seat grid, selected seats, payment state,
// and booking result.

part of 'seat_selection_bloc.dart';

/// All possible payment methods for seat booking.
enum PaymentMethod { wallet, card, voucher }

/// Overall status of the seat selection flow.
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

/// Immutable state for the seat selection screen.
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
  final String genderFilter; // '', 'male', 'female', 'family'
  final bool showOnlyAvailable; // toggle to hide booked seats
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

  /// All seats that are currently bookable (available + selected).
  List<PassengerSeatModel> get bookableSeats =>
      seats.where((s) => !s.isStructural).toList();

  /// Number of seats currently booked.
  int get bookedCount => bookedSeatNumbers.length;

  /// Whether a seat is currently selected.
  bool get hasSelection => selectedSeat != null;

  /// Filtered seats (by gender), sorted top-to-bottom, left-to-right.
  List<PassengerSeatModel> get filteredSeats {
    var list = seats.toList();
    if (genderFilter.isNotEmpty) {
      list = list
          .where(
              (s) => s.genderRestriction == null || s.genderRestriction == genderFilter)
          .toList();
    }
    if (showOnlyAvailable) {
      list = list
          .where((s) =>
              s.availability == SeatAvailability.available ||
              s.availability == SeatAvailability.selected)
          .toList();
    }
    return list;
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
      selectedSeat:
          clearSelected ? null : (selectedSeat ?? this.selectedSeat),
      bookedSeatNumbers: bookedSeatNumbers ?? this.bookedSeatNumbers,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      baseTicketPrice: baseTicketPrice ?? this.baseTicketPrice,
      voucherCode:
          clearVoucher ? null : (voucherCode ?? this.voucherCode),
      bookingResult: bookingResult ?? this.bookingResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      genderFilter: genderFilter ?? this.genderFilter,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
    );
  }
}
