// Truck Conductor App — independent Flutter build
// Deployed at: /var/www/traceodd/truck-conductor/
// Hits: POST /api/v1/goods-fleet/conductor-login

import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/conductor_login_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/conductor_dashboard.dart';
import 'package:trace_odd/shared/app_scaffold.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Truck Conductor',
  loginScreen: const FleetConductorLoginScreen(
    loginEndpoint: '/goods-fleet/conductor-login',
    appTitle: 'Truck Conductor Portal',
    appIcon: Icons.local_shipping_rounded,
    dashboardPath: '/truck-conductor/dashboard',
  ),
  dashboardScreen: const ConductorDashboardScreen(),
);
