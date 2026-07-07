// Telemetry Tracking Events
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_models.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_tracking_state.dart';

abstract class TelemetryTrackingEvent extends Equatable {
  const TelemetryTrackingEvent();
  @override
  List<Object?> get props => [];
}

/// Initialize and connect to the telemetry WebSocket stream.
/// Subscribes to the appropriate channels based on scope.
class StartTelemetryStream extends TelemetryTrackingEvent {
  final TelemetryScope scope;
  final String? authToken;
  final String? ownerId; // For owner-scoped views
  final String? vehicleId; // For driver-scoped views
  final String baseUrl;

  const StartTelemetryStream({
    required this.scope,
    this.authToken,
    this.ownerId,
    this.vehicleId,
    required this.baseUrl,
  });

  @override
  List<Object?> get props => [scope, authToken, ownerId, vehicleId, baseUrl];
}

/// Explicitly close the WebSocket stream and clean up resources.
class StopTelemetryStream extends TelemetryTrackingEvent {
  const StopTelemetryStream();
}

/// Fired when a new telemetry packet arrives from the stream.
class TelemetryPacketReceived extends TelemetryTrackingEvent {
  final VehicleTelemetry packet;
  const TelemetryPacketReceived(this.packet);
  @override
  List<Object?> get props => [packet];
}

/// Change the visibility scope (fleet → owner → driver).
class UpdateTelemetryScope extends TelemetryTrackingEvent {
  final TelemetryScope scope;
  final String? ownerId;
  final String? vehicleId;
  const UpdateTelemetryScope({
    required this.scope,
    this.ownerId,
    this.vehicleId,
  });
  @override
  List<Object?> get props => [scope, ownerId, vehicleId];
}

/// Manually set which vehicle IDs are visible (override auto-filtering).
class SetVisibleVehicles extends TelemetryTrackingEvent {
  final Set<String> vehicleIds;
  const SetVisibleVehicles(this.vehicleIds);
  @override
  List<Object?> get props => [vehicleIds];
}

/// Connection state changed (internal — from WebSocket stream).
class ConnectionStateUpdated extends TelemetryTrackingEvent {
  final TelemetryConnectionState state;
  const ConnectionStateUpdated(this.state);
  @override
  List<Object?> get props => [state];
}

/// Flush queued offline packets to the backend.
class FlushOfflineCache extends TelemetryTrackingEvent {
  const FlushOfflineCache();
}

/// Clear any error state.
class ClearTelemetryError extends TelemetryTrackingEvent {
  const ClearTelemetryError();
}
