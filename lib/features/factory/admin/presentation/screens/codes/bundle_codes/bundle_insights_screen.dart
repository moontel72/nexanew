import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/bundle_codes/insights/bundle_insights_bloc.dart';
import 'package:trace_odd/features/factory/admin/presentation/widgets/link_units_to_packet_modal.dart';

/// Comprehensive Bundle Insights / Aggregation Report.
///
/// Shows: Bundle → Cartons → Packets → Units hierarchy
/// with summary totals, product breakdown, and manual unit linking per packet.
class BundleInsightsScreen extends StatefulWidget {
  final String bundleId;

  const BundleInsightsScreen({super.key, required this.bundleId});

  @override
  State<BundleInsightsScreen> createState() => _BundleInsightsScreenState();
}

class _BundleInsightsScreenState extends State<BundleInsightsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BundleInsightsBloc>().add(LoadBundleInsights(widget.bundleId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bundle Insights')),
      body: BlocBuilder<BundleInsightsBloc, BundleInsightsState>(
        builder: (context, state) {
          if (state.status == BundleInsightsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BundleInsightsStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.errorMessage ?? 'Failed to load'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<BundleInsightsBloc>().add(
                      LoadBundleInsights(widget.bundleId),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = state.insightsData;
          if (data == null) return const SizedBox.shrink();

          final bundle = data['bundle'] as Map<String, dynamic>? ?? {};
          final summary = data['summary'] as Map<String, dynamic>? ?? {};
          final cartons =
              (data['cartons'] as List<dynamic>?)
                  ?.map((c) => c as Map<String, dynamic>)
                  .toList() ??
              [];
          final standalone =
              (data['standalonePackets'] as List<dynamic>?)
                  ?.map((p) => p as Map<String, dynamic>)
                  .toList() ??
              [];
          final products =
              (data['products'] as List<dynamic>?)
                  ?.map((p) => p as Map<String, dynamic>)
                  .toList() ??
              [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Bundle Header ──
                _sectionTitle('Bundle'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('Code', bundle['bundleCode']?.toString() ?? '-'),
                        _kv(
                          'Order',
                          bundle['orderReference']?.toString() ?? '-',
                        ),
                        _kv('Status', bundle['status']?.toString() ?? '-'),
                        _kv(
                          'Location',
                          '${bundle['locationStore'] ?? ''} / ${bundle['locationShelf'] ?? ''}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Summary Cards ──
                _sectionTitle('Summary'),
                Row(
                  children: [
                    _statCard(
                      context,
                      'Cartons',
                      summary['totalCartons']?.toString() ?? '0',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      context,
                      'Packets',
                      summary['totalPackets']?.toString() ?? '0',
                      Icons.view_module,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      context,
                      'Units',
                      summary['totalUnits']?.toString() ?? '0',
                      Icons.medication,
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Product Breakdown ──
                if (products.isNotEmpty) ...[
                  _sectionTitle('Products'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: products.map((p) {
                      return Chip(
                        avatar: const Icon(Icons.medication, size: 18),
                        label: Text(p['name']?.toString() ?? '-'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Hierarchy: Cartons → Packets → Units ──
                _sectionTitle('Hierarchy'),
                if (cartons.isEmpty && standalone.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No cartons or packets linked yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                // Cartons
                ...cartons.map((carton) => _buildCartonTile(carton, products)),

                // Standalone packets
                if (standalone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Standalone Packets',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.orange),
                  ),
                  ...standalone.map(
                    (packet) =>
                        _buildPacketTile(packet, products, isStandalone: true),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Widget Builders ──────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        color: color.withAlpha(25),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildCartonTile(
    Map<String, dynamic> carton,
    List<Map<String, dynamic>> products,
  ) {
    final packets =
        (carton['packets'] as List<dynamic>?)
            ?.map((p) => p as Map<String, dynamic>)
            .toList() ??
        [];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.inventory_2, color: Colors.blue),
        title: Text(
          'Carton: ${carton['code'] ?? '-'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${carton['packetCount'] ?? 0} packets · ${carton['totalUnits'] ?? 0} units',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Status', carton['status']?.toString() ?? '-'),
                _kv('Batch', carton['batchId']?.toString() ?? '-'),
                const Divider(),
                if (packets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'No packets linked',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ...packets.map((packet) => _buildPacketTile(packet, products)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacketTile(
    Map<String, dynamic> packet,
    List<Map<String, dynamic>> products, {
    bool isStandalone = false,
  }) {
    final units =
        (packet['units'] as List<dynamic>?)
            ?.map((u) => u as Map<String, dynamic>)
            .toList() ??
        [];

    return Card(
      margin: EdgeInsets.only(left: isStandalone ? 0 : 16, bottom: 6),
      color: Colors.grey.shade50,
      child: ExpansionTile(
        leading: const Icon(Icons.view_module, color: Colors.orange, size: 22),
        title: Text(
          'Packet: ${packet['code'] ?? '-'}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${packet['unitCount'] ?? 0} units',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Link Units button
            IconButton(
              icon: const Icon(Icons.link, size: 20, color: Colors.blue),
              tooltip: 'Link Units to this Packet',
              onPressed: () {
                final bloc = context.read<BundleInsightsBloc>();
                showDialog(
                  context: context,
                  builder: (_) => LinkUnitsToPacketModal(
                    packetId: packet['id'] as String,
                    packetCode: packet['code'] as String? ?? '-',
                    bloc: bloc,
                  ),
                ).then((didLink) {
                  if (didLink == true && mounted) {
                    // Refresh insights
                    context.read<BundleInsightsBloc>().add(
                      LoadBundleInsights(widget.bundleId),
                    );
                  }
                });
              },
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Status', packet['status']?.toString() ?? '-'),
                _kv('Batch', packet['batchId']?.toString() ?? '-'),
                const Divider(),
                if (units.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'No units linked — tap 🔗 to link',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                if (units.isNotEmpty)
                  Text(
                    'Units (${units.length}):',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ...units.map((unit) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.medication,
                      size: 18,
                      color: Colors.green,
                    ),
                    title: Text(
                      unit['code']?.toString() ?? '-',
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      'SN: ${unit['serialNumber'] ?? '-'}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
