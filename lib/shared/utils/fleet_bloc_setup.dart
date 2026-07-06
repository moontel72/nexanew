// Fleet BLoC Setup — shared initialisation helper
// =================================================
// Every fleet entry point (bus-owner, bus-driver, truck-*, etc.) needs
// the same NexaTraceApiClient → PanelAuthRepository → PanelAuthBloc chain.
// This helper eliminates 7 near-identical initialisation blocks.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/network/api_client_v2.dart';
import 'package:trace_odd/core/services/web_safe_storage.dart';
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';

/// Creates a [BlocProvider] for [PanelAuthBloc] wired to the Dio-based
/// [NexaTraceApiClient] and a web-safe storage adapter.
///
/// On web over HTTP, [WebSafeStorage] falls back to SharedPreferences
/// because FlutterSecureStorage requires HTTPS.
///
/// Call once per entry point — stores are singletons under the hood.
BlocProvider<PanelAuthBloc> fleetBlocProvider() {
  final storage = WebSafeStorage();

  // Ensure the Dio singleton is initialised (idempotent after first call).
  NexaTraceApiClient(storage: storage);

  return BlocProvider<PanelAuthBloc>(
    create: (_) => PanelAuthBloc(
      repository: PanelAuthRepository(
        client: NexaTraceApiClient.instance,
        storage: storage,
      ),
    ),
  );
}
