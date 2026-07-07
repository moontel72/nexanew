// Sub-Admin Login Screen — BLoC-driven
//
// Two-field login: Email/Phone + Password → Sub-Admin Dashboard
// Hits: POST /api/v1/auth/login (unified endpoint)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_event.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/sub_admin/sub_admin_state.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class SubAdminLoginScreen extends StatelessWidget {
  const SubAdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubAdminBloc(),
      child: const _SubAdminLoginView(),
    );
  }
}

class _SubAdminLoginView extends StatefulWidget {
  const _SubAdminLoginView();

  @override
  State<_SubAdminLoginView> createState() => _SubAdminLoginViewState();
}

class _SubAdminLoginViewState extends State<_SubAdminLoginView> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final cardWidth = isWide ? 440.0 : double.infinity;

    return BlocConsumer<SubAdminBloc, SubAdminState>(
      listener: (context, state) {
        if (state.authStatus == SubAdminAuthStatus.success) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (context.mounted) context.go('/sub-admin/dashboard');
          });
        }
      },
      builder: (context, state) {
        final bloc = context.read<SubAdminBloc>();
        final isLoading = state.authStatus == SubAdminAuthStatus.loading;

        return Scaffold(
          backgroundColor: const Color(0xFF0F2B33),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: cardWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF256B77), Color(0xFF14434D)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 34),
                      ),
                      const Gap(20),
                      const Text(
                        'Sub-Admin Terminal',
                        style: TextStyle(
                          color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                      const Gap(4),
                      const Text(
                        'Ecosystem Vertical Management',
                        style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 13),
                      ),
                      const Gap(28),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _identifierController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Email or Phone',
                                  hintText: 'subadmin@nexatrace.com',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true, fillColor: AppColors.inputBackgroundLight,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                              const Gap(14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: state.obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => bloc.add(SubAdminLoginRequested(
                                  identifier: _identifierController.text.trim(),
                                  password: _passwordController.text,
                                )),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(state.obscurePassword
                                        ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => bloc.add(const TogglePasswordVisibility()),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true, fillColor: AppColors.inputBackgroundLight,
                                ),
                                validator: (v) =>
                                    (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                              ),
                              if (state.authError != null) ...[
                                const Gap(14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                    const Gap(8),
                                    Expanded(child: Text(state.authError!,
                                        style: const TextStyle(color: AppColors.error, fontSize: 13))),
                                  ]),
                                ),
                              ],
                              if (state.authSuccess != null) ...[
                                const Gap(14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                                    const Gap(8),
                                    Expanded(child: Text(state.authSuccess!,
                                        style: const TextStyle(color: AppColors.success, fontSize: 13))),
                                  ]),
                                ),
                              ],
                              const Gap(22),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!.validate()) {
                                            bloc.add(SubAdminLoginRequested(
                                              identifier: _identifierController.text.trim(),
                                              password: _passwordController.text,
                                            ));
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1F5E6B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 22, height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Sign In',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(22),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('← Back to Super Admin Login',
                            style: TextStyle(color: Color(0xFFBDD8DB))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
