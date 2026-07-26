// Route List State — immutable state for route registry
import 'package:equatable/equatable.dart';

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
