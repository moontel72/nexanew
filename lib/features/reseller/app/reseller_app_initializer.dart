import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:trace_odd/core/interfaces/secure_storage_interface.dart';
import 'package:trace_odd/core/providers/app_providers.dart';
import 'package:trace_odd/core/services/mock_secure_storage.dart';
import 'package:trace_odd/core/services/secure_storage_service.dart';
import 'package:trace_odd/shared/theme/app_theme.dart';

import 'package:trace_odd/features/reseller/data/repositories/reseller_session_repository.dart';
import 'package:trace_odd/features/reseller/data/datasources/reseller_marketplace_remote_datasource.dart';
import 'package:trace_odd/features/reseller/data/repositories/reseller_marketplace_repository.dart';
import 'package:trace_odd/features/reseller/data/datasources/reseller_order_remote_datasource.dart';
import 'package:trace_odd/features/reseller/data/repositories/reseller_order_repository.dart';
import 'package:trace_odd/features/reseller/presentation/bloc/auth/reseller_auth_bloc.dart';
import 'package:trace_odd/features/reseller/presentation/bloc/dashboard/reseller_dashboard_bloc.dart';
import 'package:trace_odd/features/reseller/presentation/bloc/marketplace/reseller_marketplace_bloc.dart';
import 'package:trace_odd/features/reseller/presentation/bloc/cart/reseller_cart_bloc.dart';
import 'package:trace_odd/features/reseller/presentation/bloc/order/reseller_order_bloc.dart';
import 'package:trace_odd/features/reseller/routes/reseller_router.dart';

class ResellerAppInitializer extends StatefulWidget {
  const ResellerAppInitializer({super.key});

  @override
  State<ResellerAppInitializer> createState() => _ResellerAppInitializerState();
}

class _ResellerAppInitializerState extends State<ResellerAppInitializer> {
  SharedPreferences? _prefs;
  SecureStorageInterface? _secureStorage;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final secure = _createSecureStorage();
    setState(() {
      _prefs = prefs;
      _secureStorage = secure;
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _prefs == null || _secureStorage == null) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final resellerSessionRepo = ResellerSessionRepository(_prefs!);
    final router = ResellerRouter(isAuthed: resellerSessionRepo.isAuthenticated());

    return MultiRepositoryProvider(
      providers: [
        ...AppProviders.getRepositoryProviders(
          sharedPreferences: _prefs!,
          secureStorage: _secureStorage!,
        ),
        RepositoryProvider<ResellerSessionRepository>.value(
          value: resellerSessionRepo,
        ),
        RepositoryProvider<ResellerMarketplaceRemoteDatasource>(
          create: (context) => ResellerMarketplaceRemoteDatasource(
            apiService: context.read(),
          ),
        ),
        RepositoryProvider<ResellerMarketplaceRepository>(
          create: (context) => ResellerMarketplaceRepository(
            remote: context.read(),
          ),
        ),
        RepositoryProvider<ResellerOrderRemoteDatasource>(
          create: (context) => ResellerOrderRemoteDatasource(
            apiService: context.read(),
          ),
        ),
        RepositoryProvider<ResellerOrderRepository>(
          create: (context) => ResellerOrderRepository(
            remote: context.read(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ResellerAuthBloc>(
            create: (context) => ResellerAuthBloc(
              repo: context.read<ResellerSessionRepository>(),
            )..add(ResellerCheckAuthRequested()),
          ),
          BlocProvider<ResellerDashboardBloc>(
            create: (context) => ResellerDashboardBloc(
              prefs: context.read<SharedPreferences>(),
            ),
          ),
          BlocProvider<ResellerMarketplaceBloc>(
            create: (context) => ResellerMarketplaceBloc(
              repo: context.read<ResellerMarketplaceRepository>(),
            ),
          ),
          BlocProvider<ResellerCartBloc>(
            create: (_) => ResellerCartBloc(),
          ),
          BlocProvider<ResellerOrderBloc>(
            create: (context) => ResellerOrderBloc(
              repo: context.read<ResellerOrderRepository>(),
            ),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Trace Odd Reseller',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: ThemeMode.light,
              routerConfig: router.config,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('ur', 'PK'),
              ],
              locale: const Locale('en', 'US'),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
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
