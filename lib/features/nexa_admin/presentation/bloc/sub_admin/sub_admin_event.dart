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

// ── Factory Company Management (inside dashboard) ──
class CreateFactoryCompany extends SubAdminEvent {
  final String name,
      regNumber,
      industryType,
      contactName,
      contactEmail,
      contactPhone,
      country,
      city,
      password;
  const CreateFactoryCompany({
    required this.name,
    required this.regNumber,
    required this.industryType,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.country,
    required this.city,
    required this.password,
  });
  @override
  List<Object?> get props => [
    name,
    regNumber,
    industryType,
    contactName,
    contactEmail,
    contactPhone,
    country,
    city,
    password,
  ];
}

class FetchFactoryCompanies extends SubAdminEvent {
  const FetchFactoryCompanies();
}

class UpdateFactoryCompanyStatus extends SubAdminEvent {
  final String companyId;
  final String
  newStatus; // pending, verified, active, inactive, suspended, deleted
  const UpdateFactoryCompanyStatus({
    required this.companyId,
    required this.newStatus,
  });
  @override
  List<Object?> get props => [companyId, newStatus];
}

class EditFactoryCompany extends SubAdminEvent {
  final String companyId;
  final Map<String, dynamic> data;
  const EditFactoryCompany({required this.companyId, required this.data});
  @override
  List<Object?> get props => [companyId, data];
}

class ResetFactoryCompanyPassword extends SubAdminEvent {
  final String companyId, newPassword;
  const ResetFactoryCompanyPassword({
    required this.companyId,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [companyId, newPassword];
}

class DeleteFactoryCompany extends SubAdminEvent {
  final String companyId;
  const DeleteFactoryCompany(this.companyId);
  @override
  List<Object?> get props => [companyId];
}

class RestoreFactoryCompany extends SubAdminEvent {
  final String companyId;
  const RestoreFactoryCompany(this.companyId);
  @override
  List<Object?> get props => [companyId];
}

// ── Reseller Account Management (inside dashboard) — C2b ──
class CreateResellerAccount extends SubAdminEvent {
  final String name,
      businessName,
      registrationNo,
      email,
      phone,
      password,
      city,
      address;
  const CreateResellerAccount({
    required this.name,
    required this.businessName,
    required this.registrationNo,
    required this.email,
    required this.phone,
    required this.password,
    required this.city,
    this.address = '',
  });
  @override
  List<Object?> get props => [
    name,
    businessName,
    registrationNo,
    email,
    phone,
    password,
    city,
    address,
  ];
}

class FetchResellerAccounts extends SubAdminEvent {
  const FetchResellerAccounts();
}

class UpdateResellerAccountStatus extends SubAdminEvent {
  final String accountId;
  final String newStatus; // active, inactive, suspended
  const UpdateResellerAccountStatus({
    required this.accountId,
    required this.newStatus,
  });
  @override
  List<Object?> get props => [accountId, newStatus];
}

class EditResellerAccount extends SubAdminEvent {
  final String accountId;
  final Map<String, dynamic> data;
  const EditResellerAccount({required this.accountId, required this.data});
  @override
  List<Object?> get props => [accountId, data];
}

class DeleteResellerAccount extends SubAdminEvent {
  final String accountId;
  const DeleteResellerAccount(this.accountId);
  @override
  List<Object?> get props => [accountId];
}

class RestoreResellerAccount extends SubAdminEvent {
  final String accountId;
  const RestoreResellerAccount(this.accountId);
  @override
  List<Object?> get props => [accountId];
}

// ── Sub-Admin Management (list + add screens) ──
class FetchSubAdmins extends SubAdminEvent {
  const FetchSubAdmins();
}

class CreateSubAdmin extends SubAdminEvent {
  final String name, email, phone, cnic, vertical, password;
  final bool canAccessStudio;
  const CreateSubAdmin({
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.vertical,
    required this.password,
    this.canAccessStudio = false,
  });
  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    cnic,
    vertical,
    password,
    canAccessStudio,
  ];
}

class ToggleStudioAccess extends SubAdminEvent {
  final bool value;
  const ToggleStudioAccess(this.value);
  @override
  List<Object?> get props => [value];
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

// ── Navigation ──
class NavigateSubAdminPage extends SubAdminEvent {
  final String page;
  const NavigateSubAdminPage(this.page);
  @override
  List<Object?> get props => [page];
}
