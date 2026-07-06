/// Bus Fleet Admin Web Panel — Unified entry point (Wave 0 BLoC)
///
/// Role-based routing:
///   - Admins / Fleet Owners → Full OwnerDashboardScreen
///   - Bus Catering Storekeepers  → ONLY the StorekeeperDashboardScreen (3 tabs)
///
/// Auth via PanelAuthBloc → FleetBlocLoginScreen shared widget.
///
/// Deployed at /var/www/traceodd/bus-fleet/
/// Served via Nginx: location /bus-fleet/

library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/constants/user_roles.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/owner_dashboard.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/storekeeper_dashboard_screen.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/shared/utils/fleet_bloc_setup.dart';
import 'package:trace_odd/shared/widgets/fleet_bloc_login_screen.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Fleet',
  loginScreen: FleetBlocLoginScreen(
    panel: UserPanel.busFleet,
    loginConfig: FleetLoginConfig.busFleet(),
  ),
  dashboardBuilder: (_) => const _BusFleetRouter(),
  loginPath: '/bus-fleet/login',
  dashboardPath: '/bus-fleet/dashboard',
  blocProviders: [fleetBlocProvider()],
);

// ── Dashboard Router ─────────────────────────────────────────

class _BusFleetRouter extends StatefulWidget {
  const _BusFleetRouter();
  @override
  State<_BusFleetRouter> createState() => _BusFleetRouterState();
}

class _BusFleetRouterState extends State<_BusFleetRouter> {
  bool _checking = true;
  bool _isStorekeeper = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('fleet_role') ?? '';
    if (mounted) {
      setState(() {
        _isStorekeeper = UserRoles.isFleetStorekeeper(role);
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_isStorekeeper) {
      return const StorekeeperDashboardScreen(
        isStorekeeperOnly: true,
        panel: 'bus-fleet',
      );
    }
    return const OwnerDashboardScreen(
      loginRoute: '/bus-fleet/login',
      panelPrefix: '/bus-fleet',
    );
  }
}
