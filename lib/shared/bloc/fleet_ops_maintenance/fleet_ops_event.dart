// Fleet Ops Events — maintenance, fuel, scheduling events
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_models.dart';
import 'package:trace_odd/shared/models/fleet_maintenance_models.dart';

abstract class FleetOpsEvent extends Equatable {
  const FleetOpsEvent();
  @override
  List<Object?> get props => [];
}

/// Accumulate odometer from telemetry packet.
class TrackOdometerAccumulation extends FleetOpsEvent {
  final VehicleTelemetry telemetry;
  const TrackOdometerAccumulation(this.telemetry);
  @override
  List<Object?> get props => [telemetry];
}

/// Log a fuel refueling event.
class LogFuelRefuelingEvent extends FleetOpsEvent {
  final FuelLogEntry entry;
  const LogFuelRefuelingEvent(this.entry);
  @override
  List<Object?> get props => [entry];
}

/// Evaluate maintenance thresholds for all vehicles.
class TriggerMaintenanceEvaluation extends FleetOpsEvent {
  const TriggerMaintenanceEvaluation();
}

/// Load vehicle health profiles from backend.
class LoadVehicleHealthProfiles extends FleetOpsEvent {
  final String? ownerId;
  const LoadVehicleHealthProfiles({this.ownerId});
  @override
  List<Object?> get props => [ownerId];
}

/// Health profiles loaded.
class VehicleHealthProfilesLoaded extends FleetOpsEvent {
  final List<VehicleHealth> profiles;
  const VehicleHealthProfilesLoaded(this.profiles);
  @override
  List<Object?> get props => [profiles];
}

/// Load fuel logs.
class LoadFuelLogs extends FleetOpsEvent {
  final String? vehicleId;
  const LoadFuelLogs({this.vehicleId});
  @override
  List<Object?> get props => [vehicleId];
}

/// Fuel logs loaded.
class FuelLogsLoaded extends FleetOpsEvent {
  final List<FuelLogEntry> logs;
  const FuelLogsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

/// Optimize crew schedule based on hours worked.
class OptimizeCrewSchedule extends FleetOpsEvent {
  const OptimizeCrewSchedule();
}

/// Acknowledge / dismiss a maintenance alert.
class DismissMaintenanceAlert extends FleetOpsEvent {
  final String alertId;
  const DismissMaintenanceAlert(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

/// Record a service completed (reset odometer/hours for a maintenance type).
class RecordServiceCompleted extends FleetOpsEvent {
  final String vehicleId;
  final MaintenanceType type;
  final double odometerAtService;
  final double hoursAtService;
  const RecordServiceCompleted({
    required this.vehicleId,
    required this.type,
    required this.odometerAtService,
    this.hoursAtService = 0,
  });
  @override
  List<Object?> get props => [
    vehicleId,
    type,
    odometerAtService,
    hoursAtService,
  ];
}

/// Clear error.
class ClearOpsError extends FleetOpsEvent {
  const ClearOpsError();
}
