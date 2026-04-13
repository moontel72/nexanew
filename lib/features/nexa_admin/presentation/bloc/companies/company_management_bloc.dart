// File: lib/features/nexa_admin/presentation/bloc/companies/company_management_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/company_management_repository.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/subscription_plan.dart';
import 'package:nexatrace_system/shared/models/company/company_document_input.dart';
import 'package:nexatrace_system/shared/models/company/company_model.dart';
import 'package:nexatrace_system/shared/models/company/company_statistics.dart';

part 'company_management_event.dart';
part 'company_management_state.dart';
part 'company_management_bloc.freezed.dart';
part 'company_management_event.freezed.dart';
part 'company_management_state.freezed.dart';

/// Company Management BLoC
/// Manages the state and business logic for company management operations
class CompanyManagementBloc
    extends Bloc<CompanyManagementEvent, CompanyManagementState> {
  final CompanyManagementRepository _repository;

  CompanyManagementBloc({required CompanyManagementRepository repository})
      : _repository = repository,
        super(const CompanyManagementState.initial()) {
    on<CompanyManagementEvent>((event, emit) async {
      await event.map(
        loadCompanies: (event) => _onLoadCompanies(event, emit),
        loadCompany: (event) => _onLoadCompany(event, emit),
        createCompany: (event) => _onCreateCompany(event, emit),
        updateCompany: (event) => _onUpdateCompany(event, emit),
        deleteCompany: (event) => _onDeleteCompany(event, emit),
        updateCompanyStatus: (event) => _onUpdateCompanyStatus(event, emit),
        updateVerificationStatus: (event) =>
            _onUpdateVerificationStatus(event, emit),
        assignPlan: (event) => _onAssignPlan(event, emit),
        uploadDocument: (event) => _onUploadDocument(event, emit),
        deleteDocument: (event) => _onDeleteDocument(event, emit),
        loadCompanyStatistics: (event) => _onLoadCompanyStatistics(event, emit),
        exportCompanies: (event) => _onExportCompanies(event, emit),
        sendWelcomeEmail: (event) => _onSendWelcomeEmail(event, emit),
        resetCompanyPassword: (event) => _onResetCompanyPassword(event, emit),
        clearError: (event) => _onClearError(event, emit),
        reset: (event) => _onReset(event, emit),
      );
    });
  }

  /// Handle load companies event
  Future<void> _onLoadCompanies(
    _LoadCompanies event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      final response = await _repository.getCompanies(
        search: event.search,
        status: event.status,
        verificationStatus: event.verificationStatus,
        country: event.country,
        planType: event.planType,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        page: event.page,
        perPage: event.perPage,
      );

      // Load statistics if first page
      CompanyStatistics? statistics;
      if (event.page == 1) {
        try {
          statistics = await _repository.getCompanyStatistics();
        } catch (error) {
          // Don't fail if statistics fail
          if (kDebugMode) {
            print('Failed to load company statistics: $error');
          }
        }
      }

      emit(CompanyManagementState.loaded(
        companies: response.companies,
        total: response.total,
        page: response.page,
        perPage: response.perPage,
        totalPages: response.totalPages,
        search: event.search,
        status: event.status,
        verificationStatus: event.verificationStatus,
        country: event.country,
        planType: event.planType,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        statistics: statistics,
        filterOptions: CompanyFilterOptions.defaultOptions(),
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle load company event
  Future<void> _onLoadCompany(
    _LoadCompany event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      final company = await _repository.getCompany(event.id);
      final usageStats = await _repository.getCompanyUsageStats(event.id);
      final availablePlans = await _repository.getAvailablePlans();

      emit(CompanyManagementState.companyDetailLoaded(
        company: company,
        usageStats: usageStats,
        availablePlans: availablePlans,
        filterOptions: CompanyFilterOptions.defaultOptions(),
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle create company event
  Future<void> _onCreateCompany(
    _CreateCompany event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      final company = await _repository.createCompany(
        name: event.name,
        businessRegistrationNumber: event.businessRegistrationNumber,
        taxId: event.taxId,
        companyType: event.companyType,
        industryType: event.industryType,
        email: event.email,
        phone: event.phone,
        website: event.website,
        country: event.country,
        city: event.city,
        address: event.address,
        postalCode: event.postalCode,
        contactPersonName: event.contactPersonName,
        contactPersonEmail: event.contactPersonEmail,
        contactPersonPhone: event.contactPersonPhone,
        contactPersonPosition: event.contactPersonPosition,
        timezone: event.timezone,
        language: event.language,
        currency: event.currency,
        planId: event.planId,
        billingCycle: event.billingCycle,
        documents: event.documents,
        adminNotes: event.adminNotes,
      );

      emit(CompanyManagementState.companyCreated(
        company: company,
        message: 'Company created successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle update company event
  Future<void> _onUpdateCompany(
    _UpdateCompany event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      final company = await _repository.updateCompany(
        id: event.id,
        name: event.name,
        businessRegistrationNumber: event.businessRegistrationNumber,
        taxId: event.taxId,
        companyType: event.companyType,
        industryType: event.industryType,
        email: event.email,
        phone: event.phone,
        website: event.website,
        country: event.country,
        city: event.city,
        address: event.address,
        postalCode: event.postalCode,
        contactPersonName: event.contactPersonName,
        contactPersonEmail: event.contactPersonEmail,
        contactPersonPhone: event.contactPersonPhone,
        contactPersonPosition: event.contactPersonPosition,
        status: event.status,
        verificationStatus: event.verificationStatus,
        verificationNotes: event.verificationNotes,
        timezone: event.timezone,
        language: event.language,
        currency: event.currency,
        planId: event.planId,
        billingCycle: event.billingCycle,
        adminNotes: event.adminNotes,
      );

      emit(CompanyManagementState.companyUpdated(
        company: company,
        message: 'Company updated successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle delete company event
  Future<void> _onDeleteCompany(
    _DeleteCompany event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      await _repository.deleteCompany(event.id);

      emit(CompanyManagementState.companyDeleted(
        companyId: event.id,
        message: 'Company deleted successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle update company status event
  Future<void> _onUpdateCompanyStatus(
    _UpdateCompanyStatus event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      await _repository.updateCompanyStatus(
        id: event.id,
        status: event.status,
        reason: event.reason,
      );

      emit(CompanyManagementState.companyStatusUpdated(
        companyId: event.id,
        status: event.status,
        message: 'Company status updated successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle update verification status event
  Future<void> _onUpdateVerificationStatus(
    _UpdateVerificationStatus event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      await _repository.updateVerificationStatus(
        id: event.id,
        verificationStatus: event.verificationStatus,
        verificationNotes: event.verificationNotes,
      );

      emit(CompanyManagementState.verificationStatusUpdated(
        companyId: event.id,
        verificationStatus: event.verificationStatus,
        message: 'Verification status updated successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle assign plan event
  Future<void> _onAssignPlan(
    _AssignPlan event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      await _repository.assignPlan(
        companyId: event.companyId,
        planId: event.planId,
        billingCycle: event.billingCycle,
        autoRenew: event.autoRenew,
        startsAt: event.startsAt,
        endsAt: event.endsAt,
      );

      // Get the assigned plan details
      final availablePlans = await _repository.getAvailablePlans();
      final assignedPlan = availablePlans.firstWhere(
        (plan) => plan.id == event.planId,
        orElse: () => SubscriptionPlan(
          id: event.planId,
          name: 'Unknown Plan',
          description: '',
          type: 'custom',
          monthlyPrice: 0.0,
          yearlyPrice: 0.0,
          billingCycle: event.billingCycle ?? 'monthly',
          currency: 'USD',
          status: 'active',
          isFeatured: false,
          isPopular: false,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          limits: const {},
          features: const [],
        ),
      );

      emit(CompanyManagementState.planAssigned(
        companyId: event.companyId,
        plan: assignedPlan,
        message: 'Plan assigned successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle upload document event
  Future<void> _onUploadDocument(
    _UploadDocument event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      final document = await _repository.uploadDocument(
        companyId: event.companyId,
        documentType: event.documentType,
        documentName: event.documentName,
        filePath: event.filePath,
      );

      emit(CompanyManagementState.documentUploaded(
        companyId: event.companyId,
        document: document,
        message: 'Document uploaded successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle delete document event
  Future<void> _onDeleteDocument(
    _DeleteDocument event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      await _repository.deleteDocument(
        companyId: event.companyId,
        documentId: event.documentId,
      );

      emit(CompanyManagementState.documentDeleted(
        companyId: event.companyId,
        documentId: event.documentId,
        message: 'Document deleted successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle load company statistics event
  Future<void> _onLoadCompanyStatistics(
    _LoadCompanyStatistics event,
    Emitter<CompanyManagementState> emit,
  ) async {
    try {
      final statistics = await _repository.getCompanyStatistics();

      // Update state if currently loaded
      if (state is _Loaded) {
        final currentState = state as _Loaded;
        emit(currentState.copyWith(statistics: statistics));
      }
    } catch (error) {
      // Silently handle statistics loading errors
      if (kDebugMode) {
        print('Failed to load company statistics: $error');
      }
    }
  }

  /// Handle export companies event
  Future<void> _onExportCompanies(
    _ExportCompanies event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.exporting());

    try {
      final filePath = await _repository.exportCompanies(
        search: event.search,
        status: event.status,
        verificationStatus: event.verificationStatus,
        country: event.country,
        planType: event.planType,
      );

      emit(CompanyManagementState.exported(
        filePath: filePath,
        message: 'Companies exported successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle send welcome email event
  Future<void> _onSendWelcomeEmail(
    _SendWelcomeEmail event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      await _repository.sendWelcomeEmail(event.companyId);

      emit(CompanyManagementState.welcomeEmailSent(
        companyId: event.companyId,
        message: 'Welcome email sent successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle reset company password event
  Future<void> _onResetCompanyPassword(
    _ResetCompanyPassword event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.loading());

    try {
      await _repository.resetCompanyPassword(event.companyId);

      emit(CompanyManagementState.passwordReset(
        companyId: event.companyId,
        message: 'Password reset email sent successfully',
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(CompanyManagementState.error(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isValidationError: failure is ValidationFailure,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle clear error event
  Future<void> _onClearError(
    _ClearError event,
    Emitter<CompanyManagementState> emit,
  ) async {
    if (state is _Error) {
      emit(const CompanyManagementState.initial());
    }
  }

  /// Handle reset event
  Future<void> _onReset(
    _Reset event,
    Emitter<CompanyManagementState> emit,
  ) async {
    emit(const CompanyManagementState.initial());
  }

  /// Get current companies from state
  List<Company> get currentCompanies {
    if (state is _Loaded) {
      return (state as _Loaded).companies;
    }
    return [];
  }

  /// Get current statistics from state
  CompanyStatistics? get currentStatistics {
    if (state is _Loaded) {
      return (state as _Loaded).statistics;
    }
    return null;
  }

  /// Get current filters from state
  CompanyFilterOptions get currentFilters {
    if (state is _Loaded) {
      return (state as _Loaded).filterOptions;
    } else if (state is _CompanyDetailLoaded) {
      return (state as _CompanyDetailLoaded).filterOptions;
    }
    return CompanyFilterOptions.defaultOptions();
  }

  /// Check if there are more pages to load
  bool get hasMorePages {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      return currentState.page < currentState.totalPages;
    }
    return false;
  }

  /// Load next page of companies
  void loadNextPage() {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      if (hasMorePages) {
        add(CompanyManagementEvent.loadCompanies(
          search: currentState.search,
          status: currentState.status,
          verificationStatus: currentState.verificationStatus,
          country: currentState.country,
          planType: currentState.planType,
          sortBy: currentState.sortBy,
          sortOrder: currentState.sortOrder,
          page: currentState.page + 1,
          perPage: currentState.perPage,
        ));
      }
    }
  }

  /// Refresh companies list
  void refreshCompanies() {
    if (state is _Loaded) {
      final currentState = state as _Loaded;
      add(CompanyManagementEvent.loadCompanies(
        search: currentState.search,
        status: currentState.status,
        verificationStatus: currentState.verificationStatus,
        country: currentState.country,
        planType: currentState.planType,
        sortBy: currentState.sortBy,
        sortOrder: currentState.sortOrder,
        page: currentState.page,
        perPage: currentState.perPage,
      ));
    } else {
      add(const CompanyManagementEvent.loadCompanies());
    }
  }
}
