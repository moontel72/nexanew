import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:trace_odd/core/errors/failures.dart';
import 'package:trace_odd/core/utils/auth_state.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/admin_auth_repository.dart';

import 'admin_auth_event.dart';
import 'admin_auth_state.dart';

class AdminAuthBloc extends Bloc<AdminAuthEvent, AdminAuthState> {
  final AdminAuthRepository _authRepository;

  Timer? _sessionTimer;
  Timer? _tokenRefreshTimer;

  AdminAuthBloc({
    required AdminAuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AdminAuthInitial()) {
    on<AdminLoginRequested>(_onLogin);
    on<AdminLogoutRequested>(_onLogout);
    on<CheckAdminAuthStatus>(_onCheckSession);
    on<RefreshAdminToken>(_onRefreshToken);
    on<ChangeAdminPassword>(_onChangePassword);
    on<AdminPasswordResetRequested>(_onForgotPassword);
    on<ClearAuthErrors>(_onClearError);
    on<UpdateAdminProfile>(_onUpdateProfile);
    on<ValidateAdminSession>(_onValidateSession);
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    return super.close();
  }

  Future<void> _onLogin(
    AdminLoginRequested event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(const AdminAuthLoading());

    try {
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
        twoFactorCode: event.twoFactorCode,
      );

      _startSessionManagement(response.tokenExpiry);

      emit(AdminAuthAuthenticated(
        user: response.user,
        token: response.token,
        tokenExpiry: response.tokenExpiry,
        needsPasswordChange: response.needsPasswordChange,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(AdminAuthError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isInvalidCredentials:
            failure.message.toLowerCase().contains('invalid email') ||
                failure.message.toLowerCase().contains('invalid password'),
        isAccountSuspended: failure.message.toLowerCase().contains('suspended'),
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onLogout(
    AdminLogoutRequested event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(const AdminAuthLoading());

    try {
      final token = await _authRepository.getAuthToken();
      if (token != null) {
        await _authRepository.logout(token);
      }
      await _authRepository.clearAuthData();

      // Reset global auth state
      resetAuthState();

      _sessionTimer?.cancel();
      _tokenRefreshTimer?.cancel();

      emit(const AdminAuthUnauthenticated(message: 'Logged out successfully'));
    } catch (error) {
      await _authRepository.clearAuthData();

      // Reset global auth state
      resetAuthState();

      _sessionTimer?.cancel();
      _tokenRefreshTimer?.cancel();
      emit(const AdminAuthUnauthenticated(message: 'Logged out successfully'));
    }
  }

  Future<void> _onCheckSession(
    CheckAdminAuthStatus event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(const AdminAuthLoading());

    try {
      final token = await _authRepository.getAuthToken();
      final user = await _authRepository.getCurrentUser();
      final tokenExpiry = await _authRepository.getTokenExpiry();

      if (token == null || user == null || tokenExpiry == null) {
        emit(const AdminAuthUnauthenticated());
        return;
      }

      final isValid = await _authRepository.validateToken(token);
      if (!isValid) {
        emit(const AdminAuthUnauthenticated());
        return;
      }

      _startSessionManagement(tokenExpiry);

      emit(AdminAuthAuthenticated(
        user: user,
        token: token,
        tokenExpiry: tokenExpiry,
        needsPasswordChange: false,
      ));
    } catch (_) {
      emit(const AdminAuthUnauthenticated());
    }
  }

  Future<void> _onRefreshToken(
    RefreshAdminToken event,
    Emitter<AdminAuthState> emit,
  ) async {
    if (state is! AdminAuthAuthenticated) {
      return;
    }

    final currentState = state as AdminAuthAuthenticated;
    final refreshToken = await _authRepository.getRefreshToken();
    if (refreshToken == null) {
      emit(const AdminAuthUnauthenticated(message: 'Session expired'));
      return;
    }

    emit(const AdminAuthLoading());

    try {
      final response = await _authRepository.refreshToken(
        token: currentState.token,
        refreshToken: refreshToken,
      );

      _startSessionManagement(response.tokenExpiry);

      emit(AdminAuthAuthenticated(
        user: response.user,
        token: response.token,
        tokenExpiry: response.tokenExpiry,
        needsPasswordChange: response.needsPasswordChange,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(AdminAuthError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onChangePassword(
    ChangeAdminPassword event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(const AdminAuthLoading());

    try {
      await _authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(const AdminAuthUnauthenticated(
          message: 'Password changed successfully'));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(AdminAuthError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onForgotPassword(
    AdminPasswordResetRequested event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(const AdminAuthLoading());

    try {
      await _authRepository.forgotPassword(email: event.email);
      emit(const AdminAuthUnauthenticated(
        message: 'Password reset link sent to your email',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(AdminAuthError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: true,
        stackTrace: stackTrace,
      ));
    }
  }

  void _onClearError(
    ClearAuthErrors event,
    Emitter<AdminAuthState> emit,
  ) {
    emit(const AdminAuthInitial());
  }

  Future<void> _onUpdateProfile(
    UpdateAdminProfile event,
    Emitter<AdminAuthState> emit,
  ) async {
    emit(const AdminAuthLoading());

    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        emit(const AdminAuthUnauthenticated());
        return;
      }

      final updatedUser = await _authRepository.updateProfile(
        token: token,
        name: event.name,
        email: event.email,
        phone: event.phone,
        profileImage: event.profileImage,
      );

      if (state is AdminAuthAuthenticated) {
        final currentState = state as AdminAuthAuthenticated;
        emit(AdminAuthAuthenticated(
          user: updatedUser,
          token: currentState.token,
          tokenExpiry: currentState.tokenExpiry,
          needsPasswordChange: currentState.needsPasswordChange,
        ));
        return;
      }

      emit(const AdminAuthUnauthenticated(
          message: 'Profile updated successfully'));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(AdminAuthError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: true,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onValidateSession(
    ValidateAdminSession event,
    Emitter<AdminAuthState> emit,
  ) async {
    try {
      if (state is! AdminAuthAuthenticated) {
        return;
      }

      final currentState = state as AdminAuthAuthenticated;
      final isValid = await _authRepository.validateToken(currentState.token);

      if (!isValid) {
        emit(const AdminAuthUnauthenticated(
          message: 'Session expired. Please login again.',
        ));
      }
    } catch (_) {}
  }

  void _startSessionManagement(DateTime tokenExpiry) {
    _sessionTimer?.cancel();
    _tokenRefreshTimer?.cancel();

    final now = DateTime.now();
    final timeUntilExpiry = tokenExpiry.difference(now);

    if (timeUntilExpiry.isNegative) {
      add(const ValidateAdminSession());
      return;
    }

    _sessionTimer = Timer(timeUntilExpiry, () {
      add(const ValidateAdminSession());
    });

    final refreshAt = timeUntilExpiry - const Duration(minutes: 5);
    if (refreshAt.isNegative) {
      return;
    }

    _tokenRefreshTimer = Timer(refreshAt, () {
      add(const RefreshAdminToken());
    });
  }
}
