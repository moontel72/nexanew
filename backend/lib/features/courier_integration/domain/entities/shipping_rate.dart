import 'package:equatable/equatable.dart';

/// Shipping Rate entity representing a courier shipping rate
class ShippingRate extends Equatable {
  final String courierServiceId;
  final double estimatedCost;
  final String currency;
  final String serviceName;
  final String? serviceCode;
  final double? weightLimit;
  final String? weightUnit;
  final double? dimensionLimit;
  final String? dimensionUnit;
  final int? estimatedDays;
  final String? estimatedDelivery;
  final bool? isCashOnDeliveryAvailable;
  final double? codFee;
  final bool? isInsuranceAvailable;
  final double? insuranceFee;
  final bool? isTrackingAvailable;
  final bool? isSignatureRequired;
  final double? signatureFee;
  final String? notes;

  const ShippingRate({
    required this.courierServiceId,
    required this.estimatedCost,
    required this.currency,
    required this.serviceName,
    this.serviceCode,
    this.weightLimit,
    this.weightUnit,
    this.dimensionLimit,
    this.dimensionUnit,
    this.estimatedDays,
    this.estimatedDelivery,
    this.isCashOnDeliveryAvailable,
    this.codFee,
    this.isInsuranceAvailable,
    this.insuranceFee,
    this.isTrackingAvailable,
    this.isSignatureRequired,
    this.signatureFee,
    this.notes,
  });

  @override
  List<Object?> get props => [
        courierServiceId,
        estimatedCost,
        currency,
        serviceName,
        serviceCode,
        weightLimit,
        weightUnit,
        dimensionLimit,
        dimensionUnit,
        estimatedDays,
        estimatedDelivery,
        isCashOnDeliveryAvailable,
        codFee,
        isInsuranceAvailable,
        insuranceFee,
        isTrackingAvailable,
        isSignatureRequired,
        signatureFee,
        notes,
      ];

  /// Creates a copy of this ShippingRate with the given fields replaced
  ShippingRate copyWith({
    String? courierServiceId,
    double? estimatedCost,
    String? currency,
    String? serviceName,
    String? serviceCode,
    double? weightLimit,
    String? weightUnit,
    double? dimensionLimit,
    String? dimensionUnit,
    int? estimatedDays,
    String? estimatedDelivery,
    bool? isCashOnDeliveryAvailable,
    double? codFee,
    bool? isInsuranceAvailable,
    double? insuranceFee,
    bool? isTrackingAvailable,
    bool? isSignatureRequired,
    double? signatureFee,
    String? notes,
  }) {
    return ShippingRate(
      courierServiceId: courierServiceId ?? this.courierServiceId,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      currency: currency ?? this.currency,
      serviceName: serviceName ?? this.serviceName,
      serviceCode: serviceCode ?? this.serviceCode,
      weightLimit: weightLimit ?? this.weightLimit,
      weightUnit: weightUnit ?? this.weightUnit,
      dimensionLimit: dimensionLimit ?? this.dimensionLimit,
      dimensionUnit: dimensionUnit ?? this.dimensionUnit,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      isCashOnDeliveryAvailable:
          isCashOnDeliveryAvailable ?? this.isCashOnDeliveryAvailable,
      codFee: codFee ?? this.codFee,
      isInsuranceAvailable: isInsuranceAvailable ?? this.isInsuranceAvailable,
      insuranceFee: insuranceFee ?? this.insuranceFee,
      isTrackingAvailable: isTrackingAvailable ?? this.isTrackingAvailable,
      isSignatureRequired: isSignatureRequired ?? this.isSignatureRequired,
      signatureFee: signatureFee ?? this.signatureFee,
      notes: notes ?? this.notes,
    );
  }

  /// Creates a ShippingRate from JSON data
  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    return ShippingRate(
      courierServiceId: json['courierServiceId'] as String,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      currency: json['currency'] as String,
      serviceName: json['serviceName'] as String,
      serviceCode: json['serviceCode'] as String?,
      weightLimit: (json['weightLimit'] as num?)?.toDouble(),
      weightUnit: json['weightUnit'] as String?,
      dimensionLimit: (json['dimensionLimit'] as num?)?.toDouble(),
      dimensionUnit: json['dimensionUnit'] as String?,
      estimatedDays: json['estimatedDays'] as int?,
      estimatedDelivery: json['estimatedDelivery'] as String?,
      isCashOnDeliveryAvailable: json['isCashOnDeliveryAvailable'] as bool?,
      codFee: (json['codFee'] as num?)?.toDouble(),
      isInsuranceAvailable: json['isInsuranceAvailable'] as bool?,
      insuranceFee: (json['insuranceFee'] as num?)?.toDouble(),
      isTrackingAvailable: json['isTrackingAvailable'] as bool?,
      isSignatureRequired: json['isSignatureRequired'] as bool?,
      signatureFee: (json['signatureFee'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  /// Converts this ShippingRate to JSON
  Map<String, dynamic> toJson() {
    return {
      'courierServiceId': courierServiceId,
      'estimatedCost': estimatedCost,
      'currency': currency,
      'serviceName': serviceName,
      'serviceCode': serviceCode,
      'weightLimit': weightLimit,
      'weightUnit': weightUnit,
      'dimensionLimit': dimensionLimit,
      'dimensionUnit': dimensionUnit,
      'estimatedDays': estimatedDays,
      'estimatedDelivery': estimatedDelivery,
      'isCashOnDeliveryAvailable': isCashOnDeliveryAvailable,
      'codFee': codFee,
      'isInsuranceAvailable': isInsuranceAvailable,
      'insuranceFee': insuranceFee,
      'isTrackingAvailable': isTrackingAvailable,
      'isSignatureRequired': isSignatureRequired,
      'signatureFee': signatureFee,
      'notes': notes,
    };
  }

  /// Returns a string representation of this ShippingRate
  @override
  String toString() {
    return 'ShippingRate(courierServiceId: $courierServiceId, serviceName: $serviceName, estimatedCost: $estimatedCost $currency)';
  }

  /// Gets the total cost including all fees
  double get totalCost {
    double total = estimatedCost;
    if (codFee != null) total += codFee!;
    if (insuranceFee != null) total += insuranceFee!;
    if (signatureFee != null) total += signatureFee!;
    return total;
  }

  /// Checks if this rate supports cash on delivery
  bool get supportsCashOnDelivery => isCashOnDeliveryAvailable == true;

  /// Checks if this rate includes insurance
  bool get includesInsurance => isInsuranceAvailable == true;

  /// Checks if this rate includes tracking
  bool get includesTracking => isTrackingAvailable == true;

  /// Checks if this rate requires signature
  bool get requiresSignature => isSignatureRequired == true;
}
