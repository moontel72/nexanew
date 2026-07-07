// Telemetry Models — fleet-wide vehicle tracking data structures
//
// Extends the existing BusLocationUpdate for fleet-level aggregation.
// Supports Bus, Truck, and any tracked asset via the generic VehicleTelemetry wrapper.
import 'package:equatable/equatable.dart';
import 'package:trace_odd/features/bus_operations/data/services/bus_tracking_models.dart';

/// Multi-tenant scoping for telemetry views.
enum TelemetryScope {
  /// Fleet/Admin — sees all active vehicles in the network.
  fleet,

  /// Owner — sees only vehicles belonging to their registered assets.
  owner,

  /// Driver/Conductor — sees only their assigned vehicle.
  driver,
}

/// Generic vehicle telemetry packet — wraps platform-specific location data
/// with fleet-level metadata (vehicle type, owner ID, route info).
class VehicleTelemetry extends Equatable {
  final String vehicleId;
  final String vehicleType; // 'bus', 'truck'
  final String? ownerId;
  final String? routeId;
  final String? tripId;
  final double lat;
  final double lng;
  final double speed; // km/h
  final double heading; // degrees 0-360
  final String status; // 'active', 'idle', 'stopped', 'completed'
  final List<BusEtaStop> etaStops;
  final DateTime timestamp;

  const VehicleTelemetry({
    required this.vehicleId,
    this.vehicleType = 'bus',
    this.ownerId,
    this.routeId,
    this.tripId,
    required this.lat,
    required this.lng,
    this.speed = 0,
    this.heading = 0,
    this.status = 'active',
    this.etaStops = const [],
    required this.timestamp,
  });

  /// Create from a [BusLocationUpdate] with optional fleet metadata.
  factory VehicleTelemetry.fromBusUpdate(
    BusLocationUpdate update, {
    String vehicleType = 'bus',
    String? ownerId,
    String? routeId,
  }) {
    return VehicleTelemetry(
      vehicleId: update.busId,
      vehicleType: vehicleType,
      ownerId: ownerId,
      routeId: routeId,
      tripId: update.tripId,
      lat: update.lat,
      lng: update.lng,
      speed: update.speed,
      status: update.tripStatus,
      etaStops: update.etaStops,
      timestamp: update.timestamp,
    );
  }

  /// Create from a raw WebSocket payload map.
  factory VehicleTelemetry.fromWsPayload(Map<String, dynamic> json) {
    final etaRaw = json['eta_stops'] ?? json['eta_json'] ?? [];
    List<BusEtaStop> stops = [];
    if (etaRaw is List) {
      stops = etaRaw
          .map(
            (e) => BusEtaStop.fromJson(
              e is Map ? Map<String, dynamic>.from(e) : {},
            ),
          )
          .toList();
    }
    return VehicleTelemetry(
      vehicleId:
          json['vehicle_id']?.toString() ?? json['bus_id']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? 'bus',
      ownerId: json['owner_id']?.toString(),
      routeId: json['route_id']?.toString(),
      tripId: json['trip_id']?.toString(),
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      speed: (json['speed'] ?? 0).toDouble(),
      heading: (json['heading'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'active',
      etaStops: stops,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert to JSON for offline caching.
  Map<String, dynamic> toJson() => {
    'vehicle_id': vehicleId,
    'vehicle_type': vehicleType,
    'owner_id': ownerId,
    'route_id': routeId,
    'trip_id': tripId,
    'lat': lat,
    'lng': lng,
    'speed': speed,
    'heading': heading,
    'status': status,
    'eta_stops': etaStops
        .map(
          (e) => {
            'station': e.station,
            'distance_km': e.distanceKm,
            'eta_seconds': e.etaSeconds,
          },
        )
        .toList(),
    'timestamp': timestamp.toIso8601String(),
  };

  bool get isActive => status == 'active';
  bool get isIdle => status == 'idle' || status == 'stopped';
  bool get isComplete => status == 'completed';

  @override
  List<Object?> get props => [
    vehicleId,
    vehicleType,
    ownerId,
    routeId,
    tripId,
    lat,
    lng,
    speed,
    heading,
    status,
    etaStops,
    timestamp,
  ];
}

/// Offline cache entry — persisted when network drops.
class CachedTelemetryPacket extends Equatable {
  final VehicleTelemetry telemetry;
  final DateTime cachedAt;

  const CachedTelemetryPacket({
    required this.telemetry,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
    'telemetry': telemetry.toJson(),
    'cached_at': cachedAt.toIso8601String(),
  };

  factory CachedTelemetryPacket.fromJson(Map<String, dynamic> json) {
    return CachedTelemetryPacket(
      telemetry: VehicleTelemetry.fromWsPayload(
        json['telemetry'] is Map
            ? Map<String, dynamic>.from(json['telemetry'])
            : {},
      ),
      cachedAt: json['cached_at'] != null
          ? DateTime.tryParse(json['cached_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [telemetry, cachedAt];
}

/// Interface for offline telemetry caching (paves way for network recovery).
abstract class ITelemetryCache {
  Future<void> cachePacket(VehicleTelemetry packet);
  Future<List<CachedTelemetryPacket>> getCachedPackets();
  Future<void> clearCache();
  Future<int> get cacheSize;
}
