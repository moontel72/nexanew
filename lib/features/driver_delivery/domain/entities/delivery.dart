import 'package:equatable/equatable.dart';

/// Delivery status enumeration
enum DeliveryStatus {
  pending,
  assigned,
  accepted,
  pickedUp,
  inTransit,
  arrived,
  delivered,
  failed,
  cancelled,
  returned,
}

/// Delivery priority enumeration
enum DeliveryPriority {
  low,
  normal,
  high,
  urgent,
}

/// Delivery entity representing a delivery assignment
class Delivery extends Equatable {
  final String id;
  final String driverId;
  final String companyId;
  final String? orderId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String pickupAddress;
  final String deliveryAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String? pickupNotes;
  final String? deliveryNotes;
  final DeliveryStatus status;
  final DeliveryPriority priority;
  final DateTime scheduledPickupTime;
  final DateTime scheduledDeliveryTime;
  final DateTime? actualPickupTime;
  final DateTime? actualDeliveryTime;
  final double? distanceKm;
  final double? estimatedDurationMinutes;
  final double? actualDurationMinutes;
  final double deliveryFee;
  final double? tipAmount;
  final String? proofImageUrl;
  final String? signatureUrl;
  final String? otp;
  final String? deliveryProofNotes;
  final String? cancellationReason;
  final String? failureReason;
  final String? returnReason;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Delivery({
    required this.id,
    required this.driverId,
    required this.companyId,
    this.orderId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    this.pickupNotes,
    this.deliveryNotes,
    this.status = DeliveryStatus.pending,
    this.priority = DeliveryPriority.normal,
    required this.scheduledPickupTime,
    required this.scheduledDeliveryTime,
    this.actualPickupTime,
    this.actualDeliveryTime,
    this.distanceKm,
    this.estimatedDurationMinutes,
    this.actualDurationMinutes,
    required this.deliveryFee,
    this.tipAmount,
    this.proofImageUrl,
    this.signatureUrl,
    this.otp,
    this.deliveryProofNotes,
    this.cancellationReason,
    this.failureReason,
    this.returnReason,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this delivery with updated values
  Delivery copyWith({
    String? id,
    String? driverId,
    String? companyId,
    String? orderId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? pickupAddress,
    String? deliveryAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? pickupNotes,
    String? deliveryNotes,
    DeliveryStatus? status,
    DeliveryPriority? priority,
    DateTime? scheduledPickupTime,
    DateTime? scheduledDeliveryTime,
    DateTime? actualPickupTime,
    DateTime? actualDeliveryTime,
    double? distanceKm,
    double? estimatedDurationMinutes,
    double? actualDurationMinutes,
    double? deliveryFee,
    double? tipAmount,
    String? proofImageUrl,
    String? signatureUrl,
    String? otp,
    String? deliveryProofNotes,
    String? cancellationReason,
    String? failureReason,
    String? returnReason,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Delivery(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      companyId: companyId ?? this.companyId,
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      pickupNotes: pickupNotes ?? this.pickupNotes,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      scheduledPickupTime: scheduledPickupTime ?? this.scheduledPickupTime,
      scheduledDeliveryTime:
          scheduledDeliveryTime ?? this.scheduledDeliveryTime,
      actualPickupTime: actualPickupTime ?? this.actualPickupTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tipAmount: tipAmount ?? this.tipAmount,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      otp: otp ?? this.otp,
      deliveryProofNotes: deliveryProofNotes ?? this.deliveryProofNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      failureReason: failureReason ?? this.failureReason,
      returnReason: returnReason ?? this.returnReason,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if delivery is currently active
  bool get isActive => [
        DeliveryStatus.assigned,
        DeliveryStatus.accepted,
        DeliveryStatus.pickedUp,
        DeliveryStatus.inTransit,
        DeliveryStatus.arrived,
      ].contains(status);

  /// Check if delivery is completed
  bool get isCompleted => [
        DeliveryStatus.delivered,
        DeliveryStatus.failed,
        DeliveryStatus.cancelled,
        DeliveryStatus.returned,
      ].contains(status);

  /// Check if delivery is in progress
  bool get isInProgress => [
        DeliveryStatus.pickedUp,
        DeliveryStatus.inTransit,
        DeliveryStatus.arrived,
      ].contains(status);

  /// Check if delivery can be started
  bool get canStart =>
      status == DeliveryStatus.assigned || status == DeliveryStatus.accepted;

  /// Check if delivery can be completed
  bool get canComplete => [
        DeliveryStatus.pickedUp,
        DeliveryStatus.inTransit,
        DeliveryStatus.arrived,
      ].contains(status);

  /// Get total amount (delivery fee + tip)
  double get totalAmount => deliveryFee + (tipAmount ?? 0.0);

  /// Check if delivery has proof
  bool get hasProof => proofImageUrl != null && proofImageUrl!.isNotEmpty;

  /// Check if delivery has signature
  bool get hasSignature => signatureUrl != null && signatureUrl!.isNotEmpty;

  /// Check if delivery has OTP verification
  bool get hasOtpVerification => otp != null && otp!.isNotEmpty;

  /// Check if delivery is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(scheduledDeliveryTime);
  }

  /// Get time remaining until scheduled delivery
  Duration get timeRemaining {
    if (isCompleted) return Duration.zero;
    return scheduledDeliveryTime.difference(DateTime.now());
  }

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (isCompleted) return 100.0;

    final totalDuration = scheduledDeliveryTime.difference(scheduledPickupTime);
    final elapsedDuration = DateTime.now().difference(scheduledPickupTime);

    if (totalDuration.inSeconds <= 0) return 0.0;

    final percentage =
        (elapsedDuration.inSeconds / totalDuration.inSeconds) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'company_id': companyId,
      'order_id': orderId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'pickup_notes': pickupNotes,
      'delivery_notes': deliveryNotes,
      'status': status.name,
      'priority': priority.name,
      'scheduled_pickup_time': scheduledPickupTime.toIso8601String(),
      'scheduled_delivery_time': scheduledDeliveryTime.toIso8601String(),
      'actual_pickup_time': actualPickupTime?.toIso8601String(),
      'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
      'distance_km': distanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'delivery_fee': deliveryFee,
      'tip_amount': tipAmount,
      'proof_image_url': proofImageUrl,
      'signature_url': signatureUrl,
      'otp': otp,
      'delivery_proof_notes': deliveryProofNotes,
      'cancellation_reason': cancellationReason,
      'failure_reason': failureReason,
      'return_reason': returnReason,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      companyId: json['company_id'] as String,
      orderId: json['order_id'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerEmail: json['customer_email'] as String?,
      pickupAddress: json['pickup_address'] as String,
      deliveryAddress: json['delivery_address'] as String,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      deliveryLatitude: (json['delivery_latitude'] as num).toDouble(),
      deliveryLongitude: (json['delivery_longitude'] as num).toDouble(),
      pickupNotes: json['pickup_notes'] as String?,
      deliveryNotes: json['delivery_notes'] as String?,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => DeliveryStatus.pending,
      ),
      priority: DeliveryPriority.values.firstWhere(
        (e) => e.name == (json['priority'] as String? ?? 'normal'),
        orElse: () => DeliveryPriority.normal,
      ),
      scheduledPickupTime:
          DateTime.parse(json['scheduled_pickup_time'] as String),
      scheduledDeliveryTime:
          DateTime.parse(json['scheduled_delivery_time'] as String),
      actualPickupTime: json['actual_pickup_time'] != null
          ? DateTime.parse(json['actual_pickup_time'] as String)
          : null,
      actualDeliveryTime: json['actual_delivery_time'] != null
          ? DateTime.parse(json['actual_delivery_time'] as String)
          : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      estimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num?)?.toDouble(),
      actualDurationMinutes:
          (json['actual_duration_minutes'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      tipAmount: (json['tip_amount'] as num?)?.toDouble(),
      proofImageUrl: json['proof_image_url'] as String?,
      signatureUrl: json['signature_url'] as String?,
      otp: json['otp'] as String?,
      deliveryProofNotes: json['delivery_proof_notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      failureReason: json['failure_reason'] as String?,
      returnReason: json['return_reason'] as String?,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      lastLocationUpdate: json['last_location_update'] != null
          ? DateTime.parse(json['last_location_update'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        driverId,
        companyId,
        orderId,
        customerName,
        customerPhone,
        customerEmail,
        pickupAddress,
        deliveryAddress,
        pickupLatitude,
        pickupLongitude,
        deliveryLatitude,
        deliveryLongitude,
        pickupNotes,
        deliveryNotes,
        status,
        priority,
        scheduledPickupTime,
        scheduledDeliveryTime,
        actualPickupTime,
        actualDeliveryTime,
        distanceKm,
        estimatedDurationMinutes,
        actualDurationMinutes,
        deliveryFee,
        tipAmount,
        proofImageUrl,
        signatureUrl,
        otp,
        deliveryProofNotes,
        cancellationReason,
        failureReason,
        returnReason,
        currentLatitude,
        currentLongitude,
        lastLocationUpdate,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
