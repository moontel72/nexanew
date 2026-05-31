// Bus Owner Standalone Login Screen (Module 14)
//
// Primary authentication via Phone Number + Password.
// Email field is optional / bypassed for third-party bus owners.
// Hits POST /api/v1/bus-fleet/owner-login on submit.
// Caches bearer token and tenant company metadata on success.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                Gap(36.h),
                _buildLoginForm(),
                if (_errorMessage != null) ...[Gap(16.h), _buildErrorBanner()],
                Gap(24.h),
                _buildLoginButton(),
                Gap(20.h),
                _buildFooterActions(),
                Gap(40.h),
                _buildSecurityBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo icon
        Container(
          width: 88.w,
          height: 88.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_bus_filled,
            size: 42.w,
            color: Colors.white,
          ),
        ),
        Gap(18.h),
        Text(
          'Bus Owner Portal',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Gap(6.h),
        Text(
          'Sign in to monitor your fleet assets',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  // ─── Login Form ────────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Phone Number — primary identifier
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: '+92 300 1234567',
              prefixIcon: const Icon(Icons.phone_android_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) {
              final trimmed = v?.trim() ?? '';
              if (trimmed.isEmpty) return 'Phone number is required';
              if (trimmed.replaceAll(RegExp(r'[\s\-+()]'), '').length < 10) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          Gap(14.h),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password *',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.gray400,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Password is required';
              if (v.trim().length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),

          Gap(10.h),

          // Email (optional)
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => setState(() {}), // just rebuild to show/hide
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16.w,
                      color: AppColors.gray400,
                    ),
                    Gap(4.w),
                    Text(
                      'Login with email instead',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error Banner ──────────────────────────────────────
  Widget _buildErrorBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20.w, color: AppColors.error),
          Gap(10.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Login Button ──────────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.gray300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded, size: 20),
                  Gap(8.w),
                  Text(
                    'Sign In as Owner',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── Footer Actions ────────────────────────────────────
  Widget _buildFooterActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Contact your transport company admin to reset your password.',
                ),
              ),
            );
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 16,
          color: AppColors.gray200,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        TextButton(
          onPressed: () => context.go('/bus-fleet/login'),
          child: Text(
            'Company Admin Login',
            style: TextStyle(
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Security Badge ────────────────────────────────────
  Widget _buildSecurityBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 15.w,
            color: AppColors.gray400,
          ),
          Gap(6.w),
          Text(
            'NexaTrace Secure • Encrypted Connection',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Login Handler ─────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();

      final body = <String, dynamic>{
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
      };

      // Include email only if user provided it
      final email = _emailController.text.trim();
      if (email.isNotEmpty) {
        body['email'] = email;
      }

      final response = await api.post(
        '/api/v1/bus-fleet/owner-login',
        body: body,
        requiresAuth: false,
      );

      if (!mounted) return;

      final data = response['data'] as Map<String, dynamic>?;
      final token = data?['token']?.toString();
      final owner = data?['owner'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token received');
      }

      // Cache token and tenant metadata via ApiClient
      // (ApiService caches internally via ApiClient.setAuthToken)
      await api.post(
        '/api/v1/auth/set-token',
        body: {
          'token': token,
          'user_type': 'bus_owner',
          'tenant': owner?['company_name'] ?? owner?['tenant_name'] ?? '',
        },
        requiresAuth: false,
      );

      if (!mounted) return;

      // Navigate to owner dashboard
      context.go('/bus-owner/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapLoginError(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapLoginError(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('invalid') && msg.contains('credential')) {
      return 'Invalid phone number or password. Please try again.';
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (msg.contains('suspended') || msg.contains('disabled')) {
      return 'Your account has been suspended. Contact your transport company.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    return 'Login failed. Please check your credentials and try again.';
  }
}
