// Factory Production Models — Lightweight data entities for dashboard metrics.
// Under 85 lines. Maps raw backend aggregates into clean Dart objects.

/// A production batch with lifecycle state.
class ProductionBatch {
  final String id;
  final String name;
  final BatchStatus status;
  final int totalUnits;
  final int completedUnits;
  final DateTime createdAt;

  const ProductionBatch({
    required this.id,
    required this.name,
    required this.status,
    required this.totalUnits,
    required this.completedUnits,
    required this.createdAt,
  });

  double get progressPercent =>
      totalUnits > 0 ? (completedUnits / totalUnits * 100).clamp(0, 100) : 0;

  factory ProductionBatch.fromJson(Map<String, dynamic> json) =>
      ProductionBatch(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        status: _parseBatchStatus(json['status']?.toString()),
        totalUnits: (json['total_units'] as num?)?.toInt() ?? 0,
        completedUnits: (json['completed_units'] as num?)?.toInt() ?? 0,
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
}

enum BatchStatus { processing, dispatched, mismatched, sealed }

BatchStatus _parseBatchStatus(String? s) => switch (s?.toLowerCase()) {
  'dispatched' => BatchStatus.dispatched,
  'mismatched' => BatchStatus.mismatched,
  'sealed' => BatchStatus.sealed,
  _ => BatchStatus.processing,
};

/// Active shipping lane connecting factory to a destination.
class ShippingLane {
  final String destination;
  final String driverName;
  final int itemCount;
  final DateTime eta;
  final double progressPercent;

  const ShippingLane({
    required this.destination,
    required this.driverName,
    required this.itemCount,
    required this.eta,
    required this.progressPercent,
  });

  factory ShippingLane.fromJson(Map<String, dynamic> json) => ShippingLane(
    destination: json['destination']?.toString() ?? '',
    driverName: json['driver_name']?.toString() ?? '—',
    itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
    eta: DateTime.tryParse(json['eta']?.toString() ?? '') ?? DateTime.now(),
    progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
  );
}
