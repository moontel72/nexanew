// Panel Provider Binder — Non-breaking DI injection for Setup 2 auth layer
//
// Provides static provider lists that wire `PanelAuthBloc` and
// `PanelAuthRepository` into the global dependency tree WITHOUT modifying
// the existing `app_providers.dart`.  The app initializer simply spreads
// these lists into the existing `MultiRepositoryProvider` and
// `MultiBlocProvider` arrays.
//
// Integration (in AppInitializer or main.dart):
//   MultiRepositoryProvider(
//     providers: [
//       ...AppProviders.getRepositoryProviders(...),
//       ...PanelProviderBinder.repositoryProviders(secureStorage),
//     ],
//     child: ...
//   );
//
//   MultiBlocProvider(
//     providers: [
//       ...AppProviders.getGlobalBlocProviders(),
//       ...PanelProviderBinder.blocProviders,
//     ],
//     child: ...
//   );

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trace_odd/core/network/api_client_v2.dart';
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';

class PanelProviderBinder {
  PanelProviderBinder._();

  /// Repository providers for the panel auth layer.
  ///
  /// Must be called AFTER `NexaTraceApiClient` is initialized (Setup 1)
  /// and AFTER `FlutterSecureStorage` is available.
  static List<RepositoryProvider> repositoryProviders({
    required FlutterSecureStorage secureStorage,
  }) {
    return [
      RepositoryProvider<PanelAuthRepository>(
        create: (context) => PanelAuthRepository(
          client: NexaTraceApiClient.instance,
          secureStorage: secureStorage,
        ),
      ),
    ];
  }

  /// BLoC providers for the panel auth layer.
  ///
  /// Depends on `PanelAuthRepository` being available in the widget tree
  /// (provided by [repositoryProviders] above).
  static List<BlocProvider> get blocProviders => [
        BlocProvider<PanelAuthBloc>(
          create: (context) => PanelAuthBloc(
            repository: context.read<PanelAuthRepository>(),
          ),
        ),
      ];

  /// Convenience: returns both repository + bloc providers in one list
  /// for the common case where both are added at the same level.
  static List<dynamic> allProviders({
    required FlutterSecureStorage secureStorage,
  }) {
    return [
      ...repositoryProviders(secureStorage: secureStorage),
      ...blocProviders,
    ];
  }
}
