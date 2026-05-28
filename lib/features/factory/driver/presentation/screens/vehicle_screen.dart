import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/factory_driver.dart';
import 'package:trace_odd/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/inputs/custom_text_field.dart';

class DriverVehicleScreen extends StatefulWidget {
  const DriverVehicleScreen({super.key});

  @override
  State<DriverVehicleScreen> createState() => _DriverVehicleScreenState();
}

class _DriverVehicleScreenState extends State<DriverVehicleScreen> {
  final _plateC = TextEditingController();
  final _startMeterC = TextEditingController();
  final _deliveryMeterC = TextEditingController();
  final _returnMeterC = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadVehicleInfo());
  }

  @override
  void dispose() {
    _plateC.dispose();
    _startMeterC.dispose();
    _deliveryMeterC.dispose();
    _returnMeterC.dispose();
    super.dispose();
  }

  void _saveMeterReadings() {
    final start = double.tryParse(_startMeterC.text);
    final delivery = double.tryParse(_deliveryMeterC.text);
    final ret = double.tryParse(_returnMeterC.text);
    context.read<DriverBloc>().add(
      UpdateMeterReadings(
        tripId: '',
        meterStart: start,
        meterDelivery: delivery,
        meterReturn: ret,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meter readings saved'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Vehicle',
      actions: [
        IconButton(
          onPressed: () => context.push('/factory/driver/maintenance'),
          icon: const Icon(Icons.build_outlined),
          tooltip: 'Maintenance Log',
        ),
        IconButton(
          onPressed: () => context.push('/factory/driver/compliance'),
          icon: const Icon(Icons.verified_user_outlined),
          tooltip: 'Compliance',
        ),
      ],
      child: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          if (state is DriverLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DriverError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  state.message,
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Info Card
              if (state is VehicleInfoLoaded) ...[
                _vehicleInfoCard(state.vehicle),
                SizedBox(height: 16.h),
              ],

              // Meter Readings Section
              _meterReadingsCard(state),
              SizedBox(height: 16.h),

              // Quick Actions
              _quickActions(),
            ],
          );
        },
      ),
    );
  }

  Widget _vehicleInfoCard(FactoryDriver driver) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.vehiclePlateNumber ?? 'No plate number',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      driver.vehicleType ?? 'Unknown type',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  'Insurance',
                  driver.insuranceNumber,
                  driver.insuranceExpiry,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _infoChip(
                  'Registration',
                  'Active',
                  driver.registrationExpiry,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String? value, DateTime? expiry) {
    final isExpired = expiry != null && expiry.isBefore(DateTime.now());
    final isExpiring =
        expiry != null &&
        expiry.isAfter(DateTime.now()) &&
        expiry.difference(DateTime.now()).inDays <= 30;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.error.withOpacity(0.08)
            : isExpiring
            ? AppColors.warning.withOpacity(0.08)
            : AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 2.h),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (expiry != null)
            Text(
              DateFormat('MMM dd, yyyy').format(expiry),
              style: TextStyle(
                fontSize: 10.sp,
                color: isExpired
                    ? AppColors.error
                    : isExpiring
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _meterReadingsCard(DriverState state) {
    // Pre-fill from VehicleInfoLoaded state
    if (state is VehicleInfoLoaded) {
      final driver = state.vehicle;
      if (_plateC.text.isEmpty && driver.vehiclePlateNumber != null) {
        _plateC.text = driver.vehiclePlateNumber!;
      }
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Meter Readings (4J)',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            controller: _plateC,
            labelText: 'Plate Number',
            prefixIcon: const Icon(Icons.directions_car),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _startMeterC,
                  labelText: 'Start Meter',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.play_arrow),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomTextField(
                  controller: _deliveryMeterC,
                  labelText: 'Delivery Meter',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CustomTextField(
            controller: _returnMeterC,
            labelText: 'Return Meter (back to factory)',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.replay),
          ),
          SizedBox(height: 12.h),
          PrimaryButton(
            text: 'Save Meter Readings',
            onPressed: _saveMeterReadings,
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon: Icons.build,
                label: 'Maintenance\nLog (4Q)',
                color: AppColors.primary,
                onTap: () => context.push('/factory/driver/maintenance'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _actionCard(
                icon: Icons.verified_user,
                label: 'Compliance\nDocs (4Y)',
                color: AppColors.success,
                onTap: () => context.push('/factory/driver/compliance'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _actionCard(
                icon: Icons.receipt,
                label: 'Expenses\n(4K-4O)',
                color: AppColors.warning,
                onTap: () => context.push('/factory/driver/expenses'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
