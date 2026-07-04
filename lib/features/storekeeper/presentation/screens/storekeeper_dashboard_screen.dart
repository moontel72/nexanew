/// StoreKeeper Dashboard — Catering & Inventory Management
///
/// Integrated into the Bus-Fleet web panel.
/// A storekeeper user sees ONLY the Catering, Issuance, and Reconciliation tabs.
/// Admins/owners see these tabs alongside their regular fleet management views.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/storekeeper/data/repositories/storekeeper_repository.dart';
import 'package:trace_odd/features/storekeeper/domain/models/storekeeper_dashboard.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/bundle_management_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/catering_management_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/issuance_screen.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/reconciliation_screen.dart';

class StorekeeperDashboardScreen extends StatefulWidget {
  final bool isStorekeeperOnly;
  final String panel; // 'bus-fleet' or 'bus-owner'

  const StorekeeperDashboardScreen({
    super.key,
    this.isStorekeeperOnly = false,
    this.panel = 'bus-fleet',
  });

  @override
  State<StorekeeperDashboardScreen> createState() =>
      _StorekeeperDashboardScreenState();
}

class _StorekeeperDashboardScreenState extends State<StorekeeperDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final StorekeeperRepository _repo;

  StorekeeperDashboardData _dashboardData = const StorekeeperDashboardData();
  bool _loading = true;
  String? _error;

  static const _tabs = ['Catering', 'Issuance', 'Reconciliation', 'Bundles'];

  @override
  void initState() {
    super.initState();
    _repo = StorekeeperRepository(panel: widget.panel);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getDashboard();
      if (mounted) setState(() => _dashboardData = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final theme = Theme.of(context);

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
            onPressed: _loadDashboard,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00B4D8),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Column(
        children: [
          // KPI ribbon
          _buildKpiRibbon(isWide, theme),
          // Tab content
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
  }

  Widget _buildKpiRibbon(bool isWide, ThemeData theme) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      );
    }

    final kpis = [
      _Kpi(
        'Total Items',
        _dashboardData.totalItems.toString(),
        Icons.inventory_2_outlined,
        const Color(0xFF7C3AED),
      ),
      _Kpi(
        'Low Stock',
        _dashboardData.lowStockItems.toString(),
        Icons.warning_amber_rounded,
        _dashboardData.lowStockItems > 0
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
      ),
      _Kpi(
        'Pending',
        _dashboardData.pendingIssuances.toString(),
        Icons.pending_actions,
        const Color(0xFFF59E0B),
      ),
      _Kpi(
        'Active Issued',
        _dashboardData.activeIssuances.toString(),
        Icons.local_shipping,
        const Color(0xFF00B4D8),
      ),
      _Kpi(
        'To Reconcile',
        _dashboardData.draftReconciliations.toString(),
        Icons.receipt_long,
        const Color(0xFFDB2777),
      ),
      _Kpi(
        'Outstanding',
        'Rs. ${_dashboardData.outstandingValueMain.toStringAsFixed(0)}',
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

    // Mobile: wrap KPIs in a horizontal scroll
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
  final String label;
  final String value;
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
          color: kpi.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kpi.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(kpi.icon, color: kpi.color, size: 18),
            const Gap(4),
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
        color: kpi.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kpi.color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(kpi.icon, color: kpi.color, size: 22),
          const Gap(10),
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
