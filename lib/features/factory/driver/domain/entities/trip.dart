import 'package:equatable/equatable.dart';

/// Trip status following strict forward-only lifecycle (4T)
enum TripStatus {
  assigned,
  pickedUp,
  inTransit,
  arrived,
  delivered,
  completed;

  bool get canTransitionToPickedUp => this == TripStatus.assigned;
  bool get canTransitionToInTransit => this == TripStatus.pickedUp;
  bool get canTransitionToArrived => this == TripStatus.inTransit;
  bool get canTransitionToDelivered => this == TripStatus.arrived;
  bool get canTransitionToCompleted => this == TripStatus.delivered;

  /// Whether this status represents a completed/final state
  bool get isCompleted =>
      this == TripStatus.delivered || this == TripStatus.completed;

  bool canTransitionTo(TripStatus next) {
    return switch (next) {
      TripStatus.pickedUp => canTransitionToPickedUp,
      TripStatus.inTransit => canTransitionToInTransit,
      TripStatus.arrived => canTransitionToArrived,
      TripStatus.delivered => canTransitionToDelivered,
      TripStatus.completed => canTransitionToCompleted,
      _ => false,
    };
  }

  String get displayName {
    return switch (this) {
      TripStatus.assigned => 'Assigned',
      TripStatus.pickedUp => 'Picked Up',
      TripStatus.inTransit => 'In Transit',
      TripStatus.arrived => 'Arrived',
      TripStatus.delivered => 'Delivered',
      TripStatus.completed => 'Completed',
    };
  }

  int get stepIndex {
    return switch (this) {
      TripStatus.assigned => 0,
      TripStatus.pickedUp => 1,
      TripStatus.inTransit => 2,
      TripStatus.arrived => 3,
      TripStatus.delivered => 4,
      TripStatus.completed => 5,
    };
  }
}

/// Expense type categories (4K, 4L, 4M, 4O)
enum ExpenseType {
  fuel,
  food,
  mechanic,
  other;

  String get displayName {
    return switch (this) {
      ExpenseType.fuel => 'Fuel Receipt',
      ExpenseType.food => 'Food Receipt',
      ExpenseType.mechanic => 'Mechanic / Spare Parts',
      ExpenseType.other => 'Other',
    };
  }

  String get iconName {
    return switch (this) {
      ExpenseType.fuel => 'local_gas_station',
      ExpenseType.food => 'restaurant',
      ExpenseType.mechanic => 'build',
      ExpenseType.other => 'more_horiz',
    };
  }
}

/// Verification type for Proof of Delivery (4E, 4R)
enum VerificationType {
  pin,
  photo,
  signature;

  String get displayName {
    return switch (this) {
      VerificationType.pin => 'PIN Code',
      VerificationType.photo => 'Photo with Documents',
      VerificationType.signature => 'Digital Signature',
    };
  }
}

/// Driver performance tier (4AA)
enum DriverTier {
  bronze,
  silver,
  gold;

  String get displayName {
    return switch (this) {
      DriverTier.bronze => 'Bronze',
      DriverTier.silver => 'Silver',
      DriverTier.gold => 'Gold',
    };
  }

  double get bonusPercent {
    return switch (this) {
      DriverTier.bronze => 0.0,
      DriverTier.silver => 2.5,
      DriverTier.gold => 5.0,
    };
  }
}

/// Dispute status (4AB)
enum DisputeStatus {
  open,
  underReview,
  resolved,
  escalated;

  String get displayName {
    return switch (this) {
      DisputeStatus.open => 'Open',
      DisputeStatus.underReview => 'Under Review',
      DisputeStatus.resolved => 'Resolved',
      DisputeStatus.escalated => 'Escalated',
    };
  }
}

/// Trip entity - core delivery assignment
class Trip extends Equatable {
  final String id;
  final String driverId;
  final String factoryId;
  final String? orderId;
  final TripStatus status;
  final String pickupAddress;
  final String deliveryAddress;
  final double deliveryLat;
  final double deliveryLng;
  final String? customerName;
  final String? customerPhone;
  final String? productCode;
  final DateTime? deliveryWindowStart;
  final DateTime? deliveryWindowEnd;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final DateTime? completedTime;
  final double? distanceKm;
  final double? estimatedDurationMin;
  final double? meterStart;
  final double? meterDelivery;
  final double? meterReturn;
  final bool meterReadingsMandatory;
  final bool fuelReceiptMandatory;
  final bool foodReceiptMandatory;
  final bool mechanicReceiptMandatory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.driverId,
    required this.factoryId,
    this.orderId,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.deliveryLat,
    required this.deliveryLng,
    this.customerName,
    this.customerPhone,
    this.productCode,
    this.deliveryWindowStart,
    this.deliveryWindowEnd,
    this.pickupTime,
    this.deliveryTime,
    this.completedTime,
    this.distanceKm,
    this.estimatedDurationMin,
    this.meterStart,
    this.meterDelivery,
    this.meterReturn,
    this.meterReadingsMandatory = false,
    this.fuelReceiptMandatory = false,
    this.foodReceiptMandatory = false,
    this.mechanicReceiptMandatory = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Trip copyWith({
    String? id,
    String? driverId,
    String? factoryId,
    String? orderId,
    TripStatus? status,
    String? pickupAddress,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? customerName,
    String? customerPhone,
    String? productCode,
    DateTime? deliveryWindowStart,
    DateTime? deliveryWindowEnd,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    DateTime? completedTime,
    double? distanceKm,
    double? estimatedDurationMin,
    double? meterStart,
    double? meterDelivery,
    double? meterReturn,
    bool? meterReadingsMandatory,
    bool? fuelReceiptMandatory,
    bool? foodReceiptMandatory,
    bool? mechanicReceiptMandatory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      factoryId: factoryId ?? this.factoryId,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLat: deliveryLat ?? this.deliveryLat,
      deliveryLng: deliveryLng ?? this.deliveryLng,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      productCode: productCode ?? this.productCode,
      deliveryWindowStart: deliveryWindowStart ?? this.deliveryWindowStart,
      deliveryWindowEnd: deliveryWindowEnd ?? this.deliveryWindowEnd,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      completedTime: completedTime ?? this.completedTime,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMin: estimatedDurationMin ?? this.estimatedDurationMin,
      meterStart: meterStart ?? this.meterStart,
      meterDelivery: meterDelivery ?? this.meterDelivery,
      meterReturn: meterReturn ?? this.meterReturn,
      meterReadingsMandatory:
          meterReadingsMandatory ?? this.meterReadingsMandatory,
      fuelReceiptMandatory: fuelReceiptMandatory ?? this.fuelReceiptMandatory,
      foodReceiptMandatory: foodReceiptMandatory ?? this.foodReceiptMandatory,
      mechanicReceiptMandatory:
          mechanicReceiptMandatory ?? this.mechanicReceiptMandatory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if delivery window is active
  bool get isDeliveryWindowActive {
    if (deliveryWindowStart == null || deliveryWindowEnd == null) return true;
    final now = DateTime.now();
    return now.isAfter(deliveryWindowStart!) &&
        now.isBefore(deliveryWindowEnd!);
  }

  /// Time remaining in delivery window
  Duration? get deliveryWindowRemaining {
    if (deliveryWindowEnd == null) return null;
    return deliveryWindowEnd!.difference(DateTime.now());
  }

  /// Whether this trip is overdue
  bool get isOverdue {
    if (deliveryWindowEnd == null) return false;
    return DateTime.now().isAfter(deliveryWindowEnd!) && !status.isCompleted;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'factory_id': factoryId,
      'order_id': orderId,
      'status': status.name,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'delivery_lat': deliveryLat,
      'delivery_lng': deliveryLng,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'product_code': productCode,
      'delivery_window_start': deliveryWindowStart?.toIso8601String(),
      'delivery_window_end': deliveryWindowEnd?.toIso8601String(),
      'pickup_time': pickupTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'completed_time': completedTime?.toIso8601String(),
      'distance_km': distanceKm,
      'estimated_duration_min': estimatedDurationMin,
      'meter_start': meterStart,
      'meter_delivery': meterDelivery,
      'meter_return': meterReturn,
      'meter_readings_mandatory': meterReadingsMandatory,
      'fuel_receipt_mandatory': fuelReceiptMandatory,
      'food_receipt_mandatory': foodReceiptMandatory,
      'mechanic_receipt_mandatory': mechanicReceiptMandatory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      factoryId: json['factory_id'] as String,
      orderId: json['order_id'] as String?,
      status: TripStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'assigned'),
        orElse: () => TripStatus.assigned,
      ),
      pickupAddress: json['pickup_address'] as String? ?? '',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble() ?? 0.0,
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      productCode: json['product_code'] as String?,
      deliveryWindowStart: json['delivery_window_start'] != null
          ? DateTime.parse(json['delivery_window_start'] as String)
          : null,
      deliveryWindowEnd: json['delivery_window_end'] != null
          ? DateTime.parse(json['delivery_window_end'] as String)
          : null,
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'] as String)
          : null,
      deliveryTime: json['delivery_time'] != null
          ? DateTime.parse(json['delivery_time'] as String)
          : null,
      completedTime: json['completed_time'] != null
          ? DateTime.parse(json['completed_time'] as String)
          : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      estimatedDurationMin: (json['estimated_duration_min'] as num?)
          ?.toDouble(),
      meterStart: (json['meter_start'] as num?)?.toDouble(),
      meterDelivery: (json['meter_delivery'] as num?)?.toDouble(),
      meterReturn: (json['meter_return'] as num?)?.toDouble(),
      meterReadingsMandatory:
          json['meter_readings_mandatory'] as bool? ?? false,
      fuelReceiptMandatory: json['fuel_receipt_mandatory'] as bool? ?? false,
      foodReceiptMandatory: json['food_receipt_mandatory'] as bool? ?? false,
      mechanicReceiptMandatory:
          json['mechanic_receipt_mandatory'] as bool? ?? false,
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
    driverId,
    factoryId,
    orderId,
    status,
    pickupAddress,
    deliveryAddress,
    deliveryLat,
    deliveryLng,
    customerName,
    customerPhone,
    productCode,
    deliveryWindowStart,
    deliveryWindowEnd,
    pickupTime,
    deliveryTime,
    completedTime,
    distanceKm,
    estimatedDurationMin,
    meterStart,
    meterDelivery,
    meterReturn,
    meterReadingsMandatory,
    fuelReceiptMandatory,
    foodReceiptMandatory,
    mechanicReceiptMandatory,
    createdAt,
    updatedAt,
  ];
}
