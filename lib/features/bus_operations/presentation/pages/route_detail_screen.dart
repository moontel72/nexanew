// Route Detail Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/error_state/error_state_widget.dart';
import 'package:trace_odd/shared/widgets/fleet/fleet_shared_widgets.dart';
import 'package:trace_odd/shared/widgets/loading/loading_state_widget.dart';

class RouteDetailScreen extends StatelessWidget {
  final String routeId;
  const RouteDetailScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteListBloc()..add(LoadRouteDetail(routeId)),
      child: BlocBuilder<RouteListBloc, RouteListState>(
        builder: (ctx, state) {
          final r = state.selectedRoute;
          return Scaffold(
            backgroundColor: AppColors.fleetBackground,
            appBar: AppBar(
              backgroundColor: AppColors.fleetCard,
              title: Text(
                r?['name']?.toString() ?? 'Route Detail',
                style: const TextStyle(color: AppColors.textInverse),
              ),
            ),
            body: state.detailLoading
                ? const LoadingState()
                : r == null
                ? ErrorState.notFound(
                    customTitle: 'Route Not Found',
                    customMessage: 'This route could not be loaded.',
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      FleetSectionCard(
                        title: 'Route Details',
                        icon: Icons.route,
                        color: AppColors.fleetAccent,
                        children: [
                          FleetDetailRow(
                            'Code',
                            r['route_code']?.toString() ?? '—',
                          ),
                          FleetDetailRow(
                            'Origin',
                            r['origin']?.toString() ?? '—',
                          ),
                          FleetDetailRow(
                            'Destination',
                            r['destination']?.toString() ?? '—',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FleetSectionCard(
                        title: 'Waypoints',
                        icon: Icons.map,
                        color: AppColors.fleetAccent,
                        children: ((r['waypoints'] as List?) ?? []).map((w) {
                          final m = w is Map
                              ? Map<String, dynamic>.from(w)
                              : <String, dynamic>{};
                          return FleetDetailRow(
                            m['label']?.toString() ?? 'Stop',
                            '${m['lat']}, ${m['lng']}',
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
