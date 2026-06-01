// Shared Fleet Driver Login Screen (Bus Driver + Truck Driver)
// Endpoint passed via constructor.
// Bus Driver  → /bus-fleet/driver-login
// Truck Driver → /goods-fleet/driver-login

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/core/services/api_client.dart';
import 'package:trace_odd/shared/theme/colors.dart';

class FleetDriverLoginScreen extends StatefulWidget {
  final String loginEndpoint;
  final String appTitle;
  final IconData appIcon;
  final String dashboardPath;

  const FleetDriverLoginScreen({
    super.key,
    this.loginEndpoint = '/bus-fleet/driver-login',
    this.appTitle = 'Bus Driver Portal',
    this.appIcon = Icons.badge_rounded,
    this.dashboardPath = '/bus-driver/dashboard',
  });

  @override
  State<FleetDriverLoginScreen> createState() => _FleetDriverLoginScreenState();
}

class _FleetDriverLoginScreenState extends State<FleetDriverLoginScreen> {
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmail(String input) => input.contains('@') && input.contains('.');
  String _normalizePhone(String raw) {
    final hasPlus = raw.trim().startsWith('+');
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (hasPlus) return '+$digits';
    if (digits.startsWith('03') && digits.length == 11)
      return '+92${digits.substring(1)}';
    if (digits.startsWith('3') && digits.length == 10) return '+92$digits';
    if (digits.startsWith('92') && digits.length == 12) return '+$digits';
    return digits;
  }

  Future<void> _handleLogin() async {
    final identity = _identityController.text.trim();
    final password = _passwordController.text;
    if (identity.isEmpty) {
      setState(() => _errorMessage = 'Enter your email or phone');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();
      final body = <String, dynamic>{'password': password};
      if (_isEmail(identity)) {
        body['email'] = identity;
      } else {
        body['phone'] = _normalizePhone(identity);
      }
      final response = await api.post(
        widget.loginEndpoint,
        body: body,
        requiresAuth: false,
      );
      if (!mounted) return;
      final token = response['token']?.toString();
      if (token == null || token.isEmpty) throw Exception('No token');
      await ApiClient().setAuthToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'driver_name',
        response['data']?['account_name']?.toString() ?? 'Driver',
      );
      if (!mounted) return;
      context.go('/bus-driver/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Login failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(widget.appIcon, size: 42, color: Colors.white),
                ),
                const Gap(18),
                Text(
                  widget.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Gap(36),
                TextFormField(
                  controller: _identityController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email or Phone Number',
                    hintText: 'driver@example.com  or  0300 1234567',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const Gap(14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                if (_errorMessage != null) ...[
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
                const Gap(24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
