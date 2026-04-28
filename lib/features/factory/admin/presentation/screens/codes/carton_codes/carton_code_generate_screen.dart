import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/carton_codes/carton_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';

import 'package:nexatrace_system/shared/widgets/dialogs/code_generation_success_dialog.dart';
import 'package:nexatrace_system/shared/widgets/dialogs/help_dialog.dart';

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
  final TextEditingController _prefixController = TextEditingController(
    text: 'C',
  );
  final TextEditingController _packetsPerCartonController =
      TextEditingController(text: '10');
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _batchNotesController = TextEditingController();
  final TextEditingController _cartonWeightController = TextEditingController();
  final TextEditingController _cartonDimensionsController =
      TextEditingController();
  final TextEditingController _cartonTypeController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _maxWeightCapacityController =
      TextEditingController();
  final TextEditingController _temperatureRequirementsController =
      TextEditingController();
  final TextEditingController _handlingInstructionsController =
      TextEditingController();

  bool _includeInternationalCodes = true;
  bool _generateQrCodes = true;
  bool _generateBarcodes = true;
  bool _generateCartonBarcode = true;
  bool _generateCartonQrCode = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _countController.dispose();
    _prefixController.dispose();
    _packetsPerCartonController.dispose();
    _batchNameController.dispose();
    _batchNotesController.dispose();
    _cartonWeightController.dispose();
    _cartonDimensionsController.dispose();
    _cartonTypeController.dispose();
    _gradeController.dispose();
    _maxWeightCapacityController.dispose();
    _temperatureRequirementsController.dispose();
    _handlingInstructionsController.dispose();
    super.dispose();
  }

  void _generateCodes() {
    if (_formKey.currentState!.validate()) {
      final request = CartonCodeGenerationRequest(
        factoryId: 'factory_123', // TODO: Get from auth state
        subscriptionPlanId: 'plan_premium', // TODO: Get from subscription state
        count: int.parse(_countController.text),
        prefix: 'C',
        bundleCode: '',
        packetsPerCarton: 0,
        includeInternationalCodes: true,
        generateQrCodes: true,
        generateBarcodes: true,
        generateCartonBarcode: true,
        generateCartonQrCode: true,
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
            'Successfully generated $count carton codes.\n\nYou can now publish and download this list for printing. Linking to bundles happens later in the Storekeeper app during scanning.',
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
            title: 'Packets per Carton',
            description:
                'Number of packets that will be contained in each carton. Typically 10-20 packets.',
          ),
          HelpItem(
            title: 'Carton Specifications',
            description:
                'Weight, dimensions, type, and grade help in logistics and handling.',
          ),
          HelpItem(
            title: 'Temperature Requirements',
            description:
                'For temperature-sensitive products (e.g., food, medicine).',
          ),
          HelpItem(
            title: 'Carton Barcode/QR Code',
            description:
                'Separate codes for carton tracking independent of product codes.',
          ),
        ],
      ),
    );
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
              'Basic Information',
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
          ],
        ),
      ),
    );
  }

  Widget _buildCartonSpecificationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carton Specifications',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cartonWeightController,
                    labelText: 'Weight (kg)',
                    hintText: 'e.g., 5.0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: _cartonDimensionsController,
                    labelText: 'Dimensions (LxWxH cm)',
                    hintText: 'e.g., 30x20x15',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cartonTypeController,
                    labelText: 'Carton Type',
                    hintText: 'e.g., Corrugated, Cardboard, Plastic',
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: _gradeController,
                    labelText: 'Grade/Quality',
                    hintText: 'e.g., A, B, Premium',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _maxWeightCapacityController,
              labelText: 'Max Weight Capacity (kg)',
              hintText: 'e.g., 20.0',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandlingRequirementsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Handling & Requirements',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _temperatureRequirementsController,
              labelText: 'Temperature Requirements',
              hintText: 'e.g., 15-25°C, Keep Frozen',
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _handlingInstructionsController,
              labelText: 'Handling Instructions',
              hintText: 'e.g., Fragile, This Side Up, Keep Dry',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeOptionsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Options',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            SwitchListTile(
              title: Text(
                'Include International Codes (GS1)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Add GS1-compliant international codes',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _includeInternationalCodes,
              onChanged: (value) {
                setState(() {
                  _includeInternationalCodes = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: Text(
                'Generate QR Codes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Generate QR codes for product verification',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _generateQrCodes,
              onChanged: (value) {
                setState(() {
                  _generateQrCodes = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: Text(
                'Generate Barcodes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Generate barcodes for scanning',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _generateBarcodes,
              onChanged: (value) {
                setState(() {
                  _generateBarcodes = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: Text(
                'Generate Carton Barcode',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Separate barcode for carton tracking',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _generateCartonBarcode,
              onChanged: (value) {
                setState(() {
                  _generateCartonBarcode = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: Text(
                'Generate Carton QR Code',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Separate QR code for carton tracking',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _generateCartonQrCode,
              onChanged: (value) {
                setState(() {
                  _generateCartonQrCode = value;
                });
              },
              activeThumbColor: AppColors.primary,
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
          text: 'Generate Carton Codes',
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
                    'Bundle: Linked later via Storekeeper app',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Packets: ${_packetsPerCartonController.text.isNotEmpty ? _packetsPerCartonController.text : "10"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Total Units: ${_packetsPerCartonController.text.isNotEmpty ? (int.parse(_packetsPerCartonController.text) * 12).toString() : "120"}',
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
                    _buildBasicInfoSection(),
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
