// Truck Driver App — independent Flutter build
// Deployed at: /var/www/traceodd/truck-driver/
// Hits: POST /api/v1/goods-fleet/driver-login

import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_login_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Truck Driver',
  loginScreen: const FleetDriverLoginScreen(
    loginEndpoint: '/goods-fleet/driver-login',
    appTitle: 'Truck Driver Portal',
    appIcon: Icons.local_shipping_rounded,
    dashboardPath: '/truck-driver/dashboard',
  ),
  dashboardScreen: const DriverDashboardScreen(),
);
