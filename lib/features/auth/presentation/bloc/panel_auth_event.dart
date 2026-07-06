// Panel Auth Events — Events for multi-panel authentication bloc

import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart';

abstract class PanelAuthEvent extends Equatable {
  const PanelAuthEvent();
  @override
  List<Object?> get props => [];
}

/// User tapped "Sign In" on a login form.
class PanelLoginRequested extends PanelAuthEvent {
  final UserPanel panel;
  final String email;
  final String password;
  final bool rememberMe;
  final String? companyId;

  /// Raw user input (email or phone number). When set, takes precedence
  /// over [email] in the API payload so fleet panels can send `identifier`.
  final String? identifier;

  /// Arbitrary key-value pairs forwarded to the login endpoint body.
  /// Used for panel-specific fields like `fleet_type`, `fleet_role`.
  final Map<String, dynamic> metadata;

  const PanelLoginRequested({
    required this.panel,
    required this.email,
    required this.password,
    this.rememberMe = false,
    this.companyId,
    this.identifier,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    panel,
    email,
    password,
    rememberMe,
    companyId,
    identifier,
    metadata,
  ];
}

/// User tapped "Logout".
class PanelLogoutRequested extends PanelAuthEvent {
  final UserPanel panel;

  const PanelLogoutRequested({required this.panel});

  @override
  List<Object?> get props => [panel];
}

/// Check whether a valid session exists for [panel].
class CheckPanelAuthStatus extends PanelAuthEvent {
  final UserPanel panel;

  const CheckPanelAuthStatus({required this.panel});

  @override
  List<Object?> get props => [panel];
}

/// Clear any error state.
class ClearPanelAuthErrors extends PanelAuthEvent {
  const ClearPanelAuthErrors();
}
