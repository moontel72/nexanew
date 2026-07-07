// Storekeeper Dashboard State — handles all 4 sub-screens
import 'package:equatable/equatable.dart';

enum StorekeeperStatus { initial, loading, loaded, error }

class StorekeeperDashboardState extends Equatable {
  final StorekeeperStatus status;
  final int totalItems, lowStockItems, pendingIssuances, activeIssuances;
  final int draftReconciliations;
  final double outstandingValue;
  final String? error;

  // Catering
  final List<dynamic> categories, items;
  final String? selectedCategoryId;
  final int itemPage;
  final String itemSearch;

  // Issuance / Reconciliation / Bundle — delegates to sub-screens
  final bool isMutating;
  final List<dynamic> issuances, reconciliations, bundles;
  final bool issuancesLoading, reconciliationsLoading, bundlesLoading;

  const StorekeeperDashboardState({
    this.status = StorekeeperStatus.initial,
    this.totalItems = 0,
    this.lowStockItems = 0,
    this.pendingIssuances = 0,
    this.activeIssuances = 0,
    this.draftReconciliations = 0,
    this.outstandingValue = 0,
    this.error,
    this.categories = const [],
    this.items = const [],
    this.selectedCategoryId,
    this.itemPage = 1,
    this.itemSearch = '',
    this.isMutating = false,
    this.issuances = const [],
    this.reconciliations = const [],
    this.bundles = const [],
    this.issuancesLoading = false,
    this.reconciliationsLoading = false,
    this.bundlesLoading = false,
  });

  StorekeeperDashboardState copyWith({
    StorekeeperStatus? status,
    int? totalItems,
    int? lowStockItems,
    int? pendingIssuances,
    int? activeIssuances,
    int? draftReconciliations,
    double? outstandingValue,
    String? error,
    List<dynamic>? categories,
    List<dynamic>? items,
    String? selectedCategoryId,
    int? itemPage,
    String? itemSearch,
    bool? isMutating,
    List<dynamic>? issuances,
    List<dynamic>? reconciliations,
    List<dynamic>? bundles,
    bool? issuancesLoading,
    bool? reconciliationsLoading,
    bool? bundlesLoading,
  }) => StorekeeperDashboardState(
    status: status ?? this.status,
    totalItems: totalItems ?? this.totalItems,
    lowStockItems: lowStockItems ?? this.lowStockItems,
    pendingIssuances: pendingIssuances ?? this.pendingIssuances,
    activeIssuances: activeIssuances ?? this.activeIssuances,
    draftReconciliations: draftReconciliations ?? this.draftReconciliations,
    outstandingValue: outstandingValue ?? this.outstandingValue,
    error: error,
    categories: categories ?? this.categories,
    items: items ?? this.items,
    selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    itemPage: itemPage ?? this.itemPage,
    itemSearch: itemSearch ?? this.itemSearch,
    isMutating: isMutating ?? this.isMutating,
    issuances: issuances ?? this.issuances,
    reconciliations: reconciliations ?? this.reconciliations,
    bundles: bundles ?? this.bundles,
    issuancesLoading: issuancesLoading ?? this.issuancesLoading,
    reconciliationsLoading:
        reconciliationsLoading ?? this.reconciliationsLoading,
    bundlesLoading: bundlesLoading ?? this.bundlesLoading,
  );

  @override
  List<Object?> get props => [
    status,
    totalItems,
    lowStockItems,
    pendingIssuances,
    activeIssuances,
    draftReconciliations,
    outstandingValue,
    error,
    categories,
    items,
    selectedCategoryId,
    itemPage,
    itemSearch,
    isMutating,
    issuances,
    reconciliations,
    bundles,
    issuancesLoading,
    reconciliationsLoading,
    bundlesLoading,
  ];
}
