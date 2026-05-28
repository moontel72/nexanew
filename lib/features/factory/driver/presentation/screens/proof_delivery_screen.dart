import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trace_odd/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/inputs/custom_text_field.dart';

class ProofDeliveryScreen extends StatefulWidget {
  const ProofDeliveryScreen({super.key});

  @override
  State<ProofDeliveryScreen> createState() => _ProofDeliveryScreenState();
}

class _ProofDeliveryScreenState extends State<ProofDeliveryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _pinC = TextEditingController();
  PlatformFile? _recipientPhoto;
  PlatformFile? _documentPhoto;
  PlatformFile? _signatureImage;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _pinC.dispose();
    super.dispose();
  }

  Future<void> _pickImage(void Function(PlatformFile?) setter) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );
    final file = result?.files.isNotEmpty == true ? result!.files.first : null;
    if (!mounted) return;
    setter(file);
  }

  void _submit() {
    final idx = _tabs.index;
    final ok = switch (idx) {
      0 => _pinC.text.trim().isNotEmpty,
      1 => _recipientPhoto != null && _documentPhoto != null,
      2 => _signatureImage != null,
      _ => false,
    };
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete required POD fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Proof of Delivery saved (stub).'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Proof of Delivery',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'PIN'),
                Tab(text: 'Photo'),
                Tab(text: 'Signature'),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 260.h,
            child: TabBarView(
              controller: _tabs,
              children: [
                _pinTab(),
                _photoTab(),
                _signatureTab(),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          PrimaryButton(text: 'Submit POD', onPressed: _submit),
        ],
      ),
    );
  }

  Widget _pinTab() {
    return Column(
      children: [
        CustomTextField(
          controller: _pinC,
          labelText: 'Recipient PIN',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.h),
        Text(
          'Ask recipient for PIN and enter it here.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _photoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fileRow(
          label: 'Recipient holding document',
          fileName: _recipientPhoto?.name,
          onPick: () => _pickImage((f) => setState(() => _recipientPhoto = f)),
        ),
        SizedBox(height: 12.h),
        _fileRow(
          label: 'Document photo (clear)',
          fileName: _documentPhoto?.name,
          onPick: () => _pickImage((f) => setState(() => _documentPhoto = f)),
        ),
      ],
    );
  }

  Widget _signatureTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fileRow(
          label: 'Signature image',
          fileName: _signatureImage?.name,
          onPick: () =>
              _pickImage((f) => setState(() => _signatureImage = f)),
        ),
        SizedBox(height: 12.h),
        Text(
          'Signature pad can be added later; this is a minimal placeholder.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _fileRow({
    required String label,
    required String? fileName,
    required VoidCallback onPick,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4.h),
                Text(
                  fileName ?? 'No file selected',
                  style: TextStyle(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file),
            label: const Text('Pick'),
          ),
        ],
      ),
    );
  }
}

