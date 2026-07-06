// Truck Conductor App — Wave 0 BLoC
// Deployed at: /var/www/traceodd/truck-conductor/
// Auth via unified PanelAuthBloc with fleet_type: truck

import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/conductor_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/shared/utils/fleet_bloc_setup.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Truck Conductor',
  loginScreen: FleetBlocLoginScreen(
    panel: UserPanel.truckFleet,
    loginConfig: FleetLoginConfig.truckConductor(),
  ),
  dashboardScreen: const ConductorDashboardScreen(),
  loginPath: '/truck-conductor/login',
  dashboardPath: '/truck-conductor/dashboard',
  blocProviders: [fleetBlocProvider()],
);
