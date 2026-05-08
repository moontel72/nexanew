import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_packing_bloc.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_packing_event.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_packing_state.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

class BundlePackingScreen extends StatefulWidget {
  const BundlePackingScreen({super.key});
  @override
  State<BundlePackingScreen> createState() => _BundlePackingScreenState();
}

class _BundlePackingScreenState extends State<BundlePackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderRefCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  final _shelfCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BundlePackingBloc>().add(const LoadFormats());
  }

  @override
  void dispose() {
    _orderRefCtrl.dispose();
    _storeCtrl.dispose();
    _shelfCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<BundlePackingBloc>().state;
    context.read<BundleBloc>().add(
      CreateBundle(
        orderReference: _orderRefCtrl.text.trim(),
        cartonCodeIds: state.selectedCartonCodeIds.isNotEmpty
            ? state.selectedCartonCodeIds.toList()
            : null,
        packetCodeIds: state.selectedPacketCodeIds.isNotEmpty
            ? state.selectedPacketCodeIds.toList()
            : null,
        locationStore: _storeCtrl.text.trim().isEmpty
            ? null
            : _storeCtrl.text.trim(),
        locationShelf: _shelfCtrl.text.trim().isEmpty
            ? null
            : _shelfCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ),
    );
  }

  // ── Cascading Dropdown Builder ──────────────────────────────────

  Widget _cascadeSection({
    required String title,
    required List<FormatOption> formats,
    required String? selectedFormat,
    required List<BatchOption> batches,
    required BatchOption? selectedBatch,
    required List<CodeOption> codes,
    required Set<String> selectedIds,
    required void Function(String?) onFormatChanged,
    required void Function(BatchOption?) onBatchChanged,
    required void Function(String) onToggleCode,
    required String chipsLabel,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            // Level 1: Format
            DropdownButtonFormField<String?>(
              value: selectedFormat,
              decoration: const InputDecoration(
                labelText: 'Code Format',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('-- Select Format --'),
                ),
                ...formats.map(
                  (f) => DropdownMenuItem(
                    value: f.value,
                    child: Text(f.displayName),
                  ),
                ),
              ],
              onChanged: onFormatChanged,
            ),
            SizedBox(height: 12.h),

            // Level 2: Batch
            if (selectedFormat != null) ...[
              DropdownButtonFormField<BatchOption?>(
                value: selectedBatch,
                decoration: InputDecoration(
                  labelText: 'Batch (${batches.length} finalized)',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('-- Select Batch --'),
                  ),
                  ...batches.map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text('${b.batchId} (${b.codeCount} codes)'),
                    ),
                  ),
                ],
                onChanged: onBatchChanged,
              ),
              SizedBox(height: 12.h),
            ],

            // Level 3: Multi-select serials
            if (selectedBatch != null && codes.isNotEmpty) ...[
              Text(
                '$chipsLabel (${selectedIds.length} selected):',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: codes
                    .map(
                      (c) => FilterChip(
                        label: Text(c.code, style: TextStyle(fontSize: 12.sp)),
                        selected: selectedIds.contains(c.id),
                        onSelected: (_) => onToggleCode(c.id),
                        selectedColor: AppColors.primary.withAlpha(40),
                        checkmarkColor: AppColors.primary,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<BundleBloc, BundleState>(
      listener: (context, state) {
        if (state.status == BundleStatus.created &&
            state.selectedBundle != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Bundle Created'),
              content: Text(
                'Bundle: ${state.selectedBundle!.bundleCode}\n${state.selectedBundle!.totalCartons} cartons, ${state.selectedBundle!.totalPackets} packets',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/factory/codes/bundles');
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        if (state.status == BundleStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Create Bundle', showBackButton: true),
        body: BlocBuilder<BundlePackingBloc, BundlePackingState>(
          builder: (context, packState) {
            if (packState.status == BundlePackingStatus.loading)
              return const Center(child: LoadingIndicator());
            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Order info
                  CustomTextField(
                    controller: _orderRefCtrl,
                    labelText: 'Order Reference *',
                    hintText: 'e.g., ORD-2026-001',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 24.h),

                  // Carton cascade
                  _cascadeSection(
                    title: '📦 Carton Codes',
                    formats: packState.cartonFormats,
                    selectedFormat: packState.selectedCartonFormat,
                    batches: packState.cartonBatches,
                    selectedBatch: packState.selectedCartonBatch,
                    codes: packState.cartonCodes,
                    selectedIds: packState.selectedCartonCodeIds,
                    onFormatChanged: (f) => context
                        .read<BundlePackingBloc>()
                        .add(SelectCartonFormat(f)),
                    onBatchChanged: (b) => context
                        .read<BundlePackingBloc>()
                        .add(SelectCartonBatch(b)),
                    onToggleCode: (id) => context.read<BundlePackingBloc>().add(
                      ToggleCartonCode(id),
                    ),
                    chipsLabel: 'Select Cartons',
                  ),

                  // Packet cascade
                  _cascadeSection(
                    title: '📁 Packet Codes',
                    formats: packState.packetFormats,
                    selectedFormat: packState.selectedPacketFormat,
                    batches: packState.packetBatches,
                    selectedBatch: packState.selectedPacketBatch,
                    codes: packState.packetCodes,
                    selectedIds: packState.selectedPacketCodeIds,
                    onFormatChanged: (f) => context
                        .read<BundlePackingBloc>()
                        .add(SelectPacketFormat(f)),
                    onBatchChanged: (b) => context
                        .read<BundlePackingBloc>()
                        .add(SelectPacketBatch(b)),
                    onToggleCode: (id) => context.read<BundlePackingBloc>().add(
                      TogglePacketCode(id),
                    ),
                    chipsLabel: 'Select Packets',
                  ),

                  // Location
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _storeCtrl,
                          labelText: 'Store Location',
                          hintText: 'e.g., Store-3',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomTextField(
                          controller: _shelfCtrl,
                          labelText: 'Shelf',
                          hintText: 'e.g., B7',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: _notesCtrl,
                    labelText: 'Notes',
                    hintText: 'Optional',
                    maxLines: 2,
                  ),
                  SizedBox(height: 32.h),

                  // Submit
                  BlocBuilder<BundleBloc, BundleState>(
                    builder: (_, bundleState) {
                      if (bundleState.status == BundleStatus.creating)
                        return const Center(child: LoadingIndicator());
                      return PrimaryButton(
                        onPressed: _submit,
                        text:
                            'Create Bundle (${packState.selectedCartonCodeIds.length} cartons + ${packState.selectedPacketCodeIds.length} packets)',
                        icon: Icons.layers,
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
