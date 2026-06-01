// Bus Driver App — independent Flutter build
// Deployed at: /var/www/traceodd/bus-driver/
// Hits: POST /api/v1/bus-fleet/driver-login

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_login_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/driver_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  if (kIsWeb) usePathUrlStrategy();
  runApp(const BusDriverApp());
}

class BusDriverApp extends StatelessWidget {
  const BusDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp.router(
        title: 'NexaTrace Bus Driver',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1F5E6B),
          useMaterial3: true,
        ),
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const FleetDriverLoginScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const DriverDashboardScreen(),
    ),
  ],
);
