import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/factory_driver_geofence_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/factory_driver_geofence_state.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/features/factory/driver/domain/utils/geo_utils.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class DriverMapTrackingScreen extends StatefulWidget {
  const DriverMapTrackingScreen({super.key});

  @override
  State<DriverMapTrackingScreen> createState() =>
      _DriverMapTrackingScreenState();
}

class _DriverMapTrackingScreenState extends State<DriverMapTrackingScreen> {
  // Simulated current position (for demo - would use GPS in production)
  double _currentLat = 24.8607;
  double _currentLng = 67.0011;
  final double _deliveryLat = 24.8610;
  final double _deliveryLng = 67.0015;

  @override
  void initState() {
    super.initState();
    // Check fake GPS on load
    context.read<DriverBloc>().add(const CheckFakeGps());
  }

  double get _distanceMeters => distanceMeters(
    fromLat: _currentLat,
    fromLng: _currentLng,
    toLat: _deliveryLat,
    toLng: _deliveryLng,
  );

  bool get _isWithinGeofence => _distanceMeters <= 100.0;

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Map Tracking (4F)',
      child: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, driverState) {
          return BlocBuilder<
            FactoryDriverGeofenceBloc,
            FactoryDriverGeofenceState
          >(
            builder: (context, geoState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Map placeholder
                  _mapPlaceholder(),
                  SizedBox(height: 16.h),

                  // Location info
                  _locationInfoCard(),
                  SizedBox(height: 12.h),

                  // Geofence status
                  _geofenceStatusCard(),
                  SizedBox(height: 12.h),

                  // Fake GPS check result
                  if (driverState is FakeGpsCheckResult)
                    _fakeGpsWarning(driverState.isSpoofingDetected),

                  SizedBox(height: 12.h),

                  // Action buttons
                  _actionButtons(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      height: 240.h,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Grid pattern to simulate map
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 64.sp,
                  color: AppColors.textSecondary.withOpacity(0.4),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Google Maps Integration',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Add google_maps_flutter package\nto enable live tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Geofence ring overlay
          Positioned(
            right: 12.w,
            bottom: 12.h,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: _isWithinGeofence
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isWithinGeofence
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _isWithinGeofence ? 'Within 100m' : 'Outside geofence',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _isWithinGeofence
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationInfoCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Location',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _locField('Latitude', _currentLat.toStringAsFixed(6)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _locField('Longitude', _currentLng.toStringAsFixed(6)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.straighten,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'Distance to delivery: ${_distanceMeters.toStringAsFixed(1)} m',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _isWithinGeofence
                      ? AppColors.success
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _geofenceStatusCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _isWithinGeofence
            ? AppColors.success.withOpacity(0.08)
            : AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isWithinGeofence
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isWithinGeofence ? Icons.check_circle : Icons.gps_off,
            color: _isWithinGeofence ? AppColors.success : AppColors.warning,
            size: 28.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isWithinGeofence
                      ? 'You are within delivery range (100m)'
                      : 'Outside delivery geofence',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _isWithinGeofence
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _isWithinGeofence
                      ? 'Scan button is unlocked (4C). Multi-source GPS verification active (4V).'
                      : 'Scan button locked until within 100m. Or request recipient confirmation (4D).',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeGpsWarning(bool detected) {
    if (!detected) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.error, size: 24.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Fake GPS detected! (4S) Third-party location spoofing app found. '
              'Please disable it to continue using the app.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: _isWithinGeofence
              ? 'Proceed to Delivery Scan'
              : 'Request Recipient Confirmation (4D)',
          onPressed: () {
            if (_isWithinGeofence) {
              Navigator.of(context).pushNamed('/factory/driver/delivery-scan');
            } else {
              Navigator.of(
                context,
              ).pushNamed('/factory/driver/location-confirm');
            }
          },
        ),
        SizedBox(height: 10.h),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              // Simulate moving closer
              _currentLat += 0.0003;
              _currentLng += 0.0003;
            });
            context.read<DriverBloc>().add(
              UpdateDriverLocation(
                tripId: 'current',
                lat: _currentLat,
                lng: _currentLng,
              ),
            );
          },
          icon: const Icon(Icons.near_me),
          label: const Text('Simulate Move Closer (Demo)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ],
    );
  }
}
