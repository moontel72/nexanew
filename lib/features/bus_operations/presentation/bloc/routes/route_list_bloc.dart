// Route List Bloc — route registry state machine
import 'package:bloc/bloc.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_state.dart';

class RouteListBloc extends Bloc<RouteListEvent, RouteListState> {
  final _api = ApiService();

  RouteListBloc() : super(const RouteListState()) {
    on<LoadRoutes>(_onLoad);
    on<LoadRouteDetail>(_onDetail);
    on<DeleteRoute>(_onDelete);
  }

  Future<void> _onLoad(LoadRoutes e, Emitter<RouteListState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final r = await _api.get('/bus-fleet/routes');
      emit(
        state.copyWith(
          routes: List<Map<String, dynamic>>.from(r['data'] ?? []),
          loading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> _onDetail(
    LoadRouteDetail e,
    Emitter<RouteListState> emit,
  ) async {
    emit(state.copyWith(detailLoading: true));
    try {
      final r = await _api.get('/bus-fleet/routes/${e.routeId}');
      final d = r is Map<String, dynamic> ? r : (r?['data'] ?? r);
      emit(state.copyWith(selectedRoute: d, detailLoading: false));
    } catch (_) {
      emit(state.copyWith(detailLoading: false));
    }
  }

  Future<void> _onDelete(DeleteRoute e, Emitter<RouteListState> emit) async {
    await _api.delete('/bus-fleet/routes/${e.routeId}');
    add(const LoadRoutes());
  }
}
