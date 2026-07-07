// Telemetry Tracking Bloc — centralized fleet telemetry state machine
//
// Manages:
//   • WebSocket connection lifecycle via WebSocketHub
//   • Multi-vehicle position aggregation
//   • Multi-tenant scope filtering (fleet / owner / driver)
//   • Offline packet queuing for network recovery
//
// Zero polling — fully event-driven via WebSocketHub streams.
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/websocket_hub.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_models.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_tracking_event.dart';
import 'package:trace_odd/shared/bloc/telemetry_tracking/telemetry_tracking_state.dart';

/// Internal event for queuing offline packets (not part of public API).
class _CacheOfflinePacket extends TelemetryTrackingEvent {
  final VehicleTelemetry packet;
  const _CacheOfflinePacket(this.packet);
  @override
  List<Object?> get props => [packet];
}

class TelemetryTrackingBloc
    extends Bloc<TelemetryTrackingEvent, TelemetryTrackingState> {
  WebSocketHub? _hub;
  StreamSubscription? _busSub;
  StreamSubscription? _fleetSub;
  StreamSubscription? _stateSub;

  /// Offline cache key prefix.
  static const _cacheKey = 'telemetry_offline_queue';

  TelemetryTrackingBloc() : super(const TelemetryTrackingState()) {
    on<StartTelemetryStream>(_onStart);
    on<StopTelemetryStream>(_onStop);
    on<TelemetryPacketReceived>(_onPacket);
    on<UpdateTelemetryScope>(_onScope);
    on<SetVisibleVehicles>(_onSetVisible);
    on<ConnectionStateUpdated>(_onConnState);
    on<FlushOfflineCache>(_onFlush);
    on<ClearTelemetryError>(_onClear);
    on<_CacheOfflinePacket>(_onCacheOffline);
  }

  // ═══════════════════ Start / Stop ═══════════════════

  Future<void> _onStart(
    StartTelemetryStream e,
    Emitter<TelemetryTrackingState> emit,
  ) async {
    emit(
      state.copyWith(
        connectionState: TelemetryConnectionState.connecting,
        scope: e.scope,
      ),
    );

    try {
      _hub = WebSocketHub(baseUrl: e.baseUrl);
      await _hub!.connect(authToken: e.authToken);

      // Subscribe to fleet-wide GPS channel
      _fleetSub = _hub!.fleetLocations.listen((wsEvent) {
        if (!isClosed) {
          final packet = VehicleTelemetry.fromWsPayload(wsEvent.payload);
          add(TelemetryPacketReceived(packet));
        }
      });

      // Subscribe to bus-specific GPS channel (Step 14)
      _busSub = _hub!.busFleetGps.listen((wsEvent) {
        if (!isClosed) {
          final packet = VehicleTelemetry.fromWsPayload(wsEvent.payload);
          add(TelemetryPacketReceived(packet));
        }
      });

      // Subscribe to specific vehicle channel if driver-scoped
      if (e.scope == TelemetryScope.driver && e.vehicleId != null) {
        _hub!.subscribe('driver.${e.vehicleId}', (payload) {
          if (!isClosed) {
            add(
              TelemetryPacketReceived(VehicleTelemetry.fromWsPayload(payload)),
            );
          }
        });
      }

      // Owner-scoped: subscribe to owner's fleet channel
      if (e.scope == TelemetryScope.owner && e.ownerId != null) {
        _hub!.subscribe('fleet.${e.ownerId}', (payload) {
          if (!isClosed) {
            add(
              TelemetryPacketReceived(VehicleTelemetry.fromWsPayload(payload)),
            );
          }
        });
      }

      // Apply scope filtering
      final newState = _applyScope(
        e.scope,
        ownerId: e.ownerId,
        vehicleId: e.vehicleId,
      );
      emit(
        newState.copyWith(connectionState: TelemetryConnectionState.connected),
      );

      // Attempt to flush any offline cache
      add(const FlushOfflineCache());
    } catch (ex) {
      emit(
        state.copyWith(
          connectionState: TelemetryConnectionState.error,
          error: 'Failed to connect: $ex',
        ),
      );
      // Load offline cache while disconnected
      final cached = await _readOfflineCache();
      if (cached.isNotEmpty) {
        emit(state.copyWith(offlineQueue: cached));
      }
    }
  }

  Future<void> _onStop(
    StopTelemetryStream e,
    Emitter<TelemetryTrackingState> emit,
  ) async {
    _busSub?.cancel();
    _fleetSub?.cancel();
    _stateSub?.cancel();
    _hub?.disconnect();
    _hub = null;
    emit(
      state.copyWith(connectionState: TelemetryConnectionState.disconnected),
    );
  }

  // ═══════════════════ Packet Handling ═══════════════════

  void _onPacket(
    TelemetryPacketReceived e,
    Emitter<TelemetryTrackingState> emit,
  ) {
    final packet = e.packet;
    final newAll = Map<String, VehicleTelemetry>.from(state.allVehicles);
    newAll[packet.vehicleId] = packet;

    // Maintain recent packets ring buffer (max 50).
    final recent = [packet, ...state.recentPackets];
    final trimmed = recent.length > 50 ? recent.sublist(0, 50) : recent;

    // Re-apply scope filter with new data.
    final filtered = _filterByScope(
      state.scope,
      newAll,
      ownerId:
          null, // Preserve existing visible set; scope reapplication happens on _onScope
      vehicleId: null,
    );

    emit(
      state.copyWith(
        allVehicles: newAll,
        visibleVehicleIds: filtered,
        recentPackets: trimmed,
        lastUpdate: packet.timestamp,
      ),
    );
  }

  // ═══════════════════ Scope Management ═══════════════════

  void _onScope(UpdateTelemetryScope e, Emitter<TelemetryTrackingState> emit) {
    final newState = _applyScope(
      e.scope,
      ownerId: e.ownerId,
      vehicleId: e.vehicleId,
    );
    emit(newState);
  }

  void _onSetVisible(
    SetVisibleVehicles e,
    Emitter<TelemetryTrackingState> emit,
  ) {
    emit(state.copyWith(visibleVehicleIds: e.vehicleIds));
  }

  /// Apply scope filtering to the current vehicle set.
  TelemetryTrackingState _applyScope(
    TelemetryScope scope, {
    String? ownerId,
    String? vehicleId,
  }) {
    final filtered = _filterByScope(
      scope,
      state.allVehicles,
      ownerId: ownerId,
      vehicleId: vehicleId,
    );
    return state.copyWith(scope: scope, visibleVehicleIds: filtered);
  }

  /// Filter vehicle map by scope rules.
  Set<String> _filterByScope(
    TelemetryScope scope,
    Map<String, VehicleTelemetry> vehicles, {
    String? ownerId,
    String? vehicleId,
  }) {
    switch (scope) {
      case TelemetryScope.fleet:
        // Fleet/Admin — show all vehicles.
        return vehicles.keys.toSet();

      case TelemetryScope.owner:
        // Owner — show only vehicles registered to this owner.
        if (ownerId != null) {
          return vehicles.values
              .where((v) => v.ownerId == ownerId)
              .map((v) => v.vehicleId)
              .toSet();
        }
        // Fallback: use existing filter or show none.
        return {};

      case TelemetryScope.driver:
        // Driver — show only the assigned vehicle.
        if (vehicleId != null && vehicles.containsKey(vehicleId)) {
          return {vehicleId};
        }
        return {};
    }
  }

  // ═══════════════════ Connection State ═══════════════════

  void _onConnState(
    ConnectionStateUpdated e,
    Emitter<TelemetryTrackingState> emit,
  ) {
    emit(state.copyWith(connectionState: e.state));
  }

  // ═══════════════════ Offline Cache ═══════════════════

  Future<void> _onFlush(
    FlushOfflineCache e,
    Emitter<TelemetryTrackingState> emit,
  ) async {
    if (state.offlineQueue.isEmpty) return;
    emit(state.copyWith(isFlushingCache: true));
    try {
      // In a real implementation, POST queued packets to backend.
      // For now, clear the queue on successful connection.
      emit(state.copyWith(offlineQueue: [], isFlushingCache: false));
      await _persistOfflineQueue([]);
    } catch (_) {
      emit(state.copyWith(isFlushingCache: false));
    }
  }

  /// Queue a packet for offline storage (called externally or on error).
  void cacheOfflinePacket(VehicleTelemetry packet) {
    add(_CacheOfflinePacket(packet));
  }

  Future<List<CachedTelemetryPacket>> _readOfflineCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map(
            (e) => CachedTelemetryPacket.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistOfflineQueue(List<CachedTelemetryPacket> queue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(queue.map((p) => p.toJson()).toList());
      await prefs.setString(_cacheKey, encoded);
    } catch (_) {}
  }

  // ═══════════════════ Error Clear ═══════════════════

  void _onClear(ClearTelemetryError e, Emitter<TelemetryTrackingState> emit) {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _onCacheOffline(
    _CacheOfflinePacket e,
    Emitter<TelemetryTrackingState> emit,
  ) async {
    final entry = CachedTelemetryPacket(
      telemetry: e.packet,
      cachedAt: DateTime.now(),
    );
    final updated = [...state.offlineQueue, entry];
    final trimmed = updated.length > 200
        ? updated.sublist(updated.length - 200)
        : updated;
    emit(state.copyWith(offlineQueue: trimmed));
    await _persistOfflineQueue(trimmed);
  }

  // ═══════════════════ Teardown ═══════════════════

  @override
  Future<void> close() {
    _busSub?.cancel();
    _fleetSub?.cancel();
    _stateSub?.cancel();
    _hub?.disconnect();
    return super.close();
  }
}
