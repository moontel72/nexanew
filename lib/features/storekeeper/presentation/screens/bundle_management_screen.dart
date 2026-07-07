/// Bundle Management Screen — BLoC-driven (P1 wired)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_event.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_state.dart';

class BundleManagementScreen extends StatelessWidget {
  const BundleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StorekeeperDashboardBloc>();
    return BlocBuilder<StorekeeperDashboardBloc, StorekeeperDashboardState>(
      builder: (ctx, state) {
        final bundles = state.bundles;
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B2838),
            title: const Text('Bundle & Smart Codes', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF00B4D8)),
                tooltip: 'Refresh',
                onPressed: () => bloc.add(LoadBundles(panel: 'bus-fleet')),
              ),
            ],
          ),
          body: state.bundlesLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.redAccent)))
                  : bundles.isEmpty
                      ? const Center(child: Text('No bundles', style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: bundles.length,
                          itemBuilder: (_, i) => _bundleCard(bundles[i]),
                        ),
        );
      },
    );
  }

  Widget _bundleCard(Map<String, dynamic> b) {
    final name = b['name']?.toString() ?? 'Bundle';
    final count = (b['item_count'] ?? b['items_count'] ?? 0).toString();
    return Card(
      color: const Color(0xFF1B2838),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0x2000B4D8),
            child: Icon(Icons.inventory, color: Color(0xFF00B4D8), size: 18)),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text('$count items', style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ),
    );
  }
}
