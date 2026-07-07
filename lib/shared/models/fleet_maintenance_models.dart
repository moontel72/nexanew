// Fleet Maintenance Models — maintenance thresholds, fuel logs, crew schedules
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/geofence_models.dart'
    show GeofenceSeverity;

// ── Maintenance Thresholds ──

enum MaintenanceType {
  oilChange,
  brakePad,
  tireRotation,
  engineTuneUp,
  transmission,
  batteryCheck,
  generalInspection,
}

/// A maintenance rule: triggers alert when odometer or hours exceed the interval.
class MaintenanceThreshold extends Equatable {
  final MaintenanceType type;
  final String label;
  final double intervalKm; // e.g. 5000 for oil change
  final double intervalHours; // e.g. 500 runtime hours
  final GeofenceSeverity severity; // re-using enum from geofence_models

  const MaintenanceThreshold({
    required this.type,
    required this.label,
    this.intervalKm = double.infinity,
    this.intervalHours = double.infinity,
    this.severity = GeofenceSeverity.warning,
  });

  /// Standard fleet thresholds.
  static const defaults = [
    MaintenanceThreshold(
      type: MaintenanceType.oilChange,
      label: 'Engine Oil Change',
      intervalKm: 5000,
      intervalHours: 250,
      severity: GeofenceSeverity.critical,
    ),
    MaintenanceThreshold(
      type: MaintenanceType.brakePad,
      label: 'Brake Pad Inspection',
      intervalKm: 15000,
      severity: GeofenceSeverity.warning,
    ),
    MaintenanceThreshold(
      type: MaintenanceType.tireRotation,
      label: 'Tyre Rotation',
      intervalKm: 10000,
      severity: GeofenceSeverity.info,
    ),
    MaintenanceThreshold(
      type: MaintenanceType.engineTuneUp,
      label: 'Engine Tune-Up',
      intervalKm: 30000,
      intervalHours: 1000,
      severity: GeofenceSeverity.warning,
    ),
    MaintenanceThreshold(
      type: MaintenanceType.transmission,
      label: 'Transmission Service',
      intervalKm: 60000,
      severity: GeofenceSeverity.info,
    ),
    MaintenanceThreshold(
      type: MaintenanceType.batteryCheck,
      label: 'Battery Check',
      intervalKm: 20000,
      intervalHours: 800,
      severity: GeofenceSeverity.info,
    ),
    MaintenanceThreshold(
      type: MaintenanceType.generalInspection,
      label: 'General Inspection',
      intervalKm: 25000,
      severity: GeofenceSeverity.info,
    ),
  ];

  @override
  List<Object?> get props => [type, label, intervalKm, intervalHours, severity];
}

// ── Fuel Log ──

class FuelLogEntry extends Equatable {
  final String id;
  final String vehicleId;
  final double litres;
  final double cost;
  final double odometerAtRefuel;
  final DateTime timestamp;
  final String? fuelType; // 'diesel', 'petrol', 'cng'

  const FuelLogEntry({
    required this.id,
    required this.vehicleId,
    required this.litres,
    required this.cost,
    required this.odometerAtRefuel,
    required this.timestamp,
    this.fuelType = 'diesel',
  });

  factory FuelLogEntry.fromJson(Map<String, dynamic> json) => FuelLogEntry(
    id: json['id']?.toString() ?? '',
    vehicleId: json['vehicle_id']?.toString() ?? '',
    litres: (json['litres'] ?? 0).toDouble(),
    cost: (json['cost'] ?? 0).toDouble(),
    odometerAtRefuel: (json['odometer_at_refuel'] ?? 0).toDouble(),
    timestamp:
        DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
        DateTime.now(),
    fuelType: json['fuel_type']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle_id': vehicleId,
    'litres': litres,
    'cost': cost,
    'odometer_at_refuel': odometerAtRefuel,
    'timestamp': timestamp.toIso8601String(),
    if (fuelType != null) 'fuel_type': fuelType,
  };

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    litres,
    cost,
    odometerAtRefuel,
    timestamp,
    fuelType,
  ];
}

/// Aggregated fuel efficiency stats per vehicle.
class FuelEfficiencyStats extends Equatable {
  final String vehicleId;
  final double totalLitres;
  final double totalCost;
  final double totalKm;
  final double avgKmPerLitre; // overall average
  final double movingAvgKmPerLitre; // last 5 refuels moving average
  final double costPerKm;
  final int refuelCount;

  const FuelEfficiencyStats({
    required this.vehicleId,
    this.totalLitres = 0,
    this.totalCost = 0,
    this.totalKm = 0,
    this.avgKmPerLitre = 0,
    this.movingAvgKmPerLitre = 0,
    this.costPerKm = 0,
    this.refuelCount = 0,
  });

  String get efficiencyLabel => '${avgKmPerLitre.toStringAsFixed(1)} km/L';
  String get costPerKmLabel => 'PKR ${costPerKm.toStringAsFixed(2)}/km';

  @override
  List<Object?> get props => [
    vehicleId,
    totalLitres,
    totalCost,
    totalKm,
    avgKmPerLitre,
    movingAvgKmPerLitre,
    costPerKm,
    refuelCount,
  ];
}

// ── Vehicle Health ──

/// Aggregated health state for a single vehicle.
class VehicleHealth extends Equatable {
  final String vehicleId;
  final String vehicleName;
  final String? ownerId;
  final double currentOdometerKm;
  final double totalRuntimeHours;
  final Map<MaintenanceType, double>
  lastServiceOdometer; // odometer at last service
  final Map<MaintenanceType, double> lastServiceHours; // hours at last service
  final List<MaintenanceAlert> activeAlerts;

  const VehicleHealth({
    required this.vehicleId,
    this.vehicleName = '',
    this.ownerId,
    this.currentOdometerKm = 0,
    this.totalRuntimeHours = 0,
    this.lastServiceOdometer = const {},
    this.lastServiceHours = const {},
    this.activeAlerts = const [],
  });

  VehicleHealth copyWith({
    String? vehicleId,
    String? vehicleName,
    String? ownerId,
    double? currentOdometerKm,
    double? totalRuntimeHours,
    Map<MaintenanceType, double>? lastServiceOdometer,
    Map<MaintenanceType, double>? lastServiceHours,
    List<MaintenanceAlert>? activeAlerts,
  }) => VehicleHealth(
    vehicleId: vehicleId ?? this.vehicleId,
    vehicleName: vehicleName ?? this.vehicleName,
    ownerId: ownerId ?? this.ownerId,
    currentOdometerKm: currentOdometerKm ?? this.currentOdometerKm,
    totalRuntimeHours: totalRuntimeHours ?? this.totalRuntimeHours,
    lastServiceOdometer: lastServiceOdometer ?? this.lastServiceOdometer,
    lastServiceHours: lastServiceHours ?? this.lastServiceHours,
    activeAlerts: activeAlerts ?? this.activeAlerts,
  );

  @override
  List<Object?> get props => [
    vehicleId,
    vehicleName,
    ownerId,
    currentOdometerKm,
    totalRuntimeHours,
    lastServiceOdometer,
    lastServiceHours,
    activeAlerts,
  ];
}

/// A maintenance alert — triggered when a threshold is breached.
class MaintenanceAlert extends Equatable {
  final String id;
  final String vehicleId;
  final MaintenanceType type;
  final String label;
  final GeofenceSeverity severity;
  final double currentKm;
  final double thresholdKm;
  final double remainingKm;
  final double percentUsed; // 0.0 (just serviced) to 1.0+ (overdue)
  final DateTime triggeredAt;

  const MaintenanceAlert({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.label,
    this.severity = GeofenceSeverity.warning,
    required this.currentKm,
    required this.thresholdKm,
    required this.remainingKm,
    required this.percentUsed,
    required this.triggeredAt,
  });

  bool get isOverdue => percentUsed >= 1.0;
  bool get isCritical => percentUsed >= 0.9;

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    type,
    label,
    severity,
    currentKm,
    thresholdKm,
    remainingKm,
    percentUsed,
    triggeredAt,
  ];
}

// ── Crew Scheduling ──

class CrewAssignment extends Equatable {
  final String assignmentId;
  final String vehicleId;
  final String driverId;
  final String driverName;
  final String? conductorId;
  final DateTime shiftStart;
  final DateTime? shiftEnd;
  final double hoursWorked;
  final double maxHoursAllowed; // regulatory max (e.g. 12h)
  final bool isOverLimit;

  const CrewAssignment({
    required this.assignmentId,
    required this.vehicleId,
    required this.driverId,
    required this.driverName,
    this.conductorId,
    required this.shiftStart,
    this.shiftEnd,
    this.hoursWorked = 0,
    this.maxHoursAllowed = 12,
    this.isOverLimit = false,
  });

  @override
  List<Object?> get props => [
    assignmentId,
    vehicleId,
    driverId,
    driverName,
    conductorId,
    shiftStart,
    shiftEnd,
    hoursWorked,
    maxHoursAllowed,
    isOverLimit,
  ];
}
