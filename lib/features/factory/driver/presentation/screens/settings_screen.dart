import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexatrace_system/features/factory/driver/presentation/widgets/driver_feature_scaffold.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  bool _offlineMode = false;
  bool _isCheckingGps = false;
  String? _gpsResult;
  int _drivingHoursToday = 5;
  int _drivingHoursWeek = 32;
  int _restReminderMinutes = 15;

  void _toggleOfflineMode(bool v) {
    setState(() => _offlineMode = v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          v
              ? 'Offline mode enabled. Data will sync when online (4Z).'
              : 'Online mode restored.',
        ),
        backgroundColor: v ? AppColors.accent : AppColors.success,
      ),
    );
  }

  Future<void> _checkFakeGps() async {
    setState(() {
      _isCheckingGps = true;
      _gpsResult = null;
    });

    // Simulate a GPS check delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Mock result
    final isSpoofed = DateTime.now().second % 3 == 0;
    setState(() {
      _isCheckingGps = false;
      _gpsResult = isSpoofed
          ? '⚠️  Potential GPS spoofing detected (4S)'
          : '✅  GPS signal verified - no spoofing detected';
    });
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all locally cached data. '
          'Unsynchronized data may be lost. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cache cleared successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Clear stored auth
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('driver_auth_token');
      await prefs.remove('driver_email');
      await prefs.remove('driver_id');
      await prefs.remove('driver_name');

      // Navigate to login
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DriverFeatureScaffold(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Offline mode
          _sectionHeader('Connectivity'),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.w),
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
                    Icon(
                      Icons.wifi_off,
                      color: _offlineMode
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Work without internet. Data syncs automatically when reconnected (4Z).',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _offlineMode,
                      onChanged: _toggleOfflineMode,
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Cache management
          _sectionHeader('Cache Management'),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _settingsRow(
                  icon: Icons.storage,
                  title: 'Cached Data',
                  subtitle: 'Clear locally stored data',
                  trailing: TextButton(
                    onPressed: _clearCache,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Divider(color: AppColors.border, height: 20.h),
                _settingsRow(
                  icon: Icons.sync,
                  title: 'Sync Status',
                  subtitle: 'Last synced: 2 minutes ago',
                  trailing: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Fake GPS check
          _sectionHeader('Location Verification'),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _settingsRow(
                  icon: Icons.gps_fixed,
                  title: 'Fake GPS Check',
                  subtitle: 'Detect location spoofing (4S)',
                  trailing: PrimaryButton(
                    text: _isCheckingGps ? 'Checking…' : 'Check',
                    onPressed: _isCheckingGps ? () {} : _checkFakeGps,
                    width: 90.w,
                    height: 34.h,
                    borderRadius: 6.r,
                  ),
                ),
                if (_gpsResult != null) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: _gpsResult!.startsWith('✅')
                          ? AppColors.success.withOpacity(0.08)
                          : AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _gpsResult!.startsWith('✅')
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _gpsResult!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: _gpsResult!.startsWith('✅')
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Fatigue status
          _sectionHeader('Fatigue Status'),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _fatigueRow(
                  label: 'Driving Today',
                  value: '${_drivingHoursToday}h',
                  max: 10,
                  current: _drivingHoursToday,
                ),
                SizedBox(height: 10.h),
                _fatigueRow(
                  label: 'Driving This Week',
                  value: '${_drivingHoursWeek}h',
                  max: 60,
                  current: _drivingHoursWeek,
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bedtime, color: AppColors.primary, size: 20),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Rest reminder in $_restReminderMinutes minutes (4AC)',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // App version
          _sectionHeader('About'),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _settingsRow(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: 'NexaTrace Driver v1.2.3 (build 145)',
                ),
                Divider(color: AppColors.border, height: 20.h),
                _settingsRow(
                  icon: Icons.system_update,
                  title: 'Check for Updates',
                  subtitle: 'You are on the latest version',
                  trailing: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Logout
          PrimaryButton(
            text: 'Logout',
            onPressed: _logout,
            backgroundColor: AppColors.error,
            borderRadius: 10.r,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 22),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _fatigueRow({
    required String label,
    required String value,
    required int max,
    required int current,
  }) {
    final ratio = (current / max).clamp(0.0, 1.0);
    final barColor = ratio > 0.8
        ? AppColors.error
        : ratio > 0.6
        ? AppColors.warning
        : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(3.r),
          child: SizedBox(
            height: 6.h,
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.gray100,
              color: barColor,
            ),
          ),
        ),
      ],
    );
  }
}
