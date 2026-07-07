import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/reseller/presentation/bloc/auth/reseller_auth_bloc.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

/// Reseller color — Deep Purple to differentiate from:
///   Super Admin (Blue), Factory Admin (Green), Store Keeper (Orange)
const Color _resellerColor = Color(0xFF673AB7);

class ResellerLoginScreen extends StatefulWidget {
  const ResellerLoginScreen({super.key});

  @override
  State<ResellerLoginScreen> createState() => _ResellerLoginScreenState();
}

class _ResellerLoginScreenState extends State<ResellerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Password visibility is a pure UI toggle — zero data mutation.
  // Allowed per project convention (same as FleetBlocLoginScreen).
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ResellerAuthBloc, ResellerAuthState>(
        listener: (context, state) {
          if (state is ResellerAuthenticated) {
            context.go('/dashboard');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_resellerColor.withValues(alpha: 0.08), Colors.white],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Icon badge ─────────────────────────
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: _resellerColor,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: _resellerColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.storefront,
                          size: 40.w,
                          color: Colors.white,
                        ),
                      ),
                      Gap(16.h),

                      // ── Title ──────────────────────────────
                      Text(
                        'Reseller Login',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _resellerColor,
                            ),
                      ),
                      Gap(8.h),
                      Text(
                        'Trace Odd B2B Marketplace Portal',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Gap(32.h),

                      // ── Login Card ─────────────────────────
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),
                              Gap(12.h),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
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
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                              ),
                              Gap(20.h),
                              BlocBuilder<ResellerAuthBloc, ResellerAuthState>(
                                builder: (context, state) {
                                  final isLoading =
                                      state is ResellerAuthLoading;
                                  final error = state is ResellerAuthError
                                      ? state.message
                                      : null;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      PrimaryButton(
                                        text: isLoading
                                            ? 'Signing in…'
                                            : 'Sign In',
                                        isLoading: isLoading,
                                        isEnabled: !isLoading,
                                        backgroundColor: _resellerColor,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          context.read<ResellerAuthBloc>().add(
                                            ResellerLoginRequested(
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                            ),
                                          );
                                        },
                                      ),
                                      if (error != null &&
                                          error.trim().isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.only(top: 12.h),
                                          child: Text(
                                            error,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.error,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(16.h),

                      // ── Footer note ────────────────────────
                      Text(
                        'Medical Companies Agent App is a separate project\nand is not part of the Reseller App.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
