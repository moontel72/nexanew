import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/codes/carton_codes/carton_codes_bloc.dart';
import 'package:trace_odd/shared/models/code/base_code_model.dart';
import 'package:trace_odd/shared/models/code/code_generation_request.dart';
import 'package:trace_odd/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/inputs/custom_text_field.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

import 'package:trace_odd/shared/widgets/dialogs/code_generation_success_dialog.dart';
import 'package:trace_odd/shared/widgets/dialogs/help_dialog.dart';

class CartonCodeGenerateScreen extends StatefulWidget {
  const CartonCodeGenerateScreen({super.key});

  @override
  State<CartonCodeGenerateScreen> createState() =>
      _CartonCodeGenerateScreenState();
}

class _CartonCodeGenerateScreenState extends State<CartonCodeGenerateScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countController = TextEditingController(
    text: '1',
  );
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();

  CartonCodeFormat _selectedFormat = CartonCodeFormat.qr;

  @override
  void dispose() {
    _scrollController.dispose();
    _countController.dispose();
    _batchNameController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  void _generateCodes() {
    if (_formKey.currentState!.validate()) {
      final request = CartonCodeGenerationRequest(
        factoryId: 'factory_123', // TODO: Get from auth state
        subscriptionPlanId: 'plan_premium', // TODO: Get from subscription state
        count: int.parse(_countController.text),
        prefix: _prefixController.text.isNotEmpty
            ? _prefixController.text
            : 'C',
        bundleCode: '',
        packetsPerCarton: 0,
        includeInternationalCodes: true,
        generateQrCodes: true,
        generateBarcodes: true,
        generateCartonBarcode: true,
        generateCartonQrCode: true,
        batchName: _batchNameController.text.isNotEmpty
            ? _batchNameController.text
            : null,
        codeFormat: _selectedFormat.value,
      );

      context.read<CartonCodesBloc>().add(GenerateCartonCodes(request));
    }
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => CodeGenerationSuccessDialog(
        title: 'Carton Codes Generated',
        content:
            'Successfully generated $count ${_selectedFormat.displayName} carton codes.\n\nYou can now publish and download this list for printing. Linking to bundles happens later in the Storekeeper app during scanning.',
        onOk: () => Navigator.pop(context),
        onViewCodes: () {
          Navigator.pop(context);
          context.go('/factory/codes/carton');
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const HelpDialog(
        title: 'Carton Code Generation Help',
        description:
            'Carton Codes are generated as standalone codes in the Factory Panel. They are linked to bundles later in the Storekeeper app during scanning.',
        items: [
          HelpItem(
            title: 'Code Format',
            description:
                'Select the barcode/QR format type. Each format is optimized for specific use cases (e.g., ITF-14 for industrial, DataMatrix for pharma).',
          ),
          HelpItem(
            title: 'Quantity',
            description:
                'Number of carton codes to generate in this batch (1-1000).',
          ),
          HelpItem(
            title: 'Batch Name',
            description:
                'Optional identifier for grouping codes generated together.',
          ),
          HelpItem(
            title: 'Prefix',
            description:
                'Optional code prefix for easy identification of this batch.',
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Format',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select ONE format type for this batch',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: CartonCodeFormat.values.map((format) {
                final isSelected = _selectedFormat == format;
                return ChoiceChip(
                  label: Text(format.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFormat = format;
                      });
                    }
                  },
                  selectedColor: AppColors.primary.withAlpha(30),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  avatar: isSelected
                      ? Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppColors.primary,
                        )
                      : Icon(
                          _formatIcon(format.value),
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                );
              }).toList(),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(8),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary.withAlpha(25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _selectedFormat.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _formatIcon(String format) {
    switch (format) {
      case 'itf14':
        return Icons.bar_chart;
      case 'gs1_128':
        return Icons.qr_code_scanner;
      case 'code128_industrial':
        return Icons.factory;
      case 'qr':
        return Icons.qr_code_2;
      case 'datamatrix':
        return Icons.grid_on;
      case 'code128_label':
        return Icons.label;
      default:
        return Icons.code;
    }
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generation Details',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _countController,
              labelText: 'Quantity',
              hintText: 'e.g., 500',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final count = int.tryParse(value);
                if (count == null || count <= 0) {
                  return 'Please enter a valid number';
                }
                if (count > 1000) {
                  return 'Maximum 1000 cartons per batch';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _batchNameController,
              labelText: 'Batch Name / ID (Optional)',
              hintText: 'e.g., BATCH-2024-001',
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _prefixController,
              labelText: 'Prefix (Optional)',
              hintText: 'e.g., C, CTN',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return BlocConsumer<CartonCodesBloc, CartonCodesState>(
      listener: (context, state) {
        if (state.status == CartonCodesStatus.generated) {
          _showSuccessDialog(state.generatedCount);
        }
      },
      builder: (context, state) {
        if (state.status == CartonCodesStatus.generating) {
          return const LoadingIndicator();
        }

        return PrimaryButton(
          onPressed: _generateCodes,
          text: 'Generate ${_selectedFormat.displayName} Carton Codes',
          icon: Icons.qr_code,
        );
      },
    );
  }

  Widget _buildCodePreview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Preview',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sample Carton Code:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${_prefixController.text.isNotEmpty ? _prefixController.text : "C"}-001',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Format: ${_selectedFormat.displayName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Bundle: Linked later via Storekeeper app',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_batchNameController.text.isNotEmpty)
                    Text(
                      'Batch: ${_batchNameController.text}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Generate Carton Codes',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<CartonCodesBloc, CartonCodesState>(
        builder: (context, state) {
          if (state.status == CartonCodesStatus.error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: AppColors.error,
                ),
              );
            });
          }

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormatSelector(),
                    SizedBox(height: 24.h),
                    _buildBasicInfoSection(),
                    SizedBox(height: 24.h),
                    _buildCodePreview(),
                    SizedBox(height: 24.h),
                    _buildGenerateButton(),
                    SizedBox(height: 16.h),
                    if (state.status == CartonCodesStatus.error)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(25),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.error, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                state.errorMessage ?? 'An error occurred',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
