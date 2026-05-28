// Factory Auth Bloc for NexaTrace System
// Business logic for factory authentication operations

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'package:trace_odd/features/factory/admin/data/repositories/factory_auth_repository.dart';

// Events
abstract class FactoryAuthEvent {}

class FactoryLoginRequested extends FactoryAuthEvent {
  final String email;
  final String password;
  final bool? rememberMe;

  FactoryLoginRequested({
    required this.email,
    required this.password,
    this.rememberMe,
  });
}

class FactoryLogoutRequested extends FactoryAuthEvent {}

class CheckFactoryAuthStatus extends FactoryAuthEvent {}

// States
abstract class FactoryAuthState {}

class FactoryAuthInitial extends FactoryAuthState {}

class FactoryAuthLoading extends FactoryAuthState {}

class FactoryAuthAuthenticated extends FactoryAuthState {
  final Map<String, dynamic> user;
  final String token;
  final DateTime? tokenExpiry;
  final bool? needsPasswordChange;

  FactoryAuthAuthenticated({
    required this.user,
    required this.token,
    this.tokenExpiry,
    this.needsPasswordChange,
  });
}

class FactoryAuthUnauthenticated extends FactoryAuthState {
  final String? message;

  FactoryAuthUnauthenticated({this.message});
}

class FactoryAuthError extends FactoryAuthState {
  final String message;
  final bool isNetworkError;
  final bool isServerError;
  final bool isInvalidCredentials;
  final bool isAccountSuspended;

  FactoryAuthError({
    required this.message,
    this.isNetworkError = false,
    this.isServerError = false,
    this.isInvalidCredentials = false,
    this.isAccountSuspended = false,
  });
}

class FactoryAuthBloc extends Bloc<FactoryAuthEvent, FactoryAuthState> {
  final FactoryAuthRepository _authRepository;

  Timer? _sessionTimer;
  Timer? _tokenRefreshTimer;

  FactoryAuthBloc({
    required FactoryAuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(FactoryAuthInitial()) {
    on<FactoryLoginRequested>(_onLogin);
    on<FactoryLogoutRequested>(_onLogout);
    on<CheckFactoryAuthStatus>(_onCheckSession);
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    return super.close();
  }

  Future<void> _onLogin(
    FactoryLoginRequested event,
    Emitter<FactoryAuthState> emit,
  ) async {
    emit(FactoryAuthLoading());

    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
        companyId: null, // Factory admin doesn't need company ID
      );

      // Parse the response
      final token = response['token'] as String?;
      final userData = response['user'] as Map<String, dynamic>? ?? response;

      if (token == null) {
        throw Exception('No authentication token received');
      }

      // Set factory authentication state
      setFactoryAuthState(
        isAuthenticated: true,
        userType: 'factory',
        userId: userData['id']?.toString() ?? '',
        token: token,
        factoryId: userData['company_id']?.toString(),
      );

      // Start session management
      _startSessionManagement();

      emit(FactoryAuthAuthenticated(
        user: userData,
        token: token,
        tokenExpiry: DateTime.now().add(const Duration(hours: 24)),
        needsPasswordChange: false,
      ));
    } catch (error) {
      final errorMessage = error.toString();
      emit(FactoryAuthError(
        message: errorMessage,
        isNetworkError: errorMessage.toLowerCase().contains('network') ||
            errorMessage.toLowerCase().contains('timeout'),
        isServerError: errorMessage.toLowerCase().contains('server') ||
            errorMessage.toLowerCase().contains('internal'),
        isInvalidCredentials: errorMessage.toLowerCase().contains('invalid') ||
            errorMessage.toLowerCase().contains('credentials'),
        isAccountSuspended: errorMessage.toLowerCase().contains('suspended'),
      ));
    }
  }

  Future<void> _onLogout(
    FactoryLogoutRequested event,
    Emitter<FactoryAuthState> emit,
  ) async {
    emit(FactoryAuthLoading());

    try {
      await _authRepository.logout();

      // Reset factory auth state
      resetFactoryAuthState();

      _sessionTimer?.cancel();
      _tokenRefreshTimer?.cancel();

      emit(FactoryAuthUnauthenticated(message: 'Logged out successfully'));
    } catch (error) {
      // Even if logout fails, clear local auth data
      resetFactoryAuthState();

      _sessionTimer?.cancel();
      _tokenRefreshTimer?.cancel();

      emit(FactoryAuthUnauthenticated(message: 'Logged out successfully'));
    }
  }

  Future<void> _onCheckSession(
    CheckFactoryAuthStatus event,
    Emitter<FactoryAuthState> emit,
  ) async {
    emit(FactoryAuthLoading());

    try {
      final profile = await _authRepository.profile();

      if (profile['id'] != null) {
        // Factory is authenticated
        emit(FactoryAuthAuthenticated(
          user: profile,
          token: '', // Token is stored in secure storage
          tokenExpiry: DateTime.now().add(const Duration(hours: 24)),
          needsPasswordChange: false,
        ));
      } else {
        emit(FactoryAuthUnauthenticated());
      }
    } catch (error) {
      emit(FactoryAuthUnauthenticated());
    }
  }

  /// Start session management timers
  void _startSessionManagement() {
    // Cancel existing timers
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();

    // Set up session expiry timer (24 hours)
    _sessionTimer = Timer(const Duration(hours: 24), () {
      add(FactoryLogoutRequested());
    });

    // Set up token refresh timer (23.5 hours)
    _tokenRefreshTimer = Timer(const Duration(hours: 23, minutes: 30), () {
      // In a real implementation, this would refresh the token
      // For now, we'll just log out when token expires
      add(FactoryLogoutRequested());
    });
  }
}
