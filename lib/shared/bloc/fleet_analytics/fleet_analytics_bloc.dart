// Fleet Analytics Bloc — geofencing, route deviation, speed corridor analysis
//
// Sits downstream from TelemetryTrackingBloc. Evaluates incoming vehicle
// telemetry against loaded route boundaries using isolated computation
// (GeoComputeService). Generates GeofenceAlert records and fleet metrics.
//
// Zero main-thread blocking — all geo-math runs in Dart isolates.
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:trace_odd/shared/bloc/fleet_analytics/fleet_analytics_event.dart';
import 'package:trace_odd/shared/bloc/fleet_analytics/fleet_analytics_state.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_models.dart';
import 'package:trace_odd/shared/models/geofence_models.dart';
import 'package:trace_odd/shared/services/geo_compute.dart';

final _uuid = const Uuid();

class FleetAnalyticsBloc
    extends Bloc<FleetAnalyticsEvent, FleetAnalyticsState> {
  StreamSubscription? _telemetrySub;

  FleetAnalyticsBloc() : super(const FleetAnalyticsState()) {
    on<LoadActiveRoutes>(_onLoadRoutes);
    on<AssignVehicleToRoute>(_onAssignVehicle);
    on<EvaluateVehicleTelemetry>(_onEvaluate);
    on<LoadTripAnalytics>(_onLoadTrips);
    on<TripAnalyticsLoaded>(_onTripsLoaded);
    on<StartAnalyticsStream>(_onStart);
    on<StopAnalyticsStream>(_onStop);
    on<ClearAnalyticsError>(_onClear);
  }

  // ═══════════════════ Route Loading ═══════════════════

  void _onLoadRoutes(LoadActiveRoutes e, Emitter<FleetAnalyticsState> emit) {
    final routes = <String, RouteBoundary>{};
    for (final r in e.routes) {
      routes[r.routeId] = r;
    }
    emit(state.copyWith(routes: routes));
  }

  void _onAssignVehicle(
    AssignVehicleToRoute e,
    Emitter<FleetAnalyticsState> emit,
  ) {
    final vrm = Map<String, String>.from(state.vehicleRouteMap);
    vrm[e.vehicleId] = e.routeId;
    emit(state.copyWith(vehicleRouteMap: vrm));
  }

  // ═══════════════════ Telemetry Evaluation ═══════════════════

  Future<void> _onEvaluate(
    EvaluateVehicleTelemetry e,
    Emitter<FleetAnalyticsState> emit,
  ) async {
    final v = e.telemetry;
    final routeId = state.vehicleRouteMap[v.vehicleId];
    if (routeId == null) return;
    final route = state.routes[routeId];
    if (route == null) return;

    emit(state.copyWith(isComputing: true));

    // Offload heavy geo-math to isolate via GeoComputeService.
    final result = await GeoComputeService.evaluate(
      vehicleLat: v.lat,
      vehicleLng: v.lng,
      vehicleSpeed: v.speed,
      vehicleId: v.vehicleId,
      route: route,
    );

    // Build alerts from computation results.
    final newAlerts = <GeofenceAlert>[];
    for (final a in result.alerts) {
      newAlerts.add(
        GeofenceAlert(
          alertId: _uuid.v4(),
          vehicleId: v.vehicleId,
          routeId: routeId,
          type: a['type']?.toString() ?? 'route_deviation',
          severity: a['severity']?.toString() == 'critical'
              ? GeofenceSeverity.critical
              : GeofenceSeverity.warning,
          lat: v.lat,
          lng: v.lng,
          distanceOffRoute: a['distance_off_route']?.toDouble(),
          currentSpeed: a['current_speed']?.toDouble(),
          speedLimit: a['speed_limit']?.toDouble(),
          zoneName: a['zone_name']?.toString(),
          timestamp: v.timestamp,
        ),
      );
    }

    // Update per-vehicle maps.
    final deviating = Map<String, bool>.from(state.vehicleDeviating);
    final speeding = Map<String, bool>.from(state.vehicleSpeeding);
    final offRoute = Map<String, double>.from(state.vehicleOffRoute);
    final inZone = Map<String, bool>.from(state.vehicleInGeofence);

    deviating[v.vehicleId] = result.isDeviating;
    speeding[v.vehicleId] = result.isSpeeding;
    offRoute[v.vehicleId] = result.distanceOffRouteMeters;
    inZone[v.vehicleId] = result.isInGeofence;

    // Merge alerts (keep last 50).
    final allAlerts = [...newAlerts, ...state.recentAlerts];
    final trimmed = allAlerts.length > 50
        ? allAlerts.sublist(0, 50)
        : allAlerts;

    // Aggregate metrics.
    final totalDev = deviating.values.where((d) => d).length;
    final totalSpd = speeding.values.where((s) => s).length;

    emit(
      state.copyWith(
        vehicleDeviating: deviating,
        vehicleSpeeding: speeding,
        vehicleOffRoute: offRoute,
        vehicleInGeofence: inZone,
        recentAlerts: trimmed,
        totalDeviations: totalDev,
        totalSpeedViolations: totalSpd,
        totalActiveTrips: state.vehicleRouteMap.length,
        isComputing: false,
      ),
    );
  }

  // ═══════════════════ Trip Analytics ═══════════════════

  Future<void> _onLoadTrips(
    LoadTripAnalytics e,
    Emitter<FleetAnalyticsState> emit,
  ) async {
    // In production, fetch from backend API.
    // For now, generate mock analytics for demo.
    final analytics = e.tripIds
        .map(
          (id) => TripAnalytics(
            tripId: id,
            vehicleId: 'VEH-${id.hashCode.abs() % 1000}',
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now(),
            totalDistanceKm: 45.3 + (id.hashCode % 50),
            avgSpeedKmh: 62.5 + (id.hashCode % 20).toDouble(),
            maxSpeedKmh: 95.0 + (id.hashCode % 15),
            drivingDuration: const Duration(hours: 1, minutes: 45),
            alertCount: id.hashCode % 5,
            deviationCount: id.hashCode % 2,
            onTimePercentage: 85.0 + (id.hashCode % 15).toDouble(),
          ),
        )
        .toList();
    add(TripAnalyticsLoaded(analytics));
  }

  void _onTripsLoaded(
    TripAnalyticsLoaded e,
    Emitter<FleetAnalyticsState> emit,
  ) {
    final map = Map<String, TripAnalytics>.from(state.tripAnalytics);
    double totalOnTime = 0;
    for (final a in e.analytics) {
      map[a.tripId] = a;
      totalOnTime += a.onTimePercentage;
    }
    final avgOnTime = e.analytics.isEmpty
        ? 100.0
        : totalOnTime / e.analytics.length;
    emit(state.copyWith(tripAnalytics: map, fleetOnTimePct: avgOnTime));
  }

  // ═══════════════════ Stream Lifecycle ═══════════════════

  void _onStart(StartAnalyticsStream e, Emitter<FleetAnalyticsState> emit) {
    emit(state.copyWith(connectionState: AnalyticsConnectionState.active));
  }

  Future<void> _onStop(
    StopAnalyticsStream e,
    Emitter<FleetAnalyticsState> emit,
  ) async {
    _telemetrySub?.cancel();
    emit(state.copyWith(connectionState: AnalyticsConnectionState.idle));
  }

  void _onClear(ClearAnalyticsError e, Emitter<FleetAnalyticsState> emit) {
    emit(state.copyWith(clearError: true));
  }

  /// Wire this BLoC to consume packets from a TelemetryTrackingBloc.
  /// Call this once after both BLoCs are initialized.
  void bindToTelemetry(Stream<VehicleTelemetry> telemetryStream) {
    _telemetrySub?.cancel();
    _telemetrySub = telemetryStream.listen((packet) {
      if (!isClosed) add(EvaluateVehicleTelemetry(packet));
    });
  }

  @override
  Future<void> close() {
    _telemetrySub?.cancel();
    return super.close();
  }
}
