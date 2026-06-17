// Truck Owner App — independent Flutter build
// Deployed at: /var/www/traceodd/truck-owner/
// Hits: POST /api/v1/goods-fleet/owner-login

import 'package:trace_odd/features/goods_operations/presentation/pages/truck_owner_login_screen.dart';
import 'package:trace_odd/features/goods_operations/presentation/pages/truck_owner_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Truck Owner',
  loginScreen: const TruckOwnerLoginScreen(),
  dashboardScreen: const TruckOwnerDashboardScreen(),
);
