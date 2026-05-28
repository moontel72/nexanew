// Factory Login Screen for NexaTrace System
// Factory Admin authentication interface - Updated to match Super Admin design pattern

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/constants/app_constants.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'package:trace_odd/features/factory/admin/presentation/bloc/auth/factory_auth_bloc.dart';

import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';

/// Factory Admin Login Screen
/// Authentication screen for factory administrators to access the factory panel
class FactoryLoginScreen extends StatefulWidget {
  const FactoryLoginScreen({super.key});

  @override
  State<FactoryLoginScreen> createState() => _FactoryLoginScreenState();
}

class _FactoryLoginScreenState extends State<FactoryLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isErrorDialogVisible = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with test credentials for development
    _emailController.text = 'factory-admin@nexatrace.local';
    _passwordController.text = 'admin12345';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FactoryAuthBloc, FactoryAuthState>(
      listener: (context, state) {
        if (state is FactoryAuthAuthenticated) {
          if (!isFactoryAuthenticatedCache) {
            setFactoryAuthState(
              isAuthenticated: true,
              userType: 'factory',
              userId: state.user['id']?.toString() ?? '',
              token: state.token,
              factoryId: state.user['company_id']?.toString(),
            );
          }
          context.go('/factory/dashboard');
        } else if (state is FactoryAuthError) {
          if (!_isErrorDialogVisible) {
            _isErrorDialogVisible = true;
            _showErrorDialog(state.message);
          }
        }
      },
      child: _buildLoginScreen(),
    );
  }

  /// Build the login screen layout
  Widget _buildLoginScreen() {
    return Scaffold(
      body: Container(
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

                  // Back to Super Admin
                  _buildBackToSuperAdmin(),
                  Gap(32.h),

                  // Security Notice
                  _buildSecurityNotice(),
                ],
              ),
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
        // Logo
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.secondary, // Factory uses secondary color (green)
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.factory, size: 40.w, color: Colors.white),
        ),
        Gap(16.h),

        // Title
        Text(
          'NexaTrace Factory',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary, // Factory uses secondary color
          ),
        ),
        Gap(8.h),

        // Subtitle
        Text(
          'Factory Administrator Portal',
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
                  labelText: 'Factory Email',
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
                    return 'Please enter your factory email';
                  }
                  if (!value.contains('@')) {
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
                      color: Colors.grey[600],
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
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _onLogin(),
              ),
              Gap(16.h),

              // Remember Me Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    fillColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.secondary;
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

  /// Build login button
  Widget _buildLoginButton() {
    return BlocBuilder<FactoryAuthBloc, FactoryAuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: state is FactoryAuthLoading
              ? const LoadingIndicator()
              : PrimaryButton(
                  onPressed: _onLogin,
                  text: 'Sign In to Factory Panel',
                  backgroundColor:
                      AppColors.secondary, // Factory uses secondary color
                  textColor: Colors.white,
                ),
        );
      },
    );
  }

  /// Build forgot password link
  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _onForgotPassword,
      child: Text(
        'Forgot Password?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build back to super admin button
  Widget _buildBackToSuperAdmin() {
    return OutlinedButton(
      onPressed: _onBackToSuperAdmin,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 20.w),
          Gap(8.w),
          Text(
            'Super Admin Portal',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Build security notice
  Widget _buildSecurityNotice() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(Icons.security, size: 24.w, color: Colors.grey[600]),
          Gap(8.h),
          Text(
            'Secure Factory Access',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Gap(4.h),
          Text(
            'Your factory data is protected with enterprise-grade security',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Handle login
  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      context.read<FactoryAuthBloc>().add(
        FactoryLoginRequested(
          email: email,
          password: password,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  /// Handle forgot password
  void _onForgotPassword() {
    // TODO: Implement forgot password flow for factory admin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot password functionality coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  /// Handle back to super admin
  void _onBackToSuperAdmin() {
    // Navigate to super admin login
    context.go('/login');
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                _isErrorDialogVisible = false;
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      _isErrorDialogVisible = false;
    });
  }
}
