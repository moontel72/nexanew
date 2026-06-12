// NEXATRACE — SHARED APP SCAFFOLD
// =================================
// Single factory for all fleet panel Flutter apps (Bus/Truck × Owner/Driver/Conductor).
// Eliminates 8 near-identical main_*.dart entry points.
//
// Usage:
//   void main() => FleetApp.run(
//     title: 'NexaTrace Bus Owner',
//     loginScreen: const OwnerLoginScreen(),
//     dashboardScreen: const OwnerDashboardScreen(),
//     loginPath: '/bus-owner/login',
//     dashboardPath: '/bus-owner/dashboard',
//   );

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/theme/app_scroll_behavior.dart';

class FleetApp {
  /// Bootstrap a fleet panel app with standard configuration.
  static void run({
    required String title,
    required Widget loginScreen,
    required Widget dashboardScreen,
    String loginPath = '/login',
    String dashboardPath = '/dashboard',
    Color? seedColor,
    Size designSize = const Size(390, 844),
  }) {
    WidgetsFlutterBinding.ensureInitialized();
    ScreenUtil.ensureScreenSize();
    if (kIsWeb) usePathUrlStrategy();

    runApp(
      _FleetMaterialApp(
        title: title,
        loginScreen: loginScreen,
        dashboardScreen: dashboardScreen,
        loginPath: loginPath,
        dashboardPath: dashboardPath,
        seedColor: seedColor,
        designSize: designSize,
      ),
    );
  }
}

class _FleetMaterialApp extends StatelessWidget {
  final String title;
  final Widget loginScreen;
  final Widget dashboardScreen;
  final String loginPath;
  final String dashboardPath;
  final Color? seedColor;
  final Size designSize;

  const _FleetMaterialApp({
    required this.title,
    required this.loginScreen,
    required this.dashboardScreen,
    required this.loginPath,
    required this.dashboardPath,
    this.seedColor,
    required this.designSize,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: loginPath,
      routes: [
        GoRoute(path: loginPath, builder: (_, __) => loginScreen),
        GoRoute(path: dashboardPath, builder: (_, __) => dashboardScreen),
      ],
    );

    return ScreenUtilInit(
      designSize: designSize,
      builder: (_, __) => MaterialApp.router(
        title: title,
        debugShowCheckedModeBanner: false,
        scrollBehavior: const WebAppScrollBehavior(),
        routerConfig: router,
        theme: ThemeData(
          colorSchemeSeed: seedColor ?? const Color(0xFF1F5E6B),
          useMaterial3: true,
        ),
      ),
    );
  }
}
