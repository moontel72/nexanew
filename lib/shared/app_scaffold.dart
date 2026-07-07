// NEXATRACE — SHARED APP SCAFFOLD
// =================================
// Single factory for all fleet panel Flutter apps (Bus/Truck × Owner/Driver/Conductor).
// Eliminates 8 near-identical main_*.dart entry points.
//
// Modern BLoC-driven usage:
//   void main() => FleetApp.run(
//     title: 'NexaTrace Bus Owner',
//     loginScreen: FleetBlocLoginScreen(panel: UserPanel.busFleet, loginConfig: FleetLoginConfig.busOwner()),
//     dashboardScreen: const OwnerDashboardPage(),
//     loginPath: '/bus-owner/login',
//     dashboardPath: '/bus-owner/dashboard',
//     blocProviders: [fleetBlocProvider()],
//   );
//
// BLoC usage (Wave 0+):
//   void main() => FleetApp.run(
//     title: 'NexaTrace Bus Fleet',
//     loginScreen: const FleetBlocLoginScreen(panel: UserPanel.busFleet),
//     dashboardBuilder: (ctx) { ... read Bloc, decide dashboard ... },
//     blocProviders: [BlocProvider<PanelAuthBloc>(...), ...],
//   );

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/theme/app_scroll_behavior.dart';

class FleetApp {
  /// Bootstrap a fleet panel app with standard configuration.
  ///
  /// [dashboardBuilder] takes precedence over [dashboardScreen] when both
  /// are provided, enabling BLoC-driven dashboard resolution.
  static void run({
    required String title,
    required Widget loginScreen,
    Widget? dashboardScreen,
    Widget Function(BuildContext)? dashboardBuilder,
    String loginPath = '/login',
    String dashboardPath = '/dashboard',
    List<BlocProvider> blocProviders = const [],
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
        dashboardBuilder: dashboardBuilder,
        loginPath: loginPath,
        dashboardPath: dashboardPath,
        blocProviders: blocProviders,
        seedColor: seedColor,
        designSize: designSize,
      ),
    );
  }
}

class _FleetMaterialApp extends StatelessWidget {
  final String title;
  final Widget loginScreen;
  final Widget? dashboardScreen;
  final Widget Function(BuildContext)? dashboardBuilder;
  final String loginPath;
  final String dashboardPath;
  final List<BlocProvider> blocProviders;
  final Color? seedColor;
  final Size designSize;

  const _FleetMaterialApp({
    required this.title,
    required this.loginScreen,
    this.dashboardScreen,
    this.dashboardBuilder,
    required this.loginPath,
    required this.dashboardPath,
    required this.blocProviders,
    this.seedColor,
    required this.designSize,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: loginPath, builder: (_, __) => loginScreen),
        GoRoute(
          path: dashboardPath,
          builder: (_, __) {
            if (dashboardBuilder != null) {
              return Builder(builder: (ctx) => dashboardBuilder!(ctx));
            }
            return dashboardScreen ?? loginScreen;
          },
        ),
      ],
      errorBuilder: (context, state) => loginScreen,
    );

    Widget app = ScreenUtilInit(
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

    // Wrap with MultiBlocProvider if any providers are supplied
    if (blocProviders.isNotEmpty) {
      app = MultiBlocProvider(providers: blocProviders, child: app);
    }

    return app;
  }
}
