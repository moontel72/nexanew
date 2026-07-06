// Fleet BLoC Login Screen — Wave 0 Auth Consolidation
// =====================================================
// Reusable login widget backed by PanelAuthBloc for all fleet panel apps.
// Replaces the 4 near-identical setState-based login screens:
//   BusFleetLoginScreen, OwnerLoginScreen, FleetDriverLoginScreen,
//   FleetConductorLoginScreen.
//
// Usage:
//   FleetBlocLoginScreen(
//     panel: UserPanel.busFleet,
//     loginConfig: const FleetLoginConfig.busFleet(),
//     onAuthenticated: (ctx, response) => ctx.go('/bus-fleet/dashboard'),
//   );

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart'
    hide PanelAuthState;
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_bloc.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_event.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_state.dart';

// ─────────────────────────────────────────────────────────────
// Login Configuration
// ─────────────────────────────────────────────────────────────

/// Configures the login form appearance and the extra metadata sent
/// to the backend for fleet-specific routing.
class FleetLoginConfig {
  /// Button / header accent colour.
  final Color accentColor;

  /// Icon shown above the form.
  final IconData headerIcon;

  /// Header title text.
  final String headerTitle;

  /// Header subtitle text.
  final String headerSubtitle;

  /// Optional role segments shown below the header (e.g. Admin / Storekeeper).
  /// Each segment maps to a metadata key-value pair sent on login.
  final List<FleetRoleSegment>? roleSegments;

  /// Extra key-value pairs merged into the login request body for this panel.
  final Map<String, dynamic> baseMetadata;

  /// Label for the identity field (email or phone).
  final String identityLabel;

  /// Hint for the identity field.
  final String identityHint;

  const FleetLoginConfig({
    required this.accentColor,
    required this.headerIcon,
    required this.headerTitle,
    required this.headerSubtitle,
    this.roleSegments,
    this.baseMetadata = const {},
    this.identityLabel = 'Email or Phone',
    this.identityHint = '',
  });

  /// Bus Fleet / Bus Owner login configuration.
  factory FleetLoginConfig.busOwner() => const FleetLoginConfig(
    accentColor: Color(0xFF00C49F),
    headerIcon: Icons.directions_bus,
    headerTitle: 'Bus Owner Portal',
    headerSubtitle: 'Sign in to manage your fleet',
    roleSegments: [
      FleetRoleSegment(
        value: 'owner',
        label: 'Bus Owner',
        icon: Icons.directions_bus,
      ),
      FleetRoleSegment(
        value: 'store_keeper',
        label: 'Storekeeper',
        icon: Icons.inventory_2,
      ),
    ],
    baseMetadata: {'fleet_type': 'bus'},
    identityHint: 'Email or phone number',
  );

  /// Bus Fleet Admin panel configuration (supports Admin + Storekeeper dual role).
  factory FleetLoginConfig.busFleet() => const FleetLoginConfig(
    accentColor: Color(0xFF00B4D8),
    headerIcon: Icons.directions_bus,
    headerTitle: 'NexaTrace Bus Fleet',
    headerSubtitle: 'Corporate Fleet Panel',
    roleSegments: [
      FleetRoleSegment(
        value: 'owner',
        label: 'Admin',
        icon: Icons.admin_panel_settings,
      ),
      FleetRoleSegment(
        value: 'store_keeper',
        label: 'Storekeeper',
        icon: Icons.inventory_2,
      ),
    ],
    baseMetadata: {'fleet_type': 'bus'},
    identityHint: 'Email or phone',
  );

  /// Driver login configuration (Bus Driver / Truck Driver).
  factory FleetLoginConfig.driver({required String appTitle}) =>
      FleetLoginConfig(
        accentColor: const Color(0xFF2563EB),
        headerIcon: Icons.badge_rounded,
        headerTitle: appTitle,
        headerSubtitle: 'Sign in to your driver terminal',
        identityHint: 'driver@example.com  or  0300 1234567',
      );

  /// Conductor login configuration (Bus Conductor / Truck Conductor).
  factory FleetLoginConfig.conductor({required String appTitle}) =>
      FleetLoginConfig(
        accentColor: const Color(0xFF2563EB),
        headerIcon: Icons.group_rounded,
        headerTitle: appTitle,
        headerSubtitle: 'Sign in to your crew terminal',
        identityHint: 'Email or phone number',
      );

  /// Truck Owner login configuration.
  factory FleetLoginConfig.truckOwner() => const FleetLoginConfig(
    accentColor: Color(0xFFF59E0B),
    headerIcon: Icons.local_shipping,
    headerTitle: 'Truck Owner Portal',
    headerSubtitle: 'Sign in to manage your fleet',
    baseMetadata: {'fleet_type': 'truck'},
    identityHint: 'Email or phone number',
  );

  /// Truck Driver login configuration.
  factory FleetLoginConfig.truckDriver() => const FleetLoginConfig(
    accentColor: Color(0xFFF59E0B),
    headerIcon: Icons.local_shipping_rounded,
    headerTitle: 'Truck Driver Portal',
    headerSubtitle: 'Sign in to your driver terminal',
    baseMetadata: {'fleet_type': 'truck'},
    identityHint: 'driver@example.com  or  0300 1234567',
  );

  /// Truck Conductor login configuration.
  factory FleetLoginConfig.truckConductor() => const FleetLoginConfig(
    accentColor: Color(0xFFF59E0B),
    headerIcon: Icons.local_shipping_rounded,
    headerTitle: 'Truck Conductor Portal',
    headerSubtitle: 'Sign in to your crew terminal',
    baseMetadata: {'fleet_type': 'truck'},
    identityHint: 'Email or phone number',
  );
}

/// A selectable role shown in a SegmentedButton below the header.
class FleetRoleSegment {
  final String value;
  final String label;
  final IconData icon;

  const FleetRoleSegment({
    required this.value,
    required this.label,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────
// Login Screen Widget
// ─────────────────────────────────────────────────────────────

class FleetBlocLoginScreen extends StatefulWidget {
  /// The panel this login authenticates into.
  final UserPanel panel;

  /// Visual configuration for the form.
  final FleetLoginConfig loginConfig;

  /// Called after authentication succeeds. Receives the build context and the
  /// full [PanelAuthResponse]. Typically uses `context.go(...)` to navigate.
  final void Function(BuildContext context, PanelAuthResponse response)?
  onAuthenticated;

  const FleetBlocLoginScreen({
    super.key,
    required this.panel,
    required this.loginConfig,
    this.onAuthenticated,
  });

  @override
  State<FleetBlocLoginScreen> createState() => _FleetBlocLoginScreenState();
}

class _FleetBlocLoginScreenState extends State<FleetBlocLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identityCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _selectedRole = 'owner';
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Default to the first role segment if available.
    final segs = widget.loginConfig.roleSegments;
    if (segs != null && segs.isNotEmpty) {
      _selectedRole = segs.first.value;
    }
  }

  @override
  void dispose() {
    _identityCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _isEmail(String input) => input.contains('@') && input.contains('.');

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final identity = _identityCtrl.text.trim();
    final bloc = context.read<PanelAuthBloc>();

    // Build metadata: base + selected role's fleet_role (if applicable).
    final metadata = Map<String, dynamic>.from(widget.loginConfig.baseMetadata);
    final segs = widget.loginConfig.roleSegments;
    if (segs != null) {
      final seg = segs.firstWhere(
        (s) => s.value == _selectedRole,
        orElse: () => segs.first,
      );
      if (seg.value != 'owner') {
        metadata['fleet_role'] = seg.value;
      }
    }

    bloc.add(
      PanelLoginRequested(
        panel: widget.panel,
        email: _isEmail(identity) ? identity : identity,
        password: _passCtrl.text,
        identifier: identity,
        metadata: metadata,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.loginConfig;

    return BlocConsumer<PanelAuthBloc, PanelAuthState>(
      listener: _onStateChange,
      builder: (context, state) {
        final isLoading = state is PanelAuthLoading;
        final error = state is PanelAuthError ? state.message : null;

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
                      // Header
                      Icon(cfg.headerIcon, size: 48, color: cfg.accentColor),
                      const SizedBox(height: 8),
                      Text(
                        cfg.headerTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cfg.headerSubtitle,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Role selector (optional)
                      if (cfg.roleSegments != null) ...[
                        _buildRoleSelector(cfg, isLoading),
                        const SizedBox(height: 20),
                      ],

                      // Identity field
                      TextFormField(
                        controller: _identityCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec(
                          cfg.identityLabel,
                          prefix: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Password field
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dec('Password', prefix: Icons.lock_outline)
                            .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white38,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                        validator: (v) =>
                            (v == null || v.length < 4) ? 'Min 4 chars' : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 8),

                      // Error banner
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            error,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cfg.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
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
      },
    );
  }

  void _onStateChange(BuildContext context, PanelAuthState state) {
    if (state is PanelAuthAuthenticated) {
      final cb = widget.onAuthenticated;
      if (cb != null) {
        cb(context, state.response);
        return;
      }
      // Default: navigate to the panel's dashboard route prefix.
      if (context.mounted) {
        context.go('${widget.panel.routePrefix}/dashboard');
      }
    }
  }

  Widget _buildRoleSelector(FleetLoginConfig cfg, bool isLoading) {
    final segs = cfg.roleSegments!;
    return SegmentedButton<String>(
      segments: segs.map((seg) {
        return ButtonSegment<String>(
          value: seg.value,
          label: Text(
            seg.label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: Icon(seg.icon, size: 16, color: Colors.white),
        );
      }).toList(),
      selected: {_selectedRole},
      onSelectionChanged: isLoading
          ? null
          : (v) => setState(() => _selectedRole = v.first),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return cfg.accentColor.withOpacity(0.35);
          }
          return const Color(0xFF1B2838);
        }),
        side: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) {
            return BorderSide(color: cfg.accentColor, width: 1.5);
          }
          return BorderSide.none;
        }),
      ),
    );
  }

  InputDecoration _dec(String hint, {IconData? prefix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    prefixIcon: prefix != null ? Icon(prefix, color: Colors.white38) : null,
    filled: true,
    fillColor: const Color(0xFF1B2838),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
