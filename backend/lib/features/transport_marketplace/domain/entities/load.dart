import 'package:equatable/equatable.dart';

/// Load status enumeration
enum LoadStatus {
  draft,
  posted,
  bidding,
  awarded,
  inProgress,
  completed,
  cancelled,
  expired,
}

/// Load type enumeration
enum LoadType {
  fullTruckLoad,
  lessThanTruckLoad,
  partLoad,
  container,
  bulk,
  refrigerated,
  hazardous,
  oversized,
  general,
}

/// Weight unit enumeration
enum WeightUnit {
  kg,
  ton,
  lb,
}

/// Load entity representing a transportation load
class Load extends Equatable {
  final String id;
  final String shipperId;
  final String companyId;
  final LoadType type;
  final LoadStatus status;

  // Origin information
  final String origin;
  final String originCity;
  final String originState;
  final String originCountry;
  final String originPostalCode;
  final double? originLatitude;
  final double? originLongitude;

  // Destination information
  final String destination;
  final String destinationCity;
  final String destinationState;
  final String destinationCountry;
  final String destinationPostalCode;
  final double? destinationLatitude;
  final double? destinationLongitude;

  // Load details
  final double weight;
  final WeightUnit weightUnit;
  final String? dimensions; // Format: "LxWxH"
  final String? commodityType;
  final String? specialRequirements;
  final bool requiresInsurance;
  final double? insuranceAmount;
  final List<String>? requiredDocuments;

  // Timing information
  final DateTime pickupDate;
  final DateTime deliveryDate;
  final bool flexibleTiming;
  final String? pickupInstructions;
  final String? deliveryInstructions;

  // Financial information
  final double budget;
  final String currency;
  final bool negotiable;
  final PaymentMethod paymentMethod;
  final int paymentTermsDays;

  // Contact information
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String? alternateContactName;
  final String? alternateContactPhone;

  // Bidding information
  final int bidCount;
  final double? lowestBid;
  final double? highestBid;
  final String? awardedBidId;
  final String? awardedTransporterId;
  final DateTime? biddingEndDate;

  // Additional information
  final String? notes;
  final List<String>? attachments;
  final String? cancellationReason;
  final String? expiryReason;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Load({
    required this.id,
    required this.shipperId,
    required this.companyId,
    required this.type,
    required this.status,
    required this.origin,
    required this.originCity,
    required this.originState,
    required this.originCountry,
    required this.originPostalCode,
    this.originLatitude,
    this.originLongitude,
    required this.destination,
    required this.destinationCity,
    required this.destinationState,
    required this.destinationCountry,
    required this.destinationPostalCode,
    this.destinationLatitude,
    this.destinationLongitude,
    required this.weight,
    required this.weightUnit,
    this.dimensions,
    this.commodityType,
    this.specialRequirements,
    this.requiresInsurance = false,
    this.insuranceAmount,
    this.requiredDocuments,
    required this.pickupDate,
    required this.deliveryDate,
    this.flexibleTiming = false,
    this.pickupInstructions,
    this.deliveryInstructions,
    required this.budget,
    required this.currency,
    this.negotiable = true,
    required this.paymentMethod,
    this.paymentTermsDays = 30,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    this.alternateContactName,
    this.alternateContactPhone,
    this.bidCount = 0,
    this.lowestBid,
    this.highestBid,
    this.awardedBidId,
    this.awardedTransporterId,
    this.biddingEndDate,
    this.notes,
    this.attachments,
    this.cancellationReason,
    this.expiryReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this load with updated values
  Load copyWith({
    String? id,
    String? shipperId,
    String? companyId,
    LoadType? type,
    LoadStatus? status,
    String? origin,
    String? originCity,
    String? originState,
    String? originCountry,
    String? originPostalCode,
    double? originLatitude,
    double? originLongitude,
    String? destination,
    String? destinationCity,
    String? destinationState,
    String? destinationCountry,
    String? destinationPostalCode,
    double? destinationLatitude,
    double? destinationLongitude,
    double? weight,
    WeightUnit? weightUnit,
    String? dimensions,
    String? commodityType,
    String? specialRequirements,
    bool? requiresInsurance,
    double? insuranceAmount,
    List<String>? requiredDocuments,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    bool? flexibleTiming,
    String? pickupInstructions,
    String? deliveryInstructions,
    double? budget,
    String? currency,
    bool? negotiable,
    PaymentMethod? paymentMethod,
    int? paymentTermsDays,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? alternateContactName,
    String? alternateContactPhone,
    int? bidCount,
    double? lowestBid,
    double? highestBid,
    String? awardedBidId,
    String? awardedTransporterId,
    DateTime? biddingEndDate,
    String? notes,
    List<String>? attachments,
    String? cancellationReason,
    String? expiryReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Load(
      id: id ?? this.id,
      shipperId: shipperId ?? this.shipperId,
      companyId: companyId ?? this.companyId,
      type: type ?? this.type,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      originCity: originCity ?? this.originCity,
      originState: originState ?? this.originState,
      originCountry: originCountry ?? this.originCountry,
      originPostalCode: originPostalCode ?? this.originPostalCode,
      originLatitude: originLatitude ?? this.originLatitude,
      originLongitude: originLongitude ?? this.originLongitude,
      destination: destination ?? this.destination,
      destinationCity: destinationCity ?? this.destinationCity,
      destinationState: destinationState ?? this.destinationState,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      destinationPostalCode:
          destinationPostalCode ?? this.destinationPostalCode,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      dimensions: dimensions ?? this.dimensions,
      commodityType: commodityType ?? this.commodityType,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      requiresInsurance: requiresInsurance ?? this.requiresInsurance,
      insuranceAmount: insuranceAmount ?? this.insuranceAmount,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      flexibleTiming: flexibleTiming ?? this.flexibleTiming,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      negotiable: negotiable ?? this.negotiable,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTermsDays: paymentTermsDays ?? this.paymentTermsDays,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      alternateContactName: alternateContactName ?? this.alternateContactName,
      alternateContactPhone:
          alternateContactPhone ?? this.alternateContactPhone,
      bidCount: bidCount ?? this.bidCount,
      lowestBid: lowestBid ?? this.lowestBid,
      highestBid: highestBid ?? this.highestBid,
      awardedBidId: awardedBidId ?? this.awardedBidId,
      awardedTransporterId: awardedTransporterId ?? this.awardedTransporterId,
      biddingEndDate: biddingEndDate ?? this.biddingEndDate,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      expiryReason: expiryReason ?? this.expiryReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if load is active (available for bidding)
  bool get isActive => [
        LoadStatus.posted,
        LoadStatus.bidding,
      ].contains(status);

  /// Check if load is awarded
  bool get isAwarded => status == LoadStatus.awarded;

  /// Check if load is in progress
  bool get isInProgress => status == LoadStatus.inProgress;

  /// Check if load is completed
  bool get isCompleted => status == LoadStatus.completed;

  /// Check if load is cancelled
  bool get isCancelled => status == LoadStatus.cancelled;

  /// Check if load is expired
  bool get isExpired => status == LoadStatus.expired;

  /// Check if load is open for bidding
  bool get isOpenForBidding =>
      isActive && biddingEndDate?.isAfter(DateTime.now()) != false;

  /// Check if load has bids
  bool get hasBids => bidCount > 0;

  /// Check if load is awarded to a transporter
  bool get isAwardedToTransporter =>
      awardedTransporterId != null && awardedTransporterId!.isNotEmpty;

  /// Check if load requires insurance
  bool get requiresInsuranceCoverage =>
      requiresInsurance && insuranceAmount != null && insuranceAmount! > 0;

  /// Get weight in kg (converted if needed)
  double get weightInKg {
    switch (weightUnit) {
      case WeightUnit.kg:
        return weight;
      case WeightUnit.ton:
        return weight * 1000;
      case WeightUnit.lb:
        return weight * 0.453592;
    }
  }

  /// Get weight in tons (converted if needed)
  double get weightInTons {
    switch (weightUnit) {
      case WeightUnit.kg:
        return weight / 1000;
      case WeightUnit.ton:
        return weight;
      case WeightUnit.lb:
        return weight * 0.000453592;
    }
  }

  /// Get transit duration in days
  int get transitDurationInDays => deliveryDate.difference(pickupDate).inDays;

  /// Check if load is urgent (delivery within 3 days)
  bool get isUrgent => transitDurationInDays <= 3;

  /// Get formatted dimensions
  String? get formattedDimensions {
    if (dimensions == null) return null;
    return dimensions!.replaceAll('x', ' × ');
  }

  /// Get origin full address
  String get originFullAddress {
    return '$origin, $originCity, $originState, $originCountry';
  }

  /// Get destination full address
  String get destinationFullAddress {
    return '$destination, $destinationCity, $destinationState, $destinationCountry';
  }

  /// Get route description
  String get routeDescription {
    return '$originCity → $destinationCity';
  }

  /// Check if load has location coordinates
  bool get hasLocationCoordinates =>
      originLatitude != null &&
      originLongitude != null &&
      destinationLatitude != null &&
      destinationLongitude != null;

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipper_id': shipperId,
      'company_id': companyId,
      'type': type.name,
      'status': status.name,
      'origin': origin,
      'origin_city': originCity,
      'origin_state': originState,
      'origin_country': originCountry,
      'origin_postal_code': originPostalCode,
      'origin_latitude': originLatitude,
      'origin_longitude': originLongitude,
      'destination': destination,
      'destination_city': destinationCity,
      'destination_state': destinationState,
      'destination_country': destinationCountry,
      'destination_postal_code': destinationPostalCode,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'weight': weight,
      'weight_unit': weightUnit.name,
      'dimensions': dimensions,
      'commodity_type': commodityType,
      'special_requirements': specialRequirements,
      'requires_insurance': requiresInsurance,
      'insurance_amount': insuranceAmount,
      'required_documents': requiredDocuments,
      'pickup_date': pickupDate.toIso8601String(),
      'delivery_date': deliveryDate.toIso8601String(),
      'flexible_timing': flexibleTiming,
      'pickup_instructions': pickupInstructions,
      'delivery_instructions': deliveryInstructions,
      'budget': budget,
      'currency': currency,
      'negotiable': negotiable,
      'payment_method': paymentMethod.name,
      'payment_terms_days': paymentTermsDays,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'alternate_contact_name': alternateContactName,
      'alternate_contact_phone': alternateContactPhone,
      'bid_count': bidCount,
      'lowest_bid': lowestBid,
      'highest_bid': highestBid,
      'awarded_bid_id': awardedBidId,
      'awarded_transporter_id': awardedTransporterId,
      'bidding_end_date': biddingEndDate?.toIso8601String(),
      'notes': notes,
      'attachments': attachments,
      'cancellation_reason': cancellationReason,
      'expiry_reason': expiryReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory Load.fromJson(Map<String, dynamic> json) {
    return Load(
      id: json['id'] as String,
      shipperId: json['shipper_id'] as String,
      companyId: json['company_id'] as String,
      type: LoadType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'general'),
        orElse: () => LoadType.general,
      ),
      status: LoadStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'draft'),
        orElse: () => LoadStatus.draft,
      ),
      origin: json['origin'] as String,
      originCity: json['origin_city'] as String,
      originState: json['origin_state'] as String,
      originCountry: json['origin_country'] as String,
      originPostalCode: json['origin_postal_code'] as String,
      originLatitude: (json['origin_latitude'] as num?)?.toDouble(),
      originLongitude: (json['origin_longitude'] as num?)?.toDouble(),
      destination: json['destination'] as String,
      destinationCity: json['destination_city'] as String,
      destinationState: json['destination_state'] as String,
      destinationCountry: json['destination_country'] as String,
      destinationPostalCode: json['destination_postal_code'] as String,
      destinationLatitude: (json['destination_latitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destination_longitude'] as num?)?.toDouble(),
      weight: (json['weight'] as num).toDouble(),
      weightUnit: WeightUnit.values.firstWhere(
        (e) => e.name == (json['weight_unit'] as String? ?? 'kg'),
        orElse: () => WeightUnit.kg,
      ),
      dimensions: json['dimensions'] as String?,
      commodityType: json['commodity_type'] as String?,
      specialRequirements: json['special_requirements'] as String?,
      requiresInsurance: json['requires_insurance'] as bool? ?? false,
      insuranceAmount: (json['insurance_amount'] as num?)?.toDouble(),
      requiredDocuments:
          (json['required_documents'] as List<dynamic>?)?.cast<String>(),
      pickupDate: DateTime.parse(json['pickup_date'] as String),
      deliveryDate: DateTime.parse(json['delivery_date'] as String),
      flexibleTiming: json['flexible_timing'] as bool? ?? false,
      pickupInstructions: json['pickup_instructions'] as String?,
      deliveryInstructions: json['delivery_instructions'] as String?,
      budget: (json['budget'] as num).toDouble(),
      currency: json['currency'] as String,
      negotiable: json['negotiable'] as bool? ?? true,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['payment_method'] as String? ?? 'online'),
        orElse: () => PaymentMethod.online,
      ),
      paymentTermsDays: json['payment_terms_days'] as int? ?? 30,
      contactName: json['contact_name'] as String,
      contactPhone: json['contact_phone'] as String,
      contactEmail: json['contact_email'] as String,
      alternateContactName: json['alternate_contact_name'] as String?,
      alternateContactPhone: json['alternate_contact_phone'] as String?,
      bidCount: json['bid_count'] as int? ?? 0,
      lowestBid: (json['lowest_bid'] as num?)?.toDouble(),
      highestBid: (json['highest_bid'] as num?)?.toDouble(),
      awardedBidId: json['awarded_bid_id'] as String?,
      awardedTransporterId: json['awarded_transporter_id'] as String?,
      biddingEndDate: json['bidding_end_date'] != null
          ? DateTime.parse(json['bidding_end_date'] as String)
          : null,
      notes: json['notes'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)?.cast<String>(),
      cancellationReason: json['cancellation_reason'] as String?,
      expiryReason: json['expiry_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        shipperId,
        companyId,
        type,
        status,
        origin,
        originCity,
        originState,
        originCountry,
        originPostalCode,
        originLatitude,
        originLongitude,
        destination,
        destinationCity,
        destinationState,
        destinationCountry,
        destinationPostalCode,
        destinationLatitude,
        destinationLongitude,
        weight,
        weightUnit,
        dimensions,
        commodityType,
        specialRequirements,
        requiresInsurance,
        insuranceAmount,
        requiredDocuments,
        pickupDate,
        deliveryDate,
        flexibleTiming,
        pickupInstructions,
        deliveryInstructions,
        budget,
        currency,
        negotiable,
        paymentMethod,
        paymentTermsDays,
        contactName,
        contactPhone,
        contactEmail,
        alternateContactName,
        alternateContactPhone,
        bidCount,
        lowestBid,
        highestBid,
        awardedBidId,
        awardedTransporterId,
        biddingEndDate,
        notes,
        attachments,
        cancellationReason,
        expiryReason,
        createdAt,
        updatedAt,
      ];
}

/// Payment method enumeration
enum PaymentMethod {
  cash,
  online,
  bankTransfer,
  cheque,
  credit,
  escrow,
}
