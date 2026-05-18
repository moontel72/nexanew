import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/earning_transaction.dart';

/// Driver earnings summary entity (4AA)
class DriverEarnings extends Equatable {
  final String driverId;
  final double totalEarnings;
  final double currentBalance;
  final double pendingEarnings;
  final double bonusAmount;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final List<EarningTransaction> recentTransactions;

  const DriverEarnings({
    required this.driverId,
    this.totalEarnings = 0.0,
    this.currentBalance = 0.0,
    this.pendingEarnings = 0.0,
    this.bonusAmount = 0.0,
    this.periodStart,
    this.periodEnd,
    this.recentTransactions = const [],
  });

  DriverEarnings copyWith({
    String? driverId,
    double? totalEarnings,
    double? currentBalance,
    double? pendingEarnings,
    double? bonusAmount,
    DateTime? periodStart,
    DateTime? periodEnd,
    List<EarningTransaction>? recentTransactions,
  }) {
    return DriverEarnings(
      driverId: driverId ?? this.driverId,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currentBalance: currentBalance ?? this.currentBalance,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  /// Available balance for withdrawal
  double get availableForWithdrawal => currentBalance;

  /// Total pending (not yet cleared)
  double get totalPending => pendingEarnings;

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'total_earnings': totalEarnings,
      'current_balance': currentBalance,
      'pending_earnings': pendingEarnings,
      'bonus_amount': bonusAmount,
      'period_start': periodStart?.toIso8601String(),
      'period_end': periodEnd?.toIso8601String(),
      'recent_transactions': recentTransactions.map((t) => t.toJson()).toList(),
    };
  }

  factory DriverEarnings.fromJson(Map<String, dynamic> json) {
    return DriverEarnings(
      driverId: json['driver_id'] as String,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
      pendingEarnings: (json['pending_earnings'] as num?)?.toDouble() ?? 0.0,
      bonusAmount: (json['bonus_amount'] as num?)?.toDouble() ?? 0.0,
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : null,
      recentTransactions:
          (json['recent_transactions'] as List<dynamic>?)
              ?.map(
                (e) => EarningTransaction.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    driverId,
    totalEarnings,
    currentBalance,
    pendingEarnings,
    bonusAmount,
    periodStart,
    periodEnd,
    recentTransactions,
  ];
}
