// Owner Dashboard State — immutable states for bus-owner panel
import 'package:equatable/equatable.dart';

enum OwnerDashboardStatus { initial, loading, loaded, error }

class OwnerDashboardState extends Equatable {
  final OwnerDashboardStatus status;
  final String ownerName, companyId, currentPage;
  final int driverCount, conductorCount, layoutCount;
  final List<Map<String, dynamic>> drivers, conductors, layouts;
  final bool driversLoading, conductorsLoading, layoutsLoading, isMutating;
  final String? error, actionError;

  // ── Carrier link (owner-side) ──
  final Map<String, dynamic>?
  linkStatus; // {linked, status, carrier_name, assignment_id, ...}
  final List<Map<String, dynamic>> availableCompanies;
  final bool linkLoading, companiesLoading;

  const OwnerDashboardState({
    this.status = OwnerDashboardStatus.initial,
    this.ownerName = 'Owner',
    this.companyId = '',
    this.currentPage = 'dashboard',
    this.driverCount = 0,
    this.conductorCount = 0,
    this.layoutCount = 0,
    this.drivers = const [],
    this.conductors = const [],
    this.layouts = const [],
    this.driversLoading = true,
    this.conductorsLoading = true,
    this.layoutsLoading = true,
    this.isMutating = false,
    this.error,
    this.actionError,
    this.linkStatus,
    this.availableCompanies = const [],
    this.linkLoading = false,
    this.companiesLoading = false,
  });

  OwnerDashboardState copyWith({
    OwnerDashboardStatus? status,
    String? ownerName,
    String? companyId,
    String? currentPage,
    int? driverCount,
    int? conductorCount,
    int? layoutCount,
    List<Map<String, dynamic>>? drivers,
    List<Map<String, dynamic>>? conductors,
    List<Map<String, dynamic>>? layouts,
    bool? driversLoading,
    bool? conductorsLoading,
    bool? layoutsLoading,
    bool? isMutating,
    String? error,
    String? actionError,
    Map<String, dynamic>? linkStatus,
    List<Map<String, dynamic>>? availableCompanies,
    bool? linkLoading,
    bool? companiesLoading,
  }) => OwnerDashboardState(
    status: status ?? this.status,
    ownerName: ownerName ?? this.ownerName,
    companyId: companyId ?? this.companyId,
    currentPage: currentPage ?? this.currentPage,
    driverCount: driverCount ?? this.driverCount,
    conductorCount: conductorCount ?? this.conductorCount,
    layoutCount: layoutCount ?? this.layoutCount,
    drivers: drivers ?? this.drivers,
    conductors: conductors ?? this.conductors,
    layouts: layouts ?? this.layouts,
    driversLoading: driversLoading ?? this.driversLoading,
    conductorsLoading: conductorsLoading ?? this.conductorsLoading,
    layoutsLoading: layoutsLoading ?? this.layoutsLoading,
    isMutating: isMutating ?? this.isMutating,
    error: error,
    actionError: actionError,
    linkStatus: linkStatus ?? this.linkStatus,
    availableCompanies: availableCompanies ?? this.availableCompanies,
    linkLoading: linkLoading ?? this.linkLoading,
    companiesLoading: companiesLoading ?? this.companiesLoading,
  );

  bool get isLinked => linkStatus?['linked'] == true;

  @override
  List<Object?> get props => [
    status,
    ownerName,
    companyId,
    currentPage,
    driverCount,
    conductorCount,
    layoutCount,
    drivers,
    conductors,
    layouts,
    driversLoading,
    conductorsLoading,
    layoutsLoading,
    isMutating,
    error,
    actionError,
    linkStatus,
    availableCompanies,
    linkLoading,
    companiesLoading,
  ];
}
