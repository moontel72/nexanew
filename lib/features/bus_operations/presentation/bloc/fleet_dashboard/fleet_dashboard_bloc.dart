// Fleet Dashboard Bloc — bus-fleet panel dashboard state machine
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/fleet_dashboard/fleet_dashboard_state.dart';

class FleetDashboardBloc
    extends Bloc<FleetDashboardEvent, FleetDashboardState> {
  final ApiService _api = ApiService();

  FleetDashboardBloc() : super(const FleetDashboardState()) {
    on<BootstrapDashboard>(_onBootstrap);
    on<FetchDashboardMetrics>(_onFetchMetrics);
    on<LoadDrivers>(_onLoadDrivers);
    on<LoadConductors>(_onLoadConductors);
    on<LoadLayouts>(_onLoadLayouts);
    on<NavigateToPage>(_onNavigate);
    on<LogoutRequested>(_onLogout);
    on<RegisterStaff>(_onRegisterStaff);
    on<RemoveStaff>(_onRemoveStaff);
    on<ClearStaffError>(_onClearError);
  }

  Future<void> _onBootstrap(
    BootstrapDashboard event,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(status: FleetDashboardStatus.loading));
    final p = await SharedPreferences.getInstance();
    final sp = event.storagePrefix;
    final t = p.getString('${sp}_auth_token') ?? '';
    if (t.isEmpty) {
      emit(
        state.copyWith(
          status: FleetDashboardStatus.initial,
          errorMessage: 'Not authenticated',
        ),
      );
      return;
    }
    final name = p.getString('${sp}_owner_name') ?? 'Fleet';
    String companyId = '';
    try {
      final r = await _api.get('${event.panelPrefix}/profile');
      companyId = r?['data']?['id']?.toString() ?? '';
    } catch (_) {}
    emit(
      state.copyWith(
        status: FleetDashboardStatus.loaded,
        ownerName: name,
        companyId: companyId,
      ),
    );
    add(FetchDashboardMetrics(panelPrefix: event.panelPrefix));
  }

  Future<void> _onFetchMetrics(
    FetchDashboardMetrics event,
    Emitter<FleetDashboardState> emit,
  ) async {
    add(LoadDrivers(panelPrefix: event.panelPrefix));
    add(LoadConductors(panelPrefix: event.panelPrefix));
    add(LoadLayouts(panelPrefix: event.panelPrefix));
  }

  Future<void> _onLoadDrivers(
    LoadDrivers event,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(driversLoading: true));
    try {
      final r = await _api.get('${event.panelPrefix}/staff/drivers');
      final d = r?['data'];
      List<Map<String, dynamic>> list = [];
      if (d is List) list = d.cast<Map<String, dynamic>>();
      emit(
        state.copyWith(
          drivers: list,
          driverCount: list.length,
          driversLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(driversLoading: false));
    }
  }

  Future<void> _onLoadConductors(
    LoadConductors event,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(conductorsLoading: true));
    try {
      final r = await _api.get('${event.panelPrefix}/staff/conductors');
      final d = r?['data'];
      List<Map<String, dynamic>> list = [];
      if (d is List) list = d.cast<Map<String, dynamic>>();
      emit(
        state.copyWith(
          conductors: list,
          conductorCount: list.length,
          conductorsLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(conductorsLoading: false));
    }
  }

  Future<void> _onLoadLayouts(
    LoadLayouts event,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(layoutsLoading: true));
    try {
      final r = await _api.get('${event.panelPrefix}/absolute-layouts');
      final d = r?['data'];
      List<Map<String, dynamic>> list = [];
      if (d is List) {
        list = d.cast<Map<String, dynamic>>();
      } else if (d is Map && d['data'] is List) {
        list = (d['data'] as List).cast<Map<String, dynamic>>();
      }
      emit(
        state.copyWith(
          layouts: list,
          layoutCount: list.length,
          layoutsLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(layoutsLoading: false));
    }
  }

  // ── Staff CRUD ─────────────────────────────────────────

  Future<void> _onRegisterStaff(
    RegisterStaff event,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isStaffSubmitting: true, staffActionError: null));
    try {
      await _api.post('${event.panelPrefix}/${event.role}s', data: event.data);
      // Reload the list after successful add.
      if (event.role == 'driver') {
        add(LoadDrivers(panelPrefix: event.panelPrefix));
      } else {
        add(LoadConductors(panelPrefix: event.panelPrefix));
      }
      emit(state.copyWith(isStaffSubmitting: false));
    } catch (e) {
      emit(
        state.copyWith(
          isStaffSubmitting: false,
          staffActionError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRemoveStaff(
    RemoveStaff event,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isStaffSubmitting: true, staffActionError: null));
    try {
      await _api.delete('${event.panelPrefix}/${event.role}s/${event.staffId}');
      if (event.role == 'driver') {
        add(LoadDrivers(panelPrefix: event.panelPrefix));
      } else {
        add(LoadConductors(panelPrefix: event.panelPrefix));
      }
      emit(state.copyWith(isStaffSubmitting: false));
    } catch (e) {
      emit(
        state.copyWith(
          isStaffSubmitting: false,
          staffActionError: e.toString(),
        ),
      );
    }
  }

  void _onClearError(ClearStaffError event, Emitter<FleetDashboardState> emit) {
    emit(state.copyWith(staffActionError: null));
  }

  void _onNavigate(NavigateToPage event, Emitter<FleetDashboardState> emit) {
    emit(state.copyWith(currentPage: event.page));
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<FleetDashboardState> emit,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('${event.storagePrefix}_auth_token');
    await p.remove('auth_token');
  }
}
