import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:nexatrace_system/core/bloc/websocket_bloc_mixin.dart';
import 'package:nexatrace_system/core/services/hardware_scan_service.dart';
import 'package:nexatrace_system/core/services/websocket_hub.dart';
import 'package:nexatrace_system/features/factory/presentation/bloc/factory_dashboard_event.dart';
import 'package:nexatrace_system/features/factory/presentation/bloc/factory_dashboard_state.dart';

class FactoryDashboardBloc
    extends Bloc<FactoryDashboardEvent, FactoryDashboardState>
    with WebSocketBlocMixin<FactoryDashboardEvent, FactoryDashboardState> {

  final HardwareScanService _scanService;
  final String _manufacturerId;

  /// Optional cross-bloc listener for SecurityMonitorBloc stream.
  StreamSubscription<dynamic>? _securityMonitorSub;

  FactoryDashboardBloc({
    required HardwareScanService scanService,
    required String manufacturerId,
  })  : _scanService = scanService,
        _manufacturerId = manufacturerId,
        super(const FactoryDashboardState()) {

    on<ScanArrivalDetected>(_onScanArrival);
    on<FleetPositionUpdated>(_onFleetPosition);
    on<TenantSecurityAlertReceived>(_onTenantAlert);
    on<ProductionMetricsRefresh>(_onProductionRefresh);

    // ── Auto-bind WebSocket streams (Setup 6 mixin) ────────
    connectStream(
      WebSocketHub.instance.fleetLocations,
      (wsEvent) => FleetPositionUpdated(wsEvent.payload),
    );
    connectStream(
      WebSocketHub.instance.busFleetGps,
      (wsEvent) => FleetPositionUpdated(wsEvent.payload),
    );

    // ── Bind hardware scan callbacks ─────────────────────
    _scanService.onScanSuccess = (result) {
      add(ScanArrivalDetected(result));
    };
    _scanService.onScanFailed = (reason) {
      if (kDebugMode) debugPrint('FACTORY_BLOC: Scan failed — $reason');
    };
  }

  // ──────────────────────────────────────────────────────────
  // Cross-bloc listener — SecurityMonitorBloc (Setup 7)
  // ──────────────────────────────────────────────────────────

  /// Attach a listener to an external SecurityMonitorBloc stream.
  /// Call once from the widget layer after both blocs are created.
  void listenToSecurityMonitor(Stream<dynamic> securityStream) {
    _securityMonitorSub?.cancel();
    _securityMonitorSub = securityStream.listen((state) {
      _checkSecurityState(state);
    });
  }

  void _checkSecurityState(dynamic securityState) {
    try {
      // Access state fields via dynamic dispatch.
      final counterfeitAlert = securityState.counterfeitFactoryAlert as Map<String, dynamic>?;
      final targetMfr = securityState.alertTargetManufacturerId?.toString();

      if (counterfeitAlert != null && targetMfr == _manufacturerId) {
        add(TenantSecurityAlertReceived(
          payload: counterfeitAlert,
          alertType: 'counterfeit',
        ));
      }

      final factoryAlert = securityState.factoryTenantAlert as Map<String, dynamic>?;
      final activeId = securityState.activeTenantId?.toString();
      if (factoryAlert != null && activeId == _manufacturerId) {
        add(TenantSecurityAlertReceived(
          payload: factoryAlert,
          alertType: 'geo_diversion',
        ));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('FACTORY_BLOC: Security state parse error — $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  // Event handlers
  // ──────────────────────────────────────────────────────────

  void _onScanArrival(ScanArrivalDetected event, Emitter<FactoryDashboardState> emit) {
    emit(state.copyWith(
      hasScanArrival: true,
      lastScanSerial: event.result.rawPayload,
    ));
    // Auto-clear scan flag after 3 seconds.
    Future.delayed(const Duration(seconds: 3), () {
      if (!isClosed) emit(state.copyWith(hasScanArrival: false));
    });
  }

  void _onFleetPosition(FleetPositionUpdated event, Emitter<FactoryDashboardState> emit) {
    final p = event.payload;
    final activeTrucks = (p['active_trucks'] as num?)?.toInt() ?? state.activeTrucks;
    final arriving = (p['arriving_within_30min'] as num?)?.toInt() ?? state.arrivingWithin30Min;
    emit(state.copyWith(
      latestFleetFrame: p,
      activeTrucks: activeTrucks,
      arrivingWithin30Min: arriving,
    ));
  }

  void _onTenantAlert(TenantSecurityAlertReceived event, Emitter<FactoryDashboardState> emit) {
    if (event.alertType == 'counterfeit') {
      emit(state.copyWith(
        hasCounterfeitAlert: true,
        counterfeitPayload: event.payload,
      ));
    } else {
      emit(state.copyWith(
        hasGeoDiversionAlert: true,
        geoDiversionPayload: event.payload,
      ));
    }
  }

  void _onProductionRefresh(
    ProductionMetricsRefresh event,
    Emitter<FactoryDashboardState> emit,
  ) {
    // In production, fetch from API / Redis cache.
    // For now, retain current state — dashboard reads from parent bloc.
  }

  @override
  Future<void> close() {
    _scanService.onScanSuccess = null;
    _scanService.onScanFailed = null;
    _securityMonitorSub?.cancel();
    return super.close();
  }
}
