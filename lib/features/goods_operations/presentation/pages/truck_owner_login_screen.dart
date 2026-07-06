// Truck Owner Login Screen — delegates to shared BLoC login
import 'package:flutter/material.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

class TruckOwnerLoginScreen extends StatelessWidget {
  const TruckOwnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) => FleetBlocLoginScreen(
    panel: UserPanel.truckFleet,
    loginConfig: FleetLoginConfig.truckOwner(),
  );
}
