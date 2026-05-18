import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/inputs/custom_text_field.dart';

class DriverMaintenanceScreen extends StatefulWidget {
  const DriverMaintenanceScreen({super.key});

  @override
  State<DriverMaintenanceScreen> createState() =>
      _DriverMaintenanceScreenState();
}

class _DriverMaintenanceScreenState extends State<DriverMaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadVehicleInfo());
  }

  void _showAddLogSheet() {
    final bloc = context.read<DriverBloc>();
    String selectedType = 'service';
    DateTime serviceDate = DateTime.now();
    DateTime? nextServiceDate;
    final mileageCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.gray300,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Add Maintenance Log',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Type dropdown
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.inputBackground,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'service',
                                child: Text('🔧 Service'),
                              ),
                              DropdownMenuItem(
                                value: 'tire',
                                child: Text('🛞 Tire'),
                              ),
                              DropdownMenuItem(
                                value: 'battery',
                                child: Text('🔋 Battery'),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text('📋 Other'),
                              ),
                            ],
                            onChanged: (v) {
                              setSheetState(() => selectedType = v!);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      // Service date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: serviceDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() => serviceDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                DateFormat('MMM d, yyyy').format(serviceDate),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              const Spacer(),
                              Text(
                                'Service Date',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Next service date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: nextServiceDate ?? serviceDate,
                            firstDate: serviceDate,
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() => nextServiceDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event,
                                color: nextServiceDate != null
                                    ? AppColors.secondary
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                nextServiceDate != null
                                    ? DateFormat(
                                        'MMM d, yyyy',
                                      ).format(nextServiceDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: nextServiceDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Next Service',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      // Mileage
                      CustomTextField(
                        controller: mileageCtrl,
                        labelText: 'Mileage (km)',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.speed),
                      ),
                      SizedBox(height: 14.h),
                      // Notes
                      CustomTextField(
                        controller: notesCtrl,
                        labelText: 'Notes (optional)',
                        maxLines: 3,
                      ),
                      SizedBox(height: 20.h),
                      PrimaryButton(
                        text: 'Add Log',
                        onPressed: () {
                          bloc.add(
                            AddMaintenanceLog(
                              type: selectedType,
                              serviceDate: serviceDate,
                              nextServiceDate: nextServiceDate,
                              mileage: double.tryParse(mileageCtrl.text.trim()),
                              notes: notesCtrl.text.trim().isNotEmpty
                                  ? notesCtrl.text.trim()
                                  : null,
                            ),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Maintenance log added!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'service':
        return Icons.build_circle;
      case 'tire':
        return Icons.tire_repair;
      case 'battery':
        return Icons.battery_charging_full;
      default:
        return Icons.miscellaneous_services;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'service':
        return 'Service';
      case 'tire':
        return 'Tire Change';
      case 'battery':
        return 'Battery';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Maintenance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Service due warning banner
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is! MaintenanceLogsLoaded) {
                return const SizedBox.shrink();
              }
              final logs = state.logs;
              final overdue = logs.where((log) {
                return log.nextServiceDate.isBefore(DateTime.now());
              }).toList();

              if (overdue.isNotEmpty) {
                return Container(
                  margin: EdgeInsets.only(bottom: 14.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 22.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '⚠️ Service overdue! ${overdue.length} maintenance item(s) require immediate attention.',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Add log button
          PrimaryButton(
            text: '+ Add Maintenance Log',
            onPressed: _showAddLogSheet,
            width: double.infinity,
            height: 44.h,
            borderRadius: 10.r,
          ),
          SizedBox(height: 16.h),
          // Log list
          Text(
            'Maintenance History',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10.h),
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is DriverLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is! MaintenanceLogsLoaded) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 50.h),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: 48.sp,
                        color: AppColors.gray400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No maintenance logs',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state.logs.isEmpty) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 50.h),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: 48.sp,
                        color: AppColors.gray400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No maintenance logs',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final logs = state.logs;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final type = log.type;
                  final serviceDate = log.serviceDate;
                  final nextDate = log.nextServiceDate;
                  final mileage = log.mileage;
                  final notes = log.notes;
                  final isDue = log.isServiceOverdue;

                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: isDue
                          ? AppColors.error.withOpacity(0.03)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDue
                            ? AppColors.error.withOpacity(0.3)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: isDue
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            _iconForType(type),
                            color: isDue ? AppColors.error : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _labelForType(type),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  if (isDue) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
                                      child: Text(
                                        'DUE',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(
                                  'Serviced: ${DateFormat('MMM d, yyyy').format(serviceDate)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Text(
                                  'Next: ${DateFormat('MMM d, yyyy').format(nextDate)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDue
                                        ? AppColors.error
                                        : AppColors.secondary,
                                    fontWeight: isDue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (mileage != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: Text(
                                    '${mileage.toStringAsFixed(0)} km',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              if (notes != null && notes.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(
                                    notes,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
