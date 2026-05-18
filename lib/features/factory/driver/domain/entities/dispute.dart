import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/trip.dart';

/// Dispute entity for contested deliveries (4AB)
class Dispute extends Equatable {
  final String id;
  final String tripId;
  final String driverId;
  final DisputeStatus status;
  final String reason;
  final String? description;
  final String? evidence;
  final String? counterEvidence;
  final String? resolution;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Dispute({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.status,
    required this.reason,
    this.description,
    this.evidence,
    this.counterEvidence,
    this.resolution,
    required this.createdAt,
    required this.updatedAt,
  });

  Dispute copyWith({
    String? id,
    String? tripId,
    String? driverId,
    DisputeStatus? status,
    String? reason,
    String? description,
    String? evidence,
    String? counterEvidence,
    String? resolution,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dispute(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      evidence: evidence ?? this.evidence,
      counterEvidence: counterEvidence ?? this.counterEvidence,
      resolution: resolution ?? this.resolution,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'driver_id': driverId,
      'status': status.name,
      'reason': reason,
      'description': description,
      'evidence': evidence,
      'counter_evidence': counterEvidence,
      'resolution': resolution,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      driverId: json['driver_id'] as String,
      status: DisputeStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'open'),
        orElse: () => DisputeStatus.open,
      ),
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      evidence: json['evidence'] as String?,
      counterEvidence: json['counter_evidence'] as String?,
      resolution: json['resolution'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    tripId,
    driverId,
    status,
    reason,
    description,
    evidence,
    counterEvidence,
    resolution,
    createdAt,
    updatedAt,
  ];
}
