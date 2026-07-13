/// Activity Log Screen — BLoC-driven (P2)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_state.dart';

class StorekeeperActivityLogScreen extends StatelessWidget {
  const StorekeeperActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorekeeperDashboardBloc, StorekeeperDashboardState>(
      builder: (ctx, state) {
        final list = state.activityLog;
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B2838),
            title: const Text(
              'Activity Log',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: state.activityLogLoading
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
              ? const Center(
                  child: Text(
                    'No activity',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final e = list[i] is Map
                        ? list[i] as Map<String, dynamic>
                        : <String, dynamic>{};
                    return Card(
                      color: const Color(0xFF1B2838),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: Color(0xFF00B4D8),
                        ),
                        title: Text(
                          e['action']?.toString() ??
                              e['event']?.toString() ??
                              '—',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          e['created_at']?.toString() ?? '',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
