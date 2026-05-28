// Bus Company Login Screen — Authentication for bus fleet company owners
// Reuses the existing AdminAuthBloc already provided by the app

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/auth/admin_auth_state.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

/// Bus Company Login Screen
class BusCompanyLoginScreen extends StatefulWidget {
  const BusCompanyLoginScreen({super.key});

  @override
  State<BusCompanyLoginScreen> createState() => _BusCompanyLoginScreenState();
}

class _BusCompanyLoginScreenState extends State<BusCompanyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminAuthBloc, AdminAuthState>(
      listener: (context, state) {
        if (state is AdminAuthAuthenticated) {
          setSuperAdminAuthState(
            isAuthenticated: true,
            userType: 'bus_fleet',
            userId: state.user.id,
            token: state.token,
          );
          context.go('/bus-fleet/dashboard');
        } else if (state is AdminAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(body: _buildLoginScreen()),
    );
  }

  Widget _buildLoginScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.info.withValues(alpha: 0.08), Colors.white],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                Gap(40.h),
                _buildLoginForm(),
                Gap(24.h),
                _buildLoginButton(),
                Gap(16.h),
                _buildForgotPasswordLink(),
                Gap(32.h),
                _buildBackToSuperAdmin(),
                Gap(32.h),
                _buildSecurityNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/logo/traceodd_logo.png',
          width: 100.w,
          height: 100.h,
        ),
        Gap(16.h),
        Text(
          'Bus Company Portal',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.info,
          ),
        ),
        Gap(4.h),
        Text(
          'Sign in to manage your fleet',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your company email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter email';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          Gap(16.h),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter password';
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          Gap(12.h),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                activeColor: AppColors.info,
              ),
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.bodyMedium,
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
          child: PrimaryButton(
            text: isLoading ? 'Signing in...' : 'Sign In',
            onPressed: () {
              if (!isLoading) _handleLogin();
            },
            isLoading: isLoading,
            backgroundColor: AppColors.info,
          ),
        );
      },
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact your super admin to reset password'),
          ),
        );
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(color: AppColors.info, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBackToSuperAdmin() {
    return TextButton.icon(
      onPressed: () => context.go('/login'),
      icon: const Icon(Icons.arrow_back, size: 16),
      label: const Text('Back to Super Admin Login'),
      style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, size: 16.w, color: AppColors.gray500),
          Gap(8.w),
          Expanded(
            child: Text(
              'Secure connection • NexaTrace System',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AdminAuthBloc>().add(
      AdminLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      ),
    );
  }
}
