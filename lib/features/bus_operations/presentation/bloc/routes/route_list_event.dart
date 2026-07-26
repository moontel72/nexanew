// Route List Events — events for route registry
import 'package:equatable/equatable.dart';

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
