/// Settlement Report Screen — BLoC-driven (P2)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_event.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_state.dart';

class StorekeeperSettlementReportScreen extends StatelessWidget {
  const StorekeeperSettlementReportScreen({super.key});

  String _fmtPaisa(dynamic v) {
    final p = v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
    return 'Rs. ${(p / 100).toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StorekeeperDashboardBloc()..add(const LoadSettlementReport()),
      child: BlocBuilder<StorekeeperDashboardBloc, StorekeeperDashboardState>(
        builder: (ctx, state) {
          final list = state.settlementReport;
          return Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1B2838),
              title: const Text(
                'Settlement Report',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: state.settlementLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                ? const Center(
                    child: Text(
                      'No settlements',
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
                            Icons.receipt_long,
                            color: Color(0xFF059669),
                          ),
                          title: Text(
                            e['trip_id']?.toString() ??
                                e['bus_plate']?.toString() ??
                                '—',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Collected: ${_fmtPaisa(e['total_collected'])}',
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
      ),
    );
  }
}
