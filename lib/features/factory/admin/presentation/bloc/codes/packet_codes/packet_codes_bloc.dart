import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/features/factory/admin/data/repositories/codes_repository_impl.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/codes_repository.dart';
import 'package:nexatrace_system/shared/models/code/base_code_model.dart';
import 'package:nexatrace_system/shared/models/code/packet_code_model.dart';
import 'package:nexatrace_system/shared/models/code/code_generation_request.dart';

part 'packet_codes_event.dart';
part 'packet_codes_state.dart';
part 'packet_codes_bloc.freezed.dart';

class PacketCodesBloc extends Bloc<PacketCodesEvent, PacketCodesState> {
  final CodesRepository _codesRepository;

  PacketCodesBloc({required CodesRepository codesRepository})
    : _codesRepository = codesRepository,
      super(const PacketCodesState()) {
    on<LoadPacketCodes>(_onLoadPacketCodes);
    on<GeneratePacketCodes>(_onGeneratePacketCodes);
    on<DeletePacketCode>(_onDeletePacketCode);
    on<DeletePacketCodeBatch>(_onDeletePacketCodeBatch);
    on<LinkPacketCodeToProduct>(_onLinkPacketCodeToProduct);
    on<PublishPacketCode>(_onPublishPacketCode);
    on<DeactivatePacketCode>(_onDeactivatePacketCode);
    on<SearchPacketCodes>(_onSearchPacketCodes);
    on<FilterPacketCodesByFormat>(_onFilterPacketCodesByFormat);
    on<FilterPacketCodes>(_onFilterPacketCodes);
    on<ExportPacketCodes>(_onExportPacketCodes);
    on<PushPacketBatch>(_onPushPacketBatch);
    on<DeletePacketBatchByGroup>(_onDeletePacketBatchByGroup);
    on<ExportPacketBatch>(_onExportPacketBatch);
    on<SelectPacketCode>(_onSelectPacketCode);
    on<ClearSelection>(_onClearSelection);
    on<RefreshPacketCodes>(_onRefreshPacketCodes);
    on<SealPacket>(_onSealPacket);
    on<UpdatePacketInspection>(_onUpdatePacketInspection);
    on<UpdatePacketProperties>(_onUpdatePacketProperties);
    on<AddTamperEvidence>(_onAddTamperEvidence);
    on<AddChildSafetyFeatures>(_onAddChildSafetyFeatures);
    on<AddInstructions>(_onAddInstructions);
  }

  Future<void> _onLoadPacketCodes(
    LoadPacketCodes event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.loading));

      final codes = await _codesRepository.getPacketCodes(
        page: 1,
        limit: 500,
        codeFormat: event.codeFormat,
      );

      emit(
        state.copyWith(
          status: PacketCodesStatus.loaded,
          packetCodes: codes,
          filteredPacketCodes: codes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Failed to load packet codes: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onGeneratePacketCodes(
    GeneratePacketCodes event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.generating));

      final request = event.request;

      await _codesRepository.generatePacketCodes(
        count: request.count,
        batchId: request.batchName,
        unitCount: null,
        codeFormat: request.codeFormat,
        prefix: request.prefix,
      );

      final updatedCodes = await _codesRepository.getPacketCodes(
        page: 1,
        limit: 200,
      );
      final updatedState = state
          .copyWith(packetCodes: updatedCodes)
          .applyFilters();

      emit(
        updatedState.copyWith(
          status: PacketCodesStatus.generated,
          generatedCount: updatedCodes.length,
          lastGeneratedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Failed to generate packet codes: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeletePacketCode(
    DeletePacketCode event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.deleting));

      await (_codesRepository as CodesRepositoryImpl).deleteCode(
        type: 'packet',
        id: event.packetCodeId,
      );

      final updatedCodes = state.packetCodes
          .where((packet) => packet.id != event.packetCodeId)
          .toList();

      emit(
        state.copyWith(
          status: PacketCodesStatus.deleted,
          packetCodes: updatedCodes,
          filteredPacketCodes: updatedCodes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Failed to delete packet code: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeletePacketCodeBatch(
    DeletePacketCodeBatch event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.deleting));

      await (_codesRepository as CodesRepositoryImpl).deleteCodesBatch(
        type: 'packet',
        ids: event.packetCodeIds,
      );

      final updatedCodes = state.packetCodes
          .where((packet) => !event.packetCodeIds.contains(packet.id))
          .toList();

      emit(
        state.copyWith(
          status: PacketCodesStatus.deleted,
          packetCodes: updatedCodes,
          filteredPacketCodes: updatedCodes,
          selectedPacketCodeIds: const {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Failed to delete packet codes: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLinkPacketCodeToProduct(
    LinkPacketCodeToProduct event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.linking));

      await _codesRepository.linkPacketCodeToProduct(
        codeId: event.packetCodeId,
        productId: event.productId,
        productBatchNumber: event.productBatchNumber,
        manufacturingDate: event.manufacturingDate,
        expiryDate: event.expiryDate,
        warrantyMonths: event.warrantyMonths,
      );

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            productId: event.productId,
            productBatchNumber: event.productBatchNumber,
            manufacturingDate: event.manufacturingDate,
            expiryDate: event.expiryDate,
            warrantyMonths: event.warrantyMonths,
            linkedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.linked));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Failed to link packet code: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onPublishPacketCode(
    PublishPacketCode event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.publishing));

      final packet = state.packetCodes.firstWhere(
        (p) => p.id == event.packetCodeId,
      );

      if (packet.status != CodeStatus.generated &&
          packet.status != CodeStatus.linked) {
        throw Exception(
          'Only generated or linked packet codes can be published',
        );
      }

      await _codesRepository.publishPacketCodes(codeIds: [event.packetCodeId]);

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            status: CodeStatus.published,
            publishedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.published));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Failed to publish packet code: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeactivatePacketCode(
    DeactivatePacketCode event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.deactivating));

      // TODO: Implement deactivation logic
      await Future.delayed(const Duration(milliseconds: 400));

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            status: CodeStatus.deactivated,
            deactivatedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.deactivated));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Failed to deactivate packet code: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSearchPacketCodes(
    SearchPacketCodes event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        emit(
          state.copyWith(
            filteredPacketCodes: state.packetCodes,
            searchQuery: '',
          ),
        );
        return;
      }

      final query = event.query.toLowerCase();
      final filtered = state.packetCodes.where((packet) {
        return packet.code.toLowerCase().contains(query) ||
            packet.storeKeeperCode.toLowerCase().contains(query) ||
            (packet.internationalCode ?? '').toLowerCase().contains(query) ||
            (packet.productId?.toLowerCase().contains(query) ?? false) ||
            (packet.productBatchNumber?.toLowerCase().contains(query) ?? false);
      }).toList();

      emit(
        state.copyWith(filteredPacketCodes: filtered, searchQuery: event.query),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onFilterPacketCodesByFormat(
    FilterPacketCodesByFormat event,
    Emitter<PacketCodesState> emit,
  ) async {
    final format = event.codeFormat;

    // Reload from API with the format filter — same as Carton architecture
    try {
      emit(
        state.copyWith(
          status: PacketCodesStatus.loading,
          filterCodeFormat: format ?? '',
          // Clear any pending export state to prevent ghost download popups
          exportPath: null,
          isExporting: false,
        ),
      );

      final codes = await _codesRepository.getPacketCodes(
        page: 1,
        limit: 500,
        codeFormat: format,
      );

      emit(
        state.copyWith(
          status: PacketCodesStatus.loaded,
          packetCodes: codes,
          filteredPacketCodes: codes,
          filterCodeFormat: format ?? '',
          exportPath: null,
          isExporting: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Format filter failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onFilterPacketCodes(
    FilterPacketCodes event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      List<PacketCodeModel> filtered = state.packetCodes;

      if (event.status != null) {
        filtered = filtered
            .where((packet) => packet.status == event.status)
            .toList();
      }

      if (event.cartonCode != null) {
        filtered = filtered
            .where((packet) => packet.cartonCode == event.cartonCode)
            .toList();
      }

      if (event.startDate != null) {
        filtered = filtered.where((packet) {
          final generatedAt = packet.generatedAt;
          return generatedAt.isAfter(event.startDate!) ||
              generatedAt.isAtSameMomentAs(event.startDate!);
        }).toList();
      }

      if (event.endDate != null) {
        filtered = filtered.where((packet) {
          final generatedAt = packet.generatedAt;
          return generatedAt.isBefore(event.endDate!) ||
              generatedAt.isAtSameMomentAs(event.endDate!);
        }).toList();
      }

      emit(
        state.copyWith(
          filteredPacketCodes: filtered,
          filterStatus: event.status,
          filterCartonCode: event.cartonCode,
          filterStartDate: event.startDate,
          filterEndDate: event.endDate,
          filterPacketType: event.packetType,
          filterCondition: event.condition,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Filter failed: ${e.toString()}'));
    }
  }

  Future<void> _onExportPacketCodes(
    ExportPacketCodes event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: PacketCodesStatus.exporting, isExporting: true),
      );

      // Get packets to export
      final packetsToExport = event.packetCodeIds.isEmpty
          ? state.filteredPacketCodes
          : state.packetCodes
                .where((packet) => event.packetCodeIds.contains(packet.id))
                .toList();

      final ids = packetsToExport.map((p) => p.id).toList();
      final format = (event.format == 'pdf') ? 'pdf' : 'csv';
      final exportPath = await _codesRepository.downloadPacketCodes(
        codeIds: ids,
        format: format,
        codeFormat: state.filterCodeFormat.isNotEmpty
            ? state.filterCodeFormat
            : null,
      );

      emit(
        state.copyWith(
          status: PacketCodesStatus.exported,
          isExporting: false,
          exportPath: exportPath,
        ),
      );
    } catch (e) {
      if (e is LockedException) {
        emit(
          state.copyWith(
            status: PacketCodesStatus.error,
            isExporting: false,
            errorMessage: '${e.message} (Invoice: ${e.invoiceId})',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          isExporting: false,
          errorMessage: 'Export failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onPushPacketBatch(
    PushPacketBatch event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.publishing));
      final batchCodes = state.packetCodes
          .where((p) => p.batchId == event.batchId)
          .map((p) => p.id)
          .toList();
      await _codesRepository.publishPacketCodes(codeIds: batchCodes);
      final updatedCodes = state.packetCodes.map((p) {
        if (p.batchId == event.batchId) {
          return p.copyWith(
            status: CodeStatus.published,
            publishedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        return p;
      }).toList();
      emit(
        state.copyWith(
          packetCodes: updatedCodes,
          filteredPacketCodes: updatedCodes,
          status: PacketCodesStatus.published,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Batch push failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeletePacketBatchByGroup(
    DeletePacketBatchByGroup event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.deleting));
      final batchCodeIds = state.packetCodes
          .where((p) => p.batchId == event.batchId)
          .map((p) => p.id)
          .toList();
      await _codesRepository.deletePacketBatch(
        batchId: event.batchId,
        codeFormat: event.codeFormat,
      );
      final updatedCodes = state.packetCodes
          .where((p) => p.batchId != event.batchId)
          .toList();
      emit(
        state.copyWith(
          packetCodes: updatedCodes,
          filteredPacketCodes: updatedCodes,
          status: PacketCodesStatus.deleted,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Batch delete failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onExportPacketBatch(
    ExportPacketBatch event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(status: PacketCodesStatus.exporting, isExporting: true),
      );
      final batchCodeIds = state.packetCodes
          .where((p) => p.batchId == event.batchId)
          .map((p) => p.id)
          .toList();
      final format = (event.format == 'pdf') ? 'pdf' : 'csv';
      final exportPath = await _codesRepository.downloadPacketCodes(
        codeIds: batchCodeIds,
        format: format,
        codeFormat: state.filterCodeFormat.isNotEmpty
            ? state.filterCodeFormat
            : null,
      );
      emit(
        state.copyWith(
          status: PacketCodesStatus.exported,
          isExporting: false,
          exportPath: exportPath,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          isExporting: false,
          errorMessage: 'Batch export failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSelectPacketCode(
    SelectPacketCode event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      final selected = {...state.selectedPacketCodeIds};
      if (event.isSelected) {
        selected.add(event.packetCodeId);
      } else {
        selected.remove(event.packetCodeId);
      }

      emit(state.copyWith(selectedPacketCodeIds: selected));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Selection failed: ${e.toString()}'));
    }
  }

  Future<void> _onClearSelection(
    ClearSelection event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          selectedPacketCodeIds: const {},
          // Also reset export state to prevent ghost download popups
          exportPath: null,
          isExporting: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Clear selection failed: ${e.toString()}'),
      );
    }
  }

  Future<void> _onRefreshPacketCodes(
    RefreshPacketCodes event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.loading));

      // TODO: Implement refresh logic
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(status: PacketCodesStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Refresh failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSealPacket(
    SealPacket event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.sealing));

      // TODO: Implement sealing logic
      await Future.delayed(const Duration(milliseconds: 400));

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            isSealed: true,
            sealedAt: DateTime.now(),
            sealedBy: event.sealedBy,
            sealingMethod: event.sealingMethod,
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.sealed));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Sealing failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdatePacketInspection(
    UpdatePacketInspection event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.updating));

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            condition: event.condition,
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Inspection update failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdatePacketProperties(
    UpdatePacketProperties event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.updating));

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            weight: event.weight,
            dimensions: event.dimensions,
            packetType: event.packetType,
            material: event.material,
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Properties update failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onAddTamperEvidence(
    AddTamperEvidence event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.updating));

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            hasTamperEvidence: true,
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Tamper evidence addition failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onAddChildSafetyFeatures(
    AddChildSafetyFeatures event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.updating));

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            hasChildSafety: true,
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage:
              'Child safety features addition failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onAddInstructions(
    AddInstructions event,
    Emitter<PacketCodesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PacketCodesStatus.updating));

      final updatedCodes = state.packetCodes.map((packet) {
        if (packet.id == event.packetCodeId) {
          return packet.copyWith(
            hasInstructions: true,
            updatedAt: DateTime.now(),
          );
        }
        return packet;
      }).toList();

      final updatedState = state.copyWith(
        packetCodes: updatedCodes,
        filteredPacketCodes: updatedCodes,
      );

      emit(updatedState.copyWith(status: PacketCodesStatus.updated));
    } catch (e) {
      emit(
        state.copyWith(
          status: PacketCodesStatus.error,
          errorMessage: 'Instructions addition failed: ${e.toString()}',
        ),
      );
    }
  }
}

extension PacketCodesStateX on PacketCodesState {
  PacketCodesState applyFilters() {
    final filtered = packetCodes.where((packet) {
      // Search filter
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          packet.code.toLowerCase().contains(query) ||
          packet.storeKeeperCode.toLowerCase().contains(query) ||
          (packet.internationalCode ?? '').toLowerCase().contains(query) ||
          (packet.productId?.toLowerCase().contains(query) ?? false) ||
          (packet.productBatchNumber?.toLowerCase().contains(query) ?? false);

      if (!matchesSearch) return false;

      // Status filter
      if (filterStatus != null && packet.status != filterStatus) return false;

      // Carton code filter
      if (filterCartonCode != null &&
          packet.cartonCode != filterCartonCode &&
          filterCartonCode!.isNotEmpty) {
        return false;
      }

      // Date range filter
      if (filterStartDate != null &&
          (packet.generatedAt.isBefore(filterStartDate!) ?? false)) {
        return false;
      }
      if (filterEndDate != null &&
          (packet.generatedAt.isAfter(filterEndDate!) ?? false)) {
        return false;
      }

      // Packet type filter
      if (filterPacketType != null &&
          packet.packetType != filterPacketType &&
          filterPacketType!.isNotEmpty) {
        return false;
      }

      // Condition filter
      if (filterCondition != null &&
          packet.condition != filterCondition &&
          filterCondition!.isNotEmpty) {
        return false;
      }

      return true;
    }).toList();

    return copyWith(filteredPacketCodes: filtered, totalCount: filtered.length);
  }
}
