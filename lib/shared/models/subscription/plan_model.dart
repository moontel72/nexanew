// File: lib/features/nexa_admin/data/models/subscription/plan_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'plan_type.dart';
import 'plan_feature_model.dart';

part 'plan_model.freezed.dart';

/// Helper function to parse features from various backend formats
List<PlanFeature> _parseFeatures(dynamic featuresJson) {
  if (featuresJson == null) {
    return [];
  }

  if (featuresJson is! List) {
    return [];
  }

  final List<PlanFeature> features = [];
  for (final item in featuresJson) {
    if (item == null) continue;

    // Case 1: Full object format - parse normally
    if (item is Map) {
      try {
        features.add(PlanFeature.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        // If parsing fails, create a minimal feature with available data
        features.add(
          PlanFeature(
            id: item['id']?.toString() ??
                item['feature_id']?.toString() ??
                'unknown',
            name: item['name']?.toString() ?? 'Unknown Feature',
            description: item['description']?.toString() ?? '',
            type: _parseFeatureType(item['type']),
            isIncluded:
                item['is_included'] == true || item['isIncluded'] == true,
            createdAt: _parseDateTime(item['created_at']) ?? DateTime.now(),
            updatedAt: _parseDateTime(item['updated_at']) ?? DateTime.now(),
          ),
        );
      }
    }
    // Case 2: Simple ID format (int or string) - create minimal feature
    else if (item is int || item is String) {
      final id = item.toString();
      features.add(
        PlanFeature(
          id: id,
          name: id,
          description: '',
          type: FeatureType.core,
          isIncluded: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  return features;
}

/// Helper function to parse FeatureType with fallback
FeatureType _parseFeatureType(dynamic value) {
  if (value == null) return FeatureType.core;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'core':
      return FeatureType.core;
    case 'advanced':
      return FeatureType.advanced;
    case 'enterprise':
      return FeatureType.enterprise;
    case 'custom':
      return FeatureType.custom;
    default:
      return FeatureType.core;
  }
}

/// Helper function to parse DateTime with fallback
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  try {
    if (value is String) {
      return DateTime.tryParse(value);
    }
  } catch (_) {
    // Fall through to return null
  }
  return null;
}

/// Helper function to parse PlanType with fallback
PlanType _parsePlanType(dynamic value) {
  if (value == null) return PlanType.basic;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'free':
      return PlanType.free;
    case 'basic':
      return PlanType.basic;
    case 'standard':
      return PlanType.standard;
    case 'premium':
      return PlanType.premium;
    case 'custom':
      return PlanType.custom;
    default:
      return PlanType.basic;
  }
}

/// Helper function to parse PlanStatus with fallback
PlanStatus _parsePlanStatus(dynamic value) {
  if (value == null) return PlanStatus.active;

  final stringValue = value.toString().toLowerCase();
  switch (stringValue) {
    case 'active':
      return PlanStatus.active;
    case 'inactive':
      return PlanStatus.inactive;
    case 'archived':
      return PlanStatus.archived;
    default:
      return PlanStatus.active;
  }
}

/// Helper function to parse UserLimits with fallback
UserLimits _parseUserLimits(dynamic value) {
  if (value == null || value is! Map) {
    return const UserLimits(
      storeKeepers: 1,
      drivers: 1,
      adminUsers: 1,
      activeProducts: 1,
    );
  }

  final map = Map<String, dynamic>.from(value);
  try {
    return UserLimits.fromJson(map);
  } catch (_) {
    return UserLimits(
      storeKeepers: (map['store_keepers'] as num?)?.toInt() ?? 1,
      drivers: (map['drivers'] as num?)?.toInt() ?? 1,
      adminUsers: (map['admin_users'] as num?)?.toInt() ?? 1,
      activeProducts: (map['active_products'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Plan Model
/// Represents a subscription plan in the NexaTrace system
@Freezed(fromJson: false, toJson: false)
abstract class Plan with _$Plan {
  const Plan._();

  const factory Plan({
    /// Unique identifier for the plan
    @JsonKey(name: 'id') required String id,

    /// Name of the plan (e.g., "Free Plan", "Basic Plan")
    @JsonKey(name: 'name') required String name,

    /// Type of the plan (Free, Basic, Standard, Premium, Custom)
    @JsonKey(name: 'type') required PlanType type,

    /// Description of the plan
    @JsonKey(name: 'description') required String description,

    /// Monthly price of the plan
    @JsonKey(name: 'monthly_price') required double monthlyPrice,

    /// Yearly price of the plan
    @JsonKey(name: 'yearly_price') required double yearlyPrice,

    /// Currency of the price (e.g., 'USD', 'EUR')
    @Default('USD') String currency,

    /// Billing cycle (e.g., 'monthly', 'yearly')
    @JsonKey(name: 'billing_cycle') required String billingCycle,

    /// Current status of the plan
    required PlanStatus status,

    /// Whether the plan is featured
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,

    /// Whether the plan is marked as popular
    @JsonKey(name: 'is_popular') @Default(false) bool isPopular,

    /// Order in which the plan is displayed
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,

    /// List of features included in the plan
    required List<PlanFeature> features,

    /// Plan limits (e.g., max users, max codes)
    @Default({}) Map<String, dynamic> limits,

    /// Metadata for the plan
    Map<String, dynamic>? metadata,

    /// User limits for this plan
    @JsonKey(name: 'user_limits') required UserLimits userLimits,

    /// Storage limit in GB
    @JsonKey(name: 'storage_gb') @Default(1) int storageGb,

    /// Daily API call limit
    @JsonKey(name: 'daily_api_calls') @Default(0) int dailyApiCalls,

    /// Whether the plan is recommended
    @JsonKey(name: 'is_recommended') @Default(false) bool isRecommended,

    /// Number of companies using this plan
    @JsonKey(name: 'company_count') @Default(0) int companyCount,

    /// Date when the plan was created
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Date when the plan was last updated
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Date when the plan was archived (if applicable)
    @JsonKey(name: 'archived_at') DateTime? archivedAt,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for all fields
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final type = _parsePlanType(json['type']);
    final description = json['description']?.toString() ?? '';
    final monthlyPrice = (json['monthly_price'] as num?)?.toDouble() ?? 0.0;
    final yearlyPrice = (json['yearly_price'] as num?)?.toDouble() ?? 0.0;
    final currency = json['currency']?.toString() ?? 'USD';
    final metadataRaw = json['metadata'];
    final metadata =
        (metadataRaw is Map) ? Map<String, dynamic>.from(metadataRaw) : null;
    final billingCycle =
        json['billing_cycle']?.toString() ??
        metadata?['billing_cycle']?.toString() ??
        'monthly';
    final status = _parsePlanStatus(json['status']);
    final isFeatured =
        json['is_featured'] == true || metadata?['is_featured'] == true;
    final isPopular =
        json['is_popular'] == true || metadata?['is_popular'] == true;
    final sortOrder =
        (json['sort_order'] as num?)?.toInt() ??
        (metadata?['sort_order'] as num?)?.toInt() ??
        0;
    final features = _parseFeatures(json['features']);
    final limitsRaw = json['limits'];
    final limits = (limitsRaw is Map)
        ? Map<String, dynamic>.from(limitsRaw)
        : <String, dynamic>{
            'monthly_unit_codes': (json['monthly_unit_codes'] as num?)?.toInt(),
            'monthly_packet_codes':
                (json['monthly_packet_codes'] as num?)?.toInt(),
            'monthly_carton_codes':
                (json['monthly_carton_codes'] as num?)?.toInt(),
            'monthly_bundle_codes':
                (json['monthly_bundle_codes'] as num?)?.toInt(),
            'max_users': (json['max_users'] as num?)?.toInt(),
            'max_stores': (json['max_stores'] as num?)?.toInt(),
            'max_drivers': (json['max_drivers'] as num?)?.toInt(),
            if (metadata?['transport_connections_per_month'] != null)
              'transport_connections_per_month':
                  metadata?['transport_connections_per_month'],
            if (metadata?['max_loads_per_month'] != null)
              'max_loads_per_month': metadata?['max_loads_per_month'],
          };

    final userLimitsRaw = json['user_limits'];
    final userLimits = userLimitsRaw is Map
        ? _parseUserLimits(userLimitsRaw)
        : _parseUserLimits({
            'store_keepers': (json['max_stores'] as num?)?.toInt() ?? 1,
            'drivers': (json['max_drivers'] as num?)?.toInt() ?? 1,
            'admin_users': (json['max_users'] as num?)?.toInt() ?? 1,
            'active_products': 1,
          });
    final storageGb = (json['storage_gb'] as num?)?.toInt() ?? 1;
    final dailyApiCalls = (json['daily_api_calls'] as num?)?.toInt() ?? 0;
    final isRecommended = json['is_recommended'] == true;
    final companyCount = (json['company_count'] as num?)?.toInt() ?? 0;
    final createdAt = _parseDateTime(json['created_at']) ?? DateTime.now();
    final updatedAt = _parseDateTime(json['updated_at']) ?? DateTime.now();
    final archivedAt = _parseDateTime(json['archived_at']);

    return Plan(
      id: id,
      name: name,
      type: type,
      description: description,
      monthlyPrice: monthlyPrice,
      yearlyPrice: yearlyPrice,
      currency: currency,
      billingCycle: billingCycle,
      status: status,
      isFeatured: isFeatured,
      isPopular: isPopular,
      sortOrder: sortOrder,
      features: features,
      limits: limits,
      metadata: metadata,
      userLimits: userLimits,
      storageGb: storageGb,
      dailyApiCalls: dailyApiCalls,
      isRecommended: isRecommended,
      companyCount: companyCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      archivedAt: archivedAt,
    );
  }

  /// Converts the Plan to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'monthly_price': monthlyPrice,
      'yearly_price': yearlyPrice,
      'currency': currency,
      'billing_cycle': billingCycle,
      'status': status.name,
      'is_featured': isFeatured,
      'is_popular': isPopular,
      'sort_order': sortOrder,
      'features': features.map((f) => f.toJson()).toList(),
      'limits': limits,
      'metadata': metadata,
      'user_limits': userLimits.toJson(),
      'storage_gb': storageGb,
      'daily_api_calls': dailyApiCalls,
      'is_recommended': isRecommended,
      'company_count': companyCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
    };
  }
}

/// Plan Limits Model
/// Represents code generation limits for a subscription plan
@Freezed(fromJson: false, toJson: false)
abstract class PlanLimits with _$PlanLimits {
  const PlanLimits._();

  const factory PlanLimits({
    /// Monthly unit code limit
    @JsonKey(name: 'monthly_unit_codes') required int monthlyUnitCodes,

    /// Monthly packet code limit
    @JsonKey(name: 'monthly_packet_codes') required int monthlyPacketCodes,

    /// Monthly carton code limit
    @JsonKey(name: 'monthly_carton_codes') required int monthlyCartonCodes,

    /// Monthly bundle code limit
    @JsonKey(name: 'monthly_bundle_codes') required int monthlyBundleCodes,

    /// Whether limits are custom (for custom plans)
    @JsonKey(name: 'is_custom') @Default(false) bool isCustom,
  }) = _PlanLimits;

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      monthlyUnitCodes: (json['monthly_unit_codes'] as num?)?.toInt() ?? 0,
      monthlyPacketCodes: (json['monthly_packet_codes'] as num?)?.toInt() ?? 0,
      monthlyCartonCodes: (json['monthly_carton_codes'] as num?)?.toInt() ?? 0,
      monthlyBundleCodes: (json['monthly_bundle_codes'] as num?)?.toInt() ?? 0,
      isCustom: json['is_custom'] == true,
    );
  }

  /// Converts the PlanLimits to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'monthly_unit_codes': monthlyUnitCodes,
      'monthly_packet_codes': monthlyPacketCodes,
      'monthly_carton_codes': monthlyCartonCodes,
      'monthly_bundle_codes': monthlyBundleCodes,
      'is_custom': isCustom,
    };
  }
}

/// User Limits Model
/// Represents user and resource limits for a subscription plan
@Freezed(fromJson: false, toJson: false)
abstract class UserLimits with _$UserLimits {
  const UserLimits._();

  const factory UserLimits({
    /// Maximum number of store keepers
    @JsonKey(name: 'store_keepers') required int storeKeepers,

    /// Maximum number of drivers
    @JsonKey(name: 'drivers') required int drivers,

    /// Maximum number of admin users
    @JsonKey(name: 'admin_users') required int adminUsers,

    /// Maximum number of active products
    @JsonKey(name: 'active_products') required int activeProducts,

    /// Whether user limits are custom (for custom plans)
    @JsonKey(name: 'is_custom') @Default(false) bool isCustom,
  }) = _UserLimits;

  factory UserLimits.fromJson(Map<String, dynamic> json) {
    return UserLimits(
      storeKeepers: (json['store_keepers'] as num?)?.toInt() ?? 1,
      drivers: (json['drivers'] as num?)?.toInt() ?? 1,
      adminUsers: (json['admin_users'] as num?)?.toInt() ?? 1,
      activeProducts: (json['active_products'] as num?)?.toInt() ?? 1,
      isCustom: json['is_custom'] == true,
    );
  }

  /// Converts the UserLimits to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'store_keepers': storeKeepers,
      'drivers': drivers,
      'admin_users': adminUsers,
      'active_products': activeProducts,
      'is_custom': isCustom,
    };
  }
}

/// Predefined plans for NexaTrace system
class PredefinedPlans {
  /// Free Plan
  static Plan get freePlan => Plan(
        id: 'plan_free',
        name: 'Free Starter',
        type: PlanType.free,
        description: 'Perfect for small factories and individual sellers',
        monthlyPrice: 0.0,
        yearlyPrice: 0.0,
        billingCycle: 'monthly',
        status: PlanStatus.active,
        isFeatured: false,
        isPopular: false,
        sortOrder: 1,
        features: [
          PlanFeature(
            id: 'feature_basic_qr',
            name: 'Basic QR Code Scanning',
            description: 'Basic QR code scanning functionality',
            type: FeatureType.core,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_manual_verification',
            name: 'Manual Product Verification',
            description: 'Manual verification of products',
            type: FeatureType.core,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_email_support',
            name: 'Email Support',
            description: 'Email support with 48-hour response time',
            type: FeatureType.core,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_mobile_app',
            name: 'Mobile App Access',
            description: 'Access to mobile applications',
            type: FeatureType.core,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_basic_reports',
            name: 'Basic Reports',
            description: 'Basic reporting functionality',
            type: FeatureType.core,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        limits: {
          'monthly_unit_codes': 5000,
          'monthly_packet_codes': 500,
          'monthly_carton_codes': 90,
          'monthly_bundle_codes': 30,
          'is_custom': false,
        },
        userLimits: UserLimits(
          storeKeepers: 1,
          drivers: 1,
          adminUsers: 1,
          activeProducts: 1,
          isCustom: false,
        ),
        storageGb: 1,
        dailyApiCalls: 0,
        isRecommended: false,
        companyCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Basic Plan
  static Plan get basicPlan => Plan(
        id: 'plan_basic',
        name: 'Basic Professional',
        type: PlanType.basic,
        description: 'Advanced features for growing businesses',
        monthlyPrice: 29.99,
        yearlyPrice: 299.99,
        billingCycle: 'monthly',
        status: PlanStatus.active,
        isFeatured: true,
        isPopular: true,
        sortOrder: 2,
        features: [
          PlanFeature(
            id: 'feature_zoho_integration',
            name: 'Zoho Sheets Integration',
            description: 'Integration with Zoho Sheets for data sync',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_basic_api',
            name: 'Basic API Access',
            description: 'Basic API access with 1000 calls per day',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_advanced_qr',
            name: 'Advanced QR Customization',
            description: 'Advanced QR code customization options',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_batch_generation',
            name: 'Batch Code Generation',
            description: 'Batch code generation functionality',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_chat_support',
            name: 'Chat Support',
            description: 'Chat support with 24-hour response time',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        limits: {
          'monthly_unit_codes': 50000,
          'monthly_packet_codes': 5000,
          'monthly_carton_codes': 900,
          'monthly_bundle_codes': 300,
          'is_custom': false,
        },
        userLimits: UserLimits(
          storeKeepers: 5,
          drivers: 3,
          adminUsers: 2,
          activeProducts: 50,
          isCustom: false,
        ),
        storageGb: 10,
        dailyApiCalls: 1000,
        isRecommended: true,
        companyCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Standard Plan
  static Plan get standardPlan => Plan(
        id: 'plan_standard',
        name: 'Standard Plan',
        type: PlanType.standard,
        description:
            'Standard plan for medium businesses. Includes GPS attendance, salary management, and bonus calculation.',
        monthlyPrice: 149.0,
        yearlyPrice: 1499.0,
        currency: 'USD',
        billingCycle: 'monthly',
        status: PlanStatus.active,
        features: [
          PlanFeature(
            id: 'feature_gps_attendance',
            name: 'GPS Attendance',
            description: 'GPS-based attendance tracking',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_salary_management',
            name: 'Salary Management',
            description: 'Employee salary management system',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_bonus_calculation',
            name: 'Bonus Calculation',
            description: 'Employee bonus calculation system',
            type: FeatureType.advanced,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_advanced_zoho',
            name: 'Advanced Zoho Integration',
            description: 'Advanced integration with Zoho suite',
            type: FeatureType.enterprise,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_priority_support',
            name: 'Priority Support',
            description: 'Priority support with 12-hour response time',
            type: FeatureType.enterprise,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        limits: {
          'monthly_unit_codes': 200000,
          'monthly_packet_codes': 20000,
          'monthly_carton_codes': 3600,
          'monthly_bundle_codes': 1200,
          'is_custom': false,
        },
        userLimits: UserLimits(
          storeKeepers: 20,
          drivers: 15,
          adminUsers: 5,
          activeProducts: 500,
          isCustom: false,
        ),
        storageGb: 50,
        dailyApiCalls: 10000,
        isRecommended: false,
        companyCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Premium Plan
  static Plan get premiumPlan => Plan(
        id: 'plan_premium',
        name: 'Premium Enterprise',
        type: PlanType.premium,
        description: 'Full control and automation for large factories',
        monthlyPrice: 99.99,
        yearlyPrice: 999.99,
        billingCycle: 'monthly',
        status: PlanStatus.active,
        isFeatured: false,
        isPopular: false,
        sortOrder: 3,
        features: [
          PlanFeature(
            id: 'feature_multi_company',
            name: 'Multi-Company Control',
            description: 'Manage multiple companies from a single dashboard',
            type: FeatureType.enterprise,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_full_api',
            name: 'Full API Access',
            description: 'Full API access with unlimited calls',
            type: FeatureType.enterprise,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_gps_tracking',
            name: 'GPS Real-time Tracking',
            description: 'Real-time GPS tracking for drivers',
            type: FeatureType.enterprise,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_white_label',
            name: 'White-labeling',
            description: 'Full white-labeling with custom branding',
            type: FeatureType.enterprise,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          PlanFeature(
            id: 'feature_247_support',
            name: '24/7 Priority Support',
            description: '24/7 priority support with 4-hour response time',
            type: FeatureType.enterprise,
            isIncluded: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        limits: {
          'monthly_unit_codes': 1000000,
          'monthly_packet_codes': 100000,
          'monthly_carton_codes': 18000,
          'monthly_bundle_codes': 6000,
          'is_custom': false,
        },
        userLimits: UserLimits(
          storeKeepers: 100,
          drivers: 50,
          adminUsers: 20,
          activeProducts: 5000,
          isCustom: false,
        ),
        storageGb: 200,
        dailyApiCalls: 0, // 0 means unlimited
        isRecommended: false,
        companyCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Get all predefined plans
  static List<Plan> get allPlans => [
        freePlan,
        basicPlan,
        standardPlan,
        premiumPlan,
      ];

  /// Get plan by type
  static Plan? getPlanByType(PlanType type) {
    switch (type) {
      case PlanType.free:
        return freePlan;
      case PlanType.basic:
        return basicPlan;
      case PlanType.standard:
        return standardPlan;
      case PlanType.premium:
        return premiumPlan;
      case PlanType.custom:
        return null; // Custom plans are created dynamically
    }
  }
}
