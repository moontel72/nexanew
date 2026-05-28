import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/services/hardware_scan_service.dart';

abstract class CustomerSuperAppEvent extends Equatable {
  const CustomerSuperAppEvent();
}

/// Product authenticity scan from HardwareScanService.
class CustomerScanVerified extends CustomerSuperAppEvent {
  final ScanResult result;
  final bool isAuthentic;
  const CustomerScanVerified({required this.result, required this.isAuthentic});
  @override
  List<Object?> get props => [result, isAuthentic];
}

/// Real-time bus GPS frame from WebSocket.
class BusTransitUpdateReceived extends CustomerSuperAppEvent {
  final Map<String, dynamic> payload;
  const BusTransitUpdateReceived(this.payload);
  @override
  List<Object?> get props => [payload];
}

/// Transit route search query submitted.
class TransitSearchRequested extends CustomerSuperAppEvent {
  final String origin;
  final String destination;
  const TransitSearchRequested({
    required this.origin,
    required this.destination,
  });
  @override
  List<Object?> get props => [origin, destination];
}

/// Seat selection toggle.
class SeatToggled extends CustomerSuperAppEvent {
  final int seatIndex;
  const SeatToggled(this.seatIndex);
  @override
  List<Object?> get props => [seatIndex];
}

/// Fleet auction bid placed.
class FleetBidPlaced extends CustomerSuperAppEvent {
  final String loadId;
  final double amount;
  const FleetBidPlaced({required this.loadId, required this.amount});
  @override
  List<Object?> get props => [loadId, amount];
}
