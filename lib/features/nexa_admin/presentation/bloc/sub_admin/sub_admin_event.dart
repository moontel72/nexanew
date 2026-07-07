// Sub-Admin Events — auth + dashboard + management
import 'package:equatable/equatable.dart';

abstract class SubAdminEvent extends Equatable {
  const SubAdminEvent();
  @override
  List<Object?> get props => [];
}

// ── Auth ──
class SubAdminLoginRequested extends SubAdminEvent {
  final String identifier, password;
  const SubAdminLoginRequested({
    required this.identifier,
    required this.password,
  });
  @override
  List<Object?> get props => [identifier, password];
}

class TogglePasswordVisibility extends SubAdminEvent {
  const TogglePasswordVisibility();
}

// ── Dashboard Bootstrap ──
class BootstrapDashboard extends SubAdminEvent {
  const BootstrapDashboard();
}

class LoadDashboardMetrics extends SubAdminEvent {
  const LoadDashboardMetrics();
}

// ── Bus Company Management (inside dashboard) ──
class CreateBusCompany extends SubAdminEvent {
  final String name, email, password, phone, regCode, fleetSize, license;
  const CreateBusCompany({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.regCode,
    required this.fleetSize,
    required this.license,
  });
  @override
  List<Object?> get props => [
    name,
    email,
    password,
    phone,
    regCode,
    fleetSize,
    license,
  ];
}

class FetchBusCompanies extends SubAdminEvent {
  const FetchBusCompanies();
}

class ToggleBusCompanyStatus extends SubAdminEvent {
  final String companyId;
  const ToggleBusCompanyStatus(this.companyId);
  @override
  List<Object?> get props => [companyId];
}

class UpdateBusCompanyStatus extends SubAdminEvent {
  final String companyId;
  final String newStatus; // verified, active, inactive, suspended, deleted
  const UpdateBusCompanyStatus({
    required this.companyId,
    required this.newStatus,
  });
  @override
  List<Object?> get props => [companyId, newStatus];
}

class EditBusCompany extends SubAdminEvent {
  final String companyId;
  final Map<String, dynamic> data;
  const EditBusCompany({required this.companyId, required this.data});
  @override
  List<Object?> get props => [companyId, data];
}

class ResetBusCompanyPassword extends SubAdminEvent {
  final String companyId, newPassword;
  const ResetBusCompanyPassword({
    required this.companyId,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [companyId, newPassword];
}

class DeleteBusCompany extends SubAdminEvent {
  final String companyId;
  const DeleteBusCompany(this.companyId);
  @override
  List<Object?> get props => [companyId];
}

class RestoreBusCompany extends SubAdminEvent {
  final String companyId;
  const RestoreBusCompany(this.companyId);
  @override
  List<Object?> get props => [companyId];
}

// ── Sub-Admin Management (list + add screens) ──
class FetchSubAdmins extends SubAdminEvent {
  const FetchSubAdmins();
}

class CreateSubAdmin extends SubAdminEvent {
  final String name, email, phone, cnic, vertical, password;
  const CreateSubAdmin({
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.vertical,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, phone, cnic, vertical, password];
}

class ToggleSubAdminStatus extends SubAdminEvent {
  final String adminId;
  const ToggleSubAdminStatus(this.adminId);
  @override
  List<Object?> get props => [adminId];
}

class EditSubAdmin extends SubAdminEvent {
  final String adminId;
  final Map<String, dynamic> data;
  const EditSubAdmin({required this.adminId, required this.data});
  @override
  List<Object?> get props => [adminId, data];
}

class ChangeSubAdminVertical extends SubAdminEvent {
  final String adminId, newVertical;
  const ChangeSubAdminVertical({
    required this.adminId,
    required this.newVertical,
  });
  @override
  List<Object?> get props => [adminId, newVertical];
}

class ResetSubAdminPassword extends SubAdminEvent {
  final String adminId, newPassword;
  const ResetSubAdminPassword({
    required this.adminId,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [adminId, newPassword];
}

class DeleteSubAdmin extends SubAdminEvent {
  final String adminId;
  const DeleteSubAdmin(this.adminId);
  @override
  List<Object?> get props => [adminId];
}

class RestoreSubAdmin extends SubAdminEvent {
  final String adminId;
  const RestoreSubAdmin(this.adminId);
  @override
  List<Object?> get props => [adminId];
}

// ── Logout ──
class SubAdminLogout extends SubAdminEvent {
  const SubAdminLogout();
}

// ── Clear error ──
class ClearSubAdminError extends SubAdminEvent {
  const ClearSubAdminError();
}
