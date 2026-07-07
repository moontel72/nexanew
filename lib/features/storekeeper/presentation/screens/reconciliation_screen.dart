/// Reconciliation Screen — BLoC-driven (P1 wired)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_reconciliation.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_event.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_state.dart';

class ReconciliationScreen extends StatelessWidget {
  final String panel;
  const ReconciliationScreen({super.key, this.panel = 'bus-fleet'});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StorekeeperDashboardBloc>();
    return BlocBuilder<StorekeeperDashboardBloc, StorekeeperDashboardState>(
      builder: (ctx, state) {
        final recs = (state.reconciliations)
            .whereType<CateringReconciliation>()
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reconciliations (${recs.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF00B4D8)),
                    tooltip: 'Refresh',
                    onPressed: () =>
                        bloc.add(LoadReconciliations(panel: panel)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.reconciliationsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? Center(
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : recs.isEmpty
                  ? const Center(
                      child: Text(
                        'No reconciliations',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recs.length,
                      itemBuilder: (_, i) => _recCard(recs[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _recCard(CateringReconciliation rec) {
    final color = _statusColor(rec.status);
    return Card(
      color: const Color(0xFF1B2838),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.balance, color: color, size: 18),
        ),
        title: Text(
          rec.issuanceId,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${rec.status?.toUpperCase() ?? 'DRAFT'} · ${_fmt(rec.createdAt)}',
          style: TextStyle(color: color, fontSize: 11),
        ),
      ),
    );
  }

  Color _statusColor(String? s) => switch (s) {
    'draft' => Colors.orange,
    'confirmed' => Colors.green,
    _ => Colors.white54,
  };

  String _fmt(DateTime? dt) => dt != null
      ? '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'
      : '—';
}
