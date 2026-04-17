import 'package:equatable/equatable.dart';

/// Driver Statistics entity representing driver's delivery statistics
class DriverStatistics extends Equatable {
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final double rating;
  final int successfulDeliveries;
  final int failedDeliveries;
  final int cancelledDeliveries;
  final int returnedDeliveries;
  final double totalEarnings;
  final double averageEarningsPerDelivery;
  final double totalDistanceKm;
  final double averageDeliveryTimeMinutes;
  final int onTimeDeliveries;
  final int lateDeliveries;
  final int customerRatingsCount;
  final double averageCustomerRating;
  final DateTime? lastDeliveryDate;
  final int currentStreakDays;
  final int bestStreakDays;
  final DateTime periodStart;
  final DateTime periodEnd;

  const DriverStatistics({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.pendingDeliveries,
    required this.rating,
    this.successfulDeliveries = 0,
    this.failedDeliveries = 0,
    this.cancelledDeliveries = 0,
    this.returnedDeliveries = 0,
    this.totalEarnings = 0.0,
    this.averageEarningsPerDelivery = 0.0,
    this.totalDistanceKm = 0.0,
    this.averageDeliveryTimeMinutes = 0.0,
    this.onTimeDeliveries = 0,
    this.lateDeliveries = 0,
    this.customerRatingsCount = 0,
    this.averageCustomerRating = 0.0,
    this.lastDeliveryDate,
    this.currentStreakDays = 0,
    this.bestStreakDays = 0,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  List<Object?> get props => [
        totalDeliveries,
        completedDeliveries,
        pendingDeliveries,
        rating,
        successfulDeliveries,
        failedDeliveries,
        cancelledDeliveries,
        returnedDeliveries,
        totalEarnings,
        averageEarningsPerDelivery,
        totalDistanceKm,
        averageDeliveryTimeMinutes,
        onTimeDeliveries,
        lateDeliveries,
        customerRatingsCount,
        averageCustomerRating,
        lastDeliveryDate,
        currentStreakDays,
        bestStreakDays,
        periodStart,
        periodEnd,
      ];

  /// Creates a copy of this DriverStatistics with the given fields replaced
  DriverStatistics copyWith({
    int? totalDeliveries,
    int? completedDeliveries,
    int? pendingDeliveries,
    double? rating,
    int? successfulDeliveries,
    int? failedDeliveries,
    int? cancelledDeliveries,
    int? returnedDeliveries,
    double? totalEarnings,
    double? averageEarningsPerDelivery,
    double? totalDistanceKm,
    double? averageDeliveryTimeMinutes,
    int? onTimeDeliveries,
    int? lateDeliveries,
    int? customerRatingsCount,
    double? averageCustomerRating,
    DateTime? lastDeliveryDate,
    int? currentStreakDays,
    int? bestStreakDays,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return DriverStatistics(
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      pendingDeliveries: pendingDeliveries ?? this.pendingDeliveries,
      rating: rating ?? this.rating,
      successfulDeliveries: successfulDeliveries ?? this.successfulDeliveries,
      failedDeliveries: failedDeliveries ?? this.failedDeliveries,
      cancelledDeliveries: cancelledDeliveries ?? this.cancelledDeliveries,
      returnedDeliveries: returnedDeliveries ?? this.returnedDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      averageEarningsPerDelivery:
          averageEarningsPerDelivery ?? this.averageEarningsPerDelivery,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      averageDeliveryTimeMinutes:
          averageDeliveryTimeMinutes ?? this.averageDeliveryTimeMinutes,
      onTimeDeliveries: onTimeDeliveries ?? this.onTimeDeliveries,
      lateDeliveries: lateDeliveries ?? this.lateDeliveries,
      customerRatingsCount: customerRatingsCount ?? this.customerRatingsCount,
      averageCustomerRating:
          averageCustomerRating ?? this.averageCustomerRating,
      lastDeliveryDate: lastDeliveryDate ?? this.lastDeliveryDate,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  /// Creates a DriverStatistics from JSON data
  factory DriverStatistics.fromJson(Map<String, dynamic> json) {
    return DriverStatistics(
      totalDeliveries: json['totalDeliveries'] as int,
      completedDeliveries: json['completedDeliveries'] as int,
      pendingDeliveries: json['pendingDeliveries'] as int,
      rating: (json['rating'] as num).toDouble(),
      successfulDeliveries: json['successfulDeliveries'] as int? ?? 0,
      failedDeliveries: json['failedDeliveries'] as int? ?? 0,
      cancelledDeliveries: json['cancelledDeliveries'] as int? ?? 0,
      returnedDeliveries: json['returnedDeliveries'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      averageEarningsPerDelivery:
          (json['averageEarningsPerDelivery'] as num?)?.toDouble() ?? 0.0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      averageDeliveryTimeMinutes:
          (json['averageDeliveryTimeMinutes'] as num?)?.toDouble() ?? 0.0,
      onTimeDeliveries: json['onTimeDeliveries'] as int? ?? 0,
      lateDeliveries: json['lateDeliveries'] as int? ?? 0,
      customerRatingsCount: json['customerRatingsCount'] as int? ?? 0,
      averageCustomerRating:
          (json['averageCustomerRating'] as num?)?.toDouble() ?? 0.0,
      lastDeliveryDate: json['lastDeliveryDate'] != null
          ? DateTime.parse(json['lastDeliveryDate'] as String)
          : null,
      currentStreakDays: json['currentStreakDays'] as int? ?? 0,
      bestStreakDays: json['bestStreakDays'] as int? ?? 0,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  /// Converts this DriverStatistics to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalDeliveries': totalDeliveries,
      'completedDeliveries': completedDeliveries,
      'pendingDeliveries': pendingDeliveries,
      'rating': rating,
      'successfulDeliveries': successfulDeliveries,
      'failedDeliveries': failedDeliveries,
      'cancelledDeliveries': cancelledDeliveries,
      'returnedDeliveries': returnedDeliveries,
      'totalEarnings': totalEarnings,
      'averageEarningsPerDelivery': averageEarningsPerDelivery,
      'totalDistanceKm': totalDistanceKm,
      'averageDeliveryTimeMinutes': averageDeliveryTimeMinutes,
      'onTimeDeliveries': onTimeDeliveries,
      'lateDeliveries': lateDeliveries,
      'customerRatingsCount': customerRatingsCount,
      'averageCustomerRating': averageCustomerRating,
      'lastDeliveryDate': lastDeliveryDate?.toIso8601String(),
      'currentStreakDays': currentStreakDays,
      'bestStreakDays': bestStreakDays,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  /// Returns a string representation of this DriverStatistics
  @override
  String toString() {
    return 'DriverStatistics(totalDeliveries: $totalDeliveries, completedDeliveries: $completedDeliveries, rating: $rating)';
  }

  /// Calculates the success rate percentage
  double get successRate {
    if (totalDeliveries == 0) return 0.0;
    return (successfulDeliveries / totalDeliveries) * 100;
  }

  /// Calculates the failure rate percentage
  double get failureRate {
    if (totalDeliveries == 0) return 0.0;
    return (failedDeliveries / totalDeliveries) * 100;
  }

  /// Calculates the on-time delivery rate percentage
  double get onTimeRate {
    final totalCompleted = successfulDeliveries + failedDeliveries;
    if (totalCompleted == 0) return 0.0;
    return (onTimeDeliveries / totalCompleted) * 100;
  }

  /// Calculates the average delivery time in hours
  double get averageDeliveryTimeHours {
    return averageDeliveryTimeMinutes / 60;
  }

  /// Calculates the average earnings per kilometer
  double get averageEarningsPerKm {
    if (totalDistanceKm == 0) return 0.0;
    return totalEarnings / totalDistanceKm;
  }

  /// Gets the active deliveries count
  int get activeDeliveries => pendingDeliveries;

  /// Gets the completed deliveries percentage
  double get completionRate {
    if (totalDeliveries == 0) return 0.0;
    return (completedDeliveries / totalDeliveries) * 100;
  }

  /// Checks if the driver has any deliveries
  bool get hasDeliveries => totalDeliveries > 0;

  /// Gets the period duration in days
  int get periodDurationInDays => periodEnd.difference(periodStart).inDays;

  /// Gets the average deliveries per day
  double get averageDeliveriesPerDay {
    final days = periodDurationInDays;
    if (days == 0) return 0.0;
    return totalDeliveries / days;
  }

  /// Gets the average earnings per day
  double get averageEarningsPerDay {
    final days = periodDurationInDays;
    if (days == 0) return 0.0;
    return totalEarnings / days;
  }
}
