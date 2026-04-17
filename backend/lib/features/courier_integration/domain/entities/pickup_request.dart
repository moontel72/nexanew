import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Pickup Request status enumeration
enum PickupRequestStatus {
  pending,
  scheduled,
  inProgress,
  completed,
  cancelled,
  failed,
}

/// Pickup Request entity representing a courier pickup request
class PickupRequest extends Equatable {
  final String id;
  final String courierServiceId;
  final DateTime pickupDate;
  final TimeOfDay pickupTime;
  final PickupRequestStatus status;
  final String address;
  final String? contactName;
  final String? contactPhone;
  final String? instructions;
  final int? numberOfPackages;
  final double? totalWeight;
  final String? confirmationNumber;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PickupRequest({
    required this.id,
    required this.courierServiceId,
    required this.pickupDate,
    required this.pickupTime,
    required this.status,
    required this.address,
    this.contactName,
    this.contactPhone,
    this.instructions,
    this.numberOfPackages,
    this.totalWeight,
    this.confirmationNumber,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.scheduledAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        courierServiceId,
        pickupDate,
        pickupTime,
        status,
        address,
        contactName,
        contactPhone,
        instructions,
        numberOfPackages,
        totalWeight,
        confirmationNumber,
        driverName,
        driverPhone,
        vehicleNumber,
        scheduledAt,
        completedAt,
        cancelledAt,
        cancellationReason,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this PickupRequest with the given fields replaced
  PickupRequest copyWith({
    String? id,
    String? courierServiceId,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    PickupRequestStatus? status,
    String? address,
    String? contactName,
    String? contactPhone,
    String? instructions,
    int? numberOfPackages,
    double? totalWeight,
    String? confirmationNumber,
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    DateTime? scheduledAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PickupRequest(
      id: id ?? this.id,
      courierServiceId: courierServiceId ?? this.courierServiceId,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      address: address ?? this.address,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      instructions: instructions ?? this.instructions,
      numberOfPackages: numberOfPackages ?? this.numberOfPackages,
      totalWeight: totalWeight ?? this.totalWeight,
      confirmationNumber: confirmationNumber ?? this.confirmationNumber,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a PickupRequest from JSON data
  factory PickupRequest.fromJson(Map<String, dynamic> json) {
    return PickupRequest(
      id: json['id'] as String,
      courierServiceId: json['courierServiceId'] as String,
      pickupDate: DateTime.parse(json['pickupDate'] as String),
      pickupTime: _parseTimeOfDayFromString(json['pickupTime'] as String),
      status: PickupRequestStatus.values[json['status'] as int],
      address: json['address'] as String,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      instructions: json['instructions'] as String?,
      numberOfPackages: json['numberOfPackages'] as int?,
      totalWeight: (json['totalWeight'] as num?)?.toDouble(),
      confirmationNumber: json['confirmationNumber'] as String?,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Helper method to parse TimeOfDay from string
  static TimeOfDay _parseTimeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Converts this PickupRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courierServiceId': courierServiceId,
      'pickupDate': pickupDate.toIso8601String(),
      'pickupTime':
          '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}',
      'status': status.index,
      'address': address,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'instructions': instructions,
      'numberOfPackages': numberOfPackages,
      'totalWeight': totalWeight,
      'confirmationNumber': confirmationNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Returns a string representation of this PickupRequest
  @override
  String toString() {
    return 'PickupRequest(id: $id, courierServiceId: $courierServiceId, status: $status, pickupDate: $pickupDate)';
  }

  /// Checks if the pickup request is pending
  bool get isPending => status == PickupRequestStatus.pending;

  /// Checks if the pickup request is scheduled
  bool get isScheduled => status == PickupRequestStatus.scheduled;

  /// Checks if the pickup request is in progress
  bool get isInProgress => status == PickupRequestStatus.inProgress;

  /// Checks if the pickup request is completed
  bool get isCompleted => status == PickupRequestStatus.completed;

  /// Checks if the pickup request is cancelled
  bool get isCancelled => status == PickupRequestStatus.cancelled;

  /// Checks if the pickup request is failed
  bool get isFailed => status == PickupRequestStatus.failed;

  /// Checks if the pickup request is active (not completed, cancelled, or failed)
  bool get isActive => !isCompleted && !isCancelled && !isFailed;

  /// Gets the scheduled pickup datetime
  DateTime get scheduledPickupDateTime {
    return DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
      pickupTime.hour,
      pickupTime.minute,
    );
  }
}
