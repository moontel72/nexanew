// Maintenance Compute Service — isolated wear & threshold calculations
//
// Evaluates vehicle odometer/hours against maintenance thresholds.
// Generates MaintenanceAlert records. Designed to run in isolates
// via compute() for zero main-thread impact.
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:trace_odd/shared/models/fleet_maintenance_models.dart';
import 'package:trace_odd/shared/models/geofence_models.dart';

final _maintUuid = const Uuid();

/// Input for maintenance evaluation.
class _MaintInput {
  final VehicleHealth health;
  final List<Map<String, dynamic>> thresholdsJson;
  const _MaintInput({required this.health, required this.thresholdsJson});
}

/// Output from maintenance evaluation.
class MaintenanceEvalResult {
  final VehicleHealth updatedHealth;
  final List<MaintenanceAlert> newAlerts;
  const MaintenanceEvalResult({
    required this.updatedHealth,
    required this.newAlerts,
  });
}

/// Top-level entry for isolate computation.
MaintenanceEvalResult _evalMaint(_MaintInput input) {
  final thresholds = input.thresholdsJson
      .map(
        (j) => MaintenanceThreshold(
          type: MaintenanceType.values.firstWhere(
            (t) => t.name == j['type'],
            orElse: () => MaintenanceType.generalInspection,
          ),
          label: j['label']?.toString() ?? '',
          intervalKm: (j['interval_km'] ?? double.infinity).toDouble(),
          intervalHours: (j['interval_hours'] ?? double.infinity).toDouble(),
          severity: GeofenceSeverity.values.firstWhere(
            (s) => s.name == j['severity'],
            orElse: () => GeofenceSeverity.warning,
          ),
        ),
      )
      .toList();

  final alerts = <MaintenanceAlert>[];
  final newOdo = Map<MaintenanceType, double>.from(
    input.health.lastServiceOdometer,
  );
  final newHrs = Map<MaintenanceType, double>.from(
    input.health.lastServiceHours,
  );

  for (final t in thresholds) {
    final lastOdo = input.health.lastServiceOdometer[t.type] ?? 0;
    final lastHrs = input.health.lastServiceHours[t.type] ?? 0;
    final sinceOdo = input.health.currentOdometerKm - lastOdo;
    final sinceHrs = input.health.totalRuntimeHours - lastHrs;

    double percentUsed = 0;
    double remainingKm = double.infinity;

    if (t.intervalKm.isFinite) {
      percentUsed = max(percentUsed, sinceOdo / t.intervalKm);
      remainingKm = min(remainingKm, t.intervalKm - sinceOdo);
    }
    if (t.intervalHours.isFinite) {
      percentUsed = max(percentUsed, sinceHrs / t.intervalHours);
    }

    if (percentUsed >= 0.8) {
      alerts.add(
        MaintenanceAlert(
          id: _maintUuid.v4(),
          vehicleId: input.health.vehicleId,
          type: t.type,
          label: t.label,
          severity: percentUsed >= 1.0 ? GeofenceSeverity.critical : t.severity,
          currentKm: sinceOdo,
          thresholdKm: t.intervalKm,
          remainingKm: remainingKm,
          percentUsed: percentUsed,
          triggeredAt: DateTime.now(),
        ),
      );
    }
  }

  final updated = input.health.copyWith(activeAlerts: alerts);
  return MaintenanceEvalResult(updatedHealth: updated, newAlerts: alerts);
}

/// Fuel efficiency computation input.
class _FuelInput {
  final List<Map<String, dynamic>> logsJson;
  const _FuelInput({required this.logsJson});
}

/// Fuel efficiency stats computed in isolate.
FuelEfficiencyStats _evalFuel(_FuelInput input) {
  final logs = input.logsJson.map((j) => FuelLogEntry.fromJson(j)).toList();
  if (logs.isEmpty)
    return FuelEfficiencyStats(vehicleId: logs.firstOrNull?.vehicleId ?? '');

  logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  double totalKm = 0;
  double totalLitres = 0;
  double totalCost = 0;
  double prevOdo = logs.first.odometerAtRefuel;

  for (int i = 1; i < logs.length; i++) {
    final dist = logs[i].odometerAtRefuel - prevOdo;
    if (dist > 0) {
      totalKm += dist;
      totalLitres += logs[i].litres;
      totalCost += logs[i].cost;
    }
    prevOdo = logs[i].odometerAtRefuel;
  }

  // Moving average of last 5 refuels
  final recent = logs.length > 5 ? logs.sublist(logs.length - 5) : logs;
  double recentKm = 0, recentLitres = 0;
  double recentPrev = recent.first.odometerAtRefuel;
  for (int i = 1; i < recent.length; i++) {
    final dist = recent[i].odometerAtRefuel - recentPrev;
    if (dist > 0) {
      recentKm += dist;
      recentLitres += recent[i].litres;
    }
    recentPrev = recent[i].odometerAtRefuel;
  }

  return FuelEfficiencyStats(
    vehicleId: logs.first.vehicleId,
    totalLitres: totalLitres,
    totalCost: totalCost,
    totalKm: totalKm,
    avgKmPerLitre: totalLitres > 0 ? totalKm / totalLitres : 0,
    movingAvgKmPerLitre: recentLitres > 0 ? recentKm / recentLitres : 0,
    costPerKm: totalKm > 0 ? totalCost / totalKm : 0,
    refuelCount: logs.length,
  );
}

/// Public service API.
class MaintenanceComputeService {
  static Future<MaintenanceEvalResult> evaluate({
    required VehicleHealth health,
    List<MaintenanceThreshold> thresholds = MaintenanceThreshold.defaults,
  }) async {
    final input = _MaintInput(
      health: health,
      thresholdsJson: thresholds
          .map(
            (t) => {
              'type': t.type.name,
              'label': t.label,
              'interval_km': t.intervalKm,
              'interval_hours': t.intervalHours,
              'severity': t.severity.name,
            },
          )
          .toList(),
    );
    if (kIsWeb) return _evalMaint(input);
    return compute(_evalMaint, input);
  }
}

class FuelComputeService {
  static Future<FuelEfficiencyStats> calculate({
    required List<FuelLogEntry> logs,
  }) async {
    final input = _FuelInput(logsJson: logs.map((l) => l.toJson()).toList());
    if (kIsWeb) return _evalFuel(input);
    return compute(_evalFuel, input);
  }
}
