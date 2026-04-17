// Company Detail Bloc for NexaTrace System
// Business logic for company detail operations

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/nexa_admin/data/repositories/company_management_repository.dart';

part 'company_detail_event.dart';
part 'company_detail_state.dart';

class CompanyDetailBloc extends Bloc<CompanyDetailEvent, CompanyDetailState> {
  final CompanyManagementRepository _companyRepository;
  StreamSubscription? _companySubscription;

  CompanyDetailBloc({
    required CompanyManagementRepository companyRepository,
  })  : _companyRepository = companyRepository,
        super(CompanyDetailInitial()) {
    on<LoadCompanyDetail>(_onLoadCompanyDetail);
    on<UpdateCompanyDetail>(_onUpdateCompanyDetail);
    on<UpdateCompanyStatus>(_onUpdateCompanyStatus);
    on<UpdateCompanyVerificationStatus>(_onUpdateCompanyVerificationStatus);
    on<DeleteCompany>(_onDeleteCompany);
    on<RefreshCompanyDetail>(_onRefreshCompanyDetail);
    on<ResetCompanyDetail>(_onResetCompanyDetail);
  }

  Future<void> _onLoadCompanyDetail(
    LoadCompanyDetail event,
    Emitter<CompanyDetailState> emit,
  ) async {
    emit(CompanyDetailLoading());

    try {
      // Load company details
      final company = await _companyRepository.getCompany(event.companyId);

      emit(CompanyDetailLoaded(
        company: company.toJson(),
      ));
    } catch (error) {
      emit(CompanyDetailError(
        message: error.toString(),
        errorCode: _getErrorCode(error),
      ));
    }
  }

  Future<void> _onUpdateCompanyDetail(
    UpdateCompanyDetail event,
    Emitter<CompanyDetailState> emit,
  ) async {
    emit(CompanyDetailLoading());

    try {
      final updatedCompany = await _companyRepository.updateCompanyRaw(
        event.companyId,
        event.companyData,
      );

      emit(CompanyDetailUpdated(
        company: updatedCompany.toJson(),
        message: 'Company updated successfully',
      ));

      // Reload company details
      add(LoadCompanyDetail(companyId: event.companyId));
    } catch (error) {
      emit(CompanyDetailError(
        message: error.toString(),
        errorCode: _getErrorCode(error),
      ));
    }
  }

  Future<void> _onUpdateCompanyStatus(
    UpdateCompanyStatus event,
    Emitter<CompanyDetailState> emit,
  ) async {
    emit(CompanyDetailLoading());

    try {
      await _companyRepository.updateCompanyStatus(
        id: event.companyId,
        status: event.status,
        reason: event.reason,
      );

      emit(CompanyStatusUpdated(
        companyId: event.companyId,
        newStatus: event.status,
        message: 'Company status updated successfully',
      ));

      // Reload company details
      add(LoadCompanyDetail(companyId: event.companyId));
    } catch (error) {
      emit(CompanyDetailError(
        message: error.toString(),
        errorCode: _getErrorCode(error),
      ));
    }
  }

  Future<void> _onUpdateCompanyVerificationStatus(
    UpdateCompanyVerificationStatus event,
    Emitter<CompanyDetailState> emit,
  ) async {
    emit(CompanyDetailLoading());

    try {
      await _companyRepository.updateVerificationStatus(
        id: event.companyId,
        verificationStatus: event.verificationStatus,
        verificationNotes: event.verificationNotes,
      );

      emit(CompanyVerificationUpdated(
        companyId: event.companyId,
        newVerificationStatus: event.verificationStatus,
        message: 'Company verification updated successfully',
      ));

      add(LoadCompanyDetail(companyId: event.companyId));
    } catch (error) {
      emit(CompanyDetailError(
        message: error.toString(),
        errorCode: _getErrorCode(error),
      ));
    }
  }

  Future<void> _onDeleteCompany(
    DeleteCompany event,
    Emitter<CompanyDetailState> emit,
  ) async {
    emit(CompanyDetailLoading());

    try {
      await _companyRepository.deleteCompany(event.companyId);

      emit(CompanyDeleted(
        companyId: event.companyId,
        message: 'Company deleted successfully',
      ));
    } catch (error) {
      emit(CompanyDetailError(
        message: error.toString(),
        errorCode: _getErrorCode(error),
      ));
    }
  }

  Future<void> _onRefreshCompanyDetail(
    RefreshCompanyDetail event,
    Emitter<CompanyDetailState> emit,
  ) async {
    add(LoadCompanyDetail(companyId: event.companyId));
  }

  void _onResetCompanyDetail(
    ResetCompanyDetail event,
    Emitter<CompanyDetailState> emit,
  ) {
    emit(CompanyDetailInitial());
  }

  String? _getErrorCode(dynamic error) {
    if (error is String) {
      if (error.contains('404')) return 'NOT_FOUND';
      if (error.contains('401')) return 'UNAUTHORIZED';
      if (error.contains('403')) return 'FORBIDDEN';
      if (error.contains('500')) return 'SERVER_ERROR';
    }
    return null;
  }

  @override
  Future<void> close() {
    _companySubscription?.cancel();
    return super.close();
  }
}
