import 'package:equatable/equatable.dart';

abstract class AdminAuthEvent extends Equatable {
  const AdminAuthEvent();

  @override
  List<Object?> get props => const [];
}

class AdminLoginRequested extends AdminAuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  final String? twoFactorCode;

  const AdminLoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
    this.twoFactorCode,
  });

  @override
  List<Object?> get props => [email, password, rememberMe, twoFactorCode];
}

class AdminLogoutRequested extends AdminAuthEvent {
  const AdminLogoutRequested();
}

class CheckAdminAuthStatus extends AdminAuthEvent {
  const CheckAdminAuthStatus();
}

class RefreshAdminToken extends AdminAuthEvent {
  const RefreshAdminToken();
}

class ChangeAdminPassword extends AdminAuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangeAdminPassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

class AdminPasswordResetRequested extends AdminAuthEvent {
  final String email;

  const AdminPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ClearAuthErrors extends AdminAuthEvent {
  const ClearAuthErrors();
}

class UpdateAdminProfile extends AdminAuthEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;

  const UpdateAdminProfile({
    this.name,
    this.email,
    this.phone,
    this.profileImage,
  });

  @override
  List<Object?> get props => [name, email, phone, profileImage];
}

class ValidateAdminSession extends AdminAuthEvent {
  const ValidateAdminSession();
}

