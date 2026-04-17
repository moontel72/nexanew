import 'package:equatable/equatable.dart';

/// Tracking Event status enumeration
enum TrackingEventStatus {
  pickupScheduled,
  pickedUp,
  inTransit,
  arrivedAtHub,
  departedFromHub,
  outForDelivery,
  deliveryAttempted,
  delivered,
  failed,
  returned,
  onHold,
  customsClearance,
  customsHeld,
}

/// Tracking Event entity representing a shipment tracking event
class TrackingEvent extends Equatable {
  final String description;
  final String? location;
  final DateTime timestamp;
  final TrackingEventStatus status;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? latitude;
  final String? longitude;
  final String? notes;
  final String? signedBy;
  final String? proofUrl;
  final String? eventCode;
  final String? courierServiceId;
  final String? trackingNumber;

  const TrackingEvent({
    required this.description,
    this.location,
    required this.timestamp,
    required this.status,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.notes,
    this.signedBy,
    this.proofUrl,
    this.eventCode,
    this.courierServiceId,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [
        description,
        location,
        timestamp,
        status,
        city,
        state,
        country,
        postalCode,
        latitude,
        longitude,
        notes,
        signedBy,
        proofUrl,
        eventCode,
        courierServiceId,
        trackingNumber,
      ];

  /// Creates a copy of this TrackingEvent with the given fields replaced
  TrackingEvent copyWith({
    String? description,
    String? location,
    DateTime? timestamp,
    TrackingEventStatus? status,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? latitude,
    String? longitude,
    String? notes,
    String? signedBy,
    String? proofUrl,
    String? eventCode,
    String? courierServiceId,
    String? trackingNumber,
  }) {
    return TrackingEvent(
      description: description ?? this.description,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      signedBy: signedBy ?? this.signedBy,
      proofUrl: proofUrl ?? this.proofUrl,
      eventCode: eventCode ?? this.eventCode,
      courierServiceId: courierServiceId ?? this.courierServiceId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  /// Creates a TrackingEvent from JSON data
  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      description: json['description'] as String,
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TrackingEventStatus.values[json['status'] as int],
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      notes: json['notes'] as String?,
      signedBy: json['signedBy'] as String?,
      proofUrl: json['proofUrl'] as String?,
      eventCode: json['eventCode'] as String?,
      courierServiceId: json['courierServiceId'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
    );
  }

  /// Converts this TrackingEvent to JSON
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'status': status.index,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'signedBy': signedBy,
      'proofUrl': proofUrl,
      'eventCode': eventCode,
      'courierServiceId': courierServiceId,
      'trackingNumber': trackingNumber,
    };
  }

  @override
  String toString() {
    return 'TrackingEvent(description: $description, timestamp: $timestamp, status: $status)';
  }

  /// Gets the full location string
  String get fullLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);

    if (parts.isEmpty && location != null && location!.isNotEmpty) {
      return location!;
    }

    return parts.join(', ');
  }

  /// Checks if this is a pickup event
  bool get isPickupEvent =>
      status == TrackingEventStatus.pickupScheduled ||
      status == TrackingEventStatus.pickedUp;

  /// Checks if this is a transit event
  bool get isTransitEvent =>
      status == TrackingEventStatus.inTransit ||
      status == TrackingEventStatus.arrivedAtHub ||
      status == TrackingEventStatus.departedFromHub ||
      status == TrackingEventStatus.customsClearance ||
      status == TrackingEventStatus.customsHeld;

  /// Checks if this is a delivery event
  bool get isDeliveryEvent =>
      status == TrackingEventStatus.outForDelivery ||
      status == TrackingEventStatus.deliveryAttempted ||
      status == TrackingEventStatus.delivered;

  /// Checks if this is a failed event
  bool get isFailedEvent =>
      status == TrackingEventStatus.failed ||
      status == TrackingEventStatus.returned ||
      status == TrackingEventStatus.onHold;

  /// Checks if this event has location coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Checks if this event has proof
  bool get hasProof => proofUrl != null && proofUrl!.isNotEmpty;

  /// Checks if this event was signed for
  bool get wasSigned => signedBy != null && signedBy!.isNotEmpty;
}

