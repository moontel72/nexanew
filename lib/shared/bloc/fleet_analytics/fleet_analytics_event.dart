// Fleet Analytics Events
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_models.dart';
import 'package:trace_odd/shared/models/geofence_models.dart';

abstract class FleetAnalyticsEvent extends Equatable {
  const FleetAnalyticsEvent();
  @override
  List<Object?> get props => [];
}

/// Hydrate route boundaries for a set of active routes.
class LoadActiveRoutes extends FleetAnalyticsEvent {
  final List<RouteBoundary> routes;
  const LoadActiveRoutes(this.routes);
  @override
  List<Object?> get props => [routes];
}

/// Assign a vehicle to a specific route for monitoring.
class AssignVehicleToRoute extends FleetAnalyticsEvent {
  final String vehicleId;
  final String routeId;
  const AssignVehicleToRoute({required this.vehicleId, required this.routeId});
  @override
  List<Object?> get props => [vehicleId, routeId];
}

/// Evaluate incoming telemetry against assigned route boundaries.
/// Dispatched from TelemetryTrackingBloc stream.
class EvaluateVehicleTelemetry extends FleetAnalyticsEvent {
  final VehicleTelemetry telemetry;
  const EvaluateVehicleTelemetry(this.telemetry);
  @override
  List<Object?> get props => [telemetry];
}

/// Load historical trip analytics for a fleet or owner.
class LoadTripAnalytics extends FleetAnalyticsEvent {
  final List<String> tripIds;
  const LoadTripAnalytics(this.tripIds);
  @override
  List<Object?> get props => [tripIds];
}

/// Trip analytics loaded from backend.
class TripAnalyticsLoaded extends FleetAnalyticsEvent {
  final List<TripAnalytics> analytics;
  const TripAnalyticsLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

/// Start the analytics stream (subscribe to telemetry).
class StartAnalyticsStream extends FleetAnalyticsEvent {
  const StartAnalyticsStream();
}

/// Stop the analytics stream.
class StopAnalyticsStream extends FleetAnalyticsEvent {
  const StopAnalyticsStream();
}

/// Clear error state.
class ClearAnalyticsError extends FleetAnalyticsEvent {
  const ClearAnalyticsError();
}
