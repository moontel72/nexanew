// Fleet Dashboard State — immutable states for bus-fleet panel dashboard
import 'package:equatable/equatable.dart';

enum FleetDashboardStatus { initial, loading, loaded, error }

class FleetDashboardState extends Equatable {
  final FleetDashboardStatus status;
  final String ownerName;
  final String companyId;
  final int driverCount;
  final int conductorCount;
  final int layoutCount;
  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> conductors;
  final List<Map<String, dynamic>> layouts;
  final bool driversLoading;
  final bool conductorsLoading;
  final bool layoutsLoading;
  final String? errorMessage;
  final String
  currentPage; // 'dashboard', 'drivers', 'conductors', 'layouts', 'carrier', 'inbox', etc.

  const FleetDashboardState({
    this.status = FleetDashboardStatus.initial,
    this.ownerName = 'Fleet',
    this.companyId = '',
    this.driverCount = 0,
    this.conductorCount = 0,
    this.layoutCount = 0,
    this.drivers = const [],
    this.conductors = const [],
    this.layouts = const [],
    this.driversLoading = true,
    this.conductorsLoading = true,
    this.layoutsLoading = true,
    this.errorMessage,
    this.currentPage = 'dashboard',
  });

  FleetDashboardState copyWith({
    FleetDashboardStatus? status,
    String? ownerName,
    String? companyId,
    int? driverCount,
    int? conductorCount,
    int? layoutCount,
    List<Map<String, dynamic>>? drivers,
    List<Map<String, dynamic>>? conductors,
    List<Map<String, dynamic>>? layouts,
    bool? driversLoading,
    bool? conductorsLoading,
    bool? layoutsLoading,
    String? errorMessage,
    String? currentPage,
  }) {
    return FleetDashboardState(
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      companyId: companyId ?? this.companyId,
      driverCount: driverCount ?? this.driverCount,
      conductorCount: conductorCount ?? this.conductorCount,
      layoutCount: layoutCount ?? this.layoutCount,
      drivers: drivers ?? this.drivers,
      conductors: conductors ?? this.conductors,
      layouts: layouts ?? this.layouts,
      driversLoading: driversLoading ?? this.driversLoading,
      conductorsLoading: conductorsLoading ?? this.conductorsLoading,
      layoutsLoading: layoutsLoading ?? this.layoutsLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    ownerName,
    companyId,
    driverCount,
    conductorCount,
    layoutCount,
    drivers,
    conductors,
    layouts,
    driversLoading,
    conductorsLoading,
    layoutsLoading,
    errorMessage,
    currentPage,
  ];
}
