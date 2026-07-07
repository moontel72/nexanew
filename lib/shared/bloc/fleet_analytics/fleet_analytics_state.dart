// Fleet Analytics State — immutable analytics state
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/geofence_models.dart';

enum AnalyticsConnectionState { idle, loading, active, error }

class FleetAnalyticsState extends Equatable {
  final AnalyticsConnectionState connectionState;

  /// Currently loaded route boundaries (keyed by routeId).
  final Map<String, RouteBoundary> routes;

  /// Active route being monitored for a specific vehicle.
  final Map<String, String> vehicleRouteMap; // vehicleId → routeId

  /// Latest evaluation result per vehicle.
  final Map<String, bool> vehicleDeviating; // vehicleId → isDeviating
  final Map<String, bool> vehicleSpeeding; // vehicleId → isSpeeding
  final Map<String, double> vehicleOffRoute; // vehicleId → distance in meters
  final Map<String, bool> vehicleInGeofence; // vehicleId → isInGeofence

  /// Alert history (last 50).
  final List<GeofenceAlert> recentAlerts;

  /// Historical trip analytics.
  final Map<String, TripAnalytics> tripAnalytics; // tripId → analytics

  /// Aggregated fleet metrics.
  final int totalActiveTrips;
  final int totalDeviations;
  final int totalSpeedViolations;
  final double fleetOnTimePct;

  final String? error;
  final bool isComputing;

  const FleetAnalyticsState({
    this.connectionState = AnalyticsConnectionState.idle,
    this.routes = const {},
    this.vehicleRouteMap = const {},
    this.vehicleDeviating = const {},
    this.vehicleSpeeding = const {},
    this.vehicleOffRoute = const {},
    this.vehicleInGeofence = const {},
    this.recentAlerts = const [],
    this.tripAnalytics = const {},
    this.totalActiveTrips = 0,
    this.totalDeviations = 0,
    this.totalSpeedViolations = 0,
    this.fleetOnTimePct = 100,
    this.error,
    this.isComputing = false,
  });

  FleetAnalyticsState copyWith({
    AnalyticsConnectionState? connectionState,
    Map<String, RouteBoundary>? routes,
    Map<String, String>? vehicleRouteMap,
    Map<String, bool>? vehicleDeviating,
    Map<String, bool>? vehicleSpeeding,
    Map<String, double>? vehicleOffRoute,
    Map<String, bool>? vehicleInGeofence,
    List<GeofenceAlert>? recentAlerts,
    Map<String, TripAnalytics>? tripAnalytics,
    int? totalActiveTrips,
    int? totalDeviations,
    int? totalSpeedViolations,
    double? fleetOnTimePct,
    String? error,
    bool? isComputing,
    bool clearError = false,
  }) => FleetAnalyticsState(
    connectionState: connectionState ?? this.connectionState,
    routes: routes ?? this.routes,
    vehicleRouteMap: vehicleRouteMap ?? this.vehicleRouteMap,
    vehicleDeviating: vehicleDeviating ?? this.vehicleDeviating,
    vehicleSpeeding: vehicleSpeeding ?? this.vehicleSpeeding,
    vehicleOffRoute: vehicleOffRoute ?? this.vehicleOffRoute,
    vehicleInGeofence: vehicleInGeofence ?? this.vehicleInGeofence,
    recentAlerts: recentAlerts ?? this.recentAlerts,
    tripAnalytics: tripAnalytics ?? this.tripAnalytics,
    totalActiveTrips: totalActiveTrips ?? this.totalActiveTrips,
    totalDeviations: totalDeviations ?? this.totalDeviations,
    totalSpeedViolations: totalSpeedViolations ?? this.totalSpeedViolations,
    fleetOnTimePct: fleetOnTimePct ?? this.fleetOnTimePct,
    error: clearError ? null : (error ?? this.error),
    isComputing: isComputing ?? this.isComputing,
  );

  /// Vehicles currently deviating from their routes.
  List<String> get deviatingVehicles =>
      vehicleDeviating.entries.where((e) => e.value).map((e) => e.key).toList();

  /// Vehicles currently speeding.
  List<String> get speedingVehicles =>
      vehicleSpeeding.entries.where((e) => e.value).map((e) => e.key).toList();

  @override
  List<Object?> get props => [
    connectionState,
    routes,
    vehicleRouteMap,
    vehicleDeviating,
    vehicleSpeeding,
    vehicleOffRoute,
    vehicleInGeofence,
    recentAlerts,
    tripAnalytics,
    totalActiveTrips,
    totalDeviations,
    totalSpeedViolations,
    fleetOnTimePct,
    error,
    isComputing,
  ];
}
