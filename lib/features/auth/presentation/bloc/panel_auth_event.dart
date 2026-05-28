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

  const PanelLoginRequested({
    required this.panel,
    required this.email,
    required this.password,
    this.rememberMe = false,
    this.companyId,
  });

  @override
  List<Object?> get props => [panel, email, password, rememberMe, companyId];
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
