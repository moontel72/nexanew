// Fleet Dashboard Events — events for bus-fleet panel dashboard
import 'package:equatable/equatable.dart';

abstract class FleetDashboardEvent extends Equatable {
  const FleetDashboardEvent();
  @override
  List<Object?> get props => [];
}

class BootstrapDashboard extends FleetDashboardEvent {
  final String storagePrefix;
  final String panelPrefix;
  final String loginRoute;
  const BootstrapDashboard({
    required this.storagePrefix,
    required this.panelPrefix,
    required this.loginRoute,
  });
  @override
  List<Object?> get props => [storagePrefix, panelPrefix, loginRoute];
}

class FetchDashboardMetrics extends FleetDashboardEvent {
  final String panelPrefix;
  const FetchDashboardMetrics({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class LoadDrivers extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadDrivers({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class LoadConductors extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadConductors({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class LoadLayouts extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadLayouts({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

class NavigateToPage extends FleetDashboardEvent {
  final String page;
  const NavigateToPage(this.page);
  @override
  List<Object?> get props => [page];
}

class LogoutRequested extends FleetDashboardEvent {
  final String storagePrefix;
  const LogoutRequested({required this.storagePrefix});
  @override
  List<Object?> get props => [storagePrefix];
}

/// Register a new driver or conductor.
class RegisterStaff extends FleetDashboardEvent {
  final String panelPrefix;
  final String role; // 'driver' or 'conductor'
  final Map<String, dynamic> data;
  const RegisterStaff({
    required this.panelPrefix,
    required this.role,
    required this.data,
  });
  @override
  List<Object?> get props => [panelPrefix, role, data];
}

/// Remove (soft-delete) a driver or conductor.
class RemoveStaff extends FleetDashboardEvent {
  final String panelPrefix;
  final String staffId;
  final String role; // 'driver' or 'conductor'
  const RemoveStaff({
    required this.panelPrefix,
    required this.staffId,
    required this.role,
  });
  @override
  List<Object?> get props => [panelPrefix, staffId, role];
}

class ClearStaffError extends FleetDashboardEvent {
  const ClearStaffError();
}
