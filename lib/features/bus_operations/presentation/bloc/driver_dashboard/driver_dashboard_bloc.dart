// Driver Dashboard Bloc
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'driver_dashboard_event.dart';
import 'driver_dashboard_state.dart';
import 'driver_profile.dart';

class DriverDashboardBloc
    extends Bloc<DriverDashboardEvent, DriverDashboardState> {
  final ApiService _api = ApiService();

  DriverDashboardBloc() : super(const DriverDashboardState()) {
    on<LoadDriverProfile>(_onLoad);
    on<RefreshDriverProfile>(_onRefresh);
    on<DriverLogout>(_onLogout);
  }

  Future<void> _onLoad(
    LoadDriverProfile e,
    Emitter<DriverDashboardState> emit,
  ) async {
    emit(state.copyWith(status: DriverDashboardStatus.loading));
    final p = await SharedPreferences.getInstance();
    final t = p.getString('${e.storagePrefix}_auth_token') ?? '';
    if (t.isEmpty) {
      emit(
        state.copyWith(
          status: DriverDashboardStatus.initial,
          error: 'Not authenticated',
        ),
      );
      return;
    }
    // Pre-populate name from prefs while loading
    final name = p.getString('${e.storagePrefix}_driver_name') ?? 'Driver';
    emit(
      state.copyWith(
        status: DriverDashboardStatus.loading,
        profile: DriverProfile(id: '', name: name),
      ),
    );
    await _fetchProfile(emit);
  }

  Future<void> _onRefresh(
    RefreshDriverProfile e,
    Emitter<DriverDashboardState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));
    await _fetchProfile(emit);
    emit(state.copyWith(isRefreshing: false));
  }

  Future<void> _fetchProfile(Emitter<DriverDashboardState> emit) async {
    try {
      final r = await _api.get('/bus-fleet/staff/profile');
      final data = r?['data'] as Map<String, dynamic>? ?? {};
      emit(
        state.copyWith(
          status: DriverDashboardStatus.loaded,
          profile: DriverProfile.fromJson(data),
          error: null,
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(
          status: DriverDashboardStatus.error,
          error: ex.toString(),
        ),
      );
    }
  }

  Future<void> _onLogout(
    DriverLogout e,
    Emitter<DriverDashboardState> emit,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('${e.storagePrefix}_auth_token');
    await p.remove('auth_token');
  }
}
