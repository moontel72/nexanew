// Route Detail Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_bloc.dart';

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
            backgroundColor: const Color(0xFF0D1B2A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1B2838),
              title: Text(
                r?['name']?.toString() ?? 'Route Detail',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            body: state.detailLoading
                ? const Center(child: CircularProgressIndicator())
                : r == null
                ? const Center(
                    child: Text(
                      'Route not found',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _row('Code', r['route_code']?.toString()),
                      _row('Origin', r['origin']?.toString()),
                      _row('Destination', r['destination']?.toString()),
                      const SizedBox(height: 16),
                      const Text(
                        'Waypoints',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ...((r['waypoints'] as List?) ?? []).map((w) {
                        final m = w is Map
                            ? Map<String, dynamic>.from(w)
                            : <String, dynamic>{};
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFF00B4D8),
                          ),
                          title: Text(
                            m['label']?.toString() ?? 'Stop',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${m['lat']}, ${m['lng']}',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        );
                      }),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String? value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Colors.white54)),
        ),
        Expanded(
          child: Text(
            value ?? '—',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
