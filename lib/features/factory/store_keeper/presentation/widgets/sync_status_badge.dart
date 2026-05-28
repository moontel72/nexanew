import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/text_styles.dart';

class SyncStatusBadge extends StatefulWidget {
  final bool showLabel;
  const SyncStatusBadge({super.key, this.showLabel = true});
  @override
  State<SyncStatusBadge> createState() => _SyncStatusBadgeState();
}

class _SyncStatusBadgeState extends State<SyncStatusBadge> {
  bool _isOnline = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  @override
  void initState() {
    super.initState();
    _check();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted)
        setState(() => _isOnline = !results.contains(ConnectivityResult.none));
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted)
      setState(() => _isOnline = !results.contains(ConnectivityResult.none));
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: (_isOnline ? AppColors.success : AppColors.warning).withOpacity(
        0.1,
      ),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: (_isOnline ? AppColors.success : AppColors.warning).withOpacity(
          0.3,
        ),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isOnline ? AppColors.success : AppColors.warning,
          ),
        ),
        if (widget.showLabel) ...[
          Gap(6.w),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyles.caption.copyWith(
              color: _isOnline ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    ),
  );
}
