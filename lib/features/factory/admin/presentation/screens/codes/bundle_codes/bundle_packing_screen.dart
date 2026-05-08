import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_bloc.dart';
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
  final _cartonIdsCtrl = TextEditingController();
  final _packetIdsCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  final _shelfCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _orderRefCtrl.dispose();
    _cartonIdsCtrl.dispose();
    _packetIdsCtrl.dispose();
    _storeCtrl.dispose();
    _shelfCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _createBundle() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BundleBloc>().add(
      CreateBundle(
        orderReference: _orderRefCtrl.text.trim(),
        cartonCodeIds: _cartonIdsCtrl.text.trim().isEmpty
            ? null
            : _cartonIdsCtrl.text
                  .trim()
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList(),
        packetCodeIds: _packetIdsCtrl.text.trim().isEmpty
            ? null
            : _packetIdsCtrl.text
                  .trim()
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList(),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BundleBloc, BundleState>(
      listener: (context, state) {
        if (state.status == BundleStatus.created &&
            state.selectedBundle != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Bundle Created'),
              content: Text(
                'Bundle Code: ${state.selectedBundle!.bundleCode}\n${state.selectedBundle!.totalCartons} cartons, ${state.selectedBundle!.totalPackets} packets',
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
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Create Bundle', showBackButton: true),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                CustomTextField(
                  controller: _orderRefCtrl,
                  labelText: 'Order Reference *',
                  hintText: 'e.g., ORD-2026-001',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _cartonIdsCtrl,
                  labelText: 'Carton Code IDs (comma-separated)',
                  hintText: 'e.g., uuid1, uuid2',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _packetIdsCtrl,
                  labelText: 'Packet Code IDs (comma-separated)',
                  hintText: 'e.g., uuid1, uuid2',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _storeCtrl,
                  labelText: 'Store Location',
                  hintText: 'e.g., Store-3',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _shelfCtrl,
                  labelText: 'Shelf',
                  hintText: 'e.g., B7',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: _notesCtrl,
                  labelText: 'Notes',
                  hintText: 'Optional notes',
                  maxLines: 3,
                ),
                SizedBox(height: 32.h),
                if (state.status == BundleStatus.creating)
                  const Center(child: LoadingIndicator())
                else
                  PrimaryButton(
                    onPressed: _createBundle,
                    text: 'Create Bundle',
                    icon: Icons.layers,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
