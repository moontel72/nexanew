import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class RackAllocationScreen extends StatefulWidget {
  const RackAllocationScreen({super.key});
  @override
  State<RackAllocationScreen> createState() => _RackAllocationScreenState();
}

class _RackAllocationScreenState extends State<RackAllocationScreen> {
  final _codeC = TextEditingController();
  final _rackC = TextEditingController();
  final _sectionC = TextEditingController();
  String? _allocatedCode;
  String? _allocatedRack;
  String? _allocatedSection;
  @override
  void dispose() {
    _codeC.dispose();
    _rackC.dispose();
    _sectionC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Rack Allocation'),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.home), onPressed: () => context.go('/factory/store-keeper/dashboard')),
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 24.w),
                Gap(12.w),
                Expanded(
                  child: Text(
                    'Scan a code and assign it to a rack location.',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(24.h),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allocate Item', style: TextStyles.heading6),
                  Gap(12.h),
                  TextField(
                    controller: _codeC,
                    decoration: InputDecoration(
                      labelText: 'Item Code',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  Gap(12.h),
                  TextField(
                    controller: _rackC,
                    decoration: InputDecoration(
                      labelText: 'Rack Code',
                      prefixIcon: const Icon(Icons.warehouse),
                      hintText: 'e.g., RACK-A-12',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  Gap(12.h),
                  TextField(
                    controller: _sectionC,
                    decoration: InputDecoration(
                      labelText: 'Section Name',
                      prefixIcon: const Icon(Icons.grid_view),
                      hintText: 'e.g., Section 3',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  Gap(16.h),
                  PrimaryButton(
                    text: 'Allocate to Rack',
                    onPressed: _allocate,
                    backgroundColor: AppColors.accent,
                    icon: Icons.save,
                  ),
                ],
              ),
            ),
          ),
          Gap(16.h),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Allocation', style: TextStyles.heading6),
                  Gap(12.h),
                  if (_allocatedCode != null)
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20.w,
                          ),
                        ),
                        Gap(12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Code: $_allocatedCode',
                                style: TextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Rack: $_allocatedRack  Section: $_allocatedSection',
                                style: TextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: Text(
                        'No allocations yet',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Gap(24.h),
          OutlinedButton.icon(
            onPressed: () => context.push('/factory/store-keeper/scanner'),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Open Scanner'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    ),
  );
  void _allocate() {
    final code = _codeC.text.trim();
    final rack = _rackC.text.trim();
    final section = _sectionC.text.trim();
    if (code.isEmpty || rack.isEmpty || section.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    context.read<StoreKeeperBloc>().add(
      AllocateToRack(codeId: code, rackCode: rack, sectionName: section),
    );
    setState(() {
      _allocatedCode = code;
      _allocatedRack = rack;
      _allocatedSection = section;
    });
    _codeC.clear();
    _rackC.clear();
    _sectionC.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Allocated $code to $rack / $section'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
