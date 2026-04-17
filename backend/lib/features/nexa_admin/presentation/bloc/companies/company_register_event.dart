part of 'company_register_bloc.dart';

abstract class CompanyRegisterEvent extends Equatable {
  const CompanyRegisterEvent();

  @override
  List<Object> get props => [];
}

/// Event to register a new company
class RegisterCompany extends CompanyRegisterEvent {
  final Map<String, dynamic> companyData;

  const RegisterCompany({required this.companyData});

  @override
  List<Object> get props => [companyData];
}

/// Event to validate company data before registration
class ValidateCompanyData extends CompanyRegisterEvent {
  final Map<String, dynamic> companyData;

  const ValidateCompanyData({required this.companyData});

  @override
  List<Object> get props => [companyData];
}

/// Event to check if company email is available
class CheckEmailAvailability extends CompanyRegisterEvent {
  final String email;

  const CheckEmailAvailability({required this.email});

  @override
  List<Object> get props => [email];
}

/// Event to check if company name is available
class CheckCompanyNameAvailability extends CompanyRegisterEvent {
  final String companyName;

  const CheckCompanyNameAvailability({required this.companyName});

  @override
  List<Object> get props => [companyName];
}

/// Event to upload company logo
class UploadCompanyLogo extends CompanyRegisterEvent {
  final String filePath;
  final String companyId;

  const UploadCompanyLogo({
    required this.filePath,
    required this.companyId,
  });

  @override
  List<Object> get props => [filePath, companyId];
}

/// Event to reset registration form
class ResetRegistrationForm extends CompanyRegisterEvent {}

/// Event to set registration step
class SetRegistrationStep extends CompanyRegisterEvent {
  final int step;

  const SetRegistrationStep({required this.step});

  @override
  List<Object> get props => [step];
}

/// Event to save draft registration
class SaveDraftRegistration extends CompanyRegisterEvent {
  final Map<String, dynamic> companyData;

  const SaveDraftRegistration({required this.companyData});

  @override
  List<Object> get props => [companyData];
}

/// Event to load draft registration
class LoadDraftRegistration extends CompanyRegisterEvent {
  final String draftId;

  const LoadDraftRegistration({required this.draftId});

  @override
  List<Object> get props => [draftId];
}
