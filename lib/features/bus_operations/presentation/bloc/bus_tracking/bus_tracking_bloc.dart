// NEXATRACE — BUS TRACKING BLOC
// ================================
// Manages live bus tracking state: WebSocket connection,
// location updates, ETA list, trip status.
//
// MODULE: 8V — Live Bus Tracking Canvas

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/data/services/bus_tracking_websocket_service.dart';

// ── Events ────────────────────────────────────────────

sealed class BusTrackingEvent {
  const BusTrackingEvent();
}

class ConnectTracking extends BusTrackingEvent {
  final String tripId;
  final String? busId;
  final String baseUrl;
  final String authToken;
  const ConnectTracking(
    this.tripId, {
    this.busId,
    required this.baseUrl,
    required this.authToken,
  });
}

class DisconnectTracking extends BusTrackingEvent {
  const DisconnectTracking();
}

class LocationReceived extends BusTrackingEvent {
  final BusLocationUpdate update;
  const LocationReceived(this.update);
}

class ConnectionStateChanged extends BusTrackingEvent {
  final TrackingConnectionState state;
  const ConnectionStateChanged(this.state);
}

// ── State ─────────────────────────────────────────────

class BusTrackingState {
  final TrackingConnectionState connectionState;
  final String tripId;
  final String? busId;
  final double currentLat;
  final double currentLng;
  final double currentSpeed;
  final List<BusEtaStop> etaStops;
  final String tripStatus;
  final DateTime? lastUpdate;
  final List<BusLocationUpdate> recentUpdates; // last 20
  final String? errorMessage;

  const BusTrackingState({
    this.connectionState = TrackingConnectionState.disconnected,
    this.tripId = '',
    this.busId,
    this.currentLat = 0,
    this.currentLng = 0,
    this.currentSpeed = 0,
    this.etaStops = const [],
    this.tripStatus = 'unknown',
    this.lastUpdate,
    this.recentUpdates = const [],
    this.errorMessage,
  });

  bool get isConnected => connectionState == TrackingConnectionState.connected;
  bool get isTripComplete => tripStatus == 'completed';

  /// Next ETA stop (closest upcoming).
  BusEtaStop? get nextStop => etaStops.isNotEmpty ? etaStops.first : null;

  BusTrackingState copyWith({
    TrackingConnectionState? connectionState,
    String? tripId,
    String? busId,
    double? currentLat,
    double? currentLng,
    double? currentSpeed,
    List<BusEtaStop>? etaStops,
    String? tripStatus,
    DateTime? lastUpdate,
    List<BusLocationUpdate>? recentUpdates,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BusTrackingState(
      connectionState: connectionState ?? this.connectionState,
      tripId: tripId ?? this.tripId,
      busId: busId ?? this.busId,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      etaStops: etaStops ?? this.etaStops,
      tripStatus: tripStatus ?? this.tripStatus,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      recentUpdates: recentUpdates ?? this.recentUpdates,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── BLoC ──────────────────────────────────────────────

class BusTrackingBloc extends Bloc<BusTrackingEvent, BusTrackingState> {
  BusTrackingWebsocketService? _service;
  StreamSubscription? _locationSub;
  StreamSubscription? _stateSub;

  BusTrackingBloc() : super(const BusTrackingState()) {
    on<ConnectTracking>(_onConnect);
    on<DisconnectTracking>(_onDisconnect);
    on<LocationReceived>(_onLocation);
    on<ConnectionStateChanged>(_onConnState);
  }

  Future<void> _onConnect(
    ConnectTracking event,
    Emitter<BusTrackingState> emit,
  ) async {
    await _service?.disconnect();
    _locationSub?.cancel();
    _stateSub?.cancel();

    _service = BusTrackingWebsocketService(
      baseUrl: event.baseUrl,
      authToken: event.authToken,
    );

    _stateSub = _service!.stateStream.listen((s) {
      if (!isClosed) add(ConnectionStateChanged(s));
    });

    _locationSub = _service!.locationStream.listen((update) {
      if (!isClosed) add(LocationReceived(update));
    });

    emit(
      state.copyWith(
        connectionState: TrackingConnectionState.connecting,
        tripId: event.tripId,
        busId: event.busId,
      ),
    );

    await _service!.connect(event.tripId, busId: event.busId);
  }

  Future<void> _onDisconnect(
    DisconnectTracking event,
    Emitter<BusTrackingState> emit,
  ) async {
    await _service?.disconnect();
    _locationSub?.cancel();
    _stateSub?.cancel();
    emit(state.copyWith(connectionState: TrackingConnectionState.disconnected));
  }

  void _onLocation(LocationReceived event, Emitter<BusTrackingState> emit) {
    final u = event.update;
    final recent = [u, ...state.recentUpdates];
    emit(
      state.copyWith(
        currentLat: u.lat,
        currentLng: u.lng,
        currentSpeed: u.speed,
        etaStops: u.etaStops,
        tripStatus: u.tripStatus,
        lastUpdate: u.timestamp,
        recentUpdates: recent.length > 20 ? recent.sublist(0, 20) : recent,
      ),
    );
  }

  void _onConnState(
    ConnectionStateChanged event,
    Emitter<BusTrackingState> emit,
  ) {
    emit(state.copyWith(connectionState: event.state));
  }

  @override
  Future<void> close() {
    _service?.dispose();
    _locationSub?.cancel();
    _stateSub?.cancel();
    return super.close();
  }
}
