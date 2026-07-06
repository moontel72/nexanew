// Panel BLoC Providers — Unified injection container for all 6 panels

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/services/hardware_scan_service.dart';
import 'package:trace_odd/core/services/web_safe_storage.dart';
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';
import 'package:trace_odd/features/factory/presentation/bloc/factory_dashboard_bloc.dart';
import 'package:trace_odd/core/network/api_client_v2.dart';

class PanelBlocProviders {
  PanelBlocProviders._();

  /// Returns all panel BLoC providers in a single spreadable list.
  static List<BlocProvider> all({
    required String manufacturerId,
    required WebSafeStorage storage,
  }) {
    final scanService = HardwareScanService();

    return [
      // Panel Auth — login/logout for all 6 panels.
      BlocProvider<PanelAuthBloc>(
        create: (context) => PanelAuthBloc(
          repository: PanelAuthRepository(
            client: NexaTraceApiClient.instance,
            storage: storage,
          ),
        ),
      ),

      // Factory Dashboard — production + logistics.
      BlocProvider<FactoryDashboardBloc>(
        create: (context) => FactoryDashboardBloc(
          scanService: scanService,
          manufacturerId: manufacturerId,
        ),
      ),
    ];
  }
}
