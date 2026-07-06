// Storekeeper Dashboard State
import 'package:equatable/equatable.dart';

enum StorekeeperStatus { initial, loading, loaded, error }

class StorekeeperDashboardState extends Equatable {
  final StorekeeperStatus status;
  final int totalItems, lowStockItems, pendingIssuances, activeIssuances;
  final int draftReconciliations;
  final double outstandingValue;
  final String? error;

  const StorekeeperDashboardState({
    this.status = StorekeeperStatus.initial,
    this.totalItems = 0,
    this.lowStockItems = 0,
    this.pendingIssuances = 0,
    this.activeIssuances = 0,
    this.draftReconciliations = 0,
    this.outstandingValue = 0,
    this.error,
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
  }) => StorekeeperDashboardState(
    status: status ?? this.status,
    totalItems: totalItems ?? this.totalItems,
    lowStockItems: lowStockItems ?? this.lowStockItems,
    pendingIssuances: pendingIssuances ?? this.pendingIssuances,
    activeIssuances: activeIssuances ?? this.activeIssuances,
    draftReconciliations: draftReconciliations ?? this.draftReconciliations,
    outstandingValue: outstandingValue ?? this.outstandingValue,
    error: error,
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
  ];
}
