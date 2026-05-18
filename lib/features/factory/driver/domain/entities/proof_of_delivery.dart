import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/trip.dart';

/// Proof of Delivery entity (4E, 4R, 4W)
class ProofOfDelivery extends Equatable {
  final String id;
  final String tripId;
  final VerificationType verificationType;
  final String? pin;
  final String? recipientPhotoUrl;
  final String? documentPhotoUrl;
  final String? signatureUrl;
  final String? recipientName;
  final List<String> debriefPhotoUrls;
  final String? damageNotes;
  final bool isComplete;
  final DateTime? completedAt;
  final DateTime createdAt;

  const ProofOfDelivery({
    required this.id,
    required this.tripId,
    required this.verificationType,
    this.pin,
    this.recipientPhotoUrl,
    this.documentPhotoUrl,
    this.signatureUrl,
    this.recipientName,
    this.debriefPhotoUrls = const [],
    this.damageNotes,
    this.isComplete = false,
    this.completedAt,
    required this.createdAt,
  });

  ProofOfDelivery copyWith({
    String? id,
    String? tripId,
    VerificationType? verificationType,
    String? pin,
    String? recipientPhotoUrl,
    String? documentPhotoUrl,
    String? signatureUrl,
    String? recipientName,
    List<String>? debriefPhotoUrls,
    String? damageNotes,
    bool? isComplete,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return ProofOfDelivery(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      verificationType: verificationType ?? this.verificationType,
      pin: pin ?? this.pin,
      recipientPhotoUrl: recipientPhotoUrl ?? this.recipientPhotoUrl,
      documentPhotoUrl: documentPhotoUrl ?? this.documentPhotoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      recipientName: recipientName ?? this.recipientName,
      debriefPhotoUrls: debriefPhotoUrls ?? this.debriefPhotoUrls,
      damageNotes: damageNotes ?? this.damageNotes,
      isComplete: isComplete ?? this.isComplete,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'verification_type': verificationType.name,
      'pin': pin,
      'recipient_photo_url': recipientPhotoUrl,
      'document_photo_url': documentPhotoUrl,
      'signature_url': signatureUrl,
      'recipient_name': recipientName,
      'debrief_photo_urls': debriefPhotoUrls,
      'damage_notes': damageNotes,
      'is_complete': isComplete,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProofOfDelivery.fromJson(Map<String, dynamic> json) {
    return ProofOfDelivery(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      verificationType: VerificationType.values.firstWhere(
        (e) => e.name == (json['verification_type'] as String? ?? 'pin'),
        orElse: () => VerificationType.pin,
      ),
      pin: json['pin'] as String?,
      recipientPhotoUrl: json['recipient_photo_url'] as String?,
      documentPhotoUrl: json['document_photo_url'] as String?,
      signatureUrl: json['signature_url'] as String?,
      recipientName: json['recipient_name'] as String?,
      debriefPhotoUrls: (json['debrief_photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      damageNotes: json['damage_notes'] as String?,
      isComplete: json['is_complete'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id, tripId, verificationType, pin, recipientPhotoUrl,
        documentPhotoUrl, signatureUrl, recipientName, debriefPhotoUrls,
        damageNotes, isComplete, completedAt, createdAt,
      ];
}
