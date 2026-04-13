part of 'company_register_bloc.dart';

abstract class CompanyRegisterState extends Equatable {
  const CompanyRegisterState();

  @override
  List<Object> get props => [];
}

/// Initial state
class CompanyRegisterInitial extends CompanyRegisterState {}

/// Loading state
class CompanyRegisterLoading extends CompanyRegisterState {
  final String? loadingMessage;

  const CompanyRegisterLoading({this.loadingMessage});

  @override
  List<Object> get props => [?loadingMessage];
}

/// Company registration successful
class CompanyRegisterSuccess extends CompanyRegisterState {
  final Map<String, dynamic> company;
  final String message;

  const CompanyRegisterSuccess({required this.company, required this.message});

  @override
  List<Object> get props => [company, message];
}

/// Company registration failed
class CompanyRegisterError extends CompanyRegisterState {
  final String message;
  final Map<String, String>? fieldErrors;
  final String? errorCode;

  const CompanyRegisterError({
    required this.message,
    this.fieldErrors,
    this.errorCode,
  });

  @override
  List<Object> get props => [message, ?fieldErrors, ?errorCode];
}

/// Company data validation state
class CompanyDataValidated extends CompanyRegisterState {
  final Map<String, dynamic> companyData;
  final bool isValid;
  final Map<String, String>? validationErrors;

  const CompanyDataValidated({
    required this.companyData,
    required this.isValid,
    this.validationErrors,
  });

  @override
  List<Object> get props => [companyData, isValid, ?validationErrors];
}

/// Email availability check state
class EmailAvailabilityChecked extends CompanyRegisterState {
  final String email;
  final bool isAvailable;
  final String? suggestion;

  const EmailAvailabilityChecked({
    required this.email,
    required this.isAvailable,
    this.suggestion,
  });

  @override
  List<Object> get props => [email, isAvailable, ?suggestion];
}

/// Company name availability check state
class CompanyNameAvailabilityChecked extends CompanyRegisterState {
  final String companyName;
  final bool isAvailable;
  final String? suggestion;

  const CompanyNameAvailabilityChecked({
    required this.companyName,
    required this.isAvailable,
    this.suggestion,
  });

  @override
  List<Object> get props => [companyName, isAvailable, ?suggestion];
}

/// Company logo upload state
class CompanyLogoUploading extends CompanyRegisterState {
  final double progress;
  final String filePath;

  const CompanyLogoUploading({required this.progress, required this.filePath});

  @override
  List<Object> get props => [progress, filePath];
}

class CompanyLogoUploaded extends CompanyRegisterState {
  final String companyId;
  final String logoUrl;
  final String message;

  const CompanyLogoUploaded({
    required this.companyId,
    required this.logoUrl,
    required this.message,
  });

  @override
  List<Object> get props => [companyId, logoUrl, message];
}

class CompanyLogoUploadError extends CompanyRegisterState {
  final String filePath;
  final String message;

  const CompanyLogoUploadError({required this.filePath, required this.message});

  @override
  List<Object> get props => [filePath, message];
}

/// Registration step state
class RegistrationStepChanged extends CompanyRegisterState {
  final int currentStep;
  final int totalSteps;
  final bool canProceed;
  final bool canGoBack;

  const RegistrationStepChanged({
    required this.currentStep,
    required this.totalSteps,
    required this.canProceed,
    required this.canGoBack,
  });

  @override
  List<Object> get props => [currentStep, totalSteps, canProceed, canGoBack];
}

/// Draft registration state
class DraftSaved extends CompanyRegisterState {
  final String draftId;
  final String message;

  const DraftSaved({required this.draftId, required this.message});

  @override
  List<Object> get props => [draftId, message];
}

class DraftLoaded extends CompanyRegisterState {
  final Map<String, dynamic> draftData;
  final String draftId;

  const DraftLoaded({required this.draftData, required this.draftId});

  @override
  List<Object> get props => [draftData, draftId];
}

class DraftError extends CompanyRegisterState {
  final String message;
  final String draftId;

  const DraftError({required this.message, required this.draftId});

  @override
  List<Object> get props => [message, draftId];
}

/// Form reset state
class RegistrationFormReset extends CompanyRegisterState {}
