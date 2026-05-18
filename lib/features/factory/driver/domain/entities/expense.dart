import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/trip.dart';

/// Expense entity for driver trip expenses (4K, 4L, 4M, 4O)
class Expense extends Equatable {
  final String id;
  final String tripId;
  final String driverId;
  final ExpenseType type;
  final double amount;
  final String? receiptUrl;
  final String? receiptPath;
  final String? notes;
  final bool isMandatory;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  final bool requiresAdminNotification;
  final DateTime submittedAt;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.type,
    required this.amount,
    this.receiptUrl,
    this.receiptPath,
    this.notes,
    this.isMandatory = false,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    this.requiresAdminNotification = false,
    required this.submittedAt,
    required this.createdAt,
  });

  Expense copyWith({
    String? id,
    String? tripId,
    String? driverId,
    ExpenseType? type,
    double? amount,
    String? receiptUrl,
    String? receiptPath,
    String? notes,
    bool? isMandatory,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvedAt,
    bool? requiresAdminNotification,
    DateTime? submittedAt,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receiptPath: receiptPath ?? this.receiptPath,
      notes: notes ?? this.notes,
      isMandatory: isMandatory ?? this.isMandatory,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      requiresAdminNotification: requiresAdminNotification ?? this.requiresAdminNotification,
      submittedAt: submittedAt ?? this.submittedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether this expense needs admin action (4N)
  bool get needsAdminApproval => !isMandatory && !isApproved && requiresAdminNotification;

  /// Red alert message for optional unapproved expenses (4N)
  String? get adminNotificationMessage {
    if (needsAdminApproval) {
      return 'You cannot receive this amount until you inform the admin. Amount pending admin approval.';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'driver_id': driverId,
      'type': type.name,
      'amount': amount,
      'receipt_url': receiptUrl,
      'receipt_path': receiptPath,
      'notes': notes,
      'is_mandatory': isMandatory,
      'is_approved': isApproved,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'requires_admin_notification': requiresAdminNotification,
      'submitted_at': submittedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      driverId: json['driver_id'] as String,
      type: ExpenseType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'other'),
        orElse: () => ExpenseType.other,
      ),
      amount: (json['amount'] as num).toDouble(),
      receiptUrl: json['receipt_url'] as String?,
      receiptPath: json['receipt_path'] as String?,
      notes: json['notes'] as String?,
      isMandatory: json['is_mandatory'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? false,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      requiresAdminNotification: json['requires_admin_notification'] as bool? ?? false,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id, tripId, driverId, type, amount, receiptUrl, receiptPath,
        notes, isMandatory, isApproved, approvedBy, approvedAt,
        requiresAdminNotification, submittedAt, createdAt,
      ];
}
