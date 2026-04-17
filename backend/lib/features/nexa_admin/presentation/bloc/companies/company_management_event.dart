part of 'company_management_bloc.dart';

/// Events for company management BLoC
@freezed
abstract class CompanyManagementEvent with _$CompanyManagementEvent {
  /// Load all companies
  const factory CompanyManagementEvent.loadCompanies({
    @Default('') String search,
    String? status,
    String? verificationStatus,
    String? country,
    String? planType,
    @Default('created_at') String sortBy,
    @Default('desc') String sortOrder,
    @Default(1) int page,
    @Default(20) int perPage,
  }) = _LoadCompanies;

  /// Load a specific company by ID
  const factory CompanyManagementEvent.loadCompany(String id) = _LoadCompany;

  /// Create a new company
  const factory CompanyManagementEvent.createCompany({
    required String name,
    required String businessRegistrationNumber,
    String? taxId,
    required String companyType,
    required String industryType,
    required String email,
    String? phone,
    String? website,
    required String country,
    required String city,
    String? address,
    String? postalCode,
    required String contactPersonName,
    required String contactPersonEmail,
    required String contactPersonPhone,
    String? contactPersonPosition,
    String? timezone,
    String? language,
    String? currency,
    String? planId,
    String? billingCycle,
    List<CompanyDocumentInput>? documents,
    String? adminNotes,
  }) = _CreateCompany;

  /// Update an existing company
  const factory CompanyManagementEvent.updateCompany({
    required String id,
    String? name,
    String? businessRegistrationNumber,
    String? taxId,
    String? companyType,
    String? industryType,
    String? email,
    String? phone,
    String? website,
    String? country,
    String? city,
    String? address,
    String? postalCode,
    String? contactPersonName,
    String? contactPersonEmail,
    String? contactPersonPhone,
    String? contactPersonPosition,
    String? status,
    String? verificationStatus,
    String? verificationNotes,
    String? timezone,
    String? language,
    String? currency,
    String? planId,
    String? billingCycle,
    String? adminNotes,
  }) = _UpdateCompany;

  /// Delete a company
  const factory CompanyManagementEvent.deleteCompany(String id) =
      _DeleteCompany;

  /// Update company status
  const factory CompanyManagementEvent.updateCompanyStatus({
    required String id,
    required String status,
    String? reason,
  }) = _UpdateCompanyStatus;

  /// Update company verification status
  const factory CompanyManagementEvent.updateVerificationStatus({
    required String id,
    required String verificationStatus,
    String? verificationNotes,
  }) = _UpdateVerificationStatus;

  /// Assign subscription plan to company
  const factory CompanyManagementEvent.assignPlan({
    required String companyId,
    required String planId,
    String? billingCycle,
    bool? autoRenew,
    DateTime? startsAt,
    DateTime? endsAt,
  }) = _AssignPlan;

  /// Upload company document
  const factory CompanyManagementEvent.uploadDocument({
    required String companyId,
    required String documentType,
    required String documentName,
    required String filePath,
  }) = _UploadDocument;

  /// Delete company document
  const factory CompanyManagementEvent.deleteDocument({
    required String companyId,
    required String documentId,
  }) = _DeleteDocument;

  /// Load company statistics
  const factory CompanyManagementEvent.loadCompanyStatistics() =
      _LoadCompanyStatistics;

  /// Export companies to CSV
  const factory CompanyManagementEvent.exportCompanies({
    String? search,
    String? status,
    String? verificationStatus,
    String? country,
    String? planType,
  }) = _ExportCompanies;

  /// Send welcome email to company
  const factory CompanyManagementEvent.sendWelcomeEmail(String companyId) =
      _SendWelcomeEmail;

  /// Reset company password
  const factory CompanyManagementEvent.resetCompanyPassword(String companyId) =
      _ResetCompanyPassword;

  /// Clear error state
  const factory CompanyManagementEvent.clearError() = _ClearError;

  /// Reset to initial state
  const factory CompanyManagementEvent.reset() = _Reset;
}

/// Company status update input
class CompanyStatusUpdate extends Equatable {
  final String status;
  final String? reason;
  final DateTime updatedAt;

  const CompanyStatusUpdate({
    required this.status,
    this.reason,
    required this.updatedAt,
  });

  /// Create CompanyStatusUpdate from JSON
  factory CompanyStatusUpdate.fromJson(Map<String, dynamic> json) {
    return CompanyStatusUpdate(
      status: json['status'] as String,
      reason: json['reason'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert CompanyStatusUpdate to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'reason': reason,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [status, reason, updatedAt];

  @override
  bool get stringify => true;
}

/// Verification status update input
class VerificationStatusUpdate extends Equatable {
  final String verificationStatus;
  final String? verificationNotes;
  final DateTime verifiedAt;
  final String verifiedBy;

  const VerificationStatusUpdate({
    required this.verificationStatus,
    this.verificationNotes,
    required this.verifiedAt,
    required this.verifiedBy,
  });

  /// Create VerificationStatusUpdate from JSON
  factory VerificationStatusUpdate.fromJson(Map<String, dynamic> json) {
    return VerificationStatusUpdate(
      verificationStatus: json['verification_status'] as String,
      verificationNotes: json['verification_notes'] as String?,
      verifiedAt: DateTime.parse(json['verified_at'] as String),
      verifiedBy: json['verified_by'] as String,
    );
  }

  /// Convert VerificationStatusUpdate to JSON
  Map<String, dynamic> toJson() {
    return {
      'verification_status': verificationStatus,
      'verification_notes': verificationNotes,
      'verified_at': verifiedAt.toIso8601String(),
      'verified_by': verifiedBy,
    };
  }

  @override
  List<Object?> get props => [
        verificationStatus,
        verificationNotes,
        verifiedAt,
        verifiedBy,
      ];

  @override
  bool get stringify => true;
}
