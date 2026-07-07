// Fuel Efficiency Ledger — fuel history breakdown widget
//
// Displays per-vehicle fuel efficiency stats, refuel history,
// and cost analysis. Driven by FleetOpsBloc state with
// multi-tenant scope filtering.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/bloc/fleet_ops_maintenance/fleet_ops_bloc.dart';
import 'package:trace_odd/shared/bloc/fleet_ops_maintenance/fleet_ops_state.dart';
import 'package:trace_odd/shared/models/fleet_maintenance_models.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class FuelEfficiencyLedger extends StatelessWidget {
  /// Optional owner ID for multi-tenant filtering.
  final String? ownerId;

  /// Optional vehicle ID to show single-vehicle view.
  final String? vehicleId;

  const FuelEfficiencyLedger({super.key, this.ownerId, this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetOpsBloc, FleetOpsState>(
      buildWhen: (prev, next) =>
          prev.fuelStats != next.fuelStats || prev.fuelLogs != next.fuelLogs,
      builder: (ctx, state) {
        final stats = _filteredStats(state);
        final logs = _filteredLogs(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Fuel Efficiency',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(12),

            // Aggregate stat cards
            if (stats.isNotEmpty)
              ...stats.entries.map(
                (e) => _StatCard(vehicleId: e.key, stats: e.value),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'No fuel data',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),

            const Gap(16),

            // Recent refuel logs
            if (logs.isNotEmpty) ...[
              const Text(
                'Recent Refuels',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              ...logs.take(6).map((l) => _RefuelRow(entry: l)),
            ],
          ],
        );
      },
    );
  }

  Map<String, FuelEfficiencyStats> _filteredStats(FleetOpsState state) {
    var s = state.fuelStats;
    if (ownerId != null) s = state.fuelForOwner(ownerId!);
    if (vehicleId != null) {
      final v = s[vehicleId];
      return v != null ? {vehicleId!: v} : {};
    }
    return s;
  }

  List<FuelLogEntry> _filteredLogs(FleetOpsState state) {
    var logs = state.fuelLogs;
    if (vehicleId != null)
      logs = logs.where((l) => l.vehicleId == vehicleId).toList();
    if (ownerId != null) {
      final ownedVehicles = state.vehicleHealth.entries
          .where((e) => e.value.ownerId == ownerId)
          .map((e) => e.key)
          .toSet();
      logs = logs.where((l) => ownedVehicles.contains(l.vehicleId)).toList();
    }
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }
}

class _StatCard extends StatelessWidget {
  final String vehicleId;
  final FuelEfficiencyStats stats;
  const _StatCard({required this.vehicleId, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x20FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_gas_station,
                color: Color(0xFFF59E0B),
                size: 18,
              ),
              const Gap(8),
              Text(
                vehicleId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              _miniStat(
                'Avg Efficiency',
                stats.efficiencyLabel,
                const Color(0xFF00B4D8),
              ),
              const Gap(12),
              _miniStat(
                'Moving Avg',
                '${stats.movingAvgKmPerLitre.toStringAsFixed(1)} km/L',
                const Color(0xFF059669),
              ),
              const Gap(12),
              _miniStat(
                'Cost/km',
                stats.costPerKmLabel,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const Gap(8),
          Row(
            children: [
              _miniStat(
                'Total Fuel',
                '${stats.totalLitres.toStringAsFixed(0)} L',
                Colors.white54,
              ),
              const Gap(12),
              _miniStat(
                'Total Cost',
                'PKR ${stats.totalCost.toStringAsFixed(0)}',
                Colors.white54,
              ),
              const Gap(12),
              _miniStat('Refuels', '${stats.refuelCount}', Colors.white54),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _RefuelRow extends StatelessWidget {
  final FuelLogEntry entry;
  const _RefuelRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.opacity, color: Color(0xFFF59E0B), size: 16),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.vehicleId} — ${entry.litres.toStringAsFixed(0)} L',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'PKR ${entry.cost.toStringAsFixed(0)} at ${entry.odometerAtRefuel.toStringAsFixed(0)} km',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
            Text(
              _formatDate(entry.timestamp),
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}';
  }
}
