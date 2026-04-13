part of 'company_detail_bloc.dart';

// Company Detail Event for NexaTrace System
// Events for CompanyDetailBloc

abstract class CompanyDetailEvent extends Equatable {
  const CompanyDetailEvent();

  @override
  List<Object> get props => [];
}

/// Event to load company details
class LoadCompanyDetail extends CompanyDetailEvent {
  final String companyId;

  const LoadCompanyDetail({required this.companyId});

  @override
  List<Object> get props => [companyId];
}

/// Event to update company details
class UpdateCompanyDetail extends CompanyDetailEvent {
  final String companyId;
  final Map<String, dynamic> companyData;

  const UpdateCompanyDetail({
    required this.companyId,
    required this.companyData,
  });

  @override
  List<Object> get props => [companyId, companyData];
}

/// Event to update company status
class UpdateCompanyStatus extends CompanyDetailEvent {
  final String companyId;
  final String status;
  final String? reason;

  const UpdateCompanyStatus({
    required this.companyId,
    required this.status,
    this.reason,
  });

  @override
  List<Object> get props => [companyId, status, ?reason];
}

class UpdateCompanyVerificationStatus extends CompanyDetailEvent {
  final String companyId;
  final String verificationStatus;
  final String? verificationNotes;

  const UpdateCompanyVerificationStatus({
    required this.companyId,
    required this.verificationStatus,
    this.verificationNotes,
  });

  @override
  List<Object> get props => [companyId, verificationStatus, ?verificationNotes];
}

/// Event to delete company
class DeleteCompany extends CompanyDetailEvent {
  final String companyId;

  const DeleteCompany({required this.companyId});

  @override
  List<Object> get props => [companyId];
}

/// Event to refresh company data
class RefreshCompanyDetail extends CompanyDetailEvent {
  final String companyId;

  const RefreshCompanyDetail({required this.companyId});

  @override
  List<Object> get props => [companyId];
}

/// Event to reset company detail state
class ResetCompanyDetail extends CompanyDetailEvent {}
