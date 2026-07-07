// Fleet Dispatch Bloc — multi-entity dispatch form state machine
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/services/api_service.dart';

// ── Events ──
abstract class DispatchEvent extends Equatable {
  const DispatchEvent();
  @override
  List<Object?> get props => [];
}

class InitDispatch extends DispatchEvent {
  final String apiPrefix;
  final String? busCompanyId;
  final String? routeId;
  const InitDispatch({
    required this.apiPrefix,
    this.busCompanyId,
    this.routeId,
  });
  @override
  List<Object?> get props => [apiPrefix, busCompanyId, routeId];
}

class SaveDispatch extends DispatchEvent {
  const SaveDispatch();
}

class SetDispatchField extends DispatchEvent {
  final String field;
  final dynamic value;
  const SetDispatchField(this.field, this.value);
  @override
  List<Object?> get props => [field, value];
}

class SetDispatchSet extends DispatchEvent {
  final String field;
  final Set<String> value;
  const SetDispatchSet(this.field, this.value);
  @override
  List<Object?> get props => [field, value];
}

class ResetDispatch extends DispatchEvent {
  const ResetDispatch();
}

// ── State ──
class DispatchState extends Equatable {
  final List<Map<String, dynamic>> vehicles,
      routes,
      drivers,
      conductors,
      waypoints;
  final String? selectedVehicle,
      selectedRoute,
      selectedDriver,
      selectedReliefDriver;
  final String? selectedConductor, selectedReliefConductor, selectedHandover;
  final Set<String> additionalDriverIds, additionalConductorIds;
  final String shift, selectedReturn;
  final DateTime? dateFrom, dateTo;
  final bool loading, saving;
  final String? error, success;
  final String apiPrefix;

  const DispatchState({
    this.vehicles = const [],
    this.routes = const [],
    this.drivers = const [],
    this.conductors = const [],
    this.waypoints = const [],
    this.selectedVehicle,
    this.selectedRoute,
    this.selectedDriver,
    this.selectedReliefDriver,
    this.selectedConductor,
    this.selectedReliefConductor,
    this.selectedHandover,
    this.additionalDriverIds = const {},
    this.additionalConductorIds = const {},
    this.shift = 'morning',
    this.selectedReturn = 'one_way',
    this.dateFrom,
    this.dateTo,
    this.loading = true,
    this.saving = false,
    this.error,
    this.success,
    this.apiPrefix = '',
  });

  DispatchState copyWith({
    List<Map<String, dynamic>>? vehicles,
    List<Map<String, dynamic>>? routes,
    List<Map<String, dynamic>>? drivers,
    List<Map<String, dynamic>>? conductors,
    List<Map<String, dynamic>>? waypoints,
    String? selectedVehicle,
    String? selectedRoute,
    String? selectedDriver,
    String? selectedReliefDriver,
    String? selectedConductor,
    String? selectedReliefConductor,
    String? selectedHandover,
    Set<String>? additionalDriverIds,
    Set<String>? additionalConductorIds,
    String? shift,
    String? selectedReturn,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? loading,
    bool? saving,
    String? error,
    String? success,
    String? apiPrefix,
  }) => DispatchState(
    vehicles: vehicles ?? this.vehicles,
    routes: routes ?? this.routes,
    drivers: drivers ?? this.drivers,
    conductors: conductors ?? this.conductors,
    waypoints: waypoints ?? this.waypoints,
    selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    selectedRoute: selectedRoute ?? this.selectedRoute,
    selectedDriver: selectedDriver ?? this.selectedDriver,
    selectedReliefDriver: selectedReliefDriver ?? this.selectedReliefDriver,
    selectedConductor: selectedConductor ?? this.selectedConductor,
    selectedReliefConductor:
        selectedReliefConductor ?? this.selectedReliefConductor,
    selectedHandover: selectedHandover ?? this.selectedHandover,
    additionalDriverIds: additionalDriverIds ?? this.additionalDriverIds,
    additionalConductorIds:
        additionalConductorIds ?? this.additionalConductorIds,
    shift: shift ?? this.shift,
    selectedReturn: selectedReturn ?? this.selectedReturn,
    dateFrom: dateFrom,
    dateTo: dateTo,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    error: error,
    success: success,
    apiPrefix: apiPrefix ?? this.apiPrefix,
  );

  @override
  List<Object?> get props => [
    vehicles,
    routes,
    drivers,
    conductors,
    waypoints,
    selectedVehicle,
    selectedRoute,
    selectedDriver,
    selectedReliefDriver,
    selectedConductor,
    selectedReliefConductor,
    selectedHandover,
    additionalDriverIds,
    additionalConductorIds,
    shift,
    selectedReturn,
    dateFrom,
    dateTo,
    loading,
    saving,
    error,
    success,
    apiPrefix,
  ];
}

// ── Bloc ──
class FleetDispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final _api = ApiService();
  FleetDispatchBloc() : super(const DispatchState()) {
    on<InitDispatch>(_onInit);
    on<SaveDispatch>(_onSave);
    on<SetDispatchField>(_onSetField);
    on<SetDispatchSet>(_onSetSet);
    on<ResetDispatch>(_onReset);
  }

  Future<void> _onInit(InitDispatch e, Emitter<DispatchState> emit) async {
    emit(state.copyWith(loading: true, apiPrefix: e.apiPrefix));
    try {
      final p = <String, dynamic>{
        if (e.busCompanyId != null) 'bus_company_id': e.busCompanyId,
        if (e.routeId != null) 'route_id': e.routeId,
      };
      final r = await _api.get(
        '${e.apiPrefix}/dispatch/resources',
        queryParams: p,
      );
      final d = r?['data'] as Map<String, dynamic>? ?? {};
      List<Map<String, dynamic>> cast(dynamic x) => (x is List)
          ? x.map((v) => Map<String, dynamic>.from(v)).toList()
          : [];
      emit(
        state.copyWith(
          vehicles: cast(d['vehicles']),
          routes: cast(d['routes']),
          drivers: cast(d['drivers']),
          conductors: cast(d['conductors']),
          waypoints: cast(d['waypoints']),
          loading: false,
        ),
      );
    } catch (ex) {
      emit(state.copyWith(loading: false, error: ex.toString()));
    }
  }

  Future<void> _onSave(SaveDispatch e, Emitter<DispatchState> emit) async {
    if (state.selectedVehicle == null ||
        state.selectedRoute == null ||
        state.selectedDriver == null) {
      emit(state.copyWith(error: 'Vehicle, Route, Driver required.'));
      return;
    }
    emit(state.copyWith(saving: true));
    try {
      final body = <String, dynamic>{
        'vehicle_id': state.selectedVehicle,
        'route_id': state.selectedRoute,
        'driver_id': state.selectedDriver,
        'conductor_id': state.selectedConductor,
        'shift': state.shift,
        'return_type': state.selectedReturn,
        if (state.additionalDriverIds.isNotEmpty)
          'additional_driver_ids': state.additionalDriverIds.toList(),
        if (state.additionalConductorIds.isNotEmpty)
          'additional_conductor_ids': state.additionalConductorIds.toList(),
        if (state.selectedReliefDriver != null)
          'relief_driver_id': state.selectedReliefDriver,
        if (state.selectedReliefConductor != null)
          'relief_conductor_id': state.selectedReliefConductor,
        if (state.selectedHandover != null)
          'handover_stop_id': state.selectedHandover,
        if (state.dateFrom != null)
          'date_from': state.dateFrom!.toIso8601String(),
        if (state.dateTo != null) 'date_to': state.dateTo!.toIso8601String(),
      };
      await _api.post('${state.apiPrefix}/dispatch/assign', body: body);
      emit(state.copyWith(saving: false, success: 'Assignment saved'));
    } catch (ex) {
      emit(state.copyWith(saving: false, error: ex.toString()));
    }
  }

  void _onSetField(SetDispatchField e, Emitter<DispatchState> emit) {
    switch (e.field) {
      case 'vehicle':
        emit(state.copyWith(selectedVehicle: e.value));
        break;
      case 'route':
        emit(state.copyWith(selectedRoute: e.value));
        break;
      case 'driver':
        emit(state.copyWith(selectedDriver: e.value));
        break;
      case 'reliefDriver':
        emit(state.copyWith(selectedReliefDriver: e.value));
        break;
      case 'conductor':
        emit(state.copyWith(selectedConductor: e.value));
        break;
      case 'reliefConductor':
        emit(state.copyWith(selectedReliefConductor: e.value));
        break;
      case 'handover':
        emit(state.copyWith(selectedHandover: e.value));
        break;
      case 'shift':
        emit(state.copyWith(shift: e.value));
        break;
      case 'return':
        emit(state.copyWith(selectedReturn: e.value));
        break;
      case 'dateFrom':
        emit(state.copyWith(dateFrom: e.value));
        break;
      case 'dateTo':
        emit(state.copyWith(dateTo: e.value));
        break;
    }
  }

  void _onSetSet(SetDispatchSet e, Emitter<DispatchState> emit) {
    switch (e.field) {
      case 'drivers':
        emit(state.copyWith(additionalDriverIds: e.value));
        break;
      case 'conductors':
        emit(state.copyWith(additionalConductorIds: e.value));
        break;
    }
  }

  void _onReset(ResetDispatch e, Emitter<DispatchState> emit) {
    emit(
      state.copyWith(
        selectedVehicle: null,
        selectedRoute: null,
        selectedDriver: null,
        selectedReliefDriver: null,
        selectedConductor: null,
        selectedReliefConductor: null,
        selectedHandover: null,
        additionalDriverIds: {},
        additionalConductorIds: {},
        dateFrom: null,
        dateTo: null,
        error: null,
        success: null,
      ),
    );
  }
}
