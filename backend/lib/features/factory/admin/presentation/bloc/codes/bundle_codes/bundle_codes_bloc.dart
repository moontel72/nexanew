import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/codes_repository.dart';
import 'package:nexatrace_system/shared/models/code/bundle_code_model.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';

part 'bundle_codes_event.dart';
part 'bundle_codes_state.dart';
part 'bundle_codes_bloc.freezed.dart';

class BundleCodesBloc extends Bloc<BundleCodesEvent, BundleCodesState> {
  final CodesRepository _codesRepository;

  BundleCodesBloc({required CodesRepository codesRepository})
    : _codesRepository = codesRepository,
      super(const BundleCodesState()) {
    on<LoadBundleCodes>(_onLoadBundleCodes);
    on<GenerateBundleCodes>(_onGenerateBundleCodes);
    on<DeleteBundleCode>(_onDeleteBundleCode);
    on<DeleteBundleCodeBatch>(_onDeleteBundleCodeBatch);
    on<LinkBundleCodeToProduct>(_onLinkBundleCodeToProduct);
    on<PublishBundleCode>(_onPublishBundleCode);
    on<DeactivateBundleCode>(_onDeactivateBundleCode);
    on<SearchBundleCodes>(_onSearchBundleCodes);
    on<FilterBundleCodes>(_onFilterBundleCodes);
    on<ExportBundleCodes>(_onExportBundleCodes);
    on<SelectBundleCode>(_onSelectBundleCode);
    on<ClearSelection>(_onClearSelection);
    on<RefreshBundleCodes>(_onRefreshBundleCodes);
    on<LoadMoreBundleCodes>(_onLoadMoreBundleCodes);
  }

  void _onLoadMoreBundleCodes(
    LoadMoreBundleCodes event,
    Emitter<BundleCodesState> emit,
  ) {
    if (state.hasMorePages) {
      emit(state.copyWith(page: state.page + 1));
    }
  }

  Future<void> _onLoadBundleCodes(
    LoadBundleCodes event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleCodesStatus.loading));

      final codes = await _codesRepository.getBundleCodes(page: 1, limit: 200);

      emit(
        state.copyWith(
          status: BundleCodesStatus.success,
          codes: codes,
          filteredCodes: codes,
          hasReachedMax: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BundleCodesStatus.failure,
          error: 'Failed to load bundle codes: $error',
        ),
      );
    }
  }

  Future<void> _onGenerateBundleCodes(
    GenerateBundleCodes event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(generationStatus: CodeGenerationStatus.generating));

      await _codesRepository.generateBundleCodes(
        count: event.request.count,
        batchId: event.request.batchName,
        cartonsPerBundle: event.request.cartonsPerBundle,
      );

      final updatedCodes = await _codesRepository.getBundleCodes(
        page: 1,
        limit: 200,
      );

      emit(
        state.copyWith(
          generationStatus: CodeGenerationStatus.success,
          codes: updatedCodes,
          filteredCodes: updatedCodes,
          lastGeneratedBatchId: event.request.batchName,
          lastGeneratedCount: event.request.count,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          generationStatus: CodeGenerationStatus.failure,
          error: 'Failed to generate bundle codes: $error',
        ),
      );
    }
  }

  Future<void> _onDeleteBundleCode(
    DeleteBundleCode event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleCodesStatus.loading));

      // Check if code can be deleted
      final codeToDelete = state.codes.firstWhere(
        (code) => code.id == event.codeId,
        orElse: () => throw Exception('Code not found'),
      );

      if (!codeToDelete.canDelete) {
        throw Exception(
          'Cannot delete code with status: ${codeToDelete.statusDisplayName}',
        );
      }

      // TODO: Implement API call to delete code
      await Future.delayed(const Duration(milliseconds: 300));

      final updatedCodes = state.codes
          .where((code) => code.id != event.codeId)
          .toList();

      emit(
        state.copyWith(
          status: BundleCodesStatus.success,
          codes: updatedCodes,
          filteredCodes: updatedCodes,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BundleCodesStatus.failure,
          error: 'Failed to delete bundle code: $error',
        ),
      );
    }
  }

  Future<void> _onDeleteBundleCodeBatch(
    DeleteBundleCodeBatch event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleCodesStatus.loading));

      // Check if all codes can be deleted
      for (final codeId in event.codeIds) {
        final code = state.codes.firstWhere(
          (c) => c.id == codeId,
          orElse: () => throw Exception('Code $codeId not found'),
        );

        if (!code.canDelete) {
          throw Exception(
            'Cannot delete code ${code.code} with status: ${code.statusDisplayName}',
          );
        }
      }

      // TODO: Implement API call to delete batch
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedCodes = state.codes
          .where((code) => !event.codeIds.contains(code.id))
          .toList();

      emit(
        state.copyWith(
          status: BundleCodesStatus.success,
          codes: updatedCodes,
          filteredCodes: updatedCodes,
          selectedCodes: {},
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BundleCodesStatus.failure,
          error: 'Failed to delete bundle codes batch: $error',
        ),
      );
    }
  }

  Future<void> _onLinkBundleCodeToProduct(
    LinkBundleCodeToProduct event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleCodesStatus.loading));

      await _codesRepository.linkBundleCodeToProduct(
        codeId: event.codeId,
        productId: event.productId,
        productBatchNumber: event.productBatchNumber,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
      );

      final updatedCodes = state.codes.map((code) {
        if (code.id == event.codeId) {
          return code.copyWith(
            status: CodeStatus.linked,
            productId: event.productId,
            productBatchNumber: event.productBatchNumber,
            manufacturingDate: event.manufacturingDate,
            expiryDate: event.expiryDate,
            warrantyMonths: event.warrantyMonths,
            linkedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        return code;
      }).toList();

      emit(
        state.copyWith(
          status: BundleCodesStatus.success,
          codes: updatedCodes,
          filteredCodes: updatedCodes,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BundleCodesStatus.failure,
          error: 'Failed to link bundle code to product: $error',
        ),
      );
    }
  }

  Future<void> _onPublishBundleCode(
    PublishBundleCode event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleCodesStatus.loading));

      await _codesRepository.publishBundleCodes(codeIds: [event.codeId]);

      final updatedCodes = state.codes.map((code) {
        if (code.id == event.codeId) {
          return code.copyWith(
            status: CodeStatus.published,
            publishedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        return code;
      }).toList();

      emit(
        state.copyWith(
          status: BundleCodesStatus.success,
          codes: updatedCodes,
          filteredCodes: updatedCodes,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BundleCodesStatus.failure,
          error: 'Failed to publish bundle code: $error',
        ),
      );
    }
  }

  Future<void> _onDeactivateBundleCode(
    DeactivateBundleCode event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: BundleCodesStatus.loading));

      // TODO: Implement API call to deactivate code
      await Future.delayed(const Duration(milliseconds: 400));

      final updatedCodes = state.codes.map((code) {
        if (code.id == event.codeId) {
          return code.copyWith(
            status: CodeStatus.deactivated,
            deactivatedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        return code;
      }).toList();

      emit(
        state.copyWith(
          status: BundleCodesStatus.success,
          codes: updatedCodes,
          filteredCodes: updatedCodes,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BundleCodesStatus.failure,
          error: 'Failed to deactivate bundle code: $error',
        ),
      );
    }
  }

  Future<void> _onSearchBundleCodes(
    SearchBundleCodes event,
    Emitter<BundleCodesState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredCodes: state.codes, searchQuery: ''));
      return;
    }

    final query = event.query.toLowerCase();
    final filtered = state.codes.where((code) {
      return code.code.toLowerCase().contains(query) ||
          code.storeKeeperCode.toLowerCase().contains(query) ||
          (code.internationalCode ?? '').toLowerCase().contains(query) ||
          (code.productBatchNumber?.toLowerCase().contains(query) ?? false) ||
          code.statusDisplayName.toLowerCase().contains(query);
    }).toList();

    emit(state.copyWith(filteredCodes: filtered, searchQuery: event.query));
  }

  Future<void> _onFilterBundleCodes(
    FilterBundleCodes event,
    Emitter<BundleCodesState> emit,
  ) async {
    List<BundleCodeModel> filtered = state.codes;

    // Filter by status
    if (event.status != null) {
      filtered = filtered.where((code) => code.status == event.status).toList();
    }

    // Filter by date range
    if (event.startDate != null) {
      filtered = filtered
          .where((code) => code.generatedAt.isAfter(event.startDate!) ?? false)
          .toList();
    }
    if (event.endDate != null) {
      filtered = filtered
          .where((code) => code.generatedAt.isBefore(event.endDate!) ?? false)
          .toList();
    }

    // Filter by carton count range
    if (event.minCartonCount != null) {
      filtered = filtered
          .where((code) => code.cartonCount >= event.minCartonCount!)
          .toList();
    }
    if (event.maxCartonCount != null) {
      filtered = filtered
          .where((code) => code.cartonCount <= event.maxCartonCount!)
          .toList();
    }

    emit(state.copyWith(filteredCodes: filtered, currentFilter: event));
  }

  Future<void> _onExportBundleCodes(
    ExportBundleCodes event,
    Emitter<BundleCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(exportStatus: ExportStatus.exporting));

      final ids = (event.codeIds ?? state.selectedCodes.toList()).toList();
      if (ids.isEmpty) {
        emit(
          state.copyWith(
            exportStatus: ExportStatus.failure,
            error: 'Select codes to export',
          ),
        );
        return;
      }

      final format = switch (event.format) {
        ExportFormat.pdf => 'pdf',
        _ => 'csv',
      };

      await _codesRepository.downloadBundleCodes(
        codeIds: ids,
        format: format,
        includeQrCodes: event.includeQrCodes,
        includeBarcodes: event.includeBarcodes,
        includeInternationalCodes: event.includeInternationalCodes,
      );

      emit(state.copyWith(exportStatus: ExportStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          exportStatus: ExportStatus.failure,
          error: 'Failed to export bundle codes: $error',
        ),
      );
    }
  }

  Future<void> _onSelectBundleCode(
    SelectBundleCode event,
    Emitter<BundleCodesState> emit,
  ) async {
    final selectedCodes = Set<String>.from(state.selectedCodes);

    if (selectedCodes.contains(event.codeId)) {
      selectedCodes.remove(event.codeId);
    } else {
      selectedCodes.add(event.codeId);
    }

    emit(state.copyWith(selectedCodes: selectedCodes));
  }

  Future<void> _onClearSelection(
    ClearSelection event,
    Emitter<BundleCodesState> emit,
  ) async {
    emit(state.copyWith(selectedCodes: {}));
  }

  Future<void> _onRefreshBundleCodes(
    RefreshBundleCodes event,
    Emitter<BundleCodesState> emit,
  ) async {
    add(const LoadBundleCodes());
  }
}
