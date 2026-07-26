// Route Editor Events — events for waypoint canvas, voucher/bonus assignments
import 'package:equatable/equatable.dart';

abstract class RouteEditorEvent extends Equatable {
  const RouteEditorEvent();
  @override
  List<Object?> get props => [];
}

class InitRouteEditor extends RouteEditorEvent {
  final String? routeId;
  final String carrierCompanyId;
  const InitRouteEditor({this.routeId, required this.carrierCompanyId});
  @override
  List<Object?> get props => [routeId, carrierCompanyId];
}

class SaveRoute extends RouteEditorEvent {
  final String code, name, origin, destination, carrierCompanyId;
  final List<Map<String, dynamic>> waypoints;
  final List<String> voucherIds, bonusIds;
  const SaveRoute({
    required this.code,
    required this.name,
    required this.origin,
    required this.destination,
    required this.carrierCompanyId,
    required this.waypoints,
    required this.voucherIds,
    required this.bonusIds,
  });
}

class AddWaypoint extends RouteEditorEvent {
  final double lat, lng;
  const AddWaypoint(this.lat, this.lng);
}

class RemoveWaypoint extends RouteEditorEvent {
  final String id;
  const RemoveWaypoint(this.id);
}

class ToggleVoucher extends RouteEditorEvent {
  final String id;
  const ToggleVoucher(this.id);
}

class ToggleBonus extends RouteEditorEvent {
  final String id;
  const ToggleBonus(this.id);
}

class UpdateField extends RouteEditorEvent {
  final String field, value;
  const UpdateField(this.field, this.value);
}
