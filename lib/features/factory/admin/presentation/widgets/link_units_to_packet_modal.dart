import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/insights/bundle_insights_bloc.dart';

/// Modal for manually linking Units to a Packet.
///
/// Flow:
/// 1. Select Product (from available products dropdown)
/// 2. Select Batch (filtered by selected product)
/// 3. Enter Quantity (manual input)
/// 4. Tap "Link Units" — the system fetches that many available units
///    and links them to the packet.
class LinkUnitsToPacketModal extends StatefulWidget {
  final String packetId;
  final String packetCode;
  final List<Map<String, dynamic>> products;

  const LinkUnitsToPacketModal({
    super.key,
    required this.packetId,
    required this.packetCode,
    required this.products,
  });

  @override
  State<LinkUnitsToPacketModal> createState() => _LinkUnitsToPacketModalState();
}

class _LinkUnitsToPacketModalState extends State<LinkUnitsToPacketModal> {
  String? _selectedProductId;
  String? _selectedBatchId;
  final _quantityController = TextEditingController(text: '10');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BundleInsightsBloc>(),
      child: BlocConsumer<BundleInsightsBloc, BundleInsightsState>(
        listener: (context, state) {
          if (state.status == BundleInsightsStatus.linked &&
              state.linkResult != null) {
            final data = state.linkResult!['data'] as Map<String, dynamic>?;
            final count = data?['linked_count'] ?? 0;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$count units linked to packet!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state.status == BundleInsightsStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final batches = state.availableBatches;
          final isLoading = state.status == BundleInsightsStatus.linking;

          return AlertDialog(
            title: Text('Link Units to Packet'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Packet: ${widget.packetCode}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Product Dropdown ──
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProductId,
                    decoration: const InputDecoration(
                      labelText: 'Select Product',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.products.map((p) {
                      return DropdownMenuItem<String>(
                        value: p['id'] as String,
                        child: Text(
                          p['name'] as String? ?? p['id'] as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
                        _selectedBatchId = null;
                      });
                      if (value != null) {
                        context.read<BundleInsightsBloc>().add(
                          FetchAvailableBatchesRequested(value),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Batch Dropdown ──
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBatchId,
                    decoration: const InputDecoration(
                      labelText: 'Select Batch',
                      border: OutlineInputBorder(),
                    ),
                    items: batches.map((b) {
                      final batchId = b['batch_id'] as String;
                      final count = b['available_count'] as int? ?? 0;
                      return DropdownMenuItem<String>(
                        value: batchId,
                        child: Text('$batchId ($count available)'),
                      );
                    }).toList(),
                    onChanged: _selectedProductId == null
                        ? null
                        : (value) {
                            setState(() => _selectedBatchId = value);
                          },
                    hint: Text(
                      _selectedProductId == null
                          ? 'Select a product first'
                          : batches.isEmpty
                          ? 'No batches available'
                          : 'Choose batch',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Quantity Input ──
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity (units to link)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. 6, 10, 12',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    isLoading ||
                        _selectedProductId == null ||
                        _selectedBatchId == null
                    ? null
                    : () {
                        final quantity =
                            int.tryParse(_quantityController.text.trim()) ?? 0;
                        if (quantity <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid quantity'),
                            ),
                          );
                          return;
                        }
                        context.read<BundleInsightsBloc>().add(
                          LinkUnitsToPacketRequested(
                            packetId: widget.packetId,
                            productId: _selectedProductId!,
                            batchId: _selectedBatchId!,
                            quantity: quantity,
                          ),
                        );
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Link Units'),
              ),
            ],
          );
        },
      ),
    );
  }
}
