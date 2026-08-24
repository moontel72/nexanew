// File: lib/features/nexa_admin/presentation/screens/super_admin/login_screen.dart
//
// Super Admin Login — compact, professional card layout. Uses FIXED sizes
// (no screenutil scaling) so it stays centered and clean on desktop
// browsers, tablets and mobiles alike.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/constants/app_constants.dart';
import 'package:trace_odd/core/utils/string_utils.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';
import 'package:trace_odd/shared/theme/traceodd_brand_tokens.dart';
import 'package:trace_odd/shared/widgets/brand/traceodd_brand.dart';

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

  /// Brand-dark premium background with a centered white card.
  Widget _buildLoginScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TraceOddBrandTokens.dark,
            Color(0xFF141829),
            TraceOddBrandTokens.dark,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 12,
              shadowColor: Colors.black38,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildLoginForm(),
                    const SizedBox(height: 20),
                    _buildLoginButton(),
                    const SizedBox(height: 8),
                    _buildForgotPasswordLink(),
                    const SizedBox(height: 18),
                    _buildSecurityNotice(),
                  ],
                ),
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
        const TraceOddBrand(badgeSize: 104, nameSize: 24, gap: 12),
        const SizedBox(height: 10),
        Text(
          'Super Administrator Portal',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${AppConstants.appVersion}',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Admin Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
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
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text('Remember me', style: TextStyle(fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '2FA Required',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
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
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AdminAuthBloc, AdminAuthState>(
      builder: (context, state) {
        final isLoading = state is AdminAuthLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: TraceOddBrandTokens.gold,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Login as Super Admin',
                        style: TextStyle(
                          fontSize: 15,
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

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _forgotPassword,
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 13,
          color: TraceOddBrandTokens.gold,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Restricted portal — all activities are logged and monitored.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkSavedCredentials() async {
    // TODO: Implement credential checking from secure storage
    _emailController.clear();
    _passwordController.clear();
  }

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

    if (state.isInvalidCredentials) {
      buffer.writeln();
      buffer.writeln('Please check your email and password.');
    } else if (state.isNetworkError) {
      buffer.writeln();
      buffer.writeln('Check your internet connection and try again.');
    } else if (state.isServerError) {
      buffer.writeln();
      buffer.writeln(
        'The server is experiencing issues. Please try again later.',
      );
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

  void _navigateToDashboard() {
    if (!mounted) return;
    if (kDebugMode) {
      debugPrint('NAV_DASHBOARD: Login successful, navigating to dashboard');
    }

    setIsAuthenticatedCache(true);
    setAuthCheckCompleted(true);

    context.go('/dashboard');
  }
}
