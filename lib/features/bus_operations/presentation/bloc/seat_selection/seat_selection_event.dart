// NEXATRACE — SEAT SELECTION EVENTS
// ===================================
// User-driven and system events for the seat selection BLoC.

part of 'seat_selection_bloc.dart';

/// Load the bus layout from the API.
class LoadBusLayout extends SeatSelectionEvent {
  final String layoutId;
  final String? tripId;
  const LoadBusLayout(this.layoutId, {this.tripId});
}

/// Passenger tapped a seat on the grid.
class SelectSeat extends SeatSelectionEvent {
  final PassengerSeatModel seat;
  const SelectSeat(this.seat);
}

/// Deselect the currently selected seat.
class DeselectSeat extends SeatSelectionEvent {
  const DeselectSeat();
}

/// Change payment method.
class ChangePaymentMethod extends SeatSelectionEvent {
  final PaymentMethod method;
  const ChangePaymentMethod(this.method);
}

/// Enter voucher code.
class SetVoucherCode extends SeatSelectionEvent {
  final String code;
  const SetVoucherCode(this.code);
}

/// Confirm and submit booking.
class ConfirmBooking extends SeatSelectionEvent {
  const ConfirmBooking();
}

/// Refresh booked seats from the server (polling).
class RefreshBookings extends SeatSelectionEvent {
  const RefreshBookings();
}

/// Filter seats by gender restriction.
class SetGenderFilter extends SeatSelectionEvent {
  final String filter; // '', 'male', 'female', 'family'
  const SetGenderFilter(this.filter);
}

/// Toggle showing only available seats.
class ToggleShowOnlyAvailable extends SeatSelectionEvent {
  const ToggleShowOnlyAvailable();
}
