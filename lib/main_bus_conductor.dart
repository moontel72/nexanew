// Bus Conductor App — independent Flutter build
// Deployed at: /var/www/traceodd/bus-conductor/
// Hits: POST /api/v1/bus-fleet/conductor-login

import 'package:trace_odd/features/bus_operations/presentation/pages/conductor_login_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/conductor_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Conductor',
  loginScreen: const FleetConductorLoginScreen(),
  dashboardScreen: const ConductorDashboardScreen(),
);
