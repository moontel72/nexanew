// Panel Provider Binder — Non-breaking DI injection for Setup 2 auth layer
//
// Provides static provider lists that wire `PanelAuthBloc` and
// `PanelAuthRepository` into the global dependency tree WITHOUT modifying
// the existing `app_providers.dart`.  The app initializer simply spreads
// these lists into the existing `MultiRepositoryProvider` and
// `MultiBlocProvider` arrays.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/network/api_client_v2.dart';
import 'package:trace_odd/core/services/web_safe_storage.dart';
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';

class PanelProviderBinder {
  PanelProviderBinder._();

  /// Repository providers for the panel auth layer.
  ///
  /// Must be called AFTER `NexaTraceApiClient` is initialized.
  static List<RepositoryProvider> repositoryProviders({
    required WebSafeStorage storage,
  }) {
    return [
      RepositoryProvider<PanelAuthRepository>(
        create: (context) => PanelAuthRepository(
          client: NexaTraceApiClient.instance,
          storage: storage,
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
      create: (context) =>
          PanelAuthBloc(repository: context.read<PanelAuthRepository>()),
    ),
  ];
}
