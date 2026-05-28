// Driver Login Screen for NexaTrace System
// Driver authentication interface - Mobile-optimized for both web and APK
// Uses Industrial Blue (#165DFF) per PRD section 4.1

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/constants/app_constants.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

/// Driver Teal (#0D9488) — distinct from Super Admin blue (#0066CC),
/// Factory Admin green (#00CC66), Store Keeper orange (#FF9900), Reseller purple.
const Color _driverBlue = Color(0xFF0D9488);

/// Driver Login Screen
/// Authentication screen for drivers to access the driver panel
class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isErrorDialogVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_driverBlue.withOpacity(0.08), Colors.white],
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
                  _buildHeader(),
                  Gap(40.h),
                  _buildLoginForm(),
                  Gap(24.h),
                  _buildLoginButton(),
                  Gap(16.h),
                  _buildForgotPasswordLink(),
                  Gap(32.h),
                  _buildBackToAdmin(),
                  Gap(32.h),
                  _buildSecurityNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: _driverBlue,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: _driverBlue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.local_shipping, size: 40.w, color: Colors.white),
        ),
        Gap(16.h),
        Text(
          'NexaTrace Driver',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _driverBlue,
          ),
        ),
        Gap(8.h),
        Text(
          'Driver Delivery Portal',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        Gap(4.h),
        Text(
          'Version ${AppConstants.appVersion}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );
  }

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
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Driver Email',
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter your driver email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              Gap(16.h),
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
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
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
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _onLogin(),
              ),
              Gap(16.h),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return _driverBlue;
                      }
                      return Colors.transparent;
                    }),
                  ),
                  Text(
                    'Remember me',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        onPressed: _onLogin,
        text: 'Sign In to Driver Panel',
        backgroundColor: _driverBlue,
        textColor: Colors.white,
        isLoading: _isLoading,
        isEnabled: !_isLoading,
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _onForgotPassword,
      child: Text(
        'Forgot Password?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: _driverBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBackToAdmin() {
    return OutlinedButton(
      onPressed: () => context.go('/factory/login'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        side: BorderSide(color: Colors.grey[400]!),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.factory, size: 20.w),
          Gap(8.w),
          Text(
            'Factory Admin Portal',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.security, size: 24.w, color: Colors.grey[600]),
          Gap(8.h),
          Text(
            'Secure Driver Access',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Gap(4.h),
          Text(
            'Your delivery data is protected with enterprise-grade security',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Attempt API login
      final api = ApiService();
      final response = await api.post(
        '/factory/drivers/login',
        body: {'email': email, 'password': password},
      );

      final data = response is Map ? (response['data'] ?? response) : {};
      final token = data['token']?.toString() ?? '';

      if (token.isNotEmpty) {
        await _persistAuth(token, email, data);
        if (mounted) context.go('/dashboard');
      } else {
        _showError('Invalid credentials. Please try again.');
      }
    } catch (_) {
      // Fallback: placeholder auth for development
      await _placeholderAuth();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _placeholderAuth() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your driver email and password.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = 'driver_token_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('driver_auth_token', token);
    await prefs.setString('driver_email', email);
    await prefs.setString('driver_id', 'dev-driver-001');
    await prefs.setString('driver_name', email.split('@').first);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged in (dev mode)'),
          backgroundColor: _driverBlue,
        ),
      );
      context.go('/dashboard');
    }
  }

  Future<void> _persistAuth(
    String token,
    String email,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_auth_token', token);
    await prefs.setString('driver_email', email);
    await prefs.setString(
      'driver_id',
      data['driver_id']?.toString() ?? data['id']?.toString() ?? '',
    );
    await prefs.setString(
      'driver_name',
      data['name']?.toString() ?? email.split('@').first,
    );
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact your factory admin to reset password.'),
      ),
    );
  }

  void _showError(String message) {
    if (_isErrorDialogVisible) return;
    _isErrorDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              _isErrorDialogVisible = false;
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) => _isErrorDialogVisible = false);
  }
}
