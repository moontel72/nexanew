// Bus Owner App — Wave 0 BLoC
// Deployed at: /var/www/traceodd/bus-owner/
// Auth via unified PanelAuthBloc with fleet_type: bus

import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/owner_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/shared/utils/fleet_bloc_setup.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Owner',
  loginScreen: FleetBlocLoginScreen(
    panel: UserPanel.busFleet,
    loginConfig: FleetLoginConfig.busOwner(),
  ),
  dashboardScreen: const OwnerDashboardScreen(),
  loginPath: '/bus-owner/login',
  dashboardPath: '/bus-owner/dashboard',
  blocProviders: [fleetBlocProvider()],
);
