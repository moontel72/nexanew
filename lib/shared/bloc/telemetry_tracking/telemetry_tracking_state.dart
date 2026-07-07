// Telemetry Tracking State — immutable fleet tracking state
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_models.dart';

enum TelemetryConnectionState { disconnected, connecting, connected, error }

class TelemetryTrackingState extends Equatable {
  final TelemetryConnectionState connectionState;
  final TelemetryScope scope;

  /// All active vehicles keyed by vehicleId.
  final Map<String, VehicleTelemetry> allVehicles;

  /// Filtered set of visible vehicle IDs based on scope.
  final Set<String> visibleVehicleIds;

  /// Last N raw packets for replay/debug.
  final List<VehicleTelemetry> recentPackets;

  final String? error;
  final DateTime? lastUpdate;

  /// Offline cache support — packets queued while disconnected.
  final List<CachedTelemetryPacket> offlineQueue;
  final bool isFlushingCache;

  const TelemetryTrackingState({
    this.connectionState = TelemetryConnectionState.disconnected,
    this.scope = TelemetryScope.fleet,
    this.allVehicles = const {},
    this.visibleVehicleIds = const {},
    this.recentPackets = const [],
    this.error,
    this.lastUpdate,
    this.offlineQueue = const [],
    this.isFlushingCache = false,
  });

  /// Filtered list of vehicles currently visible to this scope.
  List<VehicleTelemetry> get visibleVehicles => visibleVehicleIds
      .where((id) => allVehicles.containsKey(id))
      .map((id) => allVehicles[id]!)
      .toList();

  int get activeCount => allVehicles.values.where((v) => v.isActive).length;

  TelemetryTrackingState copyWith({
    TelemetryConnectionState? connectionState,
    TelemetryScope? scope,
    Map<String, VehicleTelemetry>? allVehicles,
    Set<String>? visibleVehicleIds,
    List<VehicleTelemetry>? recentPackets,
    String? error,
    DateTime? lastUpdate,
    List<CachedTelemetryPacket>? offlineQueue,
    bool? isFlushingCache,
    bool clearError = false,
  }) {
    return TelemetryTrackingState(
      connectionState: connectionState ?? this.connectionState,
      scope: scope ?? this.scope,
      allVehicles: allVehicles ?? this.allVehicles,
      visibleVehicleIds: visibleVehicleIds ?? this.visibleVehicleIds,
      recentPackets: recentPackets ?? this.recentPackets,
      error: clearError ? null : (error ?? this.error),
      lastUpdate: lastUpdate ?? this.lastUpdate,
      offlineQueue: offlineQueue ?? this.offlineQueue,
      isFlushingCache: isFlushingCache ?? this.isFlushingCache,
    );
  }

  @override
  List<Object?> get props => [
    connectionState,
    scope,
    allVehicles,
    visibleVehicleIds,
    recentPackets,
    error,
    lastUpdate,
    offlineQueue,
    isFlushingCache,
  ];
}
