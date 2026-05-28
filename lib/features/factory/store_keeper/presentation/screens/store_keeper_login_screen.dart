import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/factory/store_keeper/presentation/bloc/store_keeper_bloc.dart';
import 'package:trace_odd/features/factory/store_keeper/presentation/widgets/sync_status_badge.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class StoreKeeperLoginScreen extends StatefulWidget {
  const StoreKeeperLoginScreen({super.key});
  @override
  State<StoreKeeperLoginScreen> createState() => _StoreKeeperLoginScreenState();
}

class _StoreKeeperLoginScreenState extends State<StoreKeeperLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void initState() {
    super.initState();
    _emailC.text = 'fasail@gmail.com';
    _passC.text = 'admin12345';
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreKeeperBloc, StoreKeeperState>(
      listener: (context, state) {
        if (state is StoreKeeperAuthenticated) {
          context.go('/factory/store-keeper/dashboard');
        }
        if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.amber.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        size: 40.w,
                        color: Colors.white,
                      ),
                    ),
                    Gap(16.h),
                    Text(
                      'Trace Odd Store',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                    ),
                    Gap(8.h),
                    Text(
                      'Store Keeper Portal',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    Gap(12.h),
                    const SyncStatusBadge(),
                    Gap(32.h),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailC,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (v) => (v ?? '').isEmpty
                                    ? 'Required'
                                    : (!v!.contains('@')
                                          ? 'Invalid email'
                                          : null),
                              ),
                              Gap(16.h),
                              TextFormField(
                                controller: _passC,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                validator: (v) => (v ?? '').isEmpty
                                    ? 'Required'
                                    : (v!.length < 6 ? 'Min 6 chars' : null),
                                onFieldSubmitted: (_) => _login(),
                              ),
                              Gap(16.h),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _remember,
                                    onChanged: (v) =>
                                        setState(() => _remember = v ?? false),
                                  ),
                                  Text(
                                    'Remember me',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Gap(24.h),
                    BlocBuilder<StoreKeeperBloc, StoreKeeperState>(
                      builder: (context, state) {
                        final isLoading = state is StoreKeeperLoggingIn;
                        return SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            onPressed: _login,
                            isEnabled: !isLoading,
                            text: isLoading
                                ? 'Signing in...'
                                : 'Sign In to Store Portal',
                            backgroundColor: Colors.amber.shade700,
                            textColor: Colors.white,
                            icon: isLoading ? Icons.lock : Icons.login,
                          ),
                        );
                      },
                    ),
                    Gap(16.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 16.w,
                            color: AppColors.warning,
                          ),
                          Gap(8.w),
                          Text(
                            'Offline mode available',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<StoreKeeperBloc>().add(
        StoreKeeperLogin(
          email: _emailC.text.trim(),
          password: _passC.text,
          rememberMe: _remember,
        ),
      );
    }
  }
}
