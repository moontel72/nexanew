import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/bloc/driver_bloc.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class DriverComplianceScreen extends StatefulWidget {
  const DriverComplianceScreen({super.key});

  @override
  State<DriverComplianceScreen> createState() => _DriverComplianceScreenState();
}

class _DriverComplianceScreenState extends State<DriverComplianceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const LoadCompliance());
  }

  Future<void> _uploadDocument(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result?.files.isNotEmpty == true) {
      final file = result!.files.first;
      if (!mounted) return;
      context.read<DriverBloc>().add(
        UploadDocument(documentType: docType, filePath: file.path ?? ''),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$docType document uploaded'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  IconData _iconForDocType(String type) {
    switch (type) {
      case 'license':
        return Icons.badge_outlined;
      case 'insurance':
        return Icons.shield_outlined;
      case 'registration':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Compliance',
      child: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          if (state is DriverLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
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

          if (state is! ComplianceChecked) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final hasExpired = state.hasExpiredDocs;
          final expiringDocs = state.expiringDocs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Blocked status banner
              if (hasExpired)
                Container(
                  margin: EdgeInsets.only(bottom: 14.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.block,
                          color: AppColors.error,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Restricted',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'One or more documents have expired. Your ability to accept new trips may be blocked (4Y). Please renew immediately.',
                              style: TextStyle(
                                color: AppColors.error.withOpacity(0.8),
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Expiring docs warning
              if (expiringDocs.isNotEmpty)
                ...expiringDocs.map((docType) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: AppColors.warning,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${_docTypeName(docType)} is expiring soon',
                            style: TextStyle(
                              color: AppColors.warning.withOpacity(0.9),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              // Document status cards
              ...['license', 'insurance', 'registration'].map((docType) {
                final isExpiring = expiringDocs.contains(docType);
                final statusClr = hasExpired
                    ? AppColors.error
                    : isExpiring
                    ? AppColors.warning
                    : AppColors.success;
                final statusLbl = hasExpired
                    ? 'Expired'
                    : isExpiring
                    ? 'Expiring Soon'
                    : 'Valid';
                final icon = _iconForDocType(docType);
                final name = _docTypeName(docType);

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: statusClr.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46.w,
                            height: 46.w,
                            decoration: BoxDecoration(
                              color: statusClr.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(icon, color: statusClr, size: 24),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusClr.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    statusLbl,
                                    style: TextStyle(
                                      color: statusClr,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 38.h,
                        child: OutlinedButton.icon(
                          onPressed: () => _uploadDocument(docType),
                          icon: Icon(Icons.upload_file, size: 16.sp),
                          label: Text('Upload Document'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Refresh button
              SizedBox(height: 10.h),
              PrimaryButton(
                text: 'Refresh Compliance Status',
                onPressed: () {
                  context.read<DriverBloc>().add(const LoadCompliance());
                },
                height: 44.h,
                borderRadius: 10.r,
              ),
            ],
          );
        },
      ),
    );
  }

  String _docTypeName(String type) {
    switch (type) {
      case 'license':
        return 'Driver License';
      case 'insurance':
        return 'Vehicle Insurance';
      case 'registration':
        return 'Vehicle Registration';
      default:
        return type;
    }
  }
}
