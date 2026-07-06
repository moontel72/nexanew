// Panel Auth State — Immutable states for multi-panel authentication bloc
// Matches the backend data structure from Setup 1's PanelAuthState.

import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/navigation/panel_routes.dart'
    hide PanelAuthState;
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';

abstract class PanelAuthState extends Equatable {
  const PanelAuthState();
}

/// Idle — no authentication attempt in progress.
class PanelAuthInitial extends PanelAuthState {
  const PanelAuthInitial();
  @override
  List<Object?> get props => [];
}

/// Login request is in-flight.
class PanelAuthLoading extends PanelAuthState {
  const PanelAuthLoading();
  @override
  List<Object?> get props => [];
}

/// Authentication succeeded.
class PanelAuthAuthenticated extends PanelAuthState {
  final PanelAuthResponse response;

  const PanelAuthAuthenticated({required this.response});

  UserPanel get panel => response.panel;
  String get token => response.token;
  String get userId => response.userId;

  @override
  List<Object?> get props => [response];
}

/// User is not authenticated.
class PanelAuthUnauthenticated extends PanelAuthState {
  final String? message;

  const PanelAuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

/// Authentication failed with a recoverable error.
class PanelAuthError extends PanelAuthState {
  final String message;
  final bool isNetworkError;
  final bool isInvalidCredentials;
  final bool isDriverTypeMismatch;
  final bool isAccountSuspended;

  const PanelAuthError({
    required this.message,
    this.isNetworkError = false,
    this.isInvalidCredentials = false,
    this.isDriverTypeMismatch = false,
    this.isAccountSuspended = false,
  });

  @override
  List<Object?> get props => [
    message,
    isNetworkError,
    isInvalidCredentials,
    isDriverTypeMismatch,
    isAccountSuspended,
  ];
}
