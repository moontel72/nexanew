// Sub-Admin Login Screen
//
// Two-field login: Email/Phone + Password → Sub-Admin Dashboard
// Sub-admins log in to their vertical-specific dashboard.
// Hits: POST /api/v1/sub-admin/auth/login

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class SubAdminLoginScreen extends StatefulWidget {
  const SubAdminLoginScreen({super.key});

  @override
  State<SubAdminLoginScreen> createState() => _SubAdminLoginScreenState();
}

class _SubAdminLoginScreenState extends State<SubAdminLoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final api = ApiClient();
      final identifier = _identifierController.text.trim();

      final res = await api.post(
        '/api/v1/sub-admin/auth/login',
        body: {'identifier': identifier, 'password': _passwordController.text},
        requiresAuth: false,
      );

      final token = res['data']?['token'] as String? ?? '';
      if (token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sub_admin_token', token);
        await prefs.setString(
          'sub_admin_name',
          res['data']?['name'] as String? ?? 'Sub-Admin',
        );
        await prefs.setString(
          'sub_admin_vertical',
          res['data']?['vertical'] as String? ?? '',
        );
        await prefs.setString(
          'sub_admin_email',
          res['data']?['email'] as String? ?? identifier,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            _success = 'Login successful!';
          });
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) context.go('/sub-admin/dashboard');
        }
      } else {
        setState(() {
          _error = 'Invalid response from server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        if (_error!.contains('401') || _error!.contains('Unauthorized')) {
          _error =
              'Invalid credentials. Please check your email/phone and password.';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final cardWidth = isWide ? 440.0 : double.infinity;

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
                  // ── Logo / Brand ──────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF256B77), Color(0xFF14434D)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    'Sub-Admin Terminal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(4),
                  const Text(
                    'Ecosystem Vertical Management',
                    style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 13),
                  ),
                  const Gap(32),

                  // ── Login Card ────────────────────────────
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackgroundLight,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const Gap(16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackgroundLight,
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Minimum 6 characters'
                                : null,
                          ),

                          if (_error != null) ...[
                            const Gap(16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (_success != null) ...[
                            const Gap(16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      _success!,
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Gap(24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F5E6B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(24),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      '← Back to Super Admin Login',
                      style: TextStyle(color: Color(0xFFBDD8DB)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
