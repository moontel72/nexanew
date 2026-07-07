// Route List Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_list_bloc.dart';

class RouteListScreen extends StatelessWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteListBloc()..add(const LoadRoutes()),
      child: BlocBuilder<RouteListBloc, RouteListState>(
        builder: (ctx, state) => Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B2838),
            title: const Text('Routes', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF00B4D8)),
                onPressed: () =>
                    ctx.read<RouteListBloc>().add(const LoadRoutes()),
              ),
            ],
          ),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.routes.isEmpty
              ? const Center(
                  child: Text(
                    'No routes',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.routes.length,
                  itemBuilder: (_, i) {
                    final r = state.routes[i];
                    return Card(
                      color: const Color(0xFF1B2838),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.route,
                          color: Color(0xFF00B4D8),
                        ),
                        title: Text(
                          r['name']?.toString() ?? 'Route',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${r['origin'] ?? ''} → ${r['destination'] ?? ''}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => ctx.read<RouteListBloc>().add(
                            DeleteRoute(r['id']?.toString() ?? ''),
                          ),
                        ),
                        onTap: () => context.push('/route-detail/${r['id']}'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
