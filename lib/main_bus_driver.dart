// Bus Driver App — Wave 0 BLoC
// Deployed at: /var/www/traceodd/bus-driver/
// Auth via unified PanelAuthBloc with fleet_type: bus

import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/shared/utils/fleet_bloc_setup.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Driver',
  loginScreen: FleetBlocLoginScreen(
    panel: UserPanel.busFleet,
    loginConfig: FleetLoginConfig.driver(appTitle: 'Bus Driver Portal'),
  ),
  dashboardScreen: const DriverDashboardScreen(),
  loginPath: '/bus-driver/login',
  dashboardPath: '/bus-driver/dashboard',
  blocProviders: [fleetBlocProvider()],
);
