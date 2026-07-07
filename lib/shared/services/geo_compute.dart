// Geo Compute Service — isolated computation utilities
//
// Offloads heavy geometric calculations from the UI thread using
// Dart isolates (via `compute()`). All methods take serializable
// inputs and return serializable outputs.
//
// Used by FleetAnalyticsBloc to evaluate vehicle telemetry against
// route boundaries, geofence zones, and speed corridors.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:trace_odd/shared/models/geofence_models.dart';

/// Input payload for geofence evaluation.
class _GeoInput {
  final double vehicleLat, vehicleLng, vehicleSpeed;
  final String vehicleId;
  final Map<String, dynamic> routeJson;

  const _GeoInput({
    required this.vehicleLat,
    required this.vehicleLng,
    required this.vehicleSpeed,
    required this.vehicleId,
    required this.routeJson,
  });
}

/// Output from geofence evaluation.
class GeoEvaluationResult {
  final bool isDeviating;
  final bool isSpeeding;
  final bool isInGeofence;
  final double distanceOffRouteMeters;
  final double? speedLimit;
  final String? breachedZoneName;
  final String? breachedZoneType;
  final List<Map<String, dynamic>> alerts;

  const GeoEvaluationResult({
    this.isDeviating = false,
    this.isSpeeding = false,
    this.isInGeofence = true,
    this.distanceOffRouteMeters = 0,
    this.speedLimit,
    this.breachedZoneName,
    this.breachedZoneType,
    this.alerts = const [],
  });
}

/// Top-level entry point for isolate computation.
GeoEvaluationResult _evaluateGeo(_GeoInput input) {
  final route = RouteBoundary.fromJson(input.routeJson);
  final alerts = <Map<String, dynamic>>[];
  bool deviating = false;
  bool speeding = false;
  bool inGeofence = true;
  double distOffRoute = 0;
  double? speedLimit;
  String? breachedZone;
  String? breachedType;

  // 1. Cross-track distance from route corridor
  final (segmentIdx, crossTrack) = route.closestSegment(
    input.vehicleLat,
    input.vehicleLng,
  );
  distOffRoute = crossTrack;
  if (crossTrack > route.corridorWidthMeters) {
    deviating = true;
    alerts.add({
      'type': 'route_deviation',
      'severity': 'warning',
      'distance_off_route': crossTrack,
    });
  }

  // 2. Speed corridor check
  final limit = route.speedLimitForSegment(segmentIdx);
  speedLimit = limit;
  if (limit != null && input.vehicleSpeed > limit) {
    speeding = true;
    alerts.add({
      'type': 'speed_violation',
      'severity': input.vehicleSpeed > limit * 1.3 ? 'critical' : 'warning',
      'current_speed': input.vehicleSpeed,
      'speed_limit': limit,
    });
  }

  // 3. Geofence zone containment
  for (final zone in route.geofenceZones) {
    if (zone.type == 'restricted' &&
        zone.containsPoint(input.vehicleLat, input.vehicleLng)) {
      inGeofence = false;
      breachedZone = zone.name;
      breachedType = 'restricted';
      alerts.add({
        'type': 'zone_breach',
        'severity': 'critical',
        'zone_name': zone.name,
        'zone_type': zone.type,
      });
      break;
    }
  }

  return GeoEvaluationResult(
    isDeviating: deviating,
    isSpeeding: speeding,
    isInGeofence: inGeofence,
    distanceOffRouteMeters: distOffRoute,
    speedLimit: speedLimit,
    breachedZoneName: breachedZone,
    breachedZoneType: breachedType,
    alerts: alerts,
  );
}

/// Public API for geo evaluation — offloads to isolate when available.
class GeoComputeService {
  /// Evaluate a vehicle telemetry point against a route boundary.
  /// Returns computed results including deviation, speeding, and zone breach flags.
  static Future<GeoEvaluationResult> evaluate({
    required double vehicleLat,
    required double vehicleLng,
    required double vehicleSpeed,
    required String vehicleId,
    required RouteBoundary route,
  }) async {
    final input = _GeoInput(
      vehicleLat: vehicleLat,
      vehicleLng: vehicleLng,
      vehicleSpeed: vehicleSpeed,
      vehicleId: vehicleId,
      routeJson: _routeToJson(route),
    );

    // Use compute() to run in a separate isolate (non-blocking).
    // Falls back to synchronous if running on web (where isolates are limited).
    if (kIsWeb) {
      return _evaluateGeo(input);
    }
    return compute(_evaluateGeo, input);
  }

  /// Serialize a RouteBoundary to a JSON-compatible map.
  static Map<String, dynamic> _routeToJson(RouteBoundary route) => {
    'route_id': route.routeId,
    'route_name': route.routeName,
    'corridor_width': route.corridorWidthMeters,
    'waypoints': route.waypoints.map((w) => w.toJson()).toList(),
    'geofence_zones': route.geofenceZones
        .map(
          (z) => {
            'id': z.id,
            'name': z.name,
            'type': z.type,
            'vertices': z.vertices
                .map((v) => {'lat': v.$1, 'lng': v.$2})
                .toList(),
          },
        )
        .toList(),
    'speed_limits': route.segmentSpeedLimits,
  };
}
