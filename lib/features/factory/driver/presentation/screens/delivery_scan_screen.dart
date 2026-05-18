import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/factory_driver_geofence_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/factory_driver_geofence_event.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/factory_driver_geofence_state.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

class DeliveryScanScreen extends StatefulWidget {
  const DeliveryScanScreen({super.key});

  @override
  State<DeliveryScanScreen> createState() => _DeliveryScanScreenState();
}

class _DeliveryScanScreenState extends State<DeliveryScanScreen> {
  final _deliveryLatC = TextEditingController(text: '24.8607');
  final _deliveryLngC = TextEditingController(text: '67.0011');
  final _currentLatC = TextEditingController(text: '24.8607');
  final _currentLngC = TextEditingController(text: '67.0011');

  @override
  void dispose() {
    _deliveryLatC.dispose();
    _deliveryLngC.dispose();
    _currentLatC.dispose();
    _currentLngC.dispose();
    super.dispose();
  }

  void _applyLocations(BuildContext context) {
    final dLat = double.tryParse(_deliveryLatC.text.trim());
    final dLng = double.tryParse(_deliveryLngC.text.trim());
    final cLat = double.tryParse(_currentLatC.text.trim());
    final cLng = double.tryParse(_currentLngC.text.trim());

    if (dLat == null || dLng == null || cLat == null || cLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid lat/lng values'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final bloc = context.read<FactoryDriverGeofenceBloc>();
    bloc.add(SetDeliveryLocation(deliveryLat: dLat, deliveryLng: dLng));
    bloc.add(SetCurrentLocation(currentLat: cLat, currentLng: cLng));
  }

  Future<void> _scan(BuildContext context) async {
    final code = await context.push<String>('/factory/store-keeper/scanner');
    if (!mounted) return;
    if (code == null || code.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivery scan: $code'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Delivery Scan',
      actions: [
        IconButton(
          onPressed: () => _applyLocations(context),
          icon: const Icon(Icons.refresh),
          tooltip: 'Recalculate',
        ),
      ],
      child: BlocBuilder<FactoryDriverGeofenceBloc, FactoryDriverGeofenceState>(
        builder: (context, state) {
          final distance = state.distanceMeters;
          final distanceText = distance == null
              ? 'Distance: unknown'
              : 'Distance: ${distance.toStringAsFixed(1)} m';
          final unlockedText = state.scanUnlocked
              ? 'Scan unlocked'
              : 'Scan locked (need within 100m)';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(distanceText),
              SizedBox(height: 4.h),
              Text(
                unlockedText,
                style: TextStyle(
                  color: state.scanUnlocked
                      ? AppColors.success
                      : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              _coordsCard(),
              SizedBox(height: 12.h),
              PrimaryButton(
                text: 'Apply Coordinates',
                onPressed: () => _applyLocations(context),
              ),
              SizedBox(height: 12.h),
              if (state.scanUnlocked)
                PrimaryButton(
                  text: 'Scan Delivery Product',
                  onPressed: () => _scan(context),
                )
              else
                PrimaryButton(
                  text: 'Request Recipient Confirmation',
                  onPressed: () => context.push('/location-confirm'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _coordsCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _deliveryLatC,
                  labelText: 'Delivery lat',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: _deliveryLngC,
                  labelText: 'Delivery lng',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _currentLatC,
                  labelText: 'Current lat',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField(
                  controller: _currentLngC,
                  labelText: 'Current lng',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
