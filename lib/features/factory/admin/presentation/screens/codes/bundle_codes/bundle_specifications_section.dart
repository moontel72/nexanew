import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

class BundleSpecificationsSection extends StatelessWidget {
  final TextEditingController cartonsPerBundleController;
  final TextEditingController bundleWeightController;
  final TextEditingController bundleDimensionsController;

  const BundleSpecificationsSection({
    super.key,
    required this.cartonsPerBundleController,
    required this.bundleWeightController,
    required this.bundleDimensionsController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bundle Specifications',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: cartonsPerBundleController,
              labelText: 'Cartons per Bundle',
              hintText: 'e.g., 10',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of cartons';
                }
                final count = int.tryParse(value);
                if (count == null || count <= 0) {
                  return 'Please enter a valid number';
                }
                if (count > 100) {
                  return 'Maximum 100 cartons per bundle';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: bundleWeightController,
                    labelText: 'Bundle Weight (kg)',
                    hintText: 'e.g., 25.5',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Please enter a valid weight';
                        }
                        if (weight > 1000) {
                          return 'Weight cannot exceed 1000 kg';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: bundleDimensionsController,
                    labelText: 'Dimensions (L×W×H cm)',
                    hintText: 'e.g., 100×50×30',
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.contains('×') && !value.contains('x')) {
                          return 'Use format: L×W×H or LxWxH';
                        }
                        final parts = value
                            .replaceAll('×', 'x')
                            .split('x')
                            .map((e) => e.trim())
                            .toList();
                        if (parts.length != 3) {
                          return 'Enter all three dimensions';
                        }
                        for (final part in parts) {
                          final dim = double.tryParse(part);
                          if (dim == null || dim <= 0) {
                            return 'Invalid dimension: $part';
                          }
                          if (dim > 500) {
                            return 'Dimension cannot exceed 500 cm';
                          }
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildCalculationsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationsInfo() {
    final cartonsText = cartonsPerBundleController.text;
    final cartons = int.tryParse(cartonsText) ?? 0;

    if (cartons == 0) {
      return Container();
    }

    final totalPackets = cartons * 6; // Assuming 6 packets per carton
    final totalUnits = totalPackets * 24; // Assuming 24 units per packet

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculated Quantities:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Cartons:', style: TextStyle(fontSize: 13.sp)),
              Text(
                '$cartons',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Packets:', style: TextStyle(fontSize: 13.sp)),
              Text(
                '$totalPackets',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Units:', style: TextStyle(fontSize: 13.sp)),
              Text(
                '$totalUnits',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Note: Based on standard packing (6 packets/carton, 24 units/packet)',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

