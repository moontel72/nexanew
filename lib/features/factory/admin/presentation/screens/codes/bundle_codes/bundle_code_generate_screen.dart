import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/bundle_codes/bundle_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';

import 'bundle_specifications_section.dart';

class BundleCodeGenerateScreen extends StatefulWidget {
  const BundleCodeGenerateScreen({super.key});

  @override
  State<BundleCodeGenerateScreen> createState() =>
      _BundleCodeGenerateScreenState();
}

class _BundleCodeGenerateScreenState extends State<BundleCodeGenerateScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countController = TextEditingController(
    text: '1',
  );
  final TextEditingController _prefixController = TextEditingController(
    text: 'A',
  );
  final TextEditingController _cartonsPerBundleController =
      TextEditingController(text: '10');
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _batchNotesController = TextEditingController();
  final TextEditingController _bundleWeightController = TextEditingController();
  final TextEditingController _bundleDimensionsController =
      TextEditingController();
  final TextEditingController _storageLocationController =
      TextEditingController();
  final TextEditingController _shippingMethodController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _handlingInstructionsController =
      TextEditingController();
  final TextEditingController _customsDeclarationController =
      TextEditingController();
  final TextEditingController _insuranceValueController =
      TextEditingController();

  bool _includeInternationalCodes = true;
  bool _generateQrCodes = true;
  bool _generateBarcodes = true;
  int _priority = 2;
  DateTime? _expectedDeliveryDate;

  @override
  void dispose() {
    _scrollController.dispose();
    _countController.dispose();
    _prefixController.dispose();
    _cartonsPerBundleController.dispose();
    _batchNameController.dispose();
    _batchNotesController.dispose();
    _bundleWeightController.dispose();
    _bundleDimensionsController.dispose();
    _storageLocationController.dispose();
    _shippingMethodController.dispose();
    _categoryController.dispose();
    _handlingInstructionsController.dispose();
    _customsDeclarationController.dispose();
    _insuranceValueController.dispose();
    super.dispose();
  }

  Future<void> _selectExpectedDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expectedDeliveryDate) {
      setState(() {
        _expectedDeliveryDate = picked;
      });
    }
  }

  void _generateCodes() {
    if (_formKey.currentState!.validate()) {
      final request = BundleCodeGenerationRequest(
        factoryId: 'factory_123', // TODO: Get from auth state
        subscriptionPlanId: 'plan_premium', // TODO: Get from subscription state
        count: int.parse(_countController.text),
        prefix: 'B',
        includeInternationalCodes: true,
        generateQrCodes: true,
        generateBarcodes: true,
        cartonsPerBundle: 0,
        priority: 2,
      );

      context.read<BundleCodesBloc>().add(GenerateBundleCodes(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Generate Bundle Codes',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<BundleCodesBloc, BundleCodesState>(
        listener: (context, state) {
          if (state.generationStatus == CodeGenerationStatus.success) {
            _showSuccessDialog(context, state);
          } else if (state.generationStatus == CodeGenerationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Failed to generate codes'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.generationStatus == CodeGenerationStatus.generating) {
            return const Center(child: LoadingIndicator());
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
                    SizedBox(height: 32.h),
                    _buildGenerateButton(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _countController,
              labelText: 'Quantity',
              hintText: 'e.g., 50',
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
                  return 'Maximum 1000 bundles per batch';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _storageLocationController,
                    labelText: 'Storage Location',
                    hintText: 'e.g., Warehouse A, Shelf 5',
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: _shippingMethodController,
                    labelText: 'Shipping Method',
                    hintText: 'e.g., Express, Standard',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectExpectedDeliveryDate(context),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        labelText: 'Expected Delivery Date',
                        hintText: 'Select date',
                        controller: TextEditingController(
                          text: _expectedDeliveryDate != null
                              ? '${_expectedDeliveryDate!.year}-${_expectedDeliveryDate!.month.toString().padLeft(2, '0')}-${_expectedDeliveryDate!.day.toString().padLeft(2, '0')}'
                              : '',
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: _customsDeclarationController,
                    labelText: 'Customs Declaration No.',
                    hintText: 'For international shipping',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _insuranceValueController,
              labelText: 'Insurance Value (\$)',
              hintText: 'e.g., 1000.00',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _categoryController,
              labelText: 'Category',
              hintText: 'e.g., Electronics, Food, Medical',
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _handlingInstructionsController,
              labelText: 'Handling Instructions',
              hintText: 'Special handling requirements',
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            _buildPrioritySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildPriorityOption(1, 'High', Colors.red),
            SizedBox(width: 12.w),
            _buildPriorityOption(2, 'Medium', Colors.orange),
            SizedBox(width: 12.w),
            _buildPriorityOption(3, 'Low', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityOption(int value, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _priority = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: _priority == value
                ? color.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: _priority == value ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.flag,
                color: _priority == value ? color : Colors.grey,
                size: 24.w,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: _priority == value ? color : Colors.grey,
                  fontWeight: _priority == value
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeOptionsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Options',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            SwitchListTile(
              title: const Text('Include International Codes (GS1)'),
              subtitle: const Text(
                'Add international standard codes alongside store keeper codes',
              ),
              value: _includeInternationalCodes,
              onChanged: (value) {
                setState(() {
                  _includeInternationalCodes = value;
                });
              },
              secondary: const Icon(Icons.language),
            ),
            SwitchListTile(
              title: const Text('Generate QR Codes'),
              subtitle: const Text('Create QR codes for each bundle code'),
              value: _generateQrCodes,
              onChanged: (value) {
                setState(() {
                  _generateQrCodes = value;
                });
              },
              secondary: const Icon(Icons.qr_code),
            ),
            SwitchListTile(
              title: const Text('Generate Barcodes'),
              subtitle: const Text('Create barcodes for each bundle code'),
              value: _generateBarcodes,
              onChanged: (value) {
                setState(() {
                  _generateBarcodes = value;
                });
              },
              secondary: const Icon(Icons.qr_code_scanner),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BundleCodesState state) {
    return PrimaryButton(
      onPressed: _generateCodes,
      text: 'Generate Bundle Codes',
      isLoading: state.generationStatus == CodeGenerationStatus.generating,
      icon: Icons.generating_tokens,
    );
  }

  Widget _buildCodePreview(BundleCodesState state) {
    if (state.lastGeneratedBatchId == null) {
      return Container();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Generated Batch',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${state.lastGeneratedCount} codes'),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Batch ID: ${state.lastGeneratedBatchId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to codes list
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View Codes'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Download codes
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, BundleCodesState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Codes Generated Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${state.lastGeneratedCount} bundle codes have been generated.',
            ),
            SizedBox(height: 8.h),
            Text(
              'Batch ID: ${state.lastGeneratedBatchId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            const Text('What would you like to do next?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/factory/codes/bundle');
            },
            child: const Text('View Codes'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Download codes
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Colors.blue),
            SizedBox(width: 8),
            Text('Bundle Code Generation Help'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bundle Codes are the highest level in the packaging hierarchy:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text('• 1 Bundle contains multiple Cartons'),
              const Text('• 1 Carton contains multiple Packets'),
              const Text('• 1 Packet contains multiple Units'),
              SizedBox(height: 16.h),
              const Text(
                'Code Format:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text('Example: A-01, A-02, A-03, etc.'),
              SizedBox(height: 8.h),
              const Text('Where:'),
              const Text('  • A = Prefix (customizable)'),
              const Text('  • 01 = Sequence number'),
              SizedBox(height: 16.h),
              const Text(
                'International Codes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text('Bundle codes include both:'),
              const Text('  • Store Keeper Code (internal)'),
              const Text('  • International Standard Code (GS1)'),
              SizedBox(height: 16.h),
              const Text(
                'Important Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text('• Codes can be deleted before publishing'),
              const Text('• After publishing, codes cannot be deleted'),
              const Text(
                '• Each code generation counts toward subscription limits',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
