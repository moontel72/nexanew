// Route List Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/loading/loading_state_widget.dart';
import 'package:trace_odd/shared/widgets/error_state/error_state_widget.dart';
import 'package:trace_odd/shared/widgets/fleet/fleet_shared_widgets.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_state.dart';

class RouteListScreen extends StatelessWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteListBloc()..add(const LoadRoutes()),
      child: BlocBuilder<RouteListBloc, RouteListState>(
        builder: (ctx, state) => Scaffold(
          backgroundColor: AppColors.fleetBackground,
          appBar: AppBar(
            backgroundColor: AppColors.fleetCard,
            title: const Text(
              'Routes',
              style: TextStyle(color: AppColors.textInverse),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.fleetAccent),
                onPressed: () =>
                    ctx.read<RouteListBloc>().add(const LoadRoutes()),
              ),
            ],
          ),
          body: state.loading
              ? const LoadingState()
              : state.routes.isEmpty
              ? ErrorState.empty(
                  customTitle: 'No Routes',
                  customMessage: 'No routes found.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.routes.length,
                  itemBuilder: (_, i) {
                    final r = state.routes[i];
                    return GestureDetector(
                      onTap: () => context.push('/route-detail/${r['id']}'),
                      child: FleetSectionCard(
                        title: r['name']?.toString() ?? 'Route',
                        icon: Icons.route,
                        color: AppColors.fleetAccent,
                        children: [
                          FleetDetailRow(
                            'Path',
                            '${r['origin'] ?? ''} → ${r['destination'] ?? ''}',
                            AppColors.fleetAccent,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              tooltip: 'Delete route',
                              onPressed: () => ctx.read<RouteListBloc>().add(
                                DeleteRoute(r['id']?.toString() ?? ''),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
