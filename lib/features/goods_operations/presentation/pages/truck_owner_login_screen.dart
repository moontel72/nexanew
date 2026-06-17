// Truck Owner Login Screen — delegates to shared fleet driver login with truck endpoint
import 'package:flutter/material.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_login_screen.dart';

class TruckOwnerLoginScreen extends StatelessWidget {
  const TruckOwnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FleetDriverLoginScreen(
      loginEndpoint: '/goods-fleet/owner-login',
      appTitle: 'Truck Owner Portal',
      appIcon: Icons.local_shipping_rounded,
      dashboardPath: '/truck-owner/dashboard',
    );
  }
}
