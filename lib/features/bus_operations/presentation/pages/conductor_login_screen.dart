// Shared Conductor Login Screen (Bus + Truck)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class FleetConductorLoginScreen extends StatefulWidget {
  final String loginEndpoint;
  final String appTitle;
  final IconData appIcon;
  final String dashboardPath;

  const FleetConductorLoginScreen({
    super.key,
    this.loginEndpoint = '/bus-fleet/conductor-login',
    this.appTitle = 'Bus Conductor / Cabin Crew Portal',
    this.appIcon = Icons.group_rounded,
    this.dashboardPath = '/bus-conductor/dashboard',
  });

  @override
  State<FleetConductorLoginScreen> createState() =>
      _FleetConductorLoginScreenState();
}

class _FleetConductorLoginScreenState extends State<FleetConductorLoginScreen> {
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmail(String input) => input.contains('@') && input.contains('.');
  String _normalizePhone(String raw) {
    final hasPlus = raw.trim().startsWith('+');
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (hasPlus) return '+$digits';
    if (digits.startsWith('03') && digits.length == 11)
      return '+92${digits.substring(1)}';
    if (digits.startsWith('3') && digits.length == 10) return '+92$digits';
    if (digits.startsWith('92') && digits.length == 12) return '+$digits';
    return digits;
  }

  Future<void> _handleLogin() async {
    final identity = _identityController.text.trim();
    final password = _passwordController.text;
    if (identity.isEmpty) {
      setState(() => _errorMessage = 'Enter your email or phone');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();
      final body = <String, dynamic>{'password': password};
      if (_isEmail(identity)) {
        body['email'] = identity;
      } else {
        body['phone'] = _normalizePhone(identity);
      }
      final response = await api.post(
        widget.loginEndpoint,
        body: body,
        requiresAuth: false,
      );
      if (!mounted) return;
      final token = response['token']?.toString();
      if (token == null || token.isEmpty) throw Exception('No token');
      await ApiClient().setAuthToken(token);
      if (!mounted) return;
      context.go(widget.dashboardPath);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Login failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88.w,
                  height: 88.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(widget.appIcon, size: 42.w, color: Colors.white),
                ),
                Gap(18.h),
                Text(
                  widget.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Gap(36.h),
                TextFormField(
                  controller: _identityController,
                  decoration: InputDecoration(
                    labelText: 'Email or Phone Number',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                Gap(14.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                if (_errorMessage != null) ...[
                  Gap(16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
                Gap(24.h),
                SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
