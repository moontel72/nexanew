import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

import 'package:trace_odd/core/interfaces/secure_storage_interface.dart';
import 'package:trace_odd/core/services/mock_secure_storage.dart';
import 'package:trace_odd/core/services/secure_storage_service.dart';
import 'package:trace_odd/shared/theme/app_theme.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/factory_driver_geofence_bloc.dart';
import 'package:trace_odd/features/factory/driver/domain/repositories/driver_repository.dart';
import 'package:trace_odd/features/factory/driver/data/repositories/driver_repository_impl.dart';
import 'package:trace_odd/features/factory/driver/data/datasources/driver_remote_datasource.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/driver_login_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/driver_dashboard_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/scan_receive_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/delivery_scan_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/location_confirm_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/proof_delivery_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/earnings_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/vehicle_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/map_tracking_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/expenses_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/payment_history_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/chat_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/maintenance_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/compliance_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/disputes_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/performance_screen.dart';
import 'package:trace_odd/features/factory/driver/presentation/screens/settings_screen.dart';

/// Initializer widget for the standalone Driver App.
/// Sets up all BLoCs, repositories, and routing for the driver mobile/web experience.
class DriverAppInitializer extends StatefulWidget {
  const DriverAppInitializer({super.key});

  @override
  State<DriverAppInitializer> createState() => _DriverAppInitializerState();
}

class _DriverAppInitializerState extends State<DriverAppInitializer> {
  SharedPreferences? _prefs;
  SecureStorageInterface? _secureStorage;
  late final GoRouter _router;
  bool _ready = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final secure = _createSecureStorage();

    // Check if driver is already logged in
    final token = prefs.getString('driver_auth_token');
    _isLoggedIn = token != null && token.isNotEmpty;

    _router = _buildRouter();

    setState(() {
      _prefs = prefs;
      _secureStorage = secure;
      _ready = true;
    });
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: _isLoggedIn ? '/dashboard' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const DriverLoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const FactoryDriverDashboardScreen(),
        ),
        GoRoute(
          path: '/scan-receive',
          builder: (context, state) => const ScanReceiveScreen(),
        ),
        GoRoute(
          path: '/delivery-scan',
          builder: (context, state) => const DeliveryScanScreen(),
        ),
        GoRoute(
          path: '/location-confirm',
          builder: (context, state) => const LocationConfirmScreen(),
        ),
        GoRoute(
          path: '/pod',
          builder: (context, state) => const ProofDeliveryScreen(),
        ),
        GoRoute(
          path: '/earnings',
          builder: (context, state) => const DriverEarningsScreen(),
        ),
        GoRoute(
          path: '/vehicle',
          builder: (context, state) => const DriverVehicleScreen(),
        ),
        GoRoute(
          path: '/map-tracking',
          builder: (context, state) => const DriverMapTrackingScreen(),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const DriverExpensesScreen(),
        ),
        GoRoute(
          path: '/payment-history',
          builder: (context, state) => const DriverPaymentHistoryScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const DriverChatScreen(),
        ),
        GoRoute(
          path: '/maintenance',
          builder: (context, state) => const DriverMaintenanceScreen(),
        ),
        GoRoute(
          path: '/compliance',
          builder: (context, state) => const DriverComplianceScreen(),
        ),
        GoRoute(
          path: '/disputes',
          builder: (context, state) => const DriverDisputesScreen(),
        ),
        GoRoute(
          path: '/performance',
          builder: (context, state) => const DriverPerformanceScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const DriverSettingsScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _prefs == null) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DriverRemoteDatasource>(
          create: (context) => DriverRemoteDatasource(),
        ),
        RepositoryProvider<DriverRepository>(
          create: (context) => DriverRepositoryImpl(
            remoteDatasource: context.read<DriverRemoteDatasource>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FactoryDriverGeofenceBloc>(
            create: (context) => FactoryDriverGeofenceBloc(),
          ),
          BlocProvider<DriverBloc>(
            create: (context) =>
                DriverBloc(repository: context.read<DriverRepository>()),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'NexaTrace Driver',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: ThemeMode.light,
              routerConfig: _router,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en', 'US')],
              locale: const Locale('en', 'US'),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.noScaling),
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }

  SecureStorageInterface _createSecureStorage() {
    if (kIsWeb) {
      return MockSecureStorage();
    }
    return SecureStorageService(const FlutterSecureStorage());
  }
}
