// Truck Owner Login Screen — delegates to shared driver login with truck endpoint
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_login_screen.dart';
import 'package:flutter/material.dart';

class TruckOwnerLoginScreen extends StatelessWidget {
  const TruckOwnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLoginScreen(
      loginEndpoint: '/goods-fleet/owner-login',
      appTitle: 'Truck Owner Portal',
      appIcon: Icons.local_shipping_rounded,
    );
  }
}
