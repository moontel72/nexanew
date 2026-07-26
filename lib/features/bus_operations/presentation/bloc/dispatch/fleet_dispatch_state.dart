// Fleet Dispatch State — immutable state for dispatch form
import 'package:equatable/equatable.dart';

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
  }) =>
      DispatchState(
        vehicles: vehicles ?? this.vehicles,
        routes: routes ?? this.routes,
        drivers: drivers ?? this.drivers,
        conductors: conductors ?? this.conductors,
        waypoints: waypoints ?? this.waypoints,
        selectedVehicle: selectedVehicle ?? this.selectedVehicle,
        selectedRoute: selectedRoute ?? this.selectedRoute,
        selectedDriver: selectedDriver ?? this.selectedDriver,
        selectedReliefDriver:
            selectedReliefDriver ?? this.selectedReliefDriver,
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
