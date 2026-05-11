import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/insights/bundle_insights_bloc.dart';

/// Modal for manually linking Units to a Packet.
///
/// Flow:
/// 1. Products load automatically → 2. Select Product → 3. Select Batch → 4. Enter Quantity → 5. Link
class LinkUnitsToPacketModal extends StatefulWidget {
  final String packetId;
  final String packetCode;
  final BundleInsightsBloc bloc;

  const LinkUnitsToPacketModal({
    super.key,
    required this.packetId,
    required this.packetCode,
    required this.bloc,
  });

  @override
  State<LinkUnitsToPacketModal> createState() => _LinkUnitsToPacketModalState();
}

class _LinkUnitsToPacketModalState extends State<LinkUnitsToPacketModal> {
  String? _selectedProductId;
  String? _selectedBatchId;
  final _quantityController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    // Fetch products as soon as modal opens
    widget.bloc.add(const LoadAvailableProducts());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocConsumer<BundleInsightsBloc, BundleInsightsState>(
        listener: (context, state) {
          if (state.status == BundleInsightsStatus.linked &&
              state.linkResult != null) {
            final result = state.linkResult!;
            final data = result['data'];
            final count = (data is Map) ? (data['linked_count'] ?? 0) : 0;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$count units linked to packet!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
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
          final products = state.availableProducts;
          final batches = state.availableBatches;
          final isLoading = state.status == BundleInsightsStatus.linking;
          final hasProducts = products.isNotEmpty;

          return AlertDialog(
            title: const Text('Link Units to Packet'),
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
                  if (!hasProducts)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'No products with available unit codes found.\nGenerate unit codes linked to a product first.',
                        style: TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: products.map((p) {
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
                          widget.bloc.add(
                            FetchAvailableBatchesRequested(value),
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 12),

                  // ── Batch Dropdown ──
                  DropdownButtonFormField<String>(
                    value: _selectedBatchId,
                    decoration: const InputDecoration(
                      labelText: 'Select Batch',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: batches.map((b) {
                      final batchId = b['batch_id'] as String;
                      final count = b['available_count'] as int? ?? 0;
                      return DropdownMenuItem<String>(
                        value: batchId,
                        child: Text('$batchId ($count available)'),
                      );
                    }).toList(),
                    onChanged: _selectedProductId == null || !hasProducts
                        ? null
                        : (value) => setState(() => _selectedBatchId = value),
                    hint: Text(
                      _selectedProductId == null
                          ? 'Select a product first'
                          : batches.isEmpty
                          ? 'No batches with available units'
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        widget.bloc.add(
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
