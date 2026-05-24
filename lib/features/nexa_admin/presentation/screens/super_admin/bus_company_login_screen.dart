// Bus Company Login Screen — Authentication for bus fleet company owners
// Pattern follows FactoryLoginScreen with bus fleet branding

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

/// Bus Company Login Screen
/// Authentication screen for bus fleet company owners
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
  void initState() {
    super.initState();
    // Pre-fill with test credentials for development
    _emailController.text = 'bus-admin@nexatrace.local';
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
    return Scaffold(body: _buildLoginScreen());
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
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.info, // Bus uses info color (blue)
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.info.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.directions_bus, size: 40.w, color: Colors.white),
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
          // Email field
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(value.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          Gap(16.h),

          // Password field
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          Gap(12.h),

          // Remember me
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
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Sign In',
        onPressed: _handleLogin,
        backgroundColor: AppColors.info,
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _handleForgotPassword,
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
              'Secure connection • Your data is encrypted • '
              '${DateTime.now().year} NexaTrace System',
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

    final email = _emailController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Login attempt for $email — Backend auth endpoint pending',
        ),
        backgroundColor: AppColors.info,
      ),
    );

    // TODO: Integrate with BusFleetAuthBloc when backend endpoint is available
    // context.read<BusFleetAuthBloc>().add(
    //   BusFleetLoginRequested(email: email, password: password),
    // );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset link will be sent to your email'),
      ),
    );
  }
}
