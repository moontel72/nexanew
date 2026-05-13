import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

/// Create Manual Order Screen
///
/// A simple form for factory admins to create manual orders (bundles) via
/// the bundle generate API. Provides an auto-generated order reference
/// (e.g., ORD-2026-009) that is editable, plus an optional notes field.
class CreateManualOrderScreen extends StatefulWidget {
  const CreateManualOrderScreen({super.key});

  @override
  State<CreateManualOrderScreen> createState() =>
      _CreateManualOrderScreenState();
}

class _CreateManualOrderScreenState extends State<CreateManualOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderRefCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _orderRefCtrl.text = _generateOrderReference();
  }

  @override
  void dispose() {
    _orderRefCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Generates an auto-incrementing order reference like ORD-2026-009.
  ///
  /// The sequence is derived from the current timestamp's millisecond component
  /// modulo 1000, giving a pseudo-random but stable-looking reference.
  /// In production this should be replaced with a server-side counter.
  String _generateOrderReference() {
    final now = DateTime.now();
    final year = now.year;
    // Use a combination of day-of-year and a hash of the current second for variety
    final dayOfYear = int.parse(
      '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );
    final seconds = now.hour * 3600 + now.minute * 60 + now.second;
    final seq = ((dayOfYear * 97 + seconds) % 999) + 1;
    return 'ORD-$year-${seq.toString().padLeft(3, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      await ApiService().post(
        '/factory/store-keeper-bundles/create-dummy',
        body: {
          'order_reference': _orderRefCtrl.text.trim(),
          if (_notesCtrl.text.trim().isNotEmpty)
            'notes': _notesCtrl.text.trim(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${_orderRefCtrl.text.trim()} created'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh the bundle list and navigate back
      context.read<BundleBloc>().add(const LoadBundles());
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: AppColors.info.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 22.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Create a manual order that can later be linked to cartons and packets by a Store Keeper.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Order Reference
              CustomTextField(
                controller: _orderRefCtrl,
                labelText: 'Order Reference *',
                hintText: 'e.g., ORD-2026-009',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 6.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    _orderRefCtrl.text = _generateOrderReference();
                  },
                  icon: Icon(Icons.refresh, size: 16.sp),
                  label: Text('Regenerate', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
              SizedBox(height: 16.h),

              // Notes
              CustomTextField(
                controller: _notesCtrl,
                labelText: 'Notes',
                hintText: 'Optional notes about this order',
                maxLines: 3,
              ),
              SizedBox(height: 32.h),

              // Submit button
              if (_isCreating)
                const Center(child: LoadingIndicator())
              else
                PrimaryButton(
                  onPressed: _submit,
                  text: 'Create Order',
                  icon: Icons.add_circle_outline,
                ),
              SizedBox(height: 12.h),

              // Cancel
              OutlinedButton(
                onPressed: _isCreating ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(color: AppColors.border),
                ),
                child: const Text('Cancel'),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
