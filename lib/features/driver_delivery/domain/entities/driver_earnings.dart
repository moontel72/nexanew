import 'package:equatable/equatable.dart';

/// Driver earnings entity representing driver's earnings and payments
class DriverEarnings extends Equatable {
  final String id;
  final String driverId;
  final String companyId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalEarnings;
  final String currency;
  final double basePay;
  final double commission;
  final double bonuses;
  final double deductions;
  final double netPay;
  final int totalDeliveries;
  final int successfulDeliveries;
  final int failedDeliveries;
  final double averageRating;
  final PaymentStatus paymentStatus;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? transactionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DriverEarnings({
    required this.id,
    required this.driverId,
    required this.companyId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalEarnings,
    required this.currency,
    required this.basePay,
    required this.commission,
    required this.bonuses,
    required this.deductions,
    required this.netPay,
    required this.totalDeliveries,
    required this.successfulDeliveries,
    required this.failedDeliveries,
    required this.averageRating,
    required this.paymentStatus,
    this.paymentDate,
    this.paymentMethod,
    this.transactionId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this earnings with updated values
  DriverEarnings copyWith({
    String? id,
    String? driverId,
    String? companyId,
    DateTime? periodStart,
    DateTime? periodEnd,
    double? totalEarnings,
    String? currency,
    double? basePay,
    double? commission,
    double? bonuses,
    double? deductions,
    double? netPay,
    int? totalDeliveries,
    int? successfulDeliveries,
    int? failedDeliveries,
    double? averageRating,
    PaymentStatus? paymentStatus,
    DateTime? paymentDate,
    String? paymentMethod,
    String? transactionId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverEarnings(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      companyId: companyId ?? this.companyId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currency: currency ?? this.currency,
      basePay: basePay ?? this.basePay,
      commission: commission ?? this.commission,
      bonuses: bonuses ?? this.bonuses,
      deductions: deductions ?? this.deductions,
      netPay: netPay ?? this.netPay,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      successfulDeliveries: successfulDeliveries ?? this.successfulDeliveries,
      failedDeliveries: failedDeliveries ?? this.failedDeliveries,
      averageRating: averageRating ?? this.averageRating,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if earnings are paid
  bool get isPaid => paymentStatus == PaymentStatus.paid;

  /// Check if earnings are pending
  bool get isPending => paymentStatus == PaymentStatus.pending;

  /// Get success rate percentage
  double get successRate {
    if (totalDeliveries == 0) return 0.0;
    return (successfulDeliveries / totalDeliveries) * 100;
  }

  /// Get earnings per delivery
  double get earningsPerDelivery {
    if (totalDeliveries == 0) return 0.0;
    return totalEarnings / totalDeliveries;
  }

  /// Get period duration in days
  int get periodDurationInDays => periodEnd.difference(periodStart).inDays;

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'company_id': companyId,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'total_earnings': totalEarnings,
      'currency': currency,
      'base_pay': basePay,
      'commission': commission,
      'bonuses': bonuses,
      'deductions': deductions,
      'net_pay': netPay,
      'total_deliveries': totalDeliveries,
      'successful_deliveries': successfulDeliveries,
      'failed_deliveries': failedDeliveries,
      'average_rating': averageRating,
      'payment_status': paymentStatus.name,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory DriverEarnings.fromJson(Map<String, dynamic> json) {
    return DriverEarnings(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      companyId: json['company_id'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      basePay: (json['base_pay'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      bonuses: (json['bonuses'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      netPay: (json['net_pay'] as num).toDouble(),
      totalDeliveries: json['total_deliveries'] as int,
      successfulDeliveries: json['successful_deliveries'] as int,
      failedDeliveries: json['failed_deliveries'] as int,
      averageRating: (json['average_rating'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['payment_status'] as String),
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        driverId,
        companyId,
        periodStart,
        periodEnd,
        totalEarnings,
        currency,
        basePay,
        commission,
        bonuses,
        deductions,
        netPay,
        totalDeliveries,
        successfulDeliveries,
        failedDeliveries,
        averageRating,
        paymentStatus,
        paymentDate,
        paymentMethod,
        transactionId,
        notes,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}

/// Payment status enumeration
enum PaymentStatus {
  pending,
  processing,
  paid,
  failed,
  cancelled,
}
