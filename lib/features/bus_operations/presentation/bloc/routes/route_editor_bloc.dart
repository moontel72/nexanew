// Route Editor Bloc — waypoint canvas, voucher/bonus assignments
import 'package:bloc/bloc.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_editor_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_editor_state.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/route_map_editor_painter.dart';

class RouteEditorBloc extends Bloc<RouteEditorEvent, RouteEditorState> {
  final _api = ApiService();

  RouteEditorBloc() : super(const RouteEditorState()) {
    on<InitRouteEditor>(_onInit);
    on<SaveRoute>(_onSave);
    on<AddWaypoint>(_onAddWp);
    on<RemoveWaypoint>(_onRemoveWp);
    on<ToggleVoucher>(_onToggleVoucher);
    on<ToggleBonus>(_onToggleBonus);
    on<UpdateField>(_onField);
  }

  Future<void> _onInit(
    InitRouteEditor e,
    Emitter<RouteEditorState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        routeId: e.routeId ?? '',
        carrierCompanyId: e.carrierCompanyId,
      ),
    );
    try {
      final res = await Future.wait([
        _api.get('/bus-fleet/vouchers?per_page=200'),
        _api.get('/bus-fleet/bonuses?per_page=200'),
      ]);
      final vouchers = List<Map<String, dynamic>>.from(res[0]?['data'] ?? []);
      final bonuses = List<Map<String, dynamic>>.from(res[1]?['data'] ?? []);
      String code = '', name = '', origin = '', dest = '';
      List<EditorWaypoint> wps = [];
      Set<String> vIds = {}, bIds = {};
      if (e.routeId != null) {
        final r = await _api.get('/bus-fleet/routes/${e.routeId}');
        final d = r is Map ? r : (r?['data'] ?? {});
        code = d['route_code']?.toString() ?? '';
        name = d['name']?.toString() ?? '';
        origin = d['origin']?.toString() ?? '';
        dest = d['destination']?.toString() ?? '';
        final rawWps = d['waypoints'] as List? ?? [];
        wps = rawWps.asMap().entries.map((e2) {
          final w = e2.value is Map
              ? Map<String, dynamic>.from(e2.value)
              : <String, dynamic>{};
          return EditorWaypoint(
            id: w['id']?.toString() ?? '${e2.key}',
            stationName: w['station_name']?.toString() ?? 'Stop ${e2.key + 1}',
            lat: (w['lat'] ?? 31.5).toDouble(),
            lng: (w['lng'] ?? 73.0).toDouble(),
            order: e2.key,
          );
        }).toList();
        vIds =
            (d['vouchers'] as List?)
                ?.map((v) => v['id']?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toSet() ??
            {};
        bIds =
            (d['bonuses'] as List?)
                ?.map((b) => b['id']?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toSet() ??
            {};
      }
      emit(
        state.copyWith(
          code: code,
          name: name,
          origin: origin,
          destination: dest,
          waypoints: wps,
          vouchers: vouchers,
          bonuses: bonuses,
          voucherIds: vIds,
          bonusIds: bIds,
          dropdownsReady: true,
          loading: false,
        ),
      );
    } catch (ex) {
      emit(state.copyWith(loading: false, error: ex.toString()));
    }
  }

  Future<void> _onSave(SaveRoute e, Emitter<RouteEditorState> emit) async {
    emit(state.copyWith(saving: true));
    try {
      final body = {
        'route_code': e.code,
        'name': e.name,
        'origin': e.origin,
        'destination': e.destination,
        'bus_company_id': e.carrierCompanyId,
        'waypoints': e.waypoints,
        'voucher_ids': e.voucherIds,
        'bonus_ids': e.bonusIds,
      };
      if (state.routeId.isNotEmpty) {
        await _api.put('/bus-fleet/routes/${state.routeId}', body: body);
      } else {
        await _api.post('/bus-fleet/routes', body: body);
      }
      emit(state.copyWith(saving: false));
    } catch (ex) {
      emit(state.copyWith(saving: false, error: ex.toString()));
    }
  }

  void _onAddWp(AddWaypoint e, Emitter<RouteEditorState> emit) {
    final wp = EditorWaypoint(
      id: 'wp_${state.waypoints.length}',
      lat: e.lat,
      lng: e.lng,
      stationName: 'Stop ${state.waypoints.length + 1}',
      order: state.waypoints.length,
    );
    emit(state.copyWith(waypoints: [...state.waypoints, wp]));
  }

  void _onRemoveWp(RemoveWaypoint e, Emitter<RouteEditorState> emit) {
    emit(
      state.copyWith(
        waypoints: state.waypoints.where((w) => w.id != e.id).toList(),
      ),
    );
  }

  void _onToggleVoucher(ToggleVoucher e, Emitter<RouteEditorState> emit) {
    final s = Set<String>.from(state.voucherIds);
    s.contains(e.id) ? s.remove(e.id) : s.add(e.id);
    emit(state.copyWith(voucherIds: s));
  }

  void _onToggleBonus(ToggleBonus e, Emitter<RouteEditorState> emit) {
    final s = Set<String>.from(state.bonusIds);
    s.contains(e.id) ? s.remove(e.id) : s.add(e.id);
    emit(state.copyWith(bonusIds: s));
  }

  void _onField(UpdateField e, Emitter<RouteEditorState> emit) {
    switch (e.field) {
      case 'code':
        emit(state.copyWith(code: e.value));
        break;
      case 'name':
        emit(state.copyWith(name: e.value));
        break;
      case 'origin':
        emit(state.copyWith(origin: e.value));
        break;
      case 'destination':
        emit(state.copyWith(destination: e.value));
        break;
    }
  }
}
