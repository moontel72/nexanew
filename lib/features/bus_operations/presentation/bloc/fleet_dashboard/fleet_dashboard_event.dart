// Fleet Dashboard Events — events for bus-fleet panel dashboard
import 'package:equatable/equatable.dart';

abstract class FleetDashboardEvent extends Equatable {
  const FleetDashboardEvent();
  @override
  List<Object?> get props => [];
}

/// Triggered on page init to bootstrap auth + profile.
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

/// Fetch all KPIs (drivers, conductors, layouts counts).
class FetchDashboardMetrics extends FleetDashboardEvent {
  final String panelPrefix;
  const FetchDashboardMetrics({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

/// Load drivers list.
class LoadDrivers extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadDrivers({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

/// Load conductors list.
class LoadConductors extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadConductors({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

/// Load layouts list.
class LoadLayouts extends FleetDashboardEvent {
  final String panelPrefix;
  const LoadLayouts({required this.panelPrefix});
  @override
  List<Object?> get props => [panelPrefix];
}

/// Navigate to a different sub-page.
class NavigateToPage extends FleetDashboardEvent {
  final String page;
  const NavigateToPage(this.page);
  @override
  List<Object?> get props => [page];
}

/// Logout.
class LogoutRequested extends FleetDashboardEvent {
  final String storagePrefix;
  const LogoutRequested({required this.storagePrefix});
  @override
  List<Object?> get props => [storagePrefix];
}
