// File: lib/features/nexa_admin/presentation/screens/super_admin/login_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/constants/app_constants.dart';
import 'package:trace_odd/core/utils/string_utils.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';

/// Super Admin Login Screen
/// Authentication screen for super administrators to access the admin panel
class SuperAdminLoginScreen extends StatefulWidget {
  const SuperAdminLoginScreen({super.key});

  @override
  State<SuperAdminLoginScreen> createState() => _SuperAdminLoginScreenState();
}

class _SuperAdminLoginScreenState extends State<SuperAdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isErrorDialogVisible = false;

  @override
  void initState() {
    super.initState();
    // Check for saved credentials
    _checkSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AdminAuthBloc, AdminAuthState>(
        listener: (context, state) {
          if (state is AdminAuthError) {
            _showErrorDialog(state);
          } else if (state is AdminAuthAuthenticated) {
            _navigateToDashboard();
          }
        },
        child: _buildLoginScreen(),
      ),
    );
  }

  /// Build the login screen layout
  Widget _buildLoginScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo and Title
                _buildHeader(),
                Gap(40.h),

                // Login Form
                _buildLoginForm(),
                Gap(24.h),

                // Login Button
                _buildLoginButton(),
                Gap(16.h),

                // Forgot Password
                _buildForgotPasswordLink(),
                Gap(32.h),

                // Security Notice
                _buildSecurityNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with logo and title
  Widget _buildHeader() {
    return Column(
      children: [
        // Combined Logo + Company Name SVG
        SvgPicture.asset(
          'assets/logo/logo-company-name.svg',
          width: 560.w,
          height: 322.h,
        ),
        Gap(8.h),

        // Subtitle
        Text(
          'Super Administrator Portal',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        Gap(4.h),

        // Version
        Text(
          'Version ${AppConstants.appVersion}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );
  }

  /// Build login form
  Widget _buildLoginForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Admin Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final raw = value ?? '';
                  final sanitized = _sanitizeEmail(raw);
                  if (sanitized.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (raw.contains(RegExp(r'\s'))) {
                    return 'Email cannot contain spaces';
                  }
                  if (!StringUtils.isValidEmail(sanitized)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              Gap(16.h),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _login(),
              ),
              Gap(16.h),

              // Remember Me & Two-Factor
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Remember Me
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Text(
                        'Remember me',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  // Two-Factor Status
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, size: 14.w, color: Colors.blue),
                        Gap(4.w),
                        Text(
                          '2FA Required',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build login button
  Widget _buildLoginButton() {
    return BlocBuilder<AdminAuthBloc, AdminAuthState>(
      builder: (context, state) {
        final isLoading = state is AdminAuthLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 4,
              shadowColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.3),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 20.w),
                      Gap(8.w),
                      Text(
                        'Login as Super Admin',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Build forgot password link
  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _forgotPassword,
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build security notice
  Widget _buildSecurityNotice() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 16.w, color: Colors.green),
              Gap(8.w),
              Text(
                'Security Notice',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          Gap(8.h),
          Text(
            'This portal is restricted to authorized super administrators only. '
            'All activities are logged and monitored for security purposes.',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          Gap(8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, size: 12.w, color: Colors.orange),
              Gap(4.w),
              Text(
                'Unauthorized access is prohibited',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Check for saved credentials
  Future<void> _checkSavedCredentials() async {
    // TODO: Implement credential checking from secure storage
    // For now, we'll just clear the fields
    _emailController.clear();
    _passwordController.clear();
  }

  /// Perform login
  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _sanitizeEmail(_emailController.text);
      final password = _passwordController.text;

      context.read<AdminAuthBloc>().add(
        AdminLoginRequested(
          email: email,
          password: password,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  String _sanitizeEmail(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').trim().toLowerCase();
  }

  /// Handle forgot password
  void _forgotPassword() {
    // TODO: Implement forgot password flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'Please contact the system administrator to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(AdminAuthError state) async {
    if (_isErrorDialogVisible) return;
    _isErrorDialogVisible = true;

    // Build a clean, user-friendly message — never expose raw stack traces
    final buffer = StringBuffer();
    buffer.writeln(state.message);

    // Append validation details if present (safe, structured format)
    if (state.isInvalidCredentials) {
      buffer.writeln();
      buffer.writeln('Please check your email and password.');
    } else if (state.isNetworkError) {
      buffer.writeln();
      buffer.writeln('Check your internet connection and try again.');
    } else if (state.isServerError) {
      buffer.writeln();
      buffer.writeln('The server is experiencing issues. Please try again later.');
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Login Error'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: SelectableText(buffer.toString()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    _isErrorDialogVisible = false;
  }

  /// Navigate to dashboard after successful login
  void _navigateToDashboard() {
    if (!mounted) return;
    if (kDebugMode) {
      debugPrint('NAV_DASHBOARD: Login successful, navigating to dashboard');
    }

    // CRITICAL: Update global auth state so router redirect allows navigation
    setIsAuthenticatedCache(true);
    setAuthCheckCompleted(true);

    if (kDebugMode) {
      debugPrint('NAV_DASHBOARD: Auth state updated, navigating now');
    }

    // Navigate to dashboard
    context.go('/dashboard');
  }
}
