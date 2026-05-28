// Panel BLoC Providers — Unified injection container for all 6 panels
//
// Provides a single spreadable list of BlocProviders for the 4 primary
// panel BLoCs (FactoryDashboardBloc, SecurityMonitorBloc, ConsumerSuperAppBloc,
// PanelAuthBloc) that can be added to the root MultiBlocProvider without
// touching the existing app_providers.dart.
//
// Integration:
//   MultiBlocProvider(
//     providers: [
//       ...AppProviders.getGlobalBlocProviders(),     // existing
//       ...PanelBlocProviders.all(screenWidth: ...),  // ← ADD
//     ],
//   );

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trace_odd/core/services/hardware_scan_service.dart';
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';
import 'package:trace_odd/features/factory/presentation/bloc/factory_dashboard_bloc.dart';
import 'package:trace_odd/core/network/api_client_v2.dart';

class PanelBlocProviders {
  PanelBlocProviders._();

  /// Returns all 4 panel BLoC providers in a single spreadable list.
  /// [manufacturerId] is the logged-in factory's company ID.
  /// [secureStorage] is used by PanelAuthBloc's repository.
  static List<BlocProvider> all({
    required String manufacturerId,
    required FlutterSecureStorage secureStorage,
  }) {
    // Shared scan service — one instance for factory + consumer panels.
    final scanService = HardwareScanService();

    return [
      // Panel Auth (Setup 2) — login/logout for all 6 panels.
      BlocProvider<PanelAuthBloc>(
        create: (context) => PanelAuthBloc(
          repository: PanelAuthRepository(
            client: NexaTraceApiClient.instance,
            secureStorage: secureStorage,
          ),
        ),
      ),

      // Factory Dashboard (Setup 8) — production + logistics.
      BlocProvider<FactoryDashboardBloc>(
        create: (context) => FactoryDashboardBloc(
          scanService: scanService,
          manufacturerId: manufacturerId,
        ),
      ),
    ];
  }
}
