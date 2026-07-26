// Route Editor State — immutable state for route editor
import 'package:equatable/equatable.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/route_map_editor_painter.dart';

class RouteEditorState extends Equatable {
  final String routeId, code, name, origin, destination, carrierCompanyId;
  final List<EditorWaypoint> waypoints;
  final Set<String> voucherIds, bonusIds;
  final List<Map<String, dynamic>> vouchers, bonuses;
  final bool loading, saving, dropdownsReady;
  final String? error;

  const RouteEditorState({
    this.routeId = '',
    this.code = '',
    this.name = '',
    this.origin = '',
    this.destination = '',
    this.carrierCompanyId = '',
    this.waypoints = const [],
    this.voucherIds = const {},
    this.bonusIds = const {},
    this.vouchers = const [],
    this.bonuses = const [],
    this.loading = true,
    this.saving = false,
    this.dropdownsReady = false,
    this.error,
  });

  RouteEditorState copyWith({
    String? routeId,
    String? code,
    String? name,
    String? origin,
    String? destination,
    String? carrierCompanyId,
    List<EditorWaypoint>? waypoints,
    Set<String>? voucherIds,
    Set<String>? bonusIds,
    List<Map<String, dynamic>>? vouchers,
    List<Map<String, dynamic>>? bonuses,
    bool? loading,
    bool? saving,
    bool? dropdownsReady,
    String? error,
  }) => RouteEditorState(
    routeId: routeId ?? this.routeId,
    code: code ?? this.code,
    name: name ?? this.name,
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    carrierCompanyId: carrierCompanyId ?? this.carrierCompanyId,
    waypoints: waypoints ?? this.waypoints,
    voucherIds: voucherIds ?? this.voucherIds,
    bonusIds: bonusIds ?? this.bonusIds,
    vouchers: vouchers ?? this.vouchers,
    bonuses: bonuses ?? this.bonuses,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    dropdownsReady: dropdownsReady ?? this.dropdownsReady,
    error: error,
  );

  @override
  List<Object?> get props => [
    routeId,
    code,
    name,
    origin,
    destination,
    waypoints,
    voucherIds,
    bonusIds,
    vouchers,
    bonuses,
    loading,
    saving,
    dropdownsReady,
    error,
  ];
}
