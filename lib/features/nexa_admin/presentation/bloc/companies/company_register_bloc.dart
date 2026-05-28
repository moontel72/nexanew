// Company Register Bloc for NexaTrace System
// Business logic for company registration operations

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/errors/failures.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/company_management_repository.dart';

part 'company_register_event.dart';
part 'company_register_state.dart';

class CompanyRegisterBloc
    extends Bloc<CompanyRegisterEvent, CompanyRegisterState> {
  final CompanyManagementRepository _companyRepository;

  CompanyRegisterBloc({
    required CompanyManagementRepository companyRepository,
  })  : _companyRepository = companyRepository,
        super(CompanyRegisterInitial()) {
    on<RegisterCompany>(_onRegisterCompany);
    on<ValidateCompanyData>(_onValidateCompanyData);
    on<CheckEmailAvailability>(_onCheckEmailAvailability);
    on<CheckCompanyNameAvailability>(_onCheckCompanyNameAvailability);
    on<UploadCompanyLogo>(_onUploadCompanyLogo);
    on<ResetRegistrationForm>(_onResetRegistrationForm);
    on<SetRegistrationStep>(_onSetRegistrationStep);
    on<SaveDraftRegistration>(_onSaveDraftRegistration);
    on<LoadDraftRegistration>(_onLoadDraftRegistration);
  }

  Future<void> _onRegisterCompany(
    RegisterCompany event,
    Emitter<CompanyRegisterState> emit,
  ) async {
    emit(CompanyRegisterLoading(loadingMessage: 'Registering company...'));

    try {
      // Validate company data first
      final validationErrors = _validateCompanyData(event.companyData);

      if (validationErrors.isNotEmpty) {
        emit(CompanyRegisterError(
          message: 'Please fix the validation errors',
          fieldErrors: validationErrors,
        ));
        return;
      }

      // Register the company
      final registeredCompany =
          await _companyRepository.createCompanyFromMap(event.companyData);

      emit(CompanyRegisterSuccess(
        company: registeredCompany.toJson(),
        message: 'Company registered successfully',
      ));
    } catch (error) {
      if (error is ValidationFailure) {
        emit(CompanyRegisterError(
          message: 'Please fix the validation errors',
          fieldErrors: error.errors.map(
            (key, value) => MapEntry(key, value.isNotEmpty ? value.first : ''),
          ),
          errorCode: 'VALIDATION_ERROR',
        ));
        return;
      }
      emit(CompanyRegisterError(
        message: error.toString(),
        errorCode: _getErrorCode(error),
      ));
    }
  }

  Future<void> _onValidateCompanyData(
    ValidateCompanyData event,
    Emitter<CompanyRegisterState> emit,
  ) async {
    final validationErrors = _validateCompanyData(event.companyData);

    emit(CompanyDataValidated(
      companyData: event.companyData,
      isValid: validationErrors.isEmpty,
      validationErrors: validationErrors.isNotEmpty ? validationErrors : null,
    ));
  }

  Future<void> _onCheckEmailAvailability(
    CheckEmailAvailability event,
    Emitter<CompanyRegisterState> emit,
  ) async {
    emit(CompanyRegisterLoading(
        loadingMessage: 'Checking email availability...'));

    try {
      // In a real app, this would call an API endpoint
      // For now, we'll simulate a check
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate email availability check
      final isAvailable =
          !event.email.contains('test') && event.email.isNotEmpty;
      final suggestion = !isAvailable ? 'Try a different email address' : null;

      emit(EmailAvailabilityChecked(
        email: event.email,
        isAvailable: isAvailable,
        suggestion: suggestion,
      ));
    } catch (error) {
      emit(CompanyRegisterError(
        message: 'Failed to check email availability',
        errorCode: 'EMAIL_CHECK_FAILED',
      ));
    }
  }

  Future<void> _onCheckCompanyNameAvailability(
    CheckCompanyNameAvailability event,
    Emitter<CompanyRegisterState> emit,
  ) async {
    emit(CompanyRegisterLoading(
        loadingMessage: 'Checking company name availability...'));

    try {
      // In a real app, this would call an API endpoint
      // For now, we'll simulate a check
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate company name availability check
      final isAvailable = event.companyName.length >= 3 &&
          !event.companyName.toLowerCase().contains('test');
      final suggestion =
          !isAvailable ? 'Company name must be at least 3 characters' : null;

      emit(CompanyNameAvailabilityChecked(
        companyName: event.companyName,
        isAvailable: isAvailable,
        suggestion: suggestion,
      ));
    } catch (error) {
      emit(CompanyRegisterError(
        message: 'Failed to check company name availability',
        errorCode: 'NAME_CHECK_FAILED',
      ));
    }
  }

  Future<void> _onUploadCompanyLogo(
    UploadCompanyLogo event,
    Emitter<CompanyRegisterState> emit,
  ) async {
    emit(CompanyLogoUploading(
      progress: 0.0,
      filePath: event.filePath,
    ));

    try {
      // Simulate upload progress
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));
        emit(CompanyLogoUploading(
          progress: progress,
          filePath: event.filePath,
        ));
      }

      // In a real app, this would upload the file to a server
      // For now, we'll simulate a successful upload
      final logoUrl = 'https://example.com/logos/${event.companyId}.png';

      emit(CompanyLogoUploaded(
        companyId: event.companyId,
        logoUrl: logoUrl,
        message: 'Logo uploaded successfully',
      ));
    } catch (error) {
      emit(CompanyLogoUploadError(
        filePath: event.filePath,
        message: 'Failed to upload logo: ${error.toString()}',
      ));
    }
  }

  void _onResetRegistrationForm(
    ResetRegistrationForm event,
    Emitter<CompanyRegisterState> emit,
  ) {
    emit(RegistrationFormReset());
  }

  void _onSetRegistrationStep(
    SetRegistrationStep event,
    Emitter<CompanyRegisterState> emit,
  ) {
    emit(RegistrationStepChanged(
      currentStep: event.step,
      totalSteps: 4, // Assuming 4-step registration process
      canProceed: event.step < 4,
      canGoBack: event.step > 1,
    ));
  }

  Future<void> _onSaveDraftRegistration(
    SaveDraftRegistration event,
    Emitter<CompanyRegisterState> emit,
  ) async {
    emit(CompanyRegisterLoading(loadingMessage: 'Saving draft...'));

    try {
      // In a real app, this would save to local storage or backend
      await Future.delayed(const Duration(milliseconds: 300));

      final draftId = 'draft_${DateTime.now().millisecondsSinceEpoch}';

      emit(DraftSaved(
        draftId: draftId,
        message: 'Draft saved successfully',
      ));
    } catch (error) {
      emit(DraftError(
        message: 'Failed to save draft',
        draftId: 'unknown',
      ));
    }
  }

  Future<void> _onLoadDraftRegistration(
    LoadDraftRegistration event,
    Emitter<CompanyRegisterState> emit,
  ) async {
    emit(CompanyRegisterLoading(loadingMessage: 'Loading draft...'));

    try {
      // In a real app, this would load from local storage or backend
      await Future.delayed(const Duration(milliseconds: 300));

      // Simulate loaded draft data
      final draftData = {
        'name': 'Sample Company',
        'email': 'contact@samplecompany.com',
        'phone': '+1234567890',
        'status': 'active',
      };

      emit(DraftLoaded(
        draftData: draftData,
        draftId: event.draftId,
      ));
    } catch (error) {
      emit(DraftError(
        message: 'Failed to load draft',
        draftId: event.draftId,
      ));
    }
  }

  Map<String, String> _validateCompanyData(Map<String, dynamic> companyData) {
    final errors = <String, String>{};

    // Validate required fields
    if (companyData['name'] == null || companyData['name'].toString().isEmpty) {
      errors['name'] = 'Company name is required';
    } else if (companyData['name'].toString().length < 3) {
      errors['name'] = 'Company name must be at least 3 characters';
    }

    if (companyData['email'] == null ||
        companyData['email'].toString().isEmpty) {
      errors['email'] = 'Email is required';
    } else {
      final email = companyData['email'].toString();
      final emailRegex = RegExp(
          r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
      if (!emailRegex.hasMatch(email)) {
        errors['email'] = 'Please enter a valid email address';
      }
    }

    if (companyData['business_registration_number'] == null ||
        companyData['business_registration_number'].toString().isEmpty) {
      errors['business_registration_number'] =
          'Business registration number is required';
    }

    if (companyData['company_type'] == null ||
        companyData['company_type'].toString().isEmpty) {
      errors['company_type'] = 'Company type is required';
    }

    if (companyData['industry_type'] == null ||
        companyData['industry_type'].toString().isEmpty) {
      errors['industry_type'] = 'Industry type is required';
    }

    if (companyData['country'] == null ||
        companyData['country'].toString().isEmpty) {
      errors['country'] = 'Country is required';
    }

    if (companyData['city'] == null || companyData['city'].toString().isEmpty) {
      errors['city'] = 'City is required';
    }

    if (companyData['contact_person_name'] == null ||
        companyData['contact_person_name'].toString().isEmpty) {
      errors['contact_person_name'] = 'Contact person name is required';
    }

    if (companyData['contact_person_email'] == null ||
        companyData['contact_person_email'].toString().isEmpty) {
      errors['contact_person_email'] = 'Contact person email is required';
    }

    if (companyData['contact_person_phone'] == null ||
        companyData['contact_person_phone'].toString().isEmpty) {
      errors['contact_person_phone'] = 'Contact person phone is required';
    }

    if (companyData['phone'] != null &&
        companyData['phone'].toString().isNotEmpty) {
      final phone = companyData['phone'].toString();
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        errors['phone'] = 'Please enter a valid phone number';
      }
    }

    if (companyData['status'] == null ||
        companyData['status'].toString().isEmpty) {
      errors['status'] = 'Status is required';
    }

    if (companyData['plan_id'] == null ||
        companyData['plan_id'].toString().isEmpty) {
      errors['plan_id'] = 'Subscription plan is required';
    }

    if (companyData['password'] == null ||
        companyData['password'].toString().isEmpty) {
      errors['password'] = 'Password is required';
    } else if (companyData['password'].toString().length < 8) {
      errors['password'] = 'Password must be at least 8 characters';
    }

    // Validate industry if provided
    if (companyData['industry'] != null &&
        companyData['industry'].toString().isNotEmpty) {
      final industry = companyData['industry'].toString();
      if (industry.length < 2) {
        errors['industry'] = 'Industry must be at least 2 characters';
      }
    }

    // Validate employee count if provided
    if (companyData['employee_count'] != null) {
      final employeeCount =
          int.tryParse(companyData['employee_count'].toString());
      if (employeeCount != null && employeeCount < 0) {
        errors['employee_count'] = 'Employee count cannot be negative';
      }
    }

    // Validate website URL if provided
    if (companyData['website'] != null &&
        companyData['website'].toString().isNotEmpty) {
      final website = companyData['website'].toString();
      if (!website.startsWith('http://') && !website.startsWith('https://')) {
        errors['website'] = 'Website must start with http:// or https://';
      }
    }

    return errors;
  }

  String? _getErrorCode(dynamic error) {
    if (error is String) {
      if (error.contains('409')) return 'DUPLICATE_COMPANY';
      if (error.contains('400')) return 'VALIDATION_ERROR';
      if (error.contains('401')) return 'UNAUTHORIZED';
      if (error.contains('403')) return 'FORBIDDEN';
      if (error.contains('500')) return 'SERVER_ERROR';
    }
    return null;
  }
}
