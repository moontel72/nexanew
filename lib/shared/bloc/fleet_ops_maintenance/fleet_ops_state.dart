// Fleet Ops State — maintenance, fuel, crew scheduling state
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/fleet_maintenance_models.dart';

class FleetOpsState extends Equatable {
  final Map<String, VehicleHealth> vehicleHealth; // vehicleId → health
  final Map<String, FuelEfficiencyStats> fuelStats; // vehicleId → fuel stats
  final List<FuelLogEntry> fuelLogs; // all fuel logs
  final List<MaintenanceAlert> activeAlerts; // all pending alerts
  final Map<String, CrewAssignment>
  crewAssignments; // assignmentId → assignment
  final bool isComputing;
  final String? error;

  const FleetOpsState({
    this.vehicleHealth = const {},
    this.fuelStats = const {},
    this.fuelLogs = const [],
    this.activeAlerts = const [],
    this.crewAssignments = const {},
    this.isComputing = false,
    this.error,
  });

  FleetOpsState copyWith({
    Map<String, VehicleHealth>? vehicleHealth,
    Map<String, FuelEfficiencyStats>? fuelStats,
    List<FuelLogEntry>? fuelLogs,
    List<MaintenanceAlert>? activeAlerts,
    Map<String, CrewAssignment>? crewAssignments,
    bool? isComputing,
    String? error,
    bool clearError = false,
  }) => FleetOpsState(
    vehicleHealth: vehicleHealth ?? this.vehicleHealth,
    fuelStats: fuelStats ?? this.fuelStats,
    fuelLogs: fuelLogs ?? this.fuelLogs,
    activeAlerts: activeAlerts ?? this.activeAlerts,
    crewAssignments: crewAssignments ?? this.crewAssignments,
    isComputing: isComputing ?? this.isComputing,
    error: clearError ? null : (error ?? this.error),
  );

  /// Filter health records by owner scope.
  Map<String, VehicleHealth> healthForOwner(String ownerId) => Map.fromEntries(
    vehicleHealth.entries.where((e) => e.value.ownerId == ownerId),
  );

  /// Filter fuel stats by owner scope.
  Map<String, FuelEfficiencyStats> fuelForOwner(String ownerId) =>
      Map.fromEntries(
        fuelStats.entries.where((e) {
          final vh = vehicleHealth[e.key];
          return vh?.ownerId == ownerId;
        }),
      );

  int get criticalAlertCount => activeAlerts.where((a) => a.isCritical).length;
  int get overdueCount => activeAlerts.where((a) => a.isOverdue).length;

  @override
  List<Object?> get props => [
    vehicleHealth,
    fuelStats,
    fuelLogs,
    activeAlerts,
    crewAssignments,
    isComputing,
    error,
  ];
}
