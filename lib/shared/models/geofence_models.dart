// Geofence & Route Models — data structures for route analytics
//
// Defines route boundaries, geofence alerts, corridor speeds, and
// historical trip analytics used by FleetAnalyticsBloc.
import 'package:equatable/equatable.dart';

/// A single waypoint on a route.
class RouteWaypoint extends Equatable {
  final double lat;
  final double lng;
  final int sequence;
  final String? label; // e.g. "Stop A - Main Terminal"

  const RouteWaypoint({
    required this.lat,
    required this.lng,
    required this.sequence,
    this.label,
  });

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) => RouteWaypoint(
    lat: (json['lat'] ?? 0).toDouble(),
    lng: (json['lng'] ?? 0).toDouble(),
    sequence: (json['sequence'] ?? 0) as int,
    label: json['label']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'sequence': sequence,
    if (label != null) 'label': label,
  };

  @override
  List<Object?> get props => [lat, lng, sequence, label];
}

/// Linear corridor route defined by an ordered list of waypoints
/// plus a corridor width (meters) on each side.
class RouteBoundary extends Equatable {
  final String routeId;
  final String routeName;
  final List<RouteWaypoint> waypoints;
  final double corridorWidthMeters; // Half-width of the route corridor
  final List<GeoPolygon>
  geofenceZones; // Optional safe zones / restricted areas
  final Map<String, double> segmentSpeedLimits; // segment_key → km/h

  const RouteBoundary({
    required this.routeId,
    required this.routeName,
    this.waypoints = const [],
    this.corridorWidthMeters = 50,
    this.geofenceZones = const [],
    this.segmentSpeedLimits = const {},
  });

  factory RouteBoundary.fromJson(Map<String, dynamic> json) {
    final wpRaw = json['waypoints'] as List? ?? [];
    final geoRaw = json['geofence_zones'] as List? ?? [];
    final speedRaw = json['speed_limits'] as Map<String, dynamic>? ?? {};
    return RouteBoundary(
      routeId: json['route_id']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? 'Unknown Route',
      waypoints: wpRaw
          .map((e) => RouteWaypoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      corridorWidthMeters: (json['corridor_width'] ?? 50).toDouble(),
      geofenceZones: geoRaw
          .map((e) => GeoPolygon.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      segmentSpeedLimits: speedRaw.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
    );
  }

  /// Find the closest segment to a given point.
  /// Returns segment index and cross-track distance in meters.
  (int segmentIdx, double crossTrackMeters) closestSegment(
    double lat,
    double lng,
  ) {
    if (waypoints.length < 2) return (0, double.infinity);
    double minDist = double.infinity;
    int bestIdx = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      final dist = _crossTrackDistance(
        waypoints[i].lat,
        waypoints[i].lng,
        waypoints[i + 1].lat,
        waypoints[i + 1].lng,
        lat,
        lng,
      );
      if (dist < minDist) {
        minDist = dist;
        bestIdx = i;
      }
    }
    return (bestIdx, minDist);
  }

  /// Get the speed limit for a segment (or null if not set).
  double? speedLimitForSegment(int segmentIdx) {
    final key =
        '${waypoints[segmentIdx].sequence}_${waypoints[segmentIdx + 1].sequence}';
    return segmentSpeedLimits[key];
  }

  @override
  List<Object?> get props => [
    routeId,
    routeName,
    waypoints,
    corridorWidthMeters,
    geofenceZones,
    segmentSpeedLimits,
  ];
}

/// Simple geo polygon for geofence zones.
class GeoPolygon extends Equatable {
  final String id;
  final String name;
  final String type; // 'safe_zone', 'restricted', 'speed_limit', 'depot'
  final List<(double lat, double lng)> vertices;

  const GeoPolygon({
    required this.id,
    required this.name,
    this.type = 'safe_zone',
    required this.vertices,
  });

  factory GeoPolygon.fromJson(Map<String, dynamic> json) {
    final vertRaw = json['vertices'] as List? ?? [];
    return GeoPolygon(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'safe_zone',
      vertices: vertRaw.map((v) {
        final m = Map<String, dynamic>.from(v);
        return ((m['lat'] ?? 0).toDouble(), (m['lng'] ?? 0).toDouble());
      }).toList(),
    );
  }

  /// Ray-casting point-in-polygon test.
  bool containsPoint(double lat, double lng) {
    if (vertices.length < 3) return false;
    bool inside = false;
    final n = vertices.length;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final (viLat, viLng) = vertices[i];
      final (vjLat, vjLng) = vertices[j];
      if ((viLng > lng) != (vjLng > lng) &&
          lat < (vjLat - viLat) * (lng - viLng) / (vjLng - viLng) + viLat) {
        inside = !inside;
      }
    }
    return inside;
  }

  @override
  List<Object?> get props => [id, name, type, vertices];
}

/// Severity levels for geofence alerts.
enum GeofenceSeverity { info, warning, critical }

/// A geofence violation / route deviation alert.
class GeofenceAlert extends Equatable {
  final String alertId;
  final String vehicleId;
  final String routeId;
  final String
  type; // 'route_deviation', 'speed_violation', 'zone_breach', 'geofence_exit'
  final GeofenceSeverity severity;
  final double lat;
  final double lng;
  final double? distanceOffRoute; // meters
  final double? currentSpeed;
  final double? speedLimit;
  final String? zoneName;
  final DateTime timestamp;

  const GeofenceAlert({
    required this.alertId,
    required this.vehicleId,
    required this.routeId,
    required this.type,
    this.severity = GeofenceSeverity.warning,
    required this.lat,
    required this.lng,
    this.distanceOffRoute,
    this.currentSpeed,
    this.speedLimit,
    this.zoneName,
    required this.timestamp,
  });

  factory GeofenceAlert.fromJson(Map<String, dynamic> json) => GeofenceAlert(
    alertId: json['alert_id']?.toString() ?? '',
    vehicleId: json['vehicle_id']?.toString() ?? '',
    routeId: json['route_id']?.toString() ?? '',
    type: json['type']?.toString() ?? 'route_deviation',
    severity: GeofenceSeverity.values.firstWhere(
      (s) => s.name == json['severity'],
      orElse: () => GeofenceSeverity.warning,
    ),
    lat: (json['lat'] ?? 0).toDouble(),
    lng: (json['lng'] ?? 0).toDouble(),
    distanceOffRoute: json['distance_off_route']?.toDouble(),
    currentSpeed: json['current_speed']?.toDouble(),
    speedLimit: json['speed_limit']?.toDouble(),
    zoneName: json['zone_name']?.toString(),
    timestamp:
        DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
        DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'alert_id': alertId,
    'vehicle_id': vehicleId,
    'route_id': routeId,
    'type': type,
    'severity': severity.name,
    'lat': lat,
    'lng': lng,
    if (distanceOffRoute != null) 'distance_off_route': distanceOffRoute,
    if (currentSpeed != null) 'current_speed': currentSpeed,
    if (speedLimit != null) 'speed_limit': speedLimit,
    if (zoneName != null) 'zone_name': zoneName,
    'timestamp': timestamp.toIso8601String(),
  };

  bool get isCritical => severity == GeofenceSeverity.critical;

  @override
  List<Object?> get props => [
    alertId,
    vehicleId,
    routeId,
    type,
    severity,
    lat,
    lng,
    distanceOffRoute,
    currentSpeed,
    speedLimit,
    zoneName,
    timestamp,
  ];
}

/// Historical trip analytics aggregation.
class TripAnalytics extends Equatable {
  final String tripId;
  final String vehicleId;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistanceKm;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final Duration drivingDuration;
  final int alertCount;
  final List<double> speedProfile; // sampled speeds over trip
  final int deviationCount;
  final double onTimePercentage; // 0-100

  const TripAnalytics({
    required this.tripId,
    required this.vehicleId,
    required this.startTime,
    this.endTime,
    this.totalDistanceKm = 0,
    this.avgSpeedKmh = 0,
    this.maxSpeedKmh = 0,
    this.drivingDuration = Duration.zero,
    this.alertCount = 0,
    this.speedProfile = const [],
    this.deviationCount = 0,
    this.onTimePercentage = 100,
  });

  factory TripAnalytics.fromJson(Map<String, dynamic> json) => TripAnalytics(
    tripId: json['trip_id']?.toString() ?? '',
    vehicleId: json['vehicle_id']?.toString() ?? '',
    startTime:
        DateTime.tryParse(json['start_time']?.toString() ?? '') ??
        DateTime.now(),
    endTime: DateTime.tryParse(json['end_time']?.toString() ?? ''),
    totalDistanceKm: (json['total_distance_km'] ?? 0).toDouble(),
    avgSpeedKmh: (json['avg_speed_kmh'] ?? 0).toDouble(),
    maxSpeedKmh: (json['max_speed_kmh'] ?? 0).toDouble(),
    drivingDuration: Duration(
      seconds: (json['driving_duration_s'] ?? 0) as int,
    ),
    alertCount: (json['alert_count'] ?? 0) as int,
    speedProfile:
        (json['speed_profile'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [],
    deviationCount: (json['deviation_count'] ?? 0) as int,
    onTimePercentage: (json['on_time_pct'] ?? 100).toDouble(),
  );

  String get durationDisplay {
    final h = drivingDuration.inHours;
    final m = drivingDuration.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  @override
  List<Object?> get props => [
    tripId,
    vehicleId,
    startTime,
    endTime,
    totalDistanceKm,
    avgSpeedKmh,
    maxSpeedKmh,
    drivingDuration,
    alertCount,
    speedProfile,
    deviationCount,
    onTimePercentage,
  ];
}

// ── Haversine & cross-track helpers (inline for BLoC use) ──

double _crossTrackDistance(
  double segStartLat,
  double segStartLng,
  double segEndLat,
  double segEndLng,
  double pointLat,
  double pointLng,
) {
  const R = 6371000.0;
  final d13 =
      _haversineMeters(segStartLat, segStartLng, pointLat, pointLng) / R;
  final bearing13 = _bearingRad(segStartLat, segStartLng, pointLat, pointLng);
  final bearing12 = _bearingRad(segStartLat, segStartLng, segEndLat, segEndLng);
  final crossTrackRad = asin(sin(d13) * sin(bearing13 - bearing12));
  return (crossTrackRad * R).abs();
}

double _haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  const R = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return R * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _bearingRad(double lat1, double lng1, double lat2, double lng2) {
  final dLng = _toRad(lng2 - lng1);
  final y = sin(dLng) * cos(_toRad(lat2));
  final x =
      cos(_toRad(lat1)) * sin(_toRad(lat2)) -
      sin(_toRad(lat1)) * cos(_toRad(lat2)) * cos(dLng);
  return atan2(y, x);
}

double _toRad(double deg) => deg * 3.141592653589793 / 180.0;
