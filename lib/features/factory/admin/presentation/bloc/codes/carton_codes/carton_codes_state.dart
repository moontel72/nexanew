part of 'carton_codes_bloc.dart';

/// Carton Codes Status
enum CartonCodesStatus {
  initial,
  loading,
  loaded,
  generating,
  generated,
  deleting,
  deleted,
  linking,
  linked,
  publishing,
  published,
  deactivating,
  deactivated,
  sealing,
  sealed,
  inspecting,
  inspected,
  updating,
  updated,
  exporting,
  exported,
  error,
}

@freezed
abstract class CartonCodesState with _$CartonCodesState {
  const factory CartonCodesState({
    @Default(CartonCodesStatus.initial) CartonCodesStatus status,
    @Default([]) List<CartonCodeModel> cartonCodes,
    @Default([]) List<CartonCodeModel> filteredCartonCodes,
    @Default({}) Set<String> selectedCartonCodeIds,
    @Default('') String searchQuery,
    CodeStatus? filterStatus,
    String? filterBundleCode,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? filterCartonType,
    String? filterCondition,
    String? errorMessage,
    @Default(false) bool hasReachedMax,
    @Default(1) int currentPage,
    @Default(0) int totalCount,
    @Default(false) bool isLoadingMore,
    @Default(0) int generatedCount,
    DateTime? lastGeneratedAt,
    String? exportPath,
    @Default(false) bool isExporting,
  }) = _CartonCodesState;

  const CartonCodesState._();

  /// Get selected carton codes
  List<CartonCodeModel> get selectedCartonCodes {
    return cartonCodes
        .where((carton) => selectedCartonCodeIds.contains(carton.id))
        .toList();
  }

  /// Get total selected units
  int get totalSelectedUnits {
    return selectedCartonCodes.fold(
      0,
      (sum, carton) => sum + carton.totalUnits,
    );
  }

  /// Get total selected packets
  int get totalSelectedPackets {
    return selectedCartonCodes.fold(
      0,
      (sum, carton) => sum + carton.packetCount,
    );
  }

  /// Get carton statistics
  Map<String, dynamic> get statistics {
    final totalCartons = cartonCodes.length;
    final sealedCartons = cartonCodes.where((c) => c.isCartonSealed).length;
    final needInspection = cartonCodes.where((c) => c.needsInspection).length;
    final overweightCartons = cartonCodes.where((c) => c.isOverweight).length;
    final totalPackets = cartonCodes.fold(0, (sum, c) => sum + c.packetCount);
    final totalUnits = cartonCodes.fold(0, (sum, c) => sum + c.totalUnits);

    return {
      'totalCartons': totalCartons,
      'sealedCartons': sealedCartons,
      'needInspection': needInspection,
      'overweightCartons': overweightCartons,
      'totalPackets': totalPackets,
      'totalUnits': totalUnits,
      'sealedPercentage': totalCartons > 0
          ? (sealedCartons / totalCartons * 100).round()
          : 0,
      'inspectionPercentage': totalCartons > 0
          ? (needInspection / totalCartons * 100).round()
          : 0,
    };
  }

  /// Check if any carton is selected
  bool get hasSelection => selectedCartonCodeIds.isNotEmpty;

  /// Check if all cartons are selected
  bool get allSelected {
    if (filteredCartonCodes.isEmpty) return false;
    return selectedCartonCodeIds.length == filteredCartonCodes.length;
  }
}
