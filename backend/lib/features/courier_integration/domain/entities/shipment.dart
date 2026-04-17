import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Shipment status enumeration
enum ShipmentStatus {
  draft,
  created,
  labelGenerated,
  pickedUp,
  inTransit,
  outForDelivery,
  delivered,
  failed,
  returned,
  cancelled,
  onHold,
}

/// Shipment type enumeration
enum ShipmentType {
  document,
  parcel,
  express,
  freight,
  international,
  sameDay,
  nextDay,
}

/// Payment method enumeration
enum PaymentMethod {
  prepaid,
  cashOnDelivery,
  credit,
  account,
  online,
}

/// Shipment entity representing a courier shipment
class Shipment extends Equatable {
  final String id;
  final String companyId;
  final String courierServiceId;
  final String? orderId;
  final String? referenceNumber;
  final String trackingNumber;
  final ShipmentType type;
  final ShipmentStatus status;
  final PaymentMethod paymentMethod;

  // Sender information
  final String senderName;
  final String senderPhone;
  final String senderEmail;
  final String senderAddress;
  final String senderCity;
  final String senderState;
  final String senderCountry;
  final String senderPostalCode;

  // Recipient information
  final String recipientName;
  final String recipientPhone;
  final String recipientEmail;
  final String recipientAddress;
  final String recipientCity;
  final String recipientState;
  final String recipientCountry;
  final String recipientPostalCode;

  // Package information
  final double weight;
  final String weightUnit;
  final double? length;
  final double? width;
  final double? height;
  final String? dimensionsUnit;
  final String? description;
  final List<String>? itemTypes;
  final double? declaredValue;
  final String? currency;

  // Delivery information
  final bool isCashOnDelivery;
  final double? codAmount;
  final String? deliveryInstructions;
  final bool requiresSignature;
  final bool requiresInsurance;
  final double? insuranceAmount;

  // Financial information
  final double shippingCost;
  final double? taxAmount;
  final double? discountAmount;
  final double totalAmount;
  final double? paidAmount;
  final DateTime? paymentDate;

  // Timing information
  final DateTime pickupDate;
  final TimeOfDay? pickupTime;
  final DateTime? actualPickupDate;
  final DateTime estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;

  // Courier information
  final String? labelUrl;
  final String? manifestId;
  final String? awbNumber;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;

  // Additional information
  final String? notes;
  final String? cancellationReason;
  final String? returnReason;
  final String? failureReason;
  final List<String>? proofImages;
  final String? signatureUrl;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shipment({
    required this.id,
    required this.companyId,
    required this.courierServiceId,
    this.orderId,
    this.referenceNumber,
    required this.trackingNumber,
    required this.type,
    required this.status,
    required this.paymentMethod,
    required this.senderName,
    required this.senderPhone,
    required this.senderEmail,
    required this.senderAddress,
    required this.senderCity,
    required this.senderState,
    required this.senderCountry,
    required this.senderPostalCode,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientEmail,
    required this.recipientAddress,
    required this.recipientCity,
    required this.recipientState,
    required this.recipientCountry,
    required this.recipientPostalCode,
    required this.weight,
    required this.weightUnit,
    this.length,
    this.width,
    this.height,
    this.dimensionsUnit,
    this.description,
    this.itemTypes,
    this.declaredValue,
    this.currency,
    this.isCashOnDelivery = false,
    this.codAmount,
    this.deliveryInstructions,
    this.requiresSignature = false,
    this.requiresInsurance = false,
    this.insuranceAmount,
    required this.shippingCost,
    this.taxAmount,
    this.discountAmount,
    required this.totalAmount,
    this.paidAmount,
    this.paymentDate,
    required this.pickupDate,
    this.pickupTime,
    this.actualPickupDate,
    required this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.labelUrl,
    this.manifestId,
    this.awbNumber,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.notes,
    this.cancellationReason,
    this.returnReason,
    this.failureReason,
    this.proofImages,
    this.signatureUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, trackingNumber, status, updatedAt];

  /// Copy with method to create a modified copy
  Shipment copyWith({
    String? id,
    String? companyId,
    String? courierServiceId,
    String? orderId,
    String? referenceNumber,
    String? trackingNumber,
    ShipmentType? type,
    ShipmentStatus? status,
    PaymentMethod? paymentMethod,
    String? senderName,
    String? senderPhone,
    String? senderEmail,
    String? senderAddress,
    String? senderCity,
    String? senderState,
    String? senderCountry,
    String? senderPostalCode,
    String? recipientName,
    String? recipientPhone,
    String? recipientEmail,
    String? recipientAddress,
    String? recipientCity,
    String? recipientState,
    String? recipientCountry,
    String? recipientPostalCode,
    double? weight,
    String? weightUnit,
    double? length,
    double? width,
    double? height,
    String? dimensionsUnit,
    String? description,
    List<String>? itemTypes,
    double? declaredValue,
    String? currency,
    bool? isCashOnDelivery,
    double? codAmount,
    String? deliveryInstructions,
    bool? requiresSignature,
    bool? requiresInsurance,
    double? insuranceAmount,
    double? shippingCost,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    DateTime? paymentDate,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    DateTime? actualPickupDate,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? labelUrl,
    String? manifestId,
    String? awbNumber,
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    String? notes,
    String? cancellationReason,
    String? returnReason,
    String? failureReason,
    List<String>? proofImages,
    String? signatureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shipment(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      courierServiceId: courierServiceId ?? this.courierServiceId,
      orderId: orderId ?? this.orderId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      senderEmail: senderEmail ?? this.senderEmail,
      senderAddress: senderAddress ?? this.senderAddress,
      senderCity: senderCity ?? this.senderCity,
      senderState: senderState ?? this.senderState,
      senderCountry: senderCountry ?? this.senderCountry,
      senderPostalCode: senderPostalCode ?? this.senderPostalCode,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      recipientCity: recipientCity ?? this.recipientCity,
      recipientState: recipientState ?? this.recipientState,
      recipientCountry: recipientCountry ?? this.recipientCountry,
      recipientPostalCode: recipientPostalCode ?? this.recipientPostalCode,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      dimensionsUnit: dimensionsUnit ?? this.dimensionsUnit,
      description: description ?? this.description,
      itemTypes: itemTypes ?? this.itemTypes,
      declaredValue: declaredValue ?? this.declaredValue,
      currency: currency ?? this.currency,
      isCashOnDelivery: isCashOnDelivery ?? this.isCashOnDelivery,
      codAmount: codAmount ?? this.codAmount,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      requiresSignature: requiresSignature ?? this.requiresSignature,
      requiresInsurance: requiresInsurance ?? this.requiresInsurance,
      insuranceAmount: insuranceAmount ?? this.insuranceAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      actualPickupDate: actualPickupDate ?? this.actualPickupDate,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      labelUrl: labelUrl ?? this.labelUrl,
      manifestId: manifestId ?? this.manifestId,
      awbNumber: awbNumber ?? this.awbNumber,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      returnReason: returnReason ?? this.returnReason,
      failureReason: failureReason ?? this.failureReason,
      proofImages: proofImages ?? this.proofImages,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if shipment is active (not completed or cancelled)
  bool get isActive => ![
        ShipmentStatus.delivered,
        ShipmentStatus.failed,
        ShipmentStatus.cancelled,
        ShipmentStatus.returned,
      ].contains(status);

  /// Check if shipment is in transit
  bool get isInTransit => [
        ShipmentStatus.inTransit,
        ShipmentStatus.outForDelivery,
      ].contains(status);

  /// Check if shipment is delivered
  bool get isDelivered => status == ShipmentStatus.delivered;

  /// Check if shipment requires payment
  bool get requiresPayment => paidAmount == null || paidAmount! < totalAmount;

  /// Check if shipment has COD
  bool get hasCashOnDelivery =>
      isCashOnDelivery && codAmount != null && codAmount! > 0;

  /// Check if shipment has insurance
  bool get hasInsurance =>
      requiresInsurance && insuranceAmount != null && insuranceAmount! > 0;

  /// Check if shipment has proof of delivery
  bool get hasProofOfDelivery => proofImages != null && proofImages!.isNotEmpty;

  /// Check if shipment has signature
  bool get hasSignature => signatureUrl != null && signatureUrl!.isNotEmpty;

  /// Check if shipment is overdue
  bool get isOverdue {
    if (isDelivered || status == ShipmentStatus.cancelled) return false;
    return DateTime.now().isAfter(estimatedDeliveryDate);
  }

  /// Get remaining payment amount
  double get remainingPayment {
    if (paidAmount == null) return totalAmount;
    return totalAmount - paidAmount!;
  }

  /// Get package volume (if dimensions available)
  double? get volume {
    if (length == null || width == null || height == null) return null;
    return length! * width! * height!;
  }

  /// Get package weight in kg (converted if needed)
  double get weightInKg {
    if (weightUnit.toLowerCase() == 'kg') return weight;
    if (weightUnit.toLowerCase() == 'g') return weight / 1000;
    if (weightUnit.toLowerCase() == 'lb') return weight * 0.453592;
    return weight; // Assume kg by default
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'courier_service_id': courierServiceId,
      'order_id': orderId,
      'reference_number': referenceNumber,
      'tracking_number': trackingNumber,
      'type': type.name,
      'status': status.name,
      'payment_method': paymentMethod.name,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'sender_email': senderEmail,
      'sender_address': senderAddress,
      'sender_city': senderCity,
      'sender_state': senderState,
      'sender_country': senderCountry,
      'sender_postal_code': senderPostalCode,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'recipient_email': recipientEmail,
      'recipient_address': recipientAddress,
      'recipient_city': recipientCity,
      'recipient_state': recipientState,
      'recipient_country': recipientCountry,
      'recipient_postal_code': recipientPostalCode,
      'weight': weight,
      'weight_unit': weightUnit,
      'length': length,
      'width': width,
      'height': height,
      'dimensions_unit': dimensionsUnit,
      'description': description,
      'item_types': itemTypes,
      'declared_value': declaredValue,
      'currency': currency,
      'is_cash_on_delivery': isCashOnDelivery,
      'cod_amount': codAmount,
      'delivery_instructions': deliveryInstructions,
      'requires_signature': requiresSignature,
      'requires_insurance': requiresInsurance,
      'insurance_amount': insuranceAmount,
      'shipping_cost': shippingCost,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'payment_date': paymentDate?.toIso8601String(),
      'pickup_date': pickupDate.toIso8601String(),
      'pickup_time': pickupTime != null
          ? '${pickupTime!.hour.toString().padLeft(2, "0")}:${pickupTime!.minute.toString().padLeft(2, "0")}'
          : null,
      'actual_pickup_date': actualPickupDate?.toIso8601String(),
      'estimated_delivery_date': estimatedDeliveryDate.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'label_url': labelUrl,
      'manifest_id': manifestId,
      'awb_number': awbNumber,
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'vehicle_number': vehicleNumber,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'return_reason': returnReason,
      'failure_reason': failureReason,
      'proof_images': proofImages,
      'signature_url': signatureUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      courierServiceId: json['courier_service_id'] as String,
      orderId: json['order_id'] as String?,
      referenceNumber: json['reference_number'] as String?,
      trackingNumber: json['tracking_number'] as String,
      type: ShipmentType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'parcel'),
        orElse: () => ShipmentType.parcel,
      ),
      status: ShipmentStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'draft'),
        orElse: () => ShipmentStatus.draft,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['payment_method'] as String? ?? 'prepaid'),
        orElse: () => PaymentMethod.prepaid,
      ),
      senderName: json['sender_name'] as String,
      senderPhone: json['sender_phone'] as String,
      senderEmail: json['sender_email'] as String,
      senderAddress: json['sender_address'] as String,
      senderCity: json['sender_city'] as String,
      senderState: json['sender_state'] as String,
      senderCountry: json['sender_country'] as String,
      senderPostalCode: json['sender_postal_code'] as String,
      recipientName: json['recipient_name'] as String,
      recipientPhone: json['recipient_phone'] as String,
      recipientEmail: json['recipient_email'] as String,
      recipientAddress: json['recipient_address'] as String,
      recipientCity: json['recipient_city'] as String,
      recipientState: json['recipient_state'] as String,
      recipientCountry: json['recipient_country'] as String,
      recipientPostalCode: json['recipient_postal_code'] as String,
      weight: (json['weight'] as num).toDouble(),
      weightUnit: json['weight_unit'] as String,
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      dimensionsUnit: json['dimensions_unit'] as String?,
      description: json['description'] as String?,
      itemTypes: (json['item_types'] as List<dynamic>?)?.cast<String>(),
      declaredValue: (json['declared_value'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      isCashOnDelivery: json['is_cash_on_delivery'] as bool? ?? false,
      codAmount: (json['cod_amount'] as num?)?.toDouble(),
      deliveryInstructions: json['delivery_instructions'] as String?,
      requiresSignature: json['requires_signature'] as bool? ?? false,
      requiresInsurance: json['requires_insurance'] as bool? ?? false,
      insuranceAmount: (json['insurance_amount'] as num?)?.toDouble(),
      shippingCost: (json['shipping_cost'] as num? ?? 0.0).toDouble(),
      taxAmount: (json['tax_amount'] as num?)?.toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num? ?? 0.0).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble(),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      pickupDate: DateTime.parse(json['pickup_date']),
      pickupTime: json['pickup_time'] != null
          ? _parseTimeOfDayFromString(json['pickup_time'] as String)
          : null,
      actualPickupDate: json['actual_pickup_date'] != null
          ? DateTime.parse(json['actual_pickup_date'])
          : null,
      estimatedDeliveryDate: DateTime.parse(json['estimated_delivery_date']),
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'])
          : null,
      labelUrl: json['label_url'] as String?,
      manifestId: json['manifest_id'] as String?,
      awbNumber: json['awb_number'] as String?,
      driverName: json['driver_name'] as String?,
      driverPhone: json['driver_phone'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      returnReason: json['return_reason'] as String?,
      failureReason: json['failure_reason'] as String?,
      proofImages: (json['proof_images'] as List<dynamic>?)?.cast<String>(),
      signatureUrl: json['signature_url'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Parse TimeOfDay from string (HH:mm format)
  static TimeOfDay? _parseTimeOfDayFromString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }
}
