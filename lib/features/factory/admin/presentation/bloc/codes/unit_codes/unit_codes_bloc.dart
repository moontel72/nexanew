import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/codes_repository.dart';
import 'package:nexatrace_system/shared/models/code/unit_code_model.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';

part 'unit_codes_event.dart';
part 'unit_codes_state.dart';

class UnitCodesBloc extends Bloc<UnitCodesEvent, UnitCodesState> {
  final CodesRepository _codesRepository;

  UnitCodesBloc({required CodesRepository codesRepository})
    : _codesRepository = codesRepository,
      super(const UnitCodesState()) {
    on<LoadUnitCodes>(_onLoadUnitCodes);
    on<GenerateUnitCodes>(_onGenerateUnitCodes);
    on<DeleteUnitCode>(_onDeleteUnitCode);
    on<DeleteUnitCodeBatch>(_onDeleteUnitCodeBatch);
    on<LinkUnitCodeToProduct>(_onLinkUnitCodeToProduct);
    on<PublishUnitCode>(_onPublishUnitCode);
    on<PublishSelectedUnitCodes>(_onPublishSelectedUnitCodes);
    on<DeactivateUnitCode>(_onDeactivateUnitCode);
    on<SearchUnitCodes>(_onSearchUnitCodes);
    on<FilterUnitCodes>(_onFilterUnitCodes);
    on<ExportUnitCodes>(_onExportUnitCodes);
    on<SelectUnitCode>(_onSelectUnitCode);
    on<ClearSelection>(_onClearSelection);
    on<RefreshUnitCodes>(_onRefreshUnitCodes);
  }

  Future<void> _onLoadUnitCodes(
    LoadUnitCodes event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UnitCodesStatus.loading));

      final codes = await _codesRepository.getUnitCodes(page: 1, limit: 200);

      emit(
        state.copyWith(
          status: UnitCodesStatus.loaded,
          unitCodes: codes,
          filteredUnitCodes: codes,
          totalCount: codes.length,
          hasReachedMax: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: 'Failed to load unit codes: $error',
        ),
      );
    }
  }

  Future<void> _onGenerateUnitCodes(
    GenerateUnitCodes event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UnitCodesStatus.generating));

      await _codesRepository.generateUnitCodes(
        count: event.request.count,
        batchId: event.request.batchName,
        codeFormat: event.request.codeFormat,
        productId: event.productId,
        prefix: event.request.prefix,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
      );

      emit(
        state.copyWith(
          status: UnitCodesStatus.generated,
          generatedCount: event.request.count,
          lastGeneratedAt: DateTime.now(),
        ),
      );

      add(const LoadUnitCodes());
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: 'Failed to generate unit codes: $error',
        ),
      );
    }
  }

  Future<void> _onDeleteUnitCode(
    DeleteUnitCode event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UnitCodesStatus.deleting));
      await Future.delayed(const Duration(milliseconds: 300));

      final updatedCodes = state.unitCodes
          .where((c) => c.id != event.unitCodeId)
          .toList();
      emit(
        state.copyWith(
          status: UnitCodesStatus.deleted,
          unitCodes: updatedCodes,
          filteredUnitCodes: updatedCodes,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteUnitCodeBatch(
    DeleteUnitCodeBatch event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UnitCodesStatus.deleting));
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedCodes = state.unitCodes
          .where((c) => !event.unitCodeIds.contains(c.id))
          .toList();
      emit(
        state.copyWith(
          status: UnitCodesStatus.deleted,
          unitCodes: updatedCodes,
          filteredUnitCodes: updatedCodes,
          selectedUnitCodeIds: {},
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onLinkUnitCodeToProduct(
    LinkUnitCodeToProduct event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UnitCodesStatus.linking));
      await _codesRepository.linkUnitCodesToProduct(
        productId: event.productId,
        unitCodeIds: [event.unitCodeId],
        productBatchNumber: event.productBatchNumber,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
      );

      emit(state.copyWith(status: UnitCodesStatus.linked));
      add(const LoadUnitCodes());
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onPublishUnitCode(
    PublishUnitCode event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UnitCodesStatus.publishing));
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage:
              'Select a product and publish from the Unit Codes list.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onPublishSelectedUnitCodes(
    PublishSelectedUnitCodes event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      if (event.unitCodeIds.isEmpty) return;

      emit(state.copyWith(status: UnitCodesStatus.publishing));

      await _codesRepository.linkUnitCodesToProduct(
        productId: event.productId,
        unitCodeIds: event.unitCodeIds,
        productBatchNumber: event.productBatchNumber,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
      );

      await _codesRepository.publishUnitCodesForProduct(
        productId: event.productId,
        unitCodeIds: event.unitCodeIds,
        productBatchNumber: event.productBatchNumber,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
      );

      emit(
        state.copyWith(
          status: UnitCodesStatus.published,
          selectedUnitCodeIds: {},
        ),
      );
      add(const LoadUnitCodes());
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeactivateUnitCode(
    DeactivateUnitCode event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: UnitCodesStatus.deactivating));
      await Future.delayed(const Duration(milliseconds: 300));

      emit(state.copyWith(status: UnitCodesStatus.deactivated));
      add(const LoadUnitCodes());
    } catch (error) {
      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchUnitCodes(
    SearchUnitCodes event,
    Emitter<UnitCodesState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query).applyFilters());
  }

  Future<void> _onFilterUnitCodes(
    FilterUnitCodes event,
    Emitter<UnitCodesState> emit,
  ) async {
    emit(
      state
          .copyWith(
            filterStatus: event.status,
            filterPacketCode: event.packetCode,
            filterStartDate: event.startDate,
            filterEndDate: event.endDate,
            filterIsMasterCode: event.isMasterCode,
            filterIsReportedFake: event.isReportedFake,
            filterIsBlocked: event.isBlocked,
          )
          .applyFilters(),
    );
  }

  Future<void> _onExportUnitCodes(
    ExportUnitCodes event,
    Emitter<UnitCodesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: UnitCodesStatus.exporting, isExporting: true),
      );
      final format = (event.format == 'pdf') ? 'pdf' : 'csv';
      final path = await _codesRepository.downloadUnitCodes(
        codeIds: event.unitCodeIds,
        format: format,
      );

      emit(
        state.copyWith(
          status: UnitCodesStatus.exported,
          isExporting: false,
          exportPath: path,
        ),
      );
    } catch (error) {
      if (error is ServerException && error.statusCode == 423) {
        String invoiceNumber = '';
        final data = error.responseData;
        if (data is Map) {
          final root = Map<String, dynamic>.from(data.cast<String, dynamic>());
          final nested = root['data'];
          if (nested is Map) {
            final nestedMap = Map<String, dynamic>.from(
              nested.cast<String, dynamic>(),
            );
            invoiceNumber = (nestedMap['invoice_number'] ?? '').toString();
          }
        }

        emit(
          state.copyWith(
            status: UnitCodesStatus.error,
            errorMessage: invoiceNumber.trim().isEmpty
                ? 'DOWNLOAD_LOCKED'
                : 'DOWNLOAD_LOCKED|$invoiceNumber',
            isExporting: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: UnitCodesStatus.error,
          errorMessage: error.toString(),
          isExporting: false,
        ),
      );
    }
  }

  Future<void> _onSelectUnitCode(
    SelectUnitCode event,
    Emitter<UnitCodesState> emit,
  ) async {
    final selectedIds = Set<String>.from(state.selectedUnitCodeIds);
    if (event.isSelected) {
      selectedIds.add(event.unitCodeId);
    } else {
      selectedIds.remove(event.unitCodeId);
    }
    emit(state.copyWith(selectedUnitCodeIds: selectedIds));
  }

  Future<void> _onClearSelection(
    ClearSelection event,
    Emitter<UnitCodesState> emit,
  ) async {
    emit(state.copyWith(selectedUnitCodeIds: {}));
  }

  Future<void> _onRefreshUnitCodes(
    RefreshUnitCodes event,
    Emitter<UnitCodesState> emit,
  ) async {
    add(const LoadUnitCodes());
  }
}
