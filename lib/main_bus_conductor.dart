// Bus Conductor App — Wave 0 BLoC
// Deployed at: /var/www/traceodd/bus-conductor/
// Auth via unified PanelAuthBloc with fleet_type: bus

import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/conductor_dashboard.dart';
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
  ),
  dashboardScreen: const ConductorDashboardScreen(),
  loginPath: '/bus-conductor/login',
  dashboardPath: '/bus-conductor/dashboard',
  blocProviders: [fleetBlocProvider()],
);
