import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/services/hardware_scan_service.dart';

abstract class FactoryDashboardEvent extends Equatable {
  const FactoryDashboardEvent();
}

/// New scan payload from HardwareScanService.
class ScanArrivalDetected extends FactoryDashboardEvent {
  final ScanResult result;
  const ScanArrivalDetected(this.result);
  @override
  List<Object?> get props => [result];
}

/// Fleet position update from WebSocket (busFleetGps / fleetLocations).
class FleetPositionUpdated extends FactoryDashboardEvent {
  final Map<String, dynamic> payload;
  const FleetPositionUpdated(this.payload);
  @override
  List<Object?> get props => [payload];
}

/// Cross-cutting infraction forwarded from SecurityMonitorBloc.
class TenantSecurityAlertReceived extends FactoryDashboardEvent {
  final Map<String, dynamic> payload;
  final String alertType; // 'counterfeit' | 'geo_diversion'
  const TenantSecurityAlertReceived({
    required this.payload,
    required this.alertType,
  });
  @override
  List<Object?> get props => [payload, alertType];
}

/// Refresh production metrics from API / cache.
class ProductionMetricsRefresh extends FactoryDashboardEvent {
  const ProductionMetricsRefresh();
  @override
  List<Object?> get props => [];
}
