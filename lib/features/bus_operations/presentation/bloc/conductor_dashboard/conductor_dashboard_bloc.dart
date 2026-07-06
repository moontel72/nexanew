// Conductor Dashboard Bloc
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'conductor_dashboard_event.dart';
import 'conductor_dashboard_state.dart';
import 'conductor_models.dart';

class ConductorDashboardBloc
    extends Bloc<ConductorDashboardEvent, ConductorDashboardState> {
  final ApiService _api = ApiService();
  TicketManifest? _lastManifest; // cached for offline fallback

  ConductorDashboardBloc() : super(const ConductorDashboardState()) {
    on<LoadConductorProfile>(_onLoad);
    on<RefreshConductorData>(_onRefresh);
    on<ConductorLogout>(_onLogout);
  }

  Future<void> _onLoad(
    LoadConductorProfile e,
    Emitter<ConductorDashboardState> emit,
  ) async {
    emit(state.copyWith(status: ConductorDashboardStatus.loading));
    final p = await SharedPreferences.getInstance();
    final t = p.getString('${e.storagePrefix}_auth_token') ?? '';
    if (t.isEmpty) {
      emit(
        state.copyWith(
          status: ConductorDashboardStatus.initial,
          error: 'Not authenticated',
        ),
      );
      return;
    }
    final name =
        p.getString('${e.storagePrefix}_conductor_name') ?? 'Conductor';
    emit(
      state.copyWith(
        status: ConductorDashboardStatus.loading,
        profile: ConductorProfile(id: '', name: name),
      ),
    );
    await _fetchAll(emit);
  }

  Future<void> _onRefresh(
    RefreshConductorData e,
    Emitter<ConductorDashboardState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    await _fetchAll(emit);
    emit(state.copyWith(isRefreshing: false));
  }

  Future<void> _fetchAll(Emitter<ConductorDashboardState> emit) async {
    try {
      final r = await _api.get('/bus-fleet/staff/profile');
      final data = r?['data'] as Map<String, dynamic>? ?? {};
      final profile = ConductorProfile.fromJson(data);
      // Build ticket manifest from profile data
      final manifest = _buildManifest(data);
      _lastManifest = manifest;
      emit(
        state.copyWith(
          status: ConductorDashboardStatus.loaded,
          profile: profile,
          manifest: manifest,
          error: null,
        ),
      );
    } catch (ex) {
      // Fallback to cached manifest on network error
      emit(
        state.copyWith(
          status: ConductorDashboardStatus.loaded,
          manifest: TicketManifest.cached(_lastManifest),
          error: ex.toString(),
        ),
      );
    }
  }

  /// Build ticket manifest from profile API response (backend provides
  /// seat data inline). Falls back to last cached state on parse failure.
  TicketManifest _buildManifest(Map<String, dynamic> data) {
    try {
      return TicketManifest.fromJson(data);
    } catch (_) {
      return TicketManifest.cached(_lastManifest);
    }
  }

  Future<void> _onLogout(
    ConductorLogout e,
    Emitter<ConductorDashboardState> emit,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('${e.storagePrefix}_auth_token');
    await p.remove('auth_token');
  }
}
