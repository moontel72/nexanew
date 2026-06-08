// Bus Driver App — independent Flutter build
// Deployed at: /var/www/traceodd/bus-driver/
// Hits: POST /api/v1/bus-fleet/driver-login

import 'package:trace_odd/features/bus_operations/presentation/pages/driver_login_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Driver',
  loginScreen: const FleetDriverLoginScreen(),
  dashboardScreen: const DriverDashboardScreen(),
);
