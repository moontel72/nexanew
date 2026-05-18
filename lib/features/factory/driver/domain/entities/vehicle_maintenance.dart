import 'package:equatable/equatable.dart';

/// Vehicle maintenance record entity
class VehicleMaintenance extends Equatable {
  final String id;
  final String vehicleId;
  final String type;
  final DateTime serviceDate;
  final DateTime nextServiceDate;
  final double? mileage;
  final String? notes;
  final DateTime createdAt;

  const VehicleMaintenance({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.serviceDate,
    required this.nextServiceDate,
    this.mileage,
    this.notes,
    required this.createdAt,
  });

  VehicleMaintenance copyWith({
    String? id,
    String? vehicleId,
    String? type,
    DateTime? serviceDate,
    DateTime? nextServiceDate,
    double? mileage,
    String? notes,
    DateTime? createdAt,
  }) {
    return VehicleMaintenance(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      serviceDate: serviceDate ?? this.serviceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      mileage: mileage ?? this.mileage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether the next service is overdue
  bool get isServiceOverdue => DateTime.now().isAfter(nextServiceDate);

  /// Days until next service
  int get daysUntilNextService =>
      nextServiceDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'type': type,
      'service_date': serviceDate.toIso8601String(),
      'next_service_date': nextServiceDate.toIso8601String(),
      'mileage': mileage,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VehicleMaintenance.fromJson(Map<String, dynamic> json) {
    return VehicleMaintenance(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      type: json['type'] as String? ?? '',
      serviceDate: DateTime.parse(json['service_date'] as String),
      nextServiceDate: DateTime.parse(json['next_service_date'] as String),
      mileage: (json['mileage'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    type,
    serviceDate,
    nextServiceDate,
    mileage,
    notes,
    createdAt,
  ];
}
