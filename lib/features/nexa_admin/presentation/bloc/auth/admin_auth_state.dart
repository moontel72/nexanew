import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/admin_user.dart';

abstract class AdminAuthState extends Equatable {
  const AdminAuthState();

  @override
  List<Object?> get props => const [];
}

class AdminAuthInitial extends AdminAuthState {
  const AdminAuthInitial();
}

class AdminAuthLoading extends AdminAuthState {
  const AdminAuthLoading();
}

class AdminAuthAuthenticated extends AdminAuthState {
  final AdminUser user;
  final String token;
  final DateTime tokenExpiry;
  final bool needsPasswordChange;

  const AdminAuthAuthenticated({
    required this.user,
    required this.token,
    required this.tokenExpiry,
    required this.needsPasswordChange,
  });

  @override
  List<Object?> get props => [user, token, tokenExpiry, needsPasswordChange];
}

class AdminAuthUnauthenticated extends AdminAuthState {
  final String? message;

  const AdminAuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AdminAuthAccountLocked extends AdminAuthState {
  final String message;
  final DateTime? unlockTime;

  const AdminAuthAccountLocked({required this.message, this.unlockTime});

  @override
  List<Object?> get props => [message, unlockTime];
}

class AdminAuthError extends AdminAuthState {
  final String message;
  final bool isNetworkError;
  final bool isServerError;
  final bool isValidationError;
  final bool isInvalidCredentials;
  final bool isAccountSuspended;
  final StackTrace? stackTrace;

  const AdminAuthError({
    required this.message,
    this.isNetworkError = false,
    this.isServerError = false,
    this.isValidationError = false,
    this.isInvalidCredentials = false,
    this.isAccountSuspended = false,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [
        message,
        isNetworkError,
        isServerError,
        isValidationError,
        isInvalidCredentials,
        isAccountSuspended,
        stackTrace,
      ];
}

