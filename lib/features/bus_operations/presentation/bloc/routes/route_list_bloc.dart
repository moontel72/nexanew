// Route List Bloc — route registry state machine
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/services/api_service.dart';

// ── Events ──
abstract class RouteListEvent extends Equatable {
  const RouteListEvent();
  @override
  List<Object?> get props => [];
}

class LoadRoutes extends RouteListEvent {
  const LoadRoutes();
}

class LoadRouteDetail extends RouteListEvent {
  final String routeId;
  const LoadRouteDetail(this.routeId);
  @override
  List<Object?> get props => [routeId];
}

class DeleteRoute extends RouteListEvent {
  final String routeId;
  const DeleteRoute(this.routeId);
  @override
  List<Object?> get props => [routeId];
}

// ── State ──
class RouteListState extends Equatable {
  final List<Map<String, dynamic>> routes;
  final Map<String, dynamic>? selectedRoute;
  final bool loading, detailLoading;
  final String? error;
  const RouteListState({
    this.routes = const [],
    this.selectedRoute,
    this.loading = true,
    this.detailLoading = false,
    this.error,
  });
  RouteListState copyWith({
    List<Map<String, dynamic>>? routes,
    Map<String, dynamic>? selectedRoute,
    bool? loading,
    bool? detailLoading,
    String? error,
  }) => RouteListState(
    routes: routes ?? this.routes,
    selectedRoute: selectedRoute ?? this.selectedRoute,
    loading: loading ?? this.loading,
    detailLoading: detailLoading ?? this.detailLoading,
    error: error,
  );
  @override
  List<Object?> get props => [
    routes,
    selectedRoute,
    loading,
    detailLoading,
    error,
  ];
}

// ── Bloc ──
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
