/// Issuance Screen — BLoC-driven (P1 wired)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_issuance.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_event.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_state.dart';

class IssuanceScreen extends StatelessWidget {
  final String panel;
  const IssuanceScreen({super.key, this.panel = 'bus-fleet'});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StorekeeperDashboardBloc>();
    return BlocBuilder<StorekeeperDashboardBloc, StorekeeperDashboardState>(
      builder: (ctx, state) {
        final issuances = (state.issuances)
            .whereType<CateringIssuance>()
            .toList();
        final isWide =
            MediaQuery.of(ctx).size.width >
            900; // retained for layout if needed

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Issuances (${issuances.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF00B4D8),
                    ),
                    tooltip: 'New Issuance',
                    onPressed: () => _showCreateIssuance(ctx, bloc),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.issuancesLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? Center(
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : issuances.isEmpty
                  ? const Center(
                      child: Text(
                        'No issuances',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: issuances.length,
                      itemBuilder: (_, i) =>
                          _issuanceCard(ctx, bloc, issuances[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _issuanceCard(
    BuildContext ctx,
    StorekeeperDashboardBloc bloc,
    CateringIssuance iss,
  ) {
    final color = _statusColor(iss.status ?? 'pending');
    return Card(
      color: const Color(0xFF1B2838),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.inventory_2, color: color, size: 18),
        ),
        title: Text(
          '${iss.busRegNumber ?? 'Bus'}: ${iss.items.length} items',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${iss.status?.toUpperCase() ?? 'PENDING'} · ${_fmt(iss.createdAt)}',
          style: TextStyle(color: color, fontSize: 11),
        ),
        trailing: iss.status == 'pending'
            ? IconButton(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF00B4D8),
                ),
                tooltip: 'Issue Items',
                onPressed: () =>
                    bloc.add(IssueItems(panel: panel, issuanceId: iss.id)),
              )
            : null,
        onTap: iss.status == 'pending'
            ? () => _showIssueDialog(ctx, bloc, iss)
            : null,
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
    'pending' => Colors.orange,
    'issued' => const Color(0xFF00B4D8),
    'reconciled' => Colors.green,
    _ => Colors.white54,
  };

  String _fmt(DateTime? dt) => dt != null
      ? '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'
      : '—';

  void _showIssueDialog(
    BuildContext ctx,
    StorekeeperDashboardBloc bloc,
    CateringIssuance iss,
  ) {
    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('Issue Items', style: TextStyle(color: Colors.white)),
        content: Text(
          'Mark all items for ${iss.busRegNumber ?? 'bus'} as issued?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dctx);
              bloc.add(IssueItems(panel: panel, issuanceId: iss.id));
            },
            child: const Text('Issue'),
          ),
        ],
      ),
    );
  }

  void _showCreateIssuance(BuildContext ctx, StorekeeperDashboardBloc bloc) {
    // Keep existing CreateIssuancePage flow — navigates to form, then refreshes on return.
    // In full BLoC migration, this would dispatch CreateIssuance event from the form.
    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text(
          'Create Issuance',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Issuance creation flow — use the full form page.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dctx);
              bloc.add(LoadIssuances(panel: panel));
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
