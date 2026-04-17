part of 'unit_codes_bloc.dart';

/// Unit Codes Status
enum UnitCodesStatus {
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
  verifying,
  verified,
  reportingFake,
  fakeReported,
  blocking,
  blocked,
  unblocking,
  unblocked,
  updating,
  updated,
  exporting,
  exported,
  error,
}

/// Unit Codes State
class UnitCodesState extends Equatable {
  final UnitCodesStatus status;
  final List<UnitCodeModel> unitCodes;
  final List<UnitCodeModel> filteredUnitCodes;
  final Set<String> selectedUnitCodeIds;
  final String searchQuery;
  final CodeStatus? filterStatus;
  final String? filterPacketCode;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final bool? filterIsMasterCode;
  final bool? filterIsReportedFake;
  final bool? filterIsBlocked;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final bool isLoadingMore;
  final int generatedCount;
  final DateTime? lastGeneratedAt;
  final String? exportPath;
  final bool isExporting;
  final Map<String, List<Map<String, dynamic>>> verificationHistory;

  const UnitCodesState({
    this.status = UnitCodesStatus.initial,
    this.unitCodes = const [],
    this.filteredUnitCodes = const [],
    this.selectedUnitCodeIds = const {},
    this.searchQuery = '',
    this.filterStatus,
    this.filterPacketCode,
    this.filterStartDate,
    this.filterEndDate,
    this.filterIsMasterCode,
    this.filterIsReportedFake,
    this.filterIsBlocked,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.isLoadingMore = false,
    this.generatedCount = 0,
    this.lastGeneratedAt,
    this.exportPath,
    this.isExporting = false,
    this.verificationHistory = const {},
  });

  /// Copy with method for immutable updates
  UnitCodesState copyWith({
    UnitCodesStatus? status,
    List<UnitCodeModel>? unitCodes,
    List<UnitCodeModel>? filteredUnitCodes,
    Set<String>? selectedUnitCodeIds,
    String? searchQuery,
    CodeStatus? filterStatus,
    String? filterPacketCode,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool? filterIsMasterCode,
    bool? filterIsReportedFake,
    bool? filterIsBlocked,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
    bool? isLoadingMore,
    int? generatedCount,
    DateTime? lastGeneratedAt,
    String? exportPath,
    bool? isExporting,
    Map<String, List<Map<String, dynamic>>>? verificationHistory,
  }) {
    return UnitCodesState(
      status: status ?? this.status,
      unitCodes: unitCodes ?? this.unitCodes,
      filteredUnitCodes: filteredUnitCodes ?? this.filteredUnitCodes,
      selectedUnitCodeIds: selectedUnitCodeIds ?? this.selectedUnitCodeIds,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      filterPacketCode: filterPacketCode ?? this.filterPacketCode,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      filterIsMasterCode: filterIsMasterCode ?? this.filterIsMasterCode,
      filterIsReportedFake: filterIsReportedFake ?? this.filterIsReportedFake,
      filterIsBlocked: filterIsBlocked ?? this.filterIsBlocked,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      generatedCount: generatedCount ?? this.generatedCount,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      exportPath: exportPath ?? this.exportPath,
      isExporting: isExporting ?? this.isExporting,
      verificationHistory: verificationHistory ?? this.verificationHistory,
    );
  }

  /// Get selected unit codes
  List<UnitCodeModel> get selectedUnitCodes {
    return unitCodes
        .where((unit) => selectedUnitCodeIds.contains(unit.id))
        .toList();
  }

  /// Get unit statistics
  Map<String, dynamic> get statistics {
    final totalUnits = unitCodes.length;
    final verifiedUnits = unitCodes
        .where((u) => u.verificationCount > 0)
        .length;
    final fakeReportedUnits = unitCodes.where((u) => u.isReportedFake).length;
    final blockedUnits = unitCodes.where((u) => u.isBlocked).length;
    final masterUnits = unitCodes.where((u) => u.isMasterCode).length;
    final publishedUnits = unitCodes
        .where((u) => u.status == CodeStatus.published)
        .length;
    final totalVerifications = unitCodes.fold(
      0,
      (sum, u) => sum + u.verificationCount,
    );

    return {
      'totalUnits': totalUnits,
      'verifiedUnits': verifiedUnits,
      'fakeReportedUnits': fakeReportedUnits,
      'blockedUnits': blockedUnits,
      'masterUnits': masterUnits,
      'publishedUnits': publishedUnits,
      'totalVerifications': totalVerifications,
      'verificationRate': totalUnits > 0
          ? (verifiedUnits / totalUnits * 100).round()
          : 0,
      'fakeReportRate': totalUnits > 0
          ? (fakeReportedUnits / totalUnits * 100).round()
          : 0,
      'blockRate': totalUnits > 0
          ? (blockedUnits / totalUnits * 100).round()
          : 0,
    };
  }

  /// Get unit codes by packet
  Map<String, List<UnitCodeModel>> get unitCodesByPacket {
    final Map<String, List<UnitCodeModel>> result = {};

    for (final unit in unitCodes) {
      final packetCode = unit.packetCode;
      if (!result.containsKey(packetCode)) {
        result[packetCode] = [];
      }
      result[packetCode]!.add(unit);
    }

    return result;
  }

  /// Get unit codes by status
  Map<CodeStatus, List<UnitCodeModel>> get unitCodesByStatus {
    final Map<CodeStatus, List<UnitCodeModel>> result = {};

    for (final unit in unitCodes) {
      final status = unit.status;
      if (!result.containsKey(status)) {
        result[status] = [];
      }
      result[status]!.add(unit);
    }

    return result;
  }

  /// Get unit codes by verification status
  Map<String, List<UnitCodeModel>> get unitCodesByVerificationStatus {
    final Map<String, List<UnitCodeModel>> result = {
      'Never Verified': [],
      'Verified Once': [],
      'Verified Multiple': [],
      'Fake Reported': [],
      'Blocked': [],
    };

    for (final unit in unitCodes) {
      if (unit.isBlocked) {
        result['Blocked']!.add(unit);
      } else if (unit.isReportedFake) {
        result['Fake Reported']!.add(unit);
      } else if (unit.verificationCount == 0) {
        result['Never Verified']!.add(unit);
      } else if (unit.verificationCount == 1) {
        result['Verified Once']!.add(unit);
      } else {
        result['Verified Multiple']!.add(unit);
      }
    }

    return result;
  }

  /// Check if any unit is selected
  bool get hasSelection => selectedUnitCodeIds.isNotEmpty;

  /// Check if all units are selected
  bool get allSelected {
    if (filteredUnitCodes.isEmpty) return false;
    return selectedUnitCodeIds.length == filteredUnitCodes.length;
  }

  /// Toggle select all
  UnitCodesState toggleSelectAll() {
    if (allSelected) {
      return copyWith(selectedUnitCodeIds: const {});
    } else {
      return copyWith(
        selectedUnitCodeIds: Set<String>.from(
          filteredUnitCodes.map((unit) => unit.id),
        ),
      );
    }
  }

  /// Apply filters and search
  UnitCodesState applyFilters() {
    List<UnitCodeModel> filtered = unitCodes;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((unit) {
        return unit.code.toLowerCase().contains(query) ||
            unit.packetCode.toLowerCase().contains(query) ||
            unit.authenticationCode.toLowerCase().contains(query) ||
            unit.serialNumber.toLowerCase().contains(query) ||
            (unit.model?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply status filter
    if (filterStatus != null) {
      filtered = filtered.where((unit) => unit.status == filterStatus).toList();
    }

    // Apply packet code filter
    if (filterPacketCode != null && filterPacketCode!.isNotEmpty) {
      filtered = filtered
          .where((unit) => unit.packetCode == filterPacketCode)
          .toList();
    }

    // Apply master code filter
    if (filterIsMasterCode != null) {
      filtered = filtered
          .where((unit) => unit.isMasterCode == filterIsMasterCode)
          .toList();
    }

    // Apply fake reported filter
    if (filterIsReportedFake != null) {
      filtered = filtered
          .where((unit) => unit.isReportedFake == filterIsReportedFake)
          .toList();
    }

    // Apply blocked filter
    if (filterIsBlocked != null) {
      filtered = filtered
          .where((unit) => unit.isBlocked == filterIsBlocked)
          .toList();
    }

    // Apply date range filter
    if (filterStartDate != null) {
      filtered = filtered.where((unit) {
        final generatedAt = unit.generatedAt;
        return generatedAt.isAfter(filterStartDate!) ||
            generatedAt.isAtSameMomentAs(filterStartDate!);
      }).toList();
    }

    if (filterEndDate != null) {
      filtered = filtered.where((unit) {
        final generatedAt = unit.generatedAt;
        return generatedAt.isBefore(filterEndDate!) ||
            generatedAt.isAtSameMomentAs(filterEndDate!);
      }).toList();
    }

    return copyWith(filteredUnitCodes: filtered);
  }

  /// Clear filters
  UnitCodesState clearFilters() {
    return copyWith(
      searchQuery: '',
      filterStatus: null,
      filterPacketCode: null,
      filterStartDate: null,
      filterEndDate: null,
      filterIsMasterCode: null,
      filterIsReportedFake: null,
      filterIsBlocked: null,
    ).applyFilters();
  }

  /// Get verification history for a unit code
  List<Map<String, dynamic>> getVerificationHistory(String unitCodeId) {
    return verificationHistory[unitCodeId] ?? [];
  }

  /// Add verification record
  UnitCodesState addVerificationRecord(
    String unitCodeId,
    Map<String, dynamic> record,
  ) {
    final currentHistory = List<Map<String, dynamic>>.from(
      verificationHistory[unitCodeId] ?? [],
    );
    currentHistory.add(record);

    final updatedHistory = Map<String, List<Map<String, dynamic>>>.from(
      verificationHistory,
    );
    updatedHistory[unitCodeId] = currentHistory;

    return copyWith(verificationHistory: updatedHistory);
  }

  @override
  List<Object?> get props => [
    status,
    unitCodes,
    filteredUnitCodes,
    selectedUnitCodeIds,
    searchQuery,
    filterStatus,
    filterPacketCode,
    filterStartDate,
    filterEndDate,
    filterIsMasterCode,
    filterIsReportedFake,
    filterIsBlocked,
    errorMessage,
    hasReachedMax,
    currentPage,
    totalCount,
    isLoadingMore,
    generatedCount,
    lastGeneratedAt,
    exportPath,
    isExporting,
    verificationHistory,
  ];

  @override
  String toString() {
    return '''UnitCodesState(
      status: $status,
      unitCodes: ${unitCodes.length} items,
      filteredUnitCodes: ${filteredUnitCodes.length} items,
      selectedUnitCodeIds: ${selectedUnitCodeIds.length} items,
      searchQuery: $searchQuery,
      filterStatus: $filterStatus,
      filterPacketCode: $filterPacketCode,
      filterStartDate: $filterStartDate,
      filterEndDate: $filterEndDate,
      filterIsMasterCode: $filterIsMasterCode,
      filterIsReportedFake: $filterIsReportedFake,
      filterIsBlocked: $filterIsBlocked,
      errorMessage: $errorMessage,
      hasReachedMax: $hasReachedMax,
      currentPage: $currentPage,
      totalCount: $totalCount,
      isLoadingMore: $isLoadingMore,
      generatedCount: $generatedCount,
      lastGeneratedAt: $lastGeneratedAt,
      exportPath: $exportPath,
      isExporting: $isExporting,
      verificationHistory: ${verificationHistory.length} records,
    )''';
  }
}
