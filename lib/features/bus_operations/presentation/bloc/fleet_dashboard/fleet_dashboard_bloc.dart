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
    on<ClearStaffError>(_onClearStaffError);
    on<PublishLayout>(_onPublishLayout);
    on<ArchiveLayout>(_onArchiveLayout);
    on<DeleteLayout>(_onDeleteLayout);
    on<PurgeAllLayouts>(_onPurgeLayouts);
    on<ClearLayoutError>(_onClearLayoutError);
  }

  // ── Bootstrap ──────────────────────────────────────────

  Future<void> _onBootstrap(
    BootstrapDashboard e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(status: FleetDashboardStatus.loading));
    final p = await SharedPreferences.getInstance();
    final t = p.getString('${e.storagePrefix}_auth_token') ?? '';
    if (t.isEmpty) {
      emit(
        state.copyWith(
          status: FleetDashboardStatus.initial,
          errorMessage: 'Not authenticated',
        ),
      );
      return;
    }
    final name = p.getString('${e.storagePrefix}_owner_name') ?? 'Fleet';
    String cid = '';
    try {
      final r = await _api.get('${e.panelPrefix}/profile');
      cid = r?['data']?['id']?.toString() ?? '';
    } catch (_) {}
    emit(
      state.copyWith(
        status: FleetDashboardStatus.loaded,
        ownerName: name,
        companyId: cid,
      ),
    );
    add(FetchDashboardMetrics(panelPrefix: e.panelPrefix));
  }

  Future<void> _onFetchMetrics(
    FetchDashboardMetrics e,
    Emitter<FleetDashboardState> emit,
  ) async {
    add(LoadDrivers(panelPrefix: e.panelPrefix));
    add(LoadConductors(panelPrefix: e.panelPrefix));
    add(LoadLayouts(panelPrefix: e.panelPrefix));
  }

  // ── Staff ──────────────────────────────────────────────

  Future<void> _onLoadDrivers(
    LoadDrivers e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(driversLoading: true));
    try {
      final r = await _api.get('${e.panelPrefix}/staff/drivers');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : [];
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
    LoadConductors e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(conductorsLoading: true));
    try {
      final r = await _api.get('${e.panelPrefix}/staff/conductors');
      final d = r?['data'];
      List<Map<String, dynamic>> list = d is List
          ? d.cast<Map<String, dynamic>>()
          : [];
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

  Future<void> _onRegisterStaff(
    RegisterStaff e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isStaffSubmitting: true, staffActionError: null));
    try {
      await _api.post('${e.panelPrefix}/${e.role}s', data: e.data);
      e.role == 'driver'
          ? add(LoadDrivers(panelPrefix: e.panelPrefix))
          : add(LoadConductors(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isStaffSubmitting: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isStaffSubmitting: false,
          staffActionError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onRemoveStaff(
    RemoveStaff e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isStaffSubmitting: true, staffActionError: null));
    try {
      await _api.delete('${e.panelPrefix}/${e.role}s/${e.staffId}');
      e.role == 'driver'
          ? add(LoadDrivers(panelPrefix: e.panelPrefix))
          : add(LoadConductors(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isStaffSubmitting: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isStaffSubmitting: false,
          staffActionError: ex.toString(),
        ),
      );
    }
  }

  void _onClearStaffError(
    ClearStaffError e,
    Emitter<FleetDashboardState> emit,
  ) {
    emit(state.copyWith(staffActionError: null));
  }

  // ── Layouts ────────────────────────────────────────────

  Future<void> _onLoadLayouts(
    LoadLayouts e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(layoutsLoading: true));
    try {
      final r = await _api.get('${e.panelPrefix}/absolute-layouts');
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

  Future<void> _onPublishLayout(
    PublishLayout e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true, layoutActionError: null));
    try {
      await _api.post(
        '${e.panelPrefix}/absolute-layouts/${e.layoutId}/publish',
      );
      add(LoadLayouts(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isLayoutMutating: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isLayoutMutating: false,
          layoutActionError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onArchiveLayout(
    ArchiveLayout e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true, layoutActionError: null));
    try {
      await _api.delete('${e.panelPrefix}/absolute-layouts/${e.layoutId}');
      add(LoadLayouts(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isLayoutMutating: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isLayoutMutating: false,
          layoutActionError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteLayout(
    DeleteLayout e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true, layoutActionError: null));
    try {
      await _api.delete(
        '${e.panelPrefix}/absolute-layouts/${e.layoutId}?permanent=true',
      );
      add(LoadLayouts(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isLayoutMutating: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isLayoutMutating: false,
          layoutActionError: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onPurgeLayouts(
    PurgeAllLayouts e,
    Emitter<FleetDashboardState> emit,
  ) async {
    emit(state.copyWith(isLayoutMutating: true, layoutActionError: null));
    try {
      await _api.delete('${e.panelPrefix}/absolute-layouts/purge/all');
      add(LoadLayouts(panelPrefix: e.panelPrefix));
      emit(state.copyWith(isLayoutMutating: false));
    } catch (ex) {
      emit(
        state.copyWith(
          isLayoutMutating: false,
          layoutActionError: ex.toString(),
        ),
      );
    }
  }

  void _onClearLayoutError(
    ClearLayoutError e,
    Emitter<FleetDashboardState> emit,
  ) {
    emit(state.copyWith(layoutActionError: null));
  }

  // ── Navigation ─────────────────────────────────────────

  void _onNavigate(NavigateToPage e, Emitter<FleetDashboardState> emit) {
    emit(state.copyWith(currentPage: e.page));
  }

  Future<void> _onLogout(
    LogoutRequested e,
    Emitter<FleetDashboardState> emit,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('${e.storagePrefix}_auth_token');
    await p.remove('auth_token');
  }
}
