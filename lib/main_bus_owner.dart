// Bus Owner App — independent Flutter build
// Deployed at: /var/www/traceodd/bus-owner/
// Served via Nginx: location /bus-owner/
//
// Two-field login: Email/Phone + Password → Dashboard
// Hits: POST /api/v1/bus-fleet/owner-login

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/owner_login_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/owner_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  if (kIsWeb) usePathUrlStrategy();
  runApp(const BusOwnerApp());
}

class BusOwnerApp extends StatelessWidget {
  const BusOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp.router(
        title: 'NexaTrace Bus Owner',
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
    GoRoute(path: '/login', builder: (_, __) => const OwnerLoginScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const OwnerDashboardScreen(),
    ),
  ],
);
