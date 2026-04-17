// Subscription Plan Entity for NexaTrace System
// This file defines the SubscriptionPlan entity used throughout the application

import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // 'free', 'basic', 'standard', 'premium', 'custom'
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final String billingCycle; // 'monthly', 'yearly'
  final String status; // 'active', 'inactive', 'archived'
  final bool isFeatured;
  final bool isPopular;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> limits;
  final List<PlanFeature> features;
  final Map<String, dynamic>? metadata;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.billingCycle,
    required this.status,
    required this.isFeatured,
    required this.isPopular,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.limits,
    required this.features,
    this.metadata,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'basic',
      monthlyPrice: (json['monthly_price'] as num?)?.toDouble() ?? 0.0,
      yearlyPrice: (json['yearly_price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      billingCycle: json['billing_cycle']?.toString() ?? 'monthly',
      status: json['status']?.toString() ?? 'active',
      isFeatured: json['is_featured'] ?? false,
      isPopular: json['is_popular'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      limits: Map<String, dynamic>.from(json['limits'] ?? {}),
      features: (json['features'] as List<dynamic>?)
              ?.map((feature) => PlanFeature.fromJson(feature))
              .toList() ??
          [],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'monthly_price': monthlyPrice,
      'yearly_price': yearlyPrice,
      'currency': currency,
      'billing_cycle': billingCycle,
      'status': status,
      'is_featured': isFeatured,
      'is_popular': isPopular,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'limits': limits,
      'features': features.map((feature) => feature.toJson()).toList(),
      'metadata': metadata,
    };
  }

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    double? monthlyPrice,
    double? yearlyPrice,
    String? currency,
    String? billingCycle,
    String? status,
    bool? isFeatured,
    bool? isPopular,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? limits,
    List<PlanFeature>? features,
    Map<String, dynamic>? metadata,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      limits: limits ?? this.limits,
      features: features ?? this.features,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        monthlyPrice,
        yearlyPrice,
        currency,
        billingCycle,
        status,
        isFeatured,
        isPopular,
        sortOrder,
        createdAt,
        updatedAt,
        limits,
        features,
        metadata,
      ];

  // Helper methods
  bool get isActive => status == 'active';
  bool get isFree => type == 'free';
  bool get isCustom => type == 'custom';
  bool get hasYearlyDiscount => yearlyPrice < monthlyPrice * 12;

  double get yearlyDiscountPercentage {
    if (monthlyPrice == 0) return 0;
    final yearlyEquivalent = monthlyPrice * 12;
    return ((yearlyEquivalent - yearlyPrice) / yearlyEquivalent) * 100;
  }

  double getPriceForBillingCycle(String cycle) {
    return cycle == 'yearly' ? yearlyPrice : monthlyPrice;
  }

  bool hasFeature(String featureCode) {
    return features
        .any((feature) => feature.code == featureCode && feature.enabled);
  }

  int getLimit(String limitKey) {
    return (limits[limitKey] as int?) ?? 0;
  }

  bool canUpgradeTo(SubscriptionPlan other) {
    // Simple upgrade logic based on monthly price
    return other.monthlyPrice > monthlyPrice;
  }

  String get displayPrice {
    if (isFree) return 'Free';
    return '\$${monthlyPrice.toStringAsFixed(2)}/month';
  }

  String get displayYearlyPrice {
    if (isFree) return 'Free';
    return '\$${yearlyPrice.toStringAsFixed(2)}/year';
  }
}

class PlanFeature extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final String category;
  final bool enabled;
  final int? limit;
  final String? unit;
  final int sortOrder;
  final bool isPremium;
  final Map<String, dynamic>? metadata;

  const PlanFeature({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.enabled,
    this.limit,
    this.unit,
    required this.sortOrder,
    required this.isPremium,
    this.metadata,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) {
    return PlanFeature(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      enabled: json['enabled'] ?? false,
      limit: json['limit'] as int?,
      unit: json['unit']?.toString(),
      sortOrder: json['sort_order'] ?? 0,
      isPremium: json['is_premium'] ?? false,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'category': category,
      'enabled': enabled,
      'limit': limit,
      'unit': unit,
      'sort_order': sortOrder,
      'is_premium': isPremium,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        category,
        enabled,
        limit,
        unit,
        sortOrder,
        isPremium,
        metadata,
      ];

  // Helper methods
  bool get hasLimit => limit != null;
  bool get isUnlimited => limit == -1;
  String get displayLimit {
    if (!hasLimit) return 'Unlimited';
    if (isUnlimited) return 'Unlimited';
    return '$limit${unit ?? ''}';
  }
}
