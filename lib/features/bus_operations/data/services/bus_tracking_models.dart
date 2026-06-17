// NEXATRACE — BUS TRACKING MODEL & INTERFACE
// =============================================
// Platform-agnostic data models and interface for
// the bus tracking WebSocket service.
//
// MODULE: 8V — Live Bus Tracking Canvas

import 'dart:async';

/// WebSocket connection states.
enum TrackingConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// A single ETA stop from the location update payload.
class BusEtaStop {
  final String station;
  final double distanceKm;
  final int etaSeconds;

  const BusEtaStop({
    required this.station,
    required this.distanceKm,
    required this.etaSeconds,
  });

  factory BusEtaStop.fromJson(Map<String, dynamic> json) {
    return BusEtaStop(
      station: json['station']?.toString() ?? 'Stop',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      etaSeconds: (json['eta_seconds'] ?? 0) as int,
    );
  }

  String get etaDisplay {
    if (etaSeconds <= 0) return 'Arrived';
    if (etaSeconds < 60) return '${etaSeconds}s';
    final minutes = etaSeconds ~/ 60;
    if (minutes < 60) return '${minutes} min';
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    return '${hours}h ${remainingMins}m';
  }

  String get distanceDisplay => '${distanceKm.toStringAsFixed(1)} km';
}

/// A single location update from the bus tracking stream.
class BusLocationUpdate {
  final String busId;
  final String tripId;
  final double lat;
  final double lng;
  final double speed;
  final List<BusEtaStop> etaStops;
  final String tripStatus;
  final String eventType;
  final DateTime timestamp;

  const BusLocationUpdate({
    required this.busId,
    required this.tripId,
    required this.lat,
    required this.lng,
    required this.speed,
    this.etaStops = const [],
    this.tripStatus = 'active',
    this.eventType = 'location_update',
    required this.timestamp,
  });

  factory BusLocationUpdate.fromJson(Map<String, dynamic> json) {
    final etaRaw = json['eta_json'] ?? [];
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
    return BusLocationUpdate(
      busId: json['bus_id']?.toString() ?? '',
      tripId: json['trip_id']?.toString() ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      speed: (json['speed'] ?? 0).toDouble(),
      etaStops: stops,
      tripStatus: json['trip_status']?.toString() ?? 'active',
      eventType: json['event_type']?.toString() ?? 'location_update',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isTripComplete => tripStatus == 'completed';
  bool get isTripStart => eventType == 'trip_started';

  /// Simulated movement: interpolate position toward next waypoint.
  BusLocationUpdate simulateTick(Duration elapsed) {
    if (etaStops.isEmpty) return this;
    final next = etaStops.first;
    final step = speed * (elapsed.inMilliseconds / 3600000.0);
    return BusLocationUpdate(
      busId: busId,
      tripId: tripId,
      lat: lat + 0.001,
      lng: lng + 0.001,
      speed: speed,
      etaStops: etaStops,
      tripStatus: tripStatus,
      eventType: 'location_update',
      timestamp: DateTime.now(),
    );
  }
}

/// Abstract interface for bus tracking connections.
abstract class IBusTrackingService {
  TrackingConnectionState get state;
  Stream<BusLocationUpdate> get locationStream;
  Stream<TrackingConnectionState> get stateStream;

  Future<void> connect(String tripId, {String? busId});
  Future<void> disconnect();
  void dispose();
}
