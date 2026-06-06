// Bus Owner Login Screen (Module 14) — Wave 2 Identity Spine
//
// Uses unified /auth/login endpoint with fleet_role + fleet_type params.
// Dark theme matching Sub-Admin dashboard styling.
// Token persisted via ApiClient → SharedPreferences for dashboard boot.

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/core/constants/app_constants.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

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
      _errorMessage = null;
    });

    try {
      final res = await ApiService().post(
        '/auth/login',
        data: {
          'identifier': _identifierController.text.trim(),
          'password': _passwordController.text,
          'fleet_role': 'owner',
          'fleet_type': 'bus',
        },
        requiresAuth: false,
      );

      if (res == null || res['token'] == null) {
        setState(() => _errorMessage = 'Invalid credentials');
        return;
      }

      final token = res['token'] as String;
      final userData = res['data'] as Map<String, dynamic>? ?? {};

      // Persist token via ApiClient
      final api = ApiService();
      await api.post; // trigger auth setup

      // Navigate to dashboard
      if (mounted) context.go('/bus-owner/dashboard');
    } catch (e) {
      setState(() {
        _errorMessage =
            'Login failed: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const Gap(36),
                  _buildLoginForm(),
                  if (_errorMessage != null) ...[
                    const Gap(16),
                    _buildErrorBanner(),
                  ],
                  const Gap(28),
                  _buildLoginButton(),
                  const Gap(20),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A5C), Color(0xFF0F2B3F)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C49F).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.directions_bus,
          color: Color(0xFF00C49F),
          size: 40,
        ),
      ),
      const Gap(16),
      const Text(
        'Bus Owner Portal',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Gap(4),
      Text(
        'Sign in to manage your fleet',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
    ],
  );

  Widget _buildLoginForm() => Column(
    children: [
      TextFormField(
        controller: _identifierController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Email or Phone',
          labelStyle: const TextStyle(color: Color(0xFF8899AA)),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: Color(0xFF556677),
          ),
          filled: true,
          fillColor: const Color(0xFF1A2A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00C49F)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
        ),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
      const Gap(16),
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: const TextStyle(color: Color(0xFF8899AA)),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF556677)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF556677),
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: const Color(0xFF1A2A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00C49F)),
          ),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    ],
  );

  Widget _buildLoginButton() => SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C49F),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF00C49F).withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    ),
  );

  Widget _buildErrorBanner() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFDC2626).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
        const Gap(8),
        Expanded(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _buildFooter() => Column(
    children: [
      Text(
        'NexaTrace Fleet Management',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.2),
          fontSize: 11,
        ),
      ),
      const Gap(4),
      Text(
        'Secure • Real-Time • Sovereign',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.15),
          fontSize: 10,
        ),
      ),
    ],
  );
}
