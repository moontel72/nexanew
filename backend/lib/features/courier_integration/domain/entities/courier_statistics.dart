import 'package:equatable/equatable.dart';

/// Courier Statistics entity representing courier service statistics
class CourierStatistics extends Equatable {
  final int totalShipments;
  final int deliveredCount;
  final int pendingCount;
  final double successRate;

  const CourierStatistics({
    required this.totalShipments,
    required this.deliveredCount,
    required this.pendingCount,
    required this.successRate,
  });

  @override
  List<Object?> get props =>
      [totalShipments, deliveredCount, pendingCount, successRate];

  /// Creates a copy of this CourierStatistics with the given fields replaced
  CourierStatistics copyWith({
    int? totalShipments,
    int? deliveredCount,
    int? pendingCount,
    double? successRate,
  }) {
    return CourierStatistics(
      totalShipments: totalShipments ?? this.totalShipments,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      pendingCount: pendingCount ?? this.pendingCount,
      successRate: successRate ?? this.successRate,
    );
  }

  /// Creates a CourierStatistics from JSON data
  factory CourierStatistics.fromJson(Map<String, dynamic> json) {
    return CourierStatistics(
      totalShipments: json['totalShipments'] as int,
      deliveredCount: json['deliveredCount'] as int,
      pendingCount: json['pendingCount'] as int,
      successRate: (json['successRate'] as num).toDouble(),
    );
  }

  /// Converts this CourierStatistics to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalShipments': totalShipments,
      'deliveredCount': deliveredCount,
      'pendingCount': pendingCount,
      'successRate': successRate,
    };
  }

  /// Returns a string representation of this CourierStatistics
  @override
  String toString() {
    return 'CourierStatistics(totalShipments: $totalShipments, deliveredCount: $deliveredCount, pendingCount: $pendingCount, successRate: $successRate)';
  }

  /// Calculates the failure count
  int get failureCount => totalShipments - deliveredCount - pendingCount;

  /// Calculates the delivery rate percentage
  double get deliveryRate =>
      totalShipments > 0 ? (deliveredCount / totalShipments) * 100 : 0.0;

  /// Calculates the pending rate percentage
  double get pendingRate =>
      totalShipments > 0 ? (pendingCount / totalShipments) * 100 : 0.0;
}
