import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/factory_driver_geofence_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/factory_driver_geofence_event.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class LocationConfirmScreen extends StatefulWidget {
  const LocationConfirmScreen({super.key});

  @override
  State<LocationConfirmScreen> createState() => _LocationConfirmScreenState();
}

class _LocationConfirmScreenState extends State<LocationConfirmScreen> {
  PlatformFile? _photo;

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );
    final file = result?.files.isNotEmpty == true ? result!.files.first : null;
    if (!mounted) return;
    setState(() => _photo = file);
  }

  void _confirm() {
    context.read<FactoryDriverGeofenceBloc>().add(const SetRecipientOverride(true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recipient confirmed. Scan unlocked.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Location Confirm',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _photo == null
                  ? 'Upload a photo of recipient location to request confirmation.'
                  : 'Selected: ${_photo!.name}',
            ),
          ),
          SizedBox(height: 12.h),
          PrimaryButton(text: 'Upload Photo', onPressed: _pickPhoto),
          SizedBox(height: 12.h),
          PrimaryButton(
            text: 'Recipient Confirmed',
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}

