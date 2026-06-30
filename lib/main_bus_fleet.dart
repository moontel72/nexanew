/// Bus Fleet Admin Web Panel — Unified entry point
///
/// Role-based routing:
///   - Admins / Fleet Owners → Full OwnerDashboardScreen
///   - Bus Catering Storekeepers  → ONLY the StorekeeperDashboardScreen (3 tabs)
///
/// Uses the unified /auth/login endpoint. The backend resolves the fleet_role
/// from fleet_assignments and returns it in the login response.
///
/// Deployed at /var/www/traceodd/bus-fleet/
/// Served via Nginx: location /bus-fleet/
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/owner_dashboard.dart';
import 'package:trace_odd/features/storekeeper/presentation/screens/storekeeper_dashboard_screen.dart';
import 'package:trace_odd/shared/app_scaffold.dart';
import 'package:trace_odd/core/constants/user_roles.dart';

void main() => FleetApp.run(
  title: 'NexaTrace Bus Fleet',
  loginScreen: const BusFleetLoginScreen(),
  dashboardScreen: const _BusFleetRouter(),
  loginPath: '/bus-fleet/login',
  dashboardPath: '/bus-fleet/dashboard',
);

/// Bus Fleet Login — accepts owner or storekeeper credentials.
class BusFleetLoginScreen extends StatefulWidget {
  const BusFleetLoginScreen({super.key});

  @override
  State<BusFleetLoginScreen> createState() => _BusFleetLoginScreenState();
}

class _BusFleetLoginScreenState extends State<BusFleetLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _selectedRole =
      'owner'; // Admin (no fleet_role sent) or store_keeper (via UserRoles)
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final payload = <String, dynamic>{
        'identifier': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'fleet_type': 'bus',
      };
      // Only storekeepers send fleet_role — admins authenticate via account_type pass-through
      if (_selectedRole == UserRoles.storeKeeper) {
        payload['fleet_role'] = UserRoles.storeKeeper;
      }
      final res = await ApiService().post(
        '/auth/login',
        data: payload,
        requiresAuth: false,
      );

      if (res == null || res['token'] == null) {
        if (mounted)
          setState(() {
            _error = 'Invalid credentials';
            _loading = false;
          });
        return;
      }

      final token = res['token'] as String;
      final userData = res['data'] as Map<String, dynamic>? ?? {};
      final assignment = userData['assignment'] as Map<String, dynamic>? ?? {};
      final fleetRole =
          assignment['role']?.toString() ??
          userData['fleet_role']?.toString() ??
          _selectedRole;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('fleet_role', fleetRole);
      await prefs.setString(
        'bus_owner_name',
        userData['account_name']?.toString() ??
            userData['display_name']?.toString() ??
            'User',
      );

      if (mounted) context.go('/bus-fleet/dashboard');
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      return;
    }
    // Loading reset handled in catch and early-return paths above
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_bus,
                    size: 48,
                    color: Color(0xFF00B4D8),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'NexaTrace Bus Fleet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Corporate Fleet Panel',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // Role selector — Admin or Storekeeper for corporate fleet
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'owner',
                        label: Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: Icon(
                          Icons.admin_panel_settings,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      ButtonSegment(
                        value: UserRoles.storeKeeper,
                        label: const Text(
                          'Storekeeper',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: Icon(
                          Icons.inventory_2,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: _loading
                        ? null
                        : (v) => setState(() => _selectedRole = v.first),
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith((s) {
                        if (s.contains(WidgetState.selected)) {
                          return const Color(0xFF00B4D8).withOpacity(0.35);
                        }
                        return const Color(0xFF1B2838);
                      }),
                      side: WidgetStateProperty.resolveWith((s) {
                        if (s.contains(WidgetState.selected)) {
                          return const BorderSide(
                            color: Color(0xFF00B4D8),
                            width: 1.5,
                          );
                        }
                        return BorderSide.none;
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec('Email or Phone'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white38,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 4) ? 'Min 4 chars' : null,
                  ),
                  const SizedBox(height: 8),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4D8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: const Color(0xFF1B2838),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

/// Router widget: decides which dashboard to show based on stored fleet_role.
///
/// - store_keeper → StorekeeperDashboardScreen (3 tabs, no fleet/finance)
/// - owner / admin → Full OwnerDashboardScreen
class _BusFleetRouter extends StatefulWidget {
  const _BusFleetRouter();

  @override
  State<_BusFleetRouter> createState() => _BusFleetRouterState();
}

class _BusFleetRouterState extends State<_BusFleetRouter> {
  bool _checking = true;
  bool _isStorekeeper = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('fleet_role') ?? '';
    if (mounted) {
      setState(() {
        _isStorekeeper = UserRoles.isFleetStorekeeper(role);
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isStorekeeper) {
      return const StorekeeperDashboardScreen(isStorekeeperOnly: true);
    }

    return const OwnerDashboardScreen(
      loginRoute: '/bus-fleet/login',
      panelPrefix: '/bus-fleet',
    );
  }
}
