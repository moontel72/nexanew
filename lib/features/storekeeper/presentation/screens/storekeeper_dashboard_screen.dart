/// StoreKeeper Dashboard — Catering & Inventory Management (BLoC-driven)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_bloc.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_event.dart';
import 'package:trace_odd/features/storekeeper/presentation/bloc/storekeeper_state.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/bundle_management_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/catering_management_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/issuance_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/reconciliation_screen.dart';

class StorekeeperDashboardScreen extends StatelessWidget {
  final bool isStorekeeperOnly;
  final String panel;
  static const _tabs = ['Catering', 'Issuance', 'Reconciliation', 'Bundles'];

  const StorekeeperDashboardScreen({
    super.key,
    this.isStorekeeperOnly = false,
    this.panel = 'bus-fleet',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StorekeeperDashboardBloc()
            ..add(LoadStorekeeperDashboard(panel: panel)),
      child: _StorekeeperView(
        isStorekeeperOnly: isStorekeeperOnly,
        panel: panel,
      ),
    );
  }
}

class _StorekeeperView extends StatefulWidget {
  final bool isStorekeeperOnly;
  final String panel;
  const _StorekeeperView({
    required this.isStorekeeperOnly,
    required this.panel,
  });

  @override
  State<_StorekeeperView> createState() => _StorekeeperViewState();
}

class _StorekeeperViewState extends State<_StorekeeperView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: StorekeeperDashboardScreen._tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorekeeperDashboardBloc, StorekeeperDashboardState>(
      builder: (ctx, state) {
        final bloc = ctx.read<StorekeeperDashboardBloc>();
        final isWide = MediaQuery.of(ctx).size.width > 900;

        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B2838),
            title: const Text(
              'Store Keeper',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                onPressed: () =>
                    bloc.add(RefreshStorekeeperData(panel: widget.panel)),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00B4D8),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: StorekeeperDashboardScreen._tabs
                  .map((t) => Tab(text: t))
                  .toList(),
            ),
          ),
          body: Column(
            children: [
              _KpiRibbon(isWide: isWide, state: state),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CateringManagementScreen(panel: widget.panel),
                    IssuanceScreen(panel: widget.panel),
                    ReconciliationScreen(panel: widget.panel),
                    const BundleManagementScreen(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiRibbon extends StatelessWidget {
  final bool isWide;
  final StorekeeperDashboardState state;
  const _KpiRibbon({required this.isWide, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == StorekeeperStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    if (state.status == StorekeeperStatus.error) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Error: ${state.error}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      );
    }

    final kpis = [
      _Kpi(
        'Total Items',
        '${state.totalItems}',
        Icons.inventory_2_outlined,
        const Color(0xFF7C3AED),
      ),
      _Kpi(
        'Low Stock',
        '${state.lowStockItems}',
        Icons.warning_amber_rounded,
        state.lowStockItems > 0
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
      ),
      _Kpi(
        'Pending',
        '${state.pendingIssuances}',
        Icons.pending_actions,
        const Color(0xFFF59E0B),
      ),
      _Kpi(
        'Active Issued',
        '${state.activeIssuances}',
        Icons.local_shipping,
        const Color(0xFF00B4D8),
      ),
      _Kpi(
        'To Reconcile',
        '${state.draftReconciliations}',
        Icons.receipt_long,
        const Color(0xFFDB2777),
      ),
      _Kpi(
        'Outstanding',
        'Rs. ${state.outstandingValue.toStringAsFixed(0)}',
        Icons.account_balance_wallet,
        const Color(0xFF16A34A),
      ),
    ];

    if (isWide) {
      return Container(
        color: const Color(0xFF1B2838),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: kpis.map((k) => Expanded(child: _KpiTile(kpi: k))).toList(),
        ),
      );
    }
    return Container(
      color: const Color(0xFF1B2838),
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: kpis.length,
        separatorBuilder: (_, __) => const Gap(10),
        itemBuilder: (_, i) => SizedBox(
          width: 110.w,
          child: _KpiTile(kpi: kpis[i], compact: true),
        ),
      ),
    );
  }
}

class _Kpi {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Kpi(this.label, this.value, this.icon, this.color);
}

class _KpiTile extends StatelessWidget {
  final _Kpi kpi;
  final bool compact;
  const _KpiTile({required this.kpi, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kpi.color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kpi.color.withValues(alpha: .3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(kpi.icon, color: kpi.color, size: 18),
            Gap(4),
            Text(
              kpi.value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              kpi.label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kpi.color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kpi.color.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Icon(kpi.icon, color: kpi.color, size: 22),
          Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kpi.value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                kpi.label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
