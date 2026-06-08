// Bus Owner App — independent Flutter build
// Deployed at: /var/www/traceodd/bus-owner/
// Served via Nginx: location /bus-owner/
// Hits: POST /api/v1/bus-fleet/owner-login

import 'package:trace_odd/features/bus_operations/presentation/pages/owner_login_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/owner_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Owner',
  loginScreen: const OwnerLoginScreen(),
  dashboardScreen: const OwnerDashboardScreen(),
  loginPath: '/bus-owner/login',
  dashboardPath: '/bus-owner/dashboard',
);
