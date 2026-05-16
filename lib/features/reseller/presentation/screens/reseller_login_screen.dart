import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/features/reseller/presentation/bloc/auth/reseller_auth_bloc.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';

class ResellerLoginScreen extends StatefulWidget {
  const ResellerLoginScreen({super.key});

  @override
  State<ResellerLoginScreen> createState() => _ResellerLoginScreenState();
}

class _ResellerLoginScreenState extends State<ResellerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
            context.go('/reseller/dashboard');
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reseller Login',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      BlocBuilder<ResellerAuthBloc, ResellerAuthState>(
                        builder: (context, state) {
                          final isLoading = state is ResellerAuthLoading;
                          final error =
                              state is ResellerAuthError ? state.message : null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PrimaryButton(
                                text: isLoading ? 'Signing in…' : 'Sign In',
                                isLoading: isLoading,
                                isEnabled: !isLoading,
                                onPressed: () {
                                  context.read<ResellerAuthBloc>().add(
                                        ResellerLoginRequested(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        ),
                                      );
                                },
                              ),
                              if (error != null && error.trim().isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 12.h),
                                  child: Text(
                                    error,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.error),
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: Text(
                                  'Medical Companies Agent App is a separate project and is not part of Reseller App.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.textSecondary),
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
            ),
          ),
        ),
      ),
    );
  }
}
