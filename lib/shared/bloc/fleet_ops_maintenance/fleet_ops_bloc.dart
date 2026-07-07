// Fleet Ops Bloc — maintenance, fuel analytics, crew scheduling state machine
//
// Tracks odometer from telemetry, processes fuel logs through isolated
// computation, evaluates maintenance thresholds, and manages crew hours.
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:trace_odd/shared/bloc/fleet_ops_maintenance/fleet_ops_event.dart';
import 'package:trace_odd/shared/bloc/fleet_ops_maintenance/fleet_ops_state.dart';
import 'package:trace_odd/shared/models/fleet_maintenance_models.dart';
import 'package:trace_odd/shared/services/maintenance_compute.dart';

final _opsUuid = const Uuid();

class FleetOpsBloc extends Bloc<FleetOpsEvent, FleetOpsState> {
  /// Cached odometer per vehicle for accumulation from telemetry.
  final Map<String, double> _lastOdometer = {};

  FleetOpsBloc() : super(const FleetOpsState()) {
    on<TrackOdometerAccumulation>(_onTrackOdo);
    on<LogFuelRefuelingEvent>(_onLogFuel);
    on<TriggerMaintenanceEvaluation>(_onEvalMaint);
    on<LoadVehicleHealthProfiles>(_onLoadHealth);
    on<VehicleHealthProfilesLoaded>(_onHealthLoaded);
    on<LoadFuelLogs>(_onLoadFuel);
    on<FuelLogsLoaded>(_onFuelLoaded);
    on<OptimizeCrewSchedule>(_onOptimize);
    on<DismissMaintenanceAlert>(_onDismiss);
    on<RecordServiceCompleted>(_onService);
    on<ClearOpsError>(_onClear);
  }

  // ═══════════════════ Odometer Tracking ═══════════════════

  void _onTrackOdo(TrackOdometerAccumulation e, Emitter<FleetOpsState> emit) {
    final v = e.telemetry;
    final prevOdo = _lastOdometer[v.vehicleId] ?? 0;
    // Approximate distance from speed * time (5-second interval typical).
    final distKm = v.speed * (5.0 / 3600.0); // 5s → hours → km
    final newOdo = prevOdo + distKm;
    _lastOdometer[v.vehicleId] = newOdo;

    final health = state.vehicleHealth[v.vehicleId];
    if (health != null) {
      final updated = health.copyWith(
        currentOdometerKm: newOdo,
        totalRuntimeHours: health.totalRuntimeHours + (5.0 / 3600.0),
      );
      final newMap = Map<String, VehicleHealth>.from(state.vehicleHealth);
      newMap[v.vehicleId] = updated;
      emit(state.copyWith(vehicleHealth: newMap));
    }
  }

  // ═══════════════════ Fuel Logging ═══════════════════

  Future<void> _onLogFuel(
    LogFuelRefuelingEvent e,
    Emitter<FleetOpsState> emit,
  ) async {
    final logs = [...state.fuelLogs, e.entry];
    emit(state.copyWith(fuelLogs: logs, isComputing: true));

    // Calculate updated efficiency via isolated compute.
    final vehicleLogs = logs
        .where((l) => l.vehicleId == e.entry.vehicleId)
        .toList();
    if (vehicleLogs.length >= 2) {
      final stats = await FuelComputeService.calculate(logs: vehicleLogs);
      final newStats = Map<String, FuelEfficiencyStats>.from(state.fuelStats);
      newStats[e.entry.vehicleId] = stats;
      emit(state.copyWith(fuelStats: newStats, isComputing: false));
    } else {
      emit(state.copyWith(isComputing: false));
    }
  }

  // ═══════════════════ Maintenance Evaluation ═══════════════════

  Future<void> _onEvalMaint(
    TriggerMaintenanceEvaluation e,
    Emitter<FleetOpsState> emit,
  ) async {
    emit(state.copyWith(isComputing: true));
    final updated = <String, VehicleHealth>{};
    final allAlerts = <MaintenanceAlert>[];

    for (final entry in state.vehicleHealth.entries) {
      final result = await MaintenanceComputeService.evaluate(
        health: entry.value,
      );
      updated[entry.key] = result.updatedHealth;
      allAlerts.addAll(result.newAlerts);
    }

    emit(
      state.copyWith(
        vehicleHealth: updated,
        activeAlerts: allAlerts,
        isComputing: false,
      ),
    );
  }

  // ═══════════════════ Health Profiles ═══════════════════

  void _onLoadHealth(LoadVehicleHealthProfiles e, Emitter<FleetOpsState> emit) {
    // In production: fetch from API. For now, emit placeholder profiles.
    final profiles = [
      VehicleHealth(
        vehicleId: 'BUS-001',
        vehicleName: 'Coach 54',
        ownerId: 'owner-1',
        currentOdometerKm: 45200,
        totalRuntimeHours: 1800,
      ),
      VehicleHealth(
        vehicleId: 'BUS-002',
        vehicleName: 'Standard 45',
        ownerId: 'owner-1',
        currentOdometerKm: 31200,
        totalRuntimeHours: 1200,
      ),
      VehicleHealth(
        vehicleId: 'TRK-001',
        vehicleName: 'Hino 500',
        ownerId: 'owner-2',
        currentOdometerKm: 68000,
        totalRuntimeHours: 3200,
      ),
    ].where((p) => e.ownerId == null || p.ownerId == e.ownerId).toList();
    add(VehicleHealthProfilesLoaded(profiles));
  }

  void _onHealthLoaded(
    VehicleHealthProfilesLoaded e,
    Emitter<FleetOpsState> emit,
  ) {
    final map = Map<String, VehicleHealth>.from(state.vehicleHealth);
    for (final p in e.profiles) {
      map[p.vehicleId] = p;
    }
    emit(state.copyWith(vehicleHealth: map));
    // Auto-trigger maintenance evaluation.
    add(const TriggerMaintenanceEvaluation());
  }

  // ═══════════════════ Fuel Logs ═══════════════════

  void _onLoadFuel(LoadFuelLogs e, Emitter<FleetOpsState> emit) {
    // Production: fetch from API. For now, generate demo logs.
    final logs = <FuelLogEntry>[
      FuelLogEntry(
        id: _opsUuid.v4(),
        vehicleId: e.vehicleId ?? 'BUS-001',
        litres: 120,
        cost: 32400,
        odometerAtRefuel: 40000,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
      ),
      FuelLogEntry(
        id: _opsUuid.v4(),
        vehicleId: e.vehicleId ?? 'BUS-001',
        litres: 115,
        cost: 31050,
        odometerAtRefuel: 42000,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FuelLogEntry(
        id: _opsUuid.v4(),
        vehicleId: e.vehicleId ?? 'BUS-001',
        litres: 130,
        cost: 35100,
        odometerAtRefuel: 44500,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ].where((l) => e.vehicleId == null || l.vehicleId == e.vehicleId).toList();
    add(FuelLogsLoaded(logs));
  }

  void _onFuelLoaded(FuelLogsLoaded e, Emitter<FleetOpsState> emit) {
    emit(state.copyWith(fuelLogs: e.logs));
    // Calculate efficiency for each vehicle.
    final vehicles = e.logs.map((l) => l.vehicleId).toSet();
    for (final vid in vehicles) {
      final vLogs = e.logs.where((l) => l.vehicleId == vid).toList();
      if (vLogs.length >= 2) {
        FuelComputeService.calculate(logs: vLogs).then((stats) {
          if (!isClosed) {
            final newStats = Map<String, FuelEfficiencyStats>.from(
              state.fuelStats,
            );
            newStats[vid] = stats;
            emit(state.copyWith(fuelStats: newStats));
          }
        });
      }
    }
  }

  // ═══════════════════ Crew Scheduling ═══════════════════

  void _onOptimize(OptimizeCrewSchedule e, Emitter<FleetOpsState> emit) {
    final assignments = Map<String, CrewAssignment>.from(state.crewAssignments);
    for (final entry in assignments.entries) {
      final a = entry.value;
      if (a.hoursWorked >= a.maxHoursAllowed && a.shiftEnd == null) {
        assignments[entry.key] = CrewAssignment(
          assignmentId: a.assignmentId,
          vehicleId: a.vehicleId,
          driverId: a.driverId,
          driverName: a.driverName,
          conductorId: a.conductorId,
          shiftStart: a.shiftStart,
          shiftEnd: DateTime.now(),
          hoursWorked: a.hoursWorked,
          maxHoursAllowed: a.maxHoursAllowed,
          isOverLimit: true,
        );
      }
    }
    emit(state.copyWith(crewAssignments: assignments));
  }

  // ═══════════════════ Alert Dismiss / Service Record ═══════════════════

  void _onDismiss(DismissMaintenanceAlert e, Emitter<FleetOpsState> emit) {
    final alerts = state.activeAlerts.where((a) => a.id != e.alertId).toList();
    emit(state.copyWith(activeAlerts: alerts));
  }

  void _onService(RecordServiceCompleted e, Emitter<FleetOpsState> emit) {
    final health = state.vehicleHealth[e.vehicleId];
    if (health == null) return;
    final newOdo = Map<MaintenanceType, double>.from(
      health.lastServiceOdometer,
    );
    final newHrs = Map<MaintenanceType, double>.from(health.lastServiceHours);
    newOdo[e.type] = e.odometerAtService;
    newHrs[e.type] = e.hoursAtService;

    final updated = health.copyWith(
      lastServiceOdometer: newOdo,
      lastServiceHours: newHrs,
    );
    final newMap = Map<String, VehicleHealth>.from(state.vehicleHealth);
    newMap[e.vehicleId] = updated;
    emit(state.copyWith(vehicleHealth: newMap));

    // Remove related alerts.
    final alerts = state.activeAlerts
        .where((a) => !(a.vehicleId == e.vehicleId && a.type == e.type))
        .toList();
    emit(state.copyWith(activeAlerts: alerts));
  }

  void _onClear(ClearOpsError e, Emitter<FleetOpsState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
