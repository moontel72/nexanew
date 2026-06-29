/// Dashboard overview data for the storekeeper.
class StorekeeperDashboardData {
  final int totalItems;
  final int activeItems;
  final int lowStockItems;
  final int pendingIssuances;
  final int activeIssuances;
  final int draftReconciliations;
  final int outstandingValuePaisa;

  const StorekeeperDashboardData({
    this.totalItems = 0,
    this.activeItems = 0,
    this.lowStockItems = 0,
    this.pendingIssuances = 0,
    this.activeIssuances = 0,
    this.draftReconciliations = 0,
    this.outstandingValuePaisa = 0,
  });

  double get outstandingValueMain => outstandingValuePaisa / 100.0;

  factory StorekeeperDashboardData.fromJson(Map<String, dynamic> json) {
    return StorekeeperDashboardData(
      totalItems: _i(json['total_items']),
      activeItems: _i(json['active_items']),
      lowStockItems: _i(json['low_stock_items']),
      pendingIssuances: _i(json['pending_issuances']),
      activeIssuances: _i(json['active_issuances']),
      draftReconciliations: _i(json['draft_reconciliations']),
      outstandingValuePaisa: _i(json['outstanding_value_paisa']),
    );
  }

  static int _i(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }
}
