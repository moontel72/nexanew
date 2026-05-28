// File: lib/core/widgets/app_initializer.dart
// Widget that initializes async dependencies before showing the app
// Replaces get_it initialization with Flutter BLoC's RepositoryProvider

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/providers/app_providers.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:trace_odd/core/interfaces/secure_storage_interface.dart';
import 'package:trace_odd/core/services/secure_storage_service.dart';
import 'package:trace_odd/core/services/mock_secure_storage.dart';
import 'package:trace_odd/core/constants/app_constants.dart';
import 'package:trace_odd/shared/theme/app_theme.dart';
import 'package:trace_odd/routes/app_router.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/admin_auth_repository.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/factory_auth_repository.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'dart:convert';

/// Widget that initializes async dependencies before showing the app
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  SharedPreferences? _sharedPreferences;
  SecureStorageInterface? _secureStorage;
  Future<List<bool>>? _authWarmup;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    try {
      // Initialize async dependencies
      final sharedPreferences = await SharedPreferences.getInstance();

      // Initialize FlutterSecureStorage with web-specific options for HTTP testing
      final secureStorage = _createSecureStorage();

      if (kDebugMode) {
        debugPrint('APP_INIT depsReady=true');
      }
      setState(() {
        _sharedPreferences = sharedPreferences;
        _secureStorage = secureStorage;
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing dependencies: $e');
      // Handle initialization error
      // For now, we'll still try to show the app with null dependencies
      // The app will handle missing dependencies gracefully
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Check if we have all required dependencies
    if (_sharedPreferences == null || _secureStorage == null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please restart the application',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeDependencies,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Provide dependencies to the entire app using RepositoryProvider
    return MultiRepositoryProvider(
      providers: AppProviders.getRepositoryProviders(
        sharedPreferences: _sharedPreferences!,
        secureStorage: _secureStorage!,
      ),
      child: Builder(
        builder: (context) {
          _authWarmup ??= Future.wait([
            context.read<AdminAuthRepository>().isAuthenticated(),
            context.read<FactoryAuthRepository>().isAuthenticated(),
          ]);

          return FutureBuilder<List<bool>>(
            future: _authWarmup,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              // Update global auth state for router redirect
              final values = snapshot.data ?? const [false, false];
              final isAdminAuthed = values.isNotEmpty ? values[0] : false;
              final isFactoryAuthed = values.length > 1 ? values[1] : false;

              setIsAuthenticatedCache(isAdminAuthed);
              setIsFactoryAuthenticatedCache(isFactoryAuthed);

              if (isFactoryAuthed) {
                final prefs = context.read<SharedPreferences>();
                final token = prefs.getString('factory_auth_token');
                final userJson = prefs.getString('factory_user');
                if (token != null && userJson != null) {
                  final user = jsonDecode(userJson) as Map<String, dynamic>;
                  setFactoryAuthState(
                    isAuthenticated: true,
                    userType: 'factory',
                    userId: user['id']?.toString() ?? '',
                    token: token,
                    factoryId: user['company_id']?.toString(),
                  );
                }
              }

              setAuthCheckCompleted(true);

              if (kDebugMode) {
                debugPrint(
                    'APP_INIT authCheckCompleted=true isAuthenticated=$isAdminAuthed isFactoryAuthenticated=$isFactoryAuthed');
              }

              return RepositoryProvider<AppRouter>(
                create: (context) => AppRouter(
                  authRepo: context.read<AdminAuthRepository>(),
                ),
                child: Builder(
                  builder: (context) {
                    final router = context.read<AppRouter>();
                    return MultiBlocProvider(
                      providers: [
                        ...AppProviders.getGlobalBlocProviders(),
                        ...AppProviders.getDriverBlocProviders(),
                        ...AppProviders.getNexaAdminBlocProviders(),
                        ...AppProviders.getFactoryAdminBlocProviders(),
                      ],
                      child: ScreenUtilInit(
                        designSize: const Size(375, 812),
                        minTextAdapt: true,
                        splitScreenMode: true,
                        builder: (context, child) {
                          return MaterialApp.router(
                            title: AppConstants.appName,
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
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Create SecureStorage instance (Mock for web, real for mobile)
  SecureStorageInterface _createSecureStorage() {
    if (kIsWeb) {
      // For web, use in-memory mock to avoid IndexedDB issues
      return MockSecureStorage();
    } else {
      // For mobile, use default secure storage
      return SecureStorageService(const FlutterSecureStorage());
    }
  }
}
