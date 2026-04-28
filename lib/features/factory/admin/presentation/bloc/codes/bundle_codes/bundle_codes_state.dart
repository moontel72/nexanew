part of 'bundle_codes_bloc.dart';

/// Bundle Codes Status
enum BundleCodesStatus { initial, loading, success, failure }

/// Code Generation Status
enum CodeGenerationStatus { initial, generating, success, failure }

/// Export Status
enum ExportStatus { initial, exporting, success, failure }

@freezed
abstract class BundleCodesState with _$BundleCodesState {
  const factory BundleCodesState({
    @Default(BundleCodesStatus.initial) BundleCodesStatus status,
    @Default(CodeGenerationStatus.initial) CodeGenerationStatus generationStatus,
    @Default(ExportStatus.initial) ExportStatus exportStatus,
    @Default([]) List<BundleCodeModel> codes,
    @Default([]) List<BundleCodeModel> filteredCodes,
    @Default({}) Set<String> selectedCodes,
    String? exportPath,
    String? error,
    @Default('') String searchQuery,
    FilterBundleCodes? currentFilter,
    String? lastGeneratedBatchId,
    int? lastGeneratedCount,
    @Default(false) bool hasReachedMax,
    @Default(1) int page,
    @Default(20) int pageSize,
  }) = _BundleCodesState;

  const BundleCodesState._();

  /// Get selected bundle codes
  List<BundleCodeModel> get selectedBundleCodes {
    return codes.where((code) => selectedCodes.contains(code.id)).toList();
  }

  /// Check if any codes are selected
  bool get hasSelection => selectedCodes.isNotEmpty;

  /// Check if all visible codes are selected
  bool get allVisibleSelected {
    if (filteredCodes.isEmpty) return false;
    return filteredCodes.every((code) => selectedCodes.contains(code.id));
  }

  /// Get codes that can be deleted (status = generated)
  List<BundleCodeModel> get deletableCodes {
    return codes.where((code) => code.status == CodeStatus.generated).toList();
  }

  /// Get statistics
  Map<String, int> get statistics {
    return {
      'total': codes.length,
      'generated': codes.where((c) => c.status == CodeStatus.generated).length,
      'linked': codes.where((c) => c.status == CodeStatus.linked).length,
      'published': codes.where((c) => c.status == CodeStatus.published).length,
      'deactivated': codes.where((c) => c.status == CodeStatus.deactivated).length,
      'expired': codes.where((c) => c.status == CodeStatus.expired).length,
      'selected': selectedCodes.length,
    };
  }

  /// Get paginated codes
  List<BundleCodeModel> get paginatedCodes {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= filteredCodes.length) {
      return [];
    }

    return filteredCodes.sublist(
      startIndex,
      endIndex > filteredCodes.length ? filteredCodes.length : endIndex,
    );
  }

  /// Check if there are more pages
  bool get hasMorePages {
    return page * pageSize < filteredCodes.length;
  }

  /// Get current page info
  String get pageInfo {
    if (filteredCodes.isEmpty) return 'No codes';

    final start = ((page - 1) * pageSize) + 1;
    final end = page * pageSize > filteredCodes.length ? filteredCodes.length : page * pageSize;
    final total = filteredCodes.length;

    return 'Showing $start-$end of $total';
  }

  /// Check if loading
  bool get isLoading => status == BundleCodesStatus.loading;
}
