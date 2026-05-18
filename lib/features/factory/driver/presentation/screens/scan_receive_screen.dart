import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class ScanReceiveScreen extends StatefulWidget {
  const ScanReceiveScreen({super.key});

  @override
  State<ScanReceiveScreen> createState() => _ScanReceiveScreenState();
}

class _ScanReceiveScreenState extends State<ScanReceiveScreen> {
  String? _lastCode;

  Future<void> _scan(BuildContext context) async {
    final code = await context.push<String>('/factory/store-keeper/scanner');
    if (!mounted) return;
    if (code == null || code.isEmpty) return;
    setState(() => _lastCode = code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Received: $code'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Receive (Scan)',
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
              _lastCode == null
                  ? 'No code scanned yet.'
                  : 'Last scanned code: $_lastCode',
            ),
          ),
          SizedBox(height: 16.h),
          PrimaryButton(text: 'Open Scanner', onPressed: () => _scan(context)),
        ],
      ),
    );
  }
}

