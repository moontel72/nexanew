// Bus Conductor App — Wave 2 BLoC Dashboard
// Deployed at: /var/www/traceodd/bus-conductor/

import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/conductor_dashboard_page.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/shared/utils/fleet_bloc_setup.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Conductor',
  loginScreen: FleetBlocLoginScreen(
    panel: UserPanel.busFleet,
    loginConfig: FleetLoginConfig.conductor(
      appTitle: 'Bus Conductor / Cabin Crew',
    ),
    onAuthenticated: (context, response) {
      GoRouter.of(context).go('/bus-conductor/dashboard');
    },
  ),
  dashboardScreen: const ConductorDashboardPage(storagePrefix: 'busFleet'),
  loginPath: '/bus-conductor/login',
  dashboardPath: '/bus-conductor/dashboard',
  blocProviders: [fleetBlocProvider()],
);
