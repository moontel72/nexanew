import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/features/factory/admin/data/repositories/codes_repository_impl.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/codes_repository.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/carton_code_model.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';

part 'carton_codes_event.dart';
part 'carton_codes_state.dart';
part 'carton_codes_bloc.freezed.dart';

class CartonCodesBloc extends Bloc<CartonCodesEvent, CartonCodesState> {
  final CodesRepository _codesRepository;

  CartonCodesBloc({required CodesRepository codesRepository})
    : _codesRepository = codesRepository,
      super(const CartonCodesState()) {
    on<LoadCartonCodes>(_onLoadCartonCodes);
    on<GenerateCartonCodes>(_onGenerateCartonCodes);
    on<DeleteCartonCode>(_onDeleteCartonCode);
    on<DeleteCartonCodeBatch>(_onDeleteCartonCodeBatch);
    on<LinkCartonCodeToProduct>(_onLinkCartonCodeToProduct);
    on<PublishCartonCode>(_onPublishCartonCode);
    on<PushCartonBatch>(_onPushCartonBatch);
    on<DeleteCartonBatchByGroup>(_onDeleteCartonBatchByGroup);
    on<ExportCartonBatch>(_onExportCartonBatch);
    on<DeactivateCartonCode>(_onDeactivateCartonCode);
    on<SearchCartonCodes>(_onSearchCartonCodes);
    on<FilterCartonCodes>(_onFilterCartonCodes);
    on<FilterCartonCodesByFormat>(_onFilterCartonCodesByFormat);
    on<ExportCartonCodes>(_onExportCartonCodes);
    on<SelectCartonCode>(_onSelectCartonCode);
    on<ClearSelection>(_onClearSelection);
    on<RefreshCartonCodes>(_onRefreshCartonCodes);
    on<SealCarton>(_onSealCarton);
    on<UpdateCartonInspection>(_onUpdateCartonInspection);
    on<UpdateCartonProperties>(_onUpdateCartonProperties);
  }

  Future<void> _onLoadCartonCodes(
    LoadCartonCodes event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.loading));

      final format = event.codeFormat ?? state.filterCodeFormat;
      final codes = await _codesRepository.getCartonCodes(
        page: 1,
        limit: 200,
        codeFormat: format.isNotEmpty ? format : null,
      );

      emit(
        state.copyWith(
          status: CartonCodesStatus.loaded,
          cartonCodes: codes,
          filteredCartonCodes: codes,
          totalCount: codes.length,
          filterCodeFormat: format,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to load carton codes: $e',
        ),
      );
    }
  }

  Future<void> _onGenerateCartonCodes(
    GenerateCartonCodes event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.generating));

      await _codesRepository.generateCartonCodes(
        count: event.request.count,
        batchId: event.request.batchName,
        packetCount: event.request.packetsPerCarton > 0
            ? event.request.packetsPerCarton
            : null,
        unitsPerPacket: null,
        codeFormat: event.request.codeFormat.isNotEmpty
            ? event.request.codeFormat
            : null,
        prefix: event.request.prefix.isNotEmpty ? event.request.prefix : null,
      );

      final updatedCodes = await _codesRepository.getCartonCodes(
        page: 1,
        limit: 200,
      );
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(
        updatedState.copyWith(
          status: CartonCodesStatus.generated,
          generatedCount: updatedCodes.length,
          lastGeneratedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to generate carton codes: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteCartonCode(
    DeleteCartonCode event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.deleting));

      // Find the carton code
      final cartonIndex = state.cartonCodes.indexWhere(
        (c) => c.id == event.cartonCodeId,
      );
      if (cartonIndex == -1) {
        throw Exception('Carton code not found');
      }

      final carton = state.cartonCodes[cartonIndex];

      // Check if carton can be deleted (only before publishing)
      if (carton.status != CodeStatus.generated &&
          carton.status != CodeStatus.linked) {
        throw Exception(
          'Cannot delete carton codes that have been published or deactivated',
        );
      }

      await (_codesRepository as CodesRepositoryImpl).deleteCode(
        type: 'carton',
        id: event.cartonCodeId,
      );

      // Remove from lists
      final updatedCodes = List<CartonCodeModel>.from(state.cartonCodes);
      updatedCodes.removeAt(cartonIndex);

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(
        updatedState.copyWith(
          status: CartonCodesStatus.deleted,
          selectedCartonCodeIds: state.selectedCartonCodeIds
              .where((id) => id != event.cartonCodeId)
              .toSet(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to delete carton code: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteCartonCodeBatch(
    DeleteCartonCodeBatch event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.deleting));

      // Filter cartons that can be deleted
      final deletableCartons = state.cartonCodes.where((carton) {
        return event.cartonCodeIds.contains(carton.id) &&
            (carton.status == CodeStatus.generated ||
                carton.status == CodeStatus.linked);
      }).toList();

      if (deletableCartons.isEmpty) {
        throw Exception('No deletable carton codes found in selection');
      }

      await (_codesRepository as CodesRepositoryImpl).deleteCodesBatch(
        type: 'carton',
        ids: deletableCartons.map((c) => c.id).toList(),
      );

      // Remove from lists
      final updatedCodes = state.cartonCodes
          .where((carton) => !event.cartonCodeIds.contains(carton.id))
          .toList();

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(
        updatedState.copyWith(
          status: CartonCodesStatus.deleted,
          selectedCartonCodeIds: const {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to delete carton codes: $e',
        ),
      );
    }
  }

  Future<void> _onLinkCartonCodeToProduct(
    LinkCartonCodeToProduct event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.linking));

      // Find the carton code
      final cartonIndex = state.cartonCodes.indexWhere(
        (c) => c.id == event.cartonCodeId,
      );
      if (cartonIndex == -1) {
        throw Exception('Carton code not found');
      }

      final carton = state.cartonCodes[cartonIndex];

      // Check if carton can be linked (only generated codes)
      if (carton.status != CodeStatus.generated) {
        throw Exception(
          'Only generated carton codes can be linked to products',
        );
      }

      await _codesRepository.linkCartonCodeToProduct(
        codeId: carton.id,
        productId: event.productId,
        productBatchNumber: event.productBatchNumber,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
      );

      // Update carton
      final updatedCarton = carton.copyWith(
        productId: event.productId,
        productBatchNumber: event.productBatchNumber,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
        status: CodeStatus.linked,
        linkedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update lists
      final updatedCodes = List<CartonCodeModel>.from(state.cartonCodes);
      updatedCodes[cartonIndex] = updatedCarton;

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(updatedState.copyWith(status: CartonCodesStatus.linked));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to link carton code to product: $e',
        ),
      );
    }
  }

  Future<void> _onPublishCartonCode(
    PublishCartonCode event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.publishing));

      // Find the carton code
      final cartonIndex = state.cartonCodes.indexWhere(
        (c) => c.id == event.cartonCodeId,
      );
      if (cartonIndex == -1) {
        throw Exception('Carton code not found');
      }

      final carton = state.cartonCodes[cartonIndex];

      if (carton.status != CodeStatus.generated &&
          carton.status != CodeStatus.linked) {
        throw Exception(
          'Only generated or linked carton codes can be published',
        );
      }

      await _codesRepository.publishCartonCodes(codeIds: [carton.id]);

      // Update carton
      final updatedCarton = carton.copyWith(
        status: CodeStatus.published,
        publishedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update lists
      final updatedCodes = List<CartonCodeModel>.from(state.cartonCodes);
      updatedCodes[cartonIndex] = updatedCarton;

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(updatedState.copyWith(status: CartonCodesStatus.published));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to publish carton code: $e',
        ),
      );
    }
  }

  Future<void> _onPushCartonBatch(
    PushCartonBatch event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.publishing));

      final publishedCount = await _codesRepository.publishCartonBatch(
        batchId: event.batchId,
        codeFormat: event.codeFormat,
        count: event.count,
      );

      if (publishedCount <= 0) {
        emit(state.copyWith(status: CartonCodesStatus.published));
        return;
      }

      final now = DateTime.now();
      final updated = state.cartonCodes.map((c) {
        if (c.batchId == event.batchId &&
            c.codeFormat == event.codeFormat &&
            (c.status == CodeStatus.generated ||
                c.status == CodeStatus.linked)) {
          return c.copyWith(
            status: CodeStatus.published,
            publishedAt: now,
            updatedAt: now,
          );
        }
        return c;
      }).toList();

      final updatedState = state.copyWith(cartonCodes: updated).applyFilters();
      emit(updatedState.copyWith(status: CartonCodesStatus.published));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to push batch: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteCartonBatchByGroup(
    DeleteCartonBatchByGroup event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.deleting));

      final deletedCount = await _codesRepository.deleteCartonBatch(
        batchId: event.batchId,
        codeFormat: event.codeFormat,
      );

      if (deletedCount <= 0) {
        emit(state.copyWith(status: CartonCodesStatus.deleted));
        return;
      }

      final updated = state.cartonCodes
          .where(
            (c) =>
                !(c.batchId == event.batchId &&
                    c.codeFormat == event.codeFormat),
          )
          .toList();

      final updatedState = state.copyWith(cartonCodes: updated).applyFilters();
      emit(updatedState.copyWith(status: CartonCodesStatus.deleted));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to delete batch: $e',
        ),
      );
    }
  }

  Future<void> _onExportCartonBatch(
    ExportCartonBatch event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: CartonCodesStatus.exporting,
          isExporting: true,
          exportPath: null,
          errorMessage: null,
        ),
      );

      final url = await _codesRepository.downloadCartonBatch(
        batchId: event.batchId,
        codeFormat: event.codeFormat,
        format: event.format,
      );

      emit(
        state.copyWith(
          status: CartonCodesStatus.exported,
          isExporting: false,
          exportPath: url,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          isExporting: false,
          errorMessage: 'Failed to export batch: $e',
        ),
      );
    }
  }

  Future<void> _onDeactivateCartonCode(
    DeactivateCartonCode event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.deactivating));

      // Find the carton code
      final cartonIndex = state.cartonCodes.indexWhere(
        (c) => c.id == event.cartonCodeId,
      );
      if (cartonIndex == -1) {
        throw Exception('Carton code not found');
      }

      final carton = state.cartonCodes[cartonIndex];

      // Check if carton can be deactivated (only published codes)
      if (carton.status != CodeStatus.published) {
        throw Exception('Only published carton codes can be deactivated');
      }

      // TODO: Implement API call to deactivate carton code
      await Future.delayed(const Duration(milliseconds: 300));

      // Update carton
      final updatedCarton = carton.copyWith(
        status: CodeStatus.deactivated,
        deactivatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: carton.metadata != null
            ? '${carton.metadata}\nDeactivation Reason: ${event.reason}'
            : 'Deactivation Reason: ${event.reason}',
      );

      // Update lists
      final updatedCodes = List<CartonCodeModel>.from(state.cartonCodes);
      updatedCodes[cartonIndex] = updatedCarton;

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(updatedState.copyWith(status: CartonCodesStatus.deactivated));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to deactivate carton code: $e',
        ),
      );
    }
  }

  Future<void> _onSearchCartonCodes(
    SearchCartonCodes event,
    Emitter<CartonCodesState> emit,
  ) async {
    final updatedState = state
        .copyWith(searchQuery: event.query)
        .applyFilters();

    emit(updatedState);
  }

  Future<void> _onFilterCartonCodesByFormat(
    FilterCartonCodesByFormat event,
    Emitter<CartonCodesState> emit,
  ) async {
    final format = event.codeFormat ?? 'qr';

    // Reload codes with the new format filter from the API
    try {
      emit(
        state.copyWith(
          status: CartonCodesStatus.loading,
          filterCodeFormat: format,
        ),
      );

      final codes = await _codesRepository.getCartonCodes(
        page: 1,
        limit: 200,
        codeFormat: format.isNotEmpty ? format : null,
      );

      final updatedState = state
          .copyWith(cartonCodes: codes, filterCodeFormat: format)
          .applyFilters();

      emit(updatedState.copyWith(status: CartonCodesStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to filter carton codes by format: $e',
        ),
      );
    }
  }

  Future<void> _onFilterCartonCodes(
    FilterCartonCodes event,
    Emitter<CartonCodesState> emit,
  ) async {
    final updatedState = state
        .copyWith(
          filterStatus: event.status,
          filterBundleCode: event.bundleCode,
          filterStartDate: event.startDate,
          filterEndDate: event.endDate,
          filterCartonType: event.cartonType,
          filterCondition: event.condition,
        )
        .applyFilters();

    emit(updatedState);
  }

  Future<void> _onExportCartonCodes(
    ExportCartonCodes event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: CartonCodesStatus.exporting, isExporting: true),
      );

      // Get cartons to export
      final cartonsToExport = event.cartonCodeIds.isEmpty
          ? state.filteredCartonCodes
          : state.cartonCodes
                .where((carton) => event.cartonCodeIds.contains(carton.id))
                .toList();

      final ids = cartonsToExport.map((c) => c.id).toList();
      final format = (event.format == 'pdf') ? 'pdf' : 'csv';
      final exportPath = await _codesRepository.downloadCartonCodes(
        codeIds: ids,
        format: format,
        codeFormat: state.filterCodeFormat.isNotEmpty
            ? state.filterCodeFormat
            : null,
      );

      emit(
        state.copyWith(
          status: CartonCodesStatus.exported,
          isExporting: false,
          exportPath: exportPath,
        ),
      );
    } catch (e) {
      if (e is LockedException) {
        emit(
          state.copyWith(
            status: CartonCodesStatus.error,
            isExporting: false,
            errorMessage: '${e.message} (Invoice: ${e.invoiceId})',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          isExporting: false,
          errorMessage: 'Failed to export carton codes: $e',
        ),
      );
    }
  }

  Future<void> _onSelectCartonCode(
    SelectCartonCode event,
    Emitter<CartonCodesState> emit,
  ) async {
    final updatedSelection = Set<String>.from(state.selectedCartonCodeIds);

    if (event.isSelected) {
      updatedSelection.add(event.cartonCodeId);
    } else {
      updatedSelection.remove(event.cartonCodeId);
    }

    emit(state.copyWith(selectedCartonCodeIds: updatedSelection));
  }

  Future<void> _onClearSelection(
    ClearSelection event,
    Emitter<CartonCodesState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCartonCodeIds: const {},
        // Also reset export state to prevent ghost download popups
        exportPath: null,
        isExporting: false,
      ),
    );
  }

  Future<void> _onRefreshCartonCodes(
    RefreshCartonCodes event,
    Emitter<CartonCodesState> emit,
  ) async {
    add(const LoadCartonCodes());
  }

  Future<void> _onSealCarton(
    SealCarton event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.sealing));

      // Find the carton code
      final cartonIndex = state.cartonCodes.indexWhere(
        (c) => c.id == event.cartonCodeId,
      );
      if (cartonIndex == -1) {
        throw Exception('Carton code not found');
      }

      final carton = state.cartonCodes[cartonIndex];

      // Check if carton is already sealed
      if (carton.isCartonSealed) {
        throw Exception('Carton is already sealed');
      }

      // TODO: Implement API call to seal carton
      await Future.delayed(const Duration(milliseconds: 300));

      // Update carton
      final updatedCarton = carton.copyWith(
        isSealed: true,
        sealedAt: DateTime.now(),
        sealedBy: event.sealedBy,
        updatedAt: DateTime.now(),
      );

      // Update lists
      final updatedCodes = List<CartonCodeModel>.from(state.cartonCodes);
      updatedCodes[cartonIndex] = updatedCarton;

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(updatedState.copyWith(status: CartonCodesStatus.sealed));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to seal carton: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateCartonInspection(
    UpdateCartonInspection event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.inspecting));

      // Find the carton code
      final cartonIndex = state.cartonCodes.indexWhere(
        (c) => c.id == event.cartonCodeId,
      );
      if (cartonIndex == -1) {
        throw Exception('Carton code not found');
      }

      final carton = state.cartonCodes[cartonIndex];

      // TODO: Implement API call to update carton inspection
      await Future.delayed(const Duration(milliseconds: 300));

      // Update carton
      final updatedCarton = carton.copyWith(
        condition: event.condition,
        lastInspectionDate: DateTime.now(),
        inspectionNotes: event.inspectionNotes,
        updatedAt: DateTime.now(),
      );

      // Update lists
      final updatedCodes = List<CartonCodeModel>.from(state.cartonCodes);
      updatedCodes[cartonIndex] = updatedCarton;

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(updatedState.copyWith(status: CartonCodesStatus.inspected));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to update carton inspection: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateCartonProperties(
    UpdateCartonProperties event,
    Emitter<CartonCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CartonCodesStatus.updating));

      // Find the carton code
      final cartonIndex = state.cartonCodes.indexWhere(
        (c) => c.id == event.cartonCodeId,
      );
      if (cartonIndex == -1) {
        throw Exception('Carton code not found');
      }

      final carton = state.cartonCodes[cartonIndex];

      // TODO: Implement API call to update carton properties
      await Future.delayed(const Duration(milliseconds: 300));

      // Update carton
      final updatedCarton = carton.copyWith(
        weight: event.weight ?? carton.weight,
        dimensions: event.dimensions ?? carton.dimensions,
        temperatureRequirements:
            event.temperatureRequirements ?? carton.temperatureRequirements,
        handlingInstructions:
            event.handlingInstructions ?? carton.handlingInstructions,
        updatedAt: DateTime.now(),
      );

      // Update lists
      final updatedCodes = List<CartonCodeModel>.from(state.cartonCodes);
      updatedCodes[cartonIndex] = updatedCarton;

      // Update filtered list
      final updatedState = state
          .copyWith(cartonCodes: updatedCodes)
          .applyFilters();

      emit(updatedState.copyWith(status: CartonCodesStatus.updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: CartonCodesStatus.error,
          errorMessage: 'Failed to update carton properties: $e',
        ),
      );
    }
  }
}

extension CartonCodesStateX on CartonCodesState {
  CartonCodesState applyFilters() {
    final filtered = cartonCodes.where((carton) {
      // Search filter
      final matchesSearch =
          searchQuery.isEmpty ||
          carton.code.toLowerCase().contains(searchQuery.toLowerCase()) ||
          carton.batchId.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      // Status filter
      if (filterStatus != null && carton.status != filterStatus) return false;

      // Bundle code filter
      if (filterBundleCode != null &&
          carton.bundleCode != filterBundleCode &&
          filterBundleCode!.isNotEmpty) {
        return false;
      }

      // Code format filter
      if (filterCodeFormat.isNotEmpty &&
          carton.codeFormat != filterCodeFormat) {
        return false;
      }

      // Date range filter
      if (filterStartDate != null &&
          (carton.createdAt.isBefore(filterStartDate!) ?? false)) {
        return false;
      }
      if (filterEndDate != null &&
          (carton.createdAt.isAfter(filterEndDate!) ?? false)) {
        return false;
      }

      // Carton type filter
      if (filterCartonType != null &&
          carton.cartonType != filterCartonType &&
          filterCartonType!.isNotEmpty) {
        return false;
      }

      // Condition filter
      if (filterCondition != null &&
          carton.condition != filterCondition &&
          filterCondition!.isNotEmpty) {
        return false;
      }

      return true;
    }).toList();

    return copyWith(filteredCartonCodes: filtered, totalCount: filtered.length);
  }
}
