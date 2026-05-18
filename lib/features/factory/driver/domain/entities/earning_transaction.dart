import 'package:equatable/equatable.dart';

/// Earning transaction type
enum EarningTransactionType {
  credit,
  debit;

  String get displayName {
    return switch (this) {
      EarningTransactionType.credit => 'Credit',
      EarningTransactionType.debit => 'Debit',
    };
  }
}

/// Individual earning/payment transaction entity
class EarningTransaction extends Equatable {
  final String id;
  final String driverId;
  final String? tripId;
  final double amount;
  final EarningTransactionType type;
  final String description;
  final String? reference;
  final String status;
  final DateTime createdAt;

  const EarningTransaction({
    required this.id,
    required this.driverId,
    this.tripId,
    required this.amount,
    required this.type,
    required this.description,
    this.reference,
    required this.status,
    required this.createdAt,
  });

  EarningTransaction copyWith({
    String? id,
    String? driverId,
    String? tripId,
    double? amount,
    EarningTransactionType? type,
    String? description,
    String? reference,
    String? status,
    DateTime? createdAt,
  }) {
    return EarningTransaction(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      tripId: tripId ?? this.tripId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'trip_id': tripId,
      'amount': amount,
      'type': type.name,
      'description': description,
      'reference': reference,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      tripId: json['trip_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: EarningTransactionType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'credit'),
        orElse: () => EarningTransactionType.credit,
      ),
      description: json['description'] as String? ?? '',
      reference: json['reference'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    driverId,
    tripId,
    amount,
    type,
    description,
    reference,
    status,
    createdAt,
  ];
}
