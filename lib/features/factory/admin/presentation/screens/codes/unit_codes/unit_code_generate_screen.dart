import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/core/utils/auth_state.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/unit_codes/unit_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/dialogs/code_generation_success_dialog.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

class UnitCodeGenerateScreen extends StatefulWidget {
  const UnitCodeGenerateScreen({super.key});

  @override
  State<UnitCodeGenerateScreen> createState() => _UnitCodeGenerateScreenState();
}

class _UnitCodeGenerateScreenState extends State<UnitCodeGenerateScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _countController = TextEditingController(text: '10');
  final _prefixController = TextEditingController(text: 'U');
  final _batchNameController = TextEditingController();
  final _batchNotesController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _countController.dispose();
    _prefixController.dispose();
    _batchNameController.dispose();
    _batchNotesController.dispose();
    super.dispose();
  }

  void _generate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = UnitCodeGenerationRequest(
      factoryId: getFactoryId() ?? '',
      subscriptionPlanId: '',
      count: int.parse(_countController.text),
      prefix: _prefixController.text.trim(),
      packetCode: '',
      batchName: _batchNameController.text.trim().isEmpty
          ? null
          : _batchNameController.text.trim(),
      batchNotes: _batchNotesController.text.trim().isEmpty
          ? null
          : _batchNotesController.text.trim(),
    );

    context.read<UnitCodesBloc>().add(GenerateUnitCodes(request));
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => CodeGenerationSuccessDialog(
        title: 'Unit Codes Generated',
        content:
            'Successfully generated $count unit codes.\n\nYou can now review and export codes from the list.',
        onOk: () => Navigator.pop(context),
        onViewCodes: () {
          Navigator.pop(context);
          context.go('/factory/codes/unit');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Generate Unit Codes',
        onBackPressed: () => context.go('/factory/codes/unit'),
      ),
      body: BlocListener<UnitCodesBloc, UnitCodesState>(
        listener: (context, state) {
          if (state.status == UnitCodesStatus.generated) {
            _showSuccessDialog(state.generatedCount);
          }
        },
        child: SafeArea(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 28.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _countController,
                      labelText: 'Count',
                      hintText: 'How many unit codes to generate',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = int.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a number';
                        }
                        if (parsed > 50000) return 'Max 50000 per batch';
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      controller: _prefixController,
                      labelText: 'Prefix',
                      hintText: 'Example: U',
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return 'Enter a prefix';
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      controller: _batchNameController,
                      labelText: 'Batch Name',
                      hintText: 'Optional',
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      controller: _batchNotesController,
                      labelText: 'Batch Notes',
                      hintText: 'Optional',
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),
                    BlocBuilder<UnitCodesBloc, UnitCodesState>(
                      builder: (context, state) {
                        final isBusy =
                            state.status == UnitCodesStatus.generating;
                        return SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            onPressed: _generate,
                            isEnabled: !isBusy,
                            isLoading: isBusy,
                            text: 'Generate Unit Codes',
                            icon: Icons.qr_code_2,
                            backgroundColor: AppColors.secondary,
                            textColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

