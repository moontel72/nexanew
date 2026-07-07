// Truck Owner App — Wave 0 BLoC
// Deployed at: /var/www/traceodd/truck-owner/
// Auth via unified PanelAuthBloc with fleet_type: truck

import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/goods_operations/presentation/pages/truck_owner_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/shared/utils/fleet_bloc_setup.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Truck Owner',
  loginScreen: FleetBlocLoginScreen(
    panel: UserPanel.truckFleet,
    loginConfig: FleetLoginConfig.truckOwner(),
  ),
  dashboardScreen: const TruckOwnerDashboardPage(),
  loginPath: '/truck-owner/login',
  dashboardPath: '/truck-owner/dashboard',
  blocProviders: [fleetBlocProvider()],
);
