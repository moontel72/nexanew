// App Providers — CORE SERVICES ONLY.
//
// PANEL-SEPARATION-PLAN.md §15b: this file used to hold every panel's repositories and BLoCs, which
// made `lib/core/` import `lib/features/` (45 violating imports). The panel-specific providers now
// live with their panels:
//
//     lib/features/nexa_admin/providers.dart   → NexaAdminProviders
//     lib/features/factory/providers.dart      → FactoryProviders
//
// This file must import **nothing** from `lib/features/`. If a panel needs a provider, add it to that
// panel's own providers file — `node .scripts/check-panel-isolation.mjs` enforces this.

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/constants/api_endpoints.dart' as api;
import 'package:trace_odd/core/interfaces/secure_storage_interface.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/core/services/api_service.dart';

class AppProviders {
  AppProviders._();

  /// Core services every panel depends on. Panel providers are composed AFTER this list by the
  /// caller (an entry point or `lib/app/app_initializer.dart`), because providers are resolved with
  /// `context.read` during creation — order matters.
  static List<RepositoryProvider> getRepositoryProviders({
    required SharedPreferences sharedPreferences,
    required SecureStorageInterface secureStorage,
  }) {
    return [
      // Core Services
      RepositoryProvider<SharedPreferences>.value(value: sharedPreferences),
      RepositoryProvider<SecureStorageInterface>.value(value: secureStorage),
      RepositoryProvider<ApiClient>(create: (context) => ApiClient()),
      RepositoryProvider<ApiService>(create: (context) => ApiService()),

      // Dio instance for services that need it
      RepositoryProvider<Dio>(
        create: (context) => Dio(
          BaseOptions(
            baseUrl: api.ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ),
      ),
    ];
  }

  /// Get global BLoC providers (available to all modules)
  static List<BlocProvider> getGlobalBlocProviders() {
    return [
      // Add global BLoCs here (e.g., theme, language, notifications)
    ];
  }
}
