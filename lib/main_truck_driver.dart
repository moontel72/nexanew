// Truck Driver App — Wave 2 BLoC Dashboard
// Deployed at: /var/www/traceodd/truck-driver/

import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_dashboard_page.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/shared/utils/fleet_bloc_setup.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Truck Driver',
  loginScreen: FleetBlocLoginScreen(
    panel: UserPanel.truckFleet,
    loginConfig: FleetLoginConfig.truckDriver(),
  ),
  dashboardScreen: const DriverDashboardPage(storagePrefix: 'truckFleet'),
  loginPath: '/truck-driver/login',
  dashboardPath: '/truck-driver/dashboard',
  blocProviders: [fleetBlocProvider()],
);
