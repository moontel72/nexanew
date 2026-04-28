//lib/features/factory/admin/presentation/screens/codes/packet_codes/packet_code_generate_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/features/factory/admin/presentation/bloc/codes/packet_codes/packet_codes_bloc.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';
import 'package:nexatrace_system/shared/widgets/app_bars/custom_app_bar.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

import 'package:nexatrace_system/shared/widgets/dialogs/code_generation_success_dialog.dart';
import 'package:nexatrace_system/shared/widgets/dialogs/help_dialog.dart';

class PacketCodeGenerateScreen extends StatefulWidget {
  const PacketCodeGenerateScreen({super.key});

  @override
  State<PacketCodeGenerateScreen> createState() =>
      _PacketCodeGenerateScreenState();
}

class _PacketCodeGenerateScreenState extends State<PacketCodeGenerateScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countController = TextEditingController(
    text: '1',
  );
  final TextEditingController _prefixController = TextEditingController(
    text: 'P',
  );
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _batchNotesController = TextEditingController();
  final TextEditingController _packetWeightController = TextEditingController();
  final TextEditingController _packetDimensionsController =
      TextEditingController();
  final TextEditingController _packetTypeController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _sealingMethodController =
      TextEditingController();

  bool _includeInternationalCodes = true;
  bool _generateQrCodes = true;
  bool _generateBarcodes = true;
  bool _generatePacketBarcode = true;
  bool _generatePacketQrCode = true;
  bool _includeTamperEvidence = false;
  bool _includeChildSafety = false;
  bool _includeInstructions = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _countController.dispose();
    _prefixController.dispose();
    _batchNameController.dispose();
    _batchNotesController.dispose();
    _packetWeightController.dispose();
    _packetDimensionsController.dispose();
    _packetTypeController.dispose();
    _materialController.dispose();
    _sealingMethodController.dispose();
    super.dispose();
  }

  void _generateCodes() {
    if (_formKey.currentState!.validate()) {
      final request = PacketCodeGenerationRequest(
        factoryId: 'factory_123', // TODO: Get from auth state
        subscriptionPlanId: 'plan_premium', // TODO: Get from subscription state
        count: int.parse(_countController.text),
        prefix: 'P',
        cartonCode: '',
        unitsPerPacket: 0,
        includeInternationalCodes: true,
        generateQrCodes: true,
        generateBarcodes: true,
        includeTamperEvidence: false,
        includeChildSafety: false,
        includeInstructions: true,
        generatePacketBarcode: true,
        generatePacketQrCode: true,
      );

      context.read<PacketCodesBloc>().add(GeneratePacketCodes(request));
    }
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => CodeGenerationSuccessDialog(
        title: 'Packet Codes Generated',
        content:
            'Successfully generated $count packet codes.\n\nYou can now publish and download this list for printing. Linking to cartons/bundles happens later in the Storekeeper app during scanning.',
        onOk: () => Navigator.pop(context),
        onViewCodes: () {
          Navigator.pop(context);
          context.go('/factory/codes/packet');
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const HelpDialog(
        title: 'Packet Code Generation Help',
        description:
            'Packet Codes are generated as standalone codes in the Factory Panel. They are linked to cartons/bundles later in the Storekeeper app during scanning.',
        items: [
          HelpItem(
            title: 'Packet Specifications',
            description:
                'Weight, dimensions, type, and material help in product identification and handling.',
          ),
          HelpItem(
            title: 'Safety Features',
            description:
                'Tamper evidence and child safety features for regulated products.',
          ),
          HelpItem(
            title: 'Packet Barcode/QR Code',
            description:
                'Separate codes for packet tracking independent of product codes.',
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
                if (count > 5000) {
                  return 'Maximum 5000 packets per batch';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPacketSpecificationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Packet Specifications',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _packetWeightController,
                    labelText: 'Weight (grams)',
                    hintText: 'e.g., 50.0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: _packetDimensionsController,
                    labelText: 'Dimensions (LxWxH cm)',
                    hintText: 'e.g., 10x8x2',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _packetTypeController,
                    labelText: 'Packet Type',
                    hintText: 'e.g., Blister, Box, Pouch, Bottle',
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: _materialController,
                    labelText: 'Material',
                    hintText: 'e.g., Plastic, Paper, Aluminum',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _sealingMethodController,
              labelText: 'Sealing Method (Optional)',
              hintText: 'e.g., Heat Seal, Adhesive, Clip',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFeaturesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Features',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            SwitchListTile(
              title: Text(
                'Include Tamper Evidence',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Add tamper-evident seals to packets',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _includeTamperEvidence,
              onChanged: (value) {
                setState(() {
                  _includeTamperEvidence = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: Text(
                'Include Child Safety Features',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Add child-resistant packaging features',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _includeChildSafety,
              onChanged: (value) {
                setState(() {
                  _includeChildSafety = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: Text(
                'Include Instructions',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Include usage instructions with packets',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _includeInstructions,
              onChanged: (value) {
                setState(() {
                  _includeInstructions = value;
                });
              },
              activeThumbColor: AppColors.primary,
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
                'Generate Packet Barcode',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Separate barcode for packet tracking',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              value: _generatePacketBarcode,
              onChanged: (value) {
                setState(() {
                  _generatePacketBarcode = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
            SwitchListTile(
              title: Text(
                'Generate Packet QR Code',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Separate QR code for packet tracking',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _generatePacketQrCode,
              onChanged: (value) {
                setState(() {
                  _generatePacketQrCode = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PacketCodesBloc, PacketCodesState>(
      listener: (context, state) {
        if (state.status == PacketCodesStatus.generated) {
          _showSuccessDialog(state.generatedCount);
        } else if (state.status == PacketCodesStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Generate Packet Codes',
            actions: [
              IconButton(
                onPressed: _showHelpDialog,
                icon: const Icon(Icons.help_outline, color: Colors.white),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildBasicInfoSection(),
                    SizedBox(height: 32.h),
                    PrimaryButton(
                      onPressed: _generateCodes,
                      text: 'Generate Codes',
                      isLoading: state.status == PacketCodesStatus.generating,
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
