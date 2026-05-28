// Panel Auth Bloc — Centralised multi-panel authentication state machine
//
// Handles login/logout for all 6 panels (Super Admin, Factory, Marketplace,
// Truck Fleet, Bus Fleet, Consumer) through a single bloc instance.
//
// Wire-up (in AppProviders or AppInitializer):
//   BlocProvider<PanelAuthBloc>(
//     create: (ctx) => PanelAuthBloc(
//       repository: PanelAuthRepository(
//         client: NexaTraceApiClient.instance,
//         secureStorage: secureStorage,
//       ),
//     ),
//   );
//
// On successful handshake, the bloc:
//   1. Persists tokens to flutter_secure_storage
//   2. Reads `driver_type` from the response
//   3. Validates against `EnsureDriverType` boundaries (Step 19)
//   4. Emits `PanelAuthAuthenticated` with full `PanelAuthResponse`

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:trace_odd/core/network/network_exceptions.dart';
import 'package:trace_odd/core/errors/app_exceptions.dart';
import 'package:trace_odd/features/auth/data/repositories/panel_auth_repository.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_event.dart';
import 'package:trace_odd/features/auth/presentation/bloc/panel_auth_state.dart';

class PanelAuthBloc extends Bloc<PanelAuthEvent, PanelAuthState> {
  final PanelAuthRepository _repository;

  PanelAuthBloc({required PanelAuthRepository repository})
    : _repository = repository,
      super(const PanelAuthInitial()) {
    on<PanelLoginRequested>(_onLogin);
    on<PanelLogoutRequested>(_onLogout);
    on<CheckPanelAuthStatus>(_onCheckSession);
    on<ClearPanelAuthErrors>(_onClearError);
  }

  // ── Login handler ─────────────────────────────────────────

  Future<void> _onLogin(
    PanelLoginRequested event,
    Emitter<PanelAuthState> emit,
  ) async {
    emit(const PanelAuthLoading());

    try {
      final response = await _repository.login(
        panel: event.panel,
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
        companyId: event.companyId,
      );

      if (kDebugMode) {
        debugPrint(
          'PANEL_AUTH_BLOC: Login success — panel=${response.panel.label}, '
          'userId=${response.userId}, driverType=${response.driverType ?? "none"}',
        );
      }

      emit(PanelAuthAuthenticated(response: response));
    } on DriverTypeMismatchException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'PANEL_AUTH_BLOC: Driver type mismatch — '
          'actual=${e.actualDriverType}, required=${e.requiredDriverType}',
        );
      }
      emit(PanelAuthError(
        message:
            'Access denied: Driver type \'${e.actualDriverType}\' is not '
            'authorized for this panel. Allowed: ${e.requiredDriverType}.',
        isDriverTypeMismatch: true,
      ));
    } on UnauthorizedException {
      emit(const PanelAuthError(
        message: 'Invalid email or password. Please try again.',
        isInvalidCredentials: true,
      ));
    } on NetworkException catch (e) {
      emit(PanelAuthError(
        message: e.message,
        isNetworkError: true,
      ));
    } on AuthException catch (e) {
      emit(PanelAuthError(
        message: e.message,
        isInvalidCredentials:
            e.message.toLowerCase().contains('invalid') ||
            e.message.toLowerCase().contains('password'),
        isAccountSuspended:
            e.message.toLowerCase().contains('suspended'),
      ));
    } catch (e) {
      emit(PanelAuthError(
        message: 'Login failed: ${e.toString()}',
      ));
    }
  }

  // ── Logout handler ────────────────────────────────────────

  Future<void> _onLogout(
    PanelLogoutRequested event,
    Emitter<PanelAuthState> emit,
  ) async {
    emit(const PanelAuthLoading());

    try {
      await _repository.logout(event.panel);
    } catch (_) {
      // Always clear local state even if API call fails.
    }

    emit(PanelAuthUnauthenticated(
      message: 'You have been logged out.',
    ));
  }

  // ── Session check handler ─────────────────────────────────

  Future<void> _onCheckSession(
    CheckPanelAuthStatus event,
    Emitter<PanelAuthState> emit,
  ) async {
    emit(const PanelAuthLoading());

    try {
      final isAuthed = await _repository.isAuthenticated(event.panel);
      if (isAuthed) {
        final token = await _repository.getStoredToken(event.panel);
        final driverType =
            await _repository.getStoredDriverType(event.panel);

        if (token != null) {
          // Build a minimal response from stored data.
          final response = PanelAuthResponse(
            panel: event.panel,
            token: token,
            userId: '',
            driverType: driverType,
            rawUser: const {},
          );
          emit(PanelAuthAuthenticated(response: response));
          return;
        }
      }
      emit(const PanelAuthUnauthenticated());
    } catch (_) {
      emit(const PanelAuthUnauthenticated());
    }
  }

  // ── Clear error handler ───────────────────────────────────

  void _onClearError(
    ClearPanelAuthErrors event,
    Emitter<PanelAuthState> emit,
  ) {
    emit(const PanelAuthInitial());
  }
}
