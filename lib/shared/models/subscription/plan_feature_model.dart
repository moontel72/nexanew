// File: lib/features/nexa_admin/data/models/subscription/plan_feature_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'plan_type.dart';

part 'plan_feature_model.freezed.dart';

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

/// Plan Feature Model
/// Represents a feature or permission included in a subscription plan
@Freezed(fromJson: false, toJson: false)
abstract class PlanFeature with _$PlanFeature {
  const PlanFeature._();

  const factory PlanFeature({
    /// Unique identifier for the feature
    @JsonKey(name: 'id') required String id,

    /// Name of the feature
    @JsonKey(name: 'name') required String name,

    /// Description of the feature
    @JsonKey(name: 'description') required String description,

    /// Type of feature (Core, Advanced, Enterprise, Custom)
    @JsonKey(name: 'type') required FeatureType type,

    /// Whether this feature is included in the plan
    @JsonKey(name: 'is_included') @Default(true) bool isIncluded,

    /// Icon name for the feature (from Material Icons)
    @JsonKey(name: 'icon') @Default('check_circle') String icon,

    /// Sort order for display
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,

    /// Whether this feature is a highlight feature
    @JsonKey(name: 'is_highlight') @Default(false) bool isHighlight,

    /// Additional metadata for the feature
    @JsonKey(name: 'metadata') @Default({}) Map<String, dynamic> metadata,

    /// Date when the feature was created
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Date when the feature was last updated
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _PlanFeature;

  factory PlanFeature.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for all fields
    final id =
        json['id']?.toString() ?? json['feature_id']?.toString() ?? 'unknown';
    final name = json['name']?.toString() ?? 'Unknown Feature';
    final description = json['description']?.toString() ?? '';
    final type = _parseFeatureType(json['type']);
    final isIncluded =
        json['is_included'] == true || json['isIncluded'] == true;
    final icon = json['icon']?.toString() ?? 'check_circle';
    final sortOrder = (json['sort_order'] as num?)?.toInt() ?? 0;
    final isHighlight = json['is_highlight'] == true;
    final metadataRaw = json['metadata'];
    final metadata = (metadataRaw is Map)
        ? Map<String, dynamic>.from(metadataRaw)
        : const <String, dynamic>{};
    final createdAt = _parseDateTime(json['created_at']) ?? DateTime.now();
    final updatedAt = _parseDateTime(json['updated_at']) ?? DateTime.now();

    return PlanFeature(
      id: id,
      name: name,
      description: description,
      type: type,
      isIncluded: isIncluded,
      icon: icon,
      sortOrder: sortOrder,
      isHighlight: isHighlight,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts the PlanFeature to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'is_included': isIncluded,
      'icon': icon,
      'sort_order': sortOrder,
      'is_highlight': isHighlight,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Predefined features for NexaTrace system
class PredefinedFeatures {
  // Core Features (Available in all plans)
  static PlanFeature get basicQrScanning => PlanFeature(
        id: 'feature_basic_qr',
        name: 'Basic QR Code Scanning',
        description: 'Basic QR code scanning functionality',
        type: FeatureType.core,
        isIncluded: true,
        icon: 'qr_code_scanner',
        sortOrder: 1,
        isHighlight: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get manualVerification => PlanFeature(
        id: 'feature_manual_verification',
        name: 'Manual Product Verification',
        description: 'Manual verification of products',
        type: FeatureType.core,
        isIncluded: true,
        icon: 'verified',
        sortOrder: 2,
        isHighlight: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get emailSupport => PlanFeature(
        id: 'feature_email_support',
        name: 'Email Support',
        description: 'Email support with 48-hour response time',
        type: FeatureType.core,
        isIncluded: true,
        icon: 'email',
        sortOrder: 3,
        isHighlight: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get mobileAppAccess => PlanFeature(
        id: 'feature_mobile_app',
        name: 'Mobile App Access',
        description: 'Access to mobile applications',
        type: FeatureType.core,
        isIncluded: true,
        icon: 'phone_iphone',
        sortOrder: 4,
        isHighlight: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get basicReports => PlanFeature(
        id: 'feature_basic_reports',
        name: 'Basic Reports',
        description: 'Basic reporting functionality',
        type: FeatureType.core,
        isIncluded: true,
        icon: 'assessment',
        sortOrder: 5,
        isHighlight: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  // Advanced Features (Available in Basic+ plans)
  static PlanFeature get zohoIntegration => PlanFeature(
        id: 'feature_zoho_integration',
        name: 'Zoho Sheets Integration',
        description: 'Integration with Zoho Sheets for data sync',
        type: FeatureType.advanced,
        isIncluded: false,
        icon: 'table_chart',
        sortOrder: 10,
        isHighlight: true,
        metadata: {
          'available_from': 'basic',
          'integration_type': 'sheets',
          'sync_frequency': 'realtime',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get basicApiAccess => PlanFeature(
        id: 'feature_basic_api',
        name: 'Basic API Access',
        description: 'Basic API access with 1000 calls per day',
        type: FeatureType.advanced,
        isIncluded: false,
        icon: 'api',
        sortOrder: 11,
        isHighlight: true,
        metadata: {
          'available_from': 'basic',
          'daily_limit': 1000,
          'rate_limit': '1000/day',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get advancedQrCustomization => PlanFeature(
        id: 'feature_advanced_qr',
        name: 'Advanced QR Customization',
        description: 'Advanced QR code customization options',
        type: FeatureType.advanced,
        isIncluded: false,
        icon: 'qr_code_2',
        sortOrder: 12,
        isHighlight: false,
        metadata: {
          'available_from': 'basic',
          'customization_options': ['colors', 'logos', 'frames'],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get batchCodeGeneration => PlanFeature(
        id: 'feature_batch_generation',
        name: 'Batch Code Generation',
        description: 'Batch code generation functionality',
        type: FeatureType.advanced,
        isIncluded: false,
        icon: 'batch_prediction',
        sortOrder: 13,
        isHighlight: false,
        metadata: {'available_from': 'basic', 'batch_size_limit': 10000},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get chatSupport => PlanFeature(
        id: 'feature_chat_support',
        name: 'Chat Support',
        description: 'Chat support with 24-hour response time',
        type: FeatureType.advanced,
        isIncluded: false,
        icon: 'chat',
        sortOrder: 14,
        isHighlight: false,
        metadata: {'available_from': 'basic', 'response_time': '24h'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  // Enterprise Features (Available in Standard+ plans)
  static PlanFeature get gpsAttendance => PlanFeature(
        id: 'feature_gps_attendance',
        name: 'GPS Attendance',
        description: 'GPS-based attendance tracking for employees',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'location_on',
        sortOrder: 20,
        isHighlight: true,
        metadata: {
          'available_from': 'standard',
          'tracking_type': 'geofencing',
          'accuracy': 'high',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get salaryManagement => PlanFeature(
        id: 'feature_salary_management',
        name: 'Salary Management',
        description: 'Employee salary management system',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'payments',
        sortOrder: 21,
        isHighlight: true,
        metadata: {
          'available_from': 'standard',
          'payroll_integration': true,
          'tax_calculation': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get bonusCalculation => PlanFeature(
        id: 'feature_bonus_calculation',
        name: 'Bonus Calculation',
        description: 'Employee bonus calculation system',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'attach_money',
        sortOrder: 22,
        isHighlight: false,
        metadata: {
          'available_from': 'standard',
          'calculation_method': 'performance_based',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get advancedZohoIntegration => PlanFeature(
        id: 'feature_advanced_zoho',
        name: 'Advanced Zoho Integration',
        description:
            'Advanced integration with Zoho suite (Books, People, Analytics)',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'integration_instructions',
        sortOrder: 23,
        isHighlight: true,
        metadata: {
          'available_from': 'standard',
          'integrations': ['zoho_books', 'zoho_people', 'zoho_analytics'],
          'sync_type': 'bidirectional',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get prioritySupport => PlanFeature(
        id: 'feature_priority_support',
        name: 'Priority Support',
        description: 'Priority support with 12-hour response time',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'priority_high',
        sortOrder: 24,
        isHighlight: false,
        metadata: {
          'available_from': 'standard',
          'response_time': '12h',
          'channels': ['email', 'chat', 'phone'],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  // Premium Features (Available in Premium+ plans)
  static PlanFeature get multiCompanyControl => PlanFeature(
        id: 'feature_multi_company',
        name: 'Multi-Company Control',
        description: 'Manage multiple companies from a single dashboard',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'corporate_fare',
        sortOrder: 30,
        isHighlight: true,
        metadata: {
          'available_from': 'premium',
          'max_companies': 'unlimited',
          'unified_dashboard': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get fullApiAccess => PlanFeature(
        id: 'feature_full_api',
        name: 'Full API Access',
        description: 'Full API access with unlimited calls',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'api',
        sortOrder: 31,
        isHighlight: true,
        metadata: {
          'available_from': 'premium',
          'rate_limit': 'unlimited',
          'endpoints': 'all',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get gpsRealTimeTracking => PlanFeature(
        id: 'feature_gps_tracking',
        name: 'GPS Real-time Tracking',
        description: 'Real-time GPS tracking for drivers and deliveries',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'gps_fixed',
        sortOrder: 32,
        isHighlight: true,
        metadata: {
          'available_from': 'premium',
          'tracking_type': 'realtime',
          'update_frequency': '5s',
          'features': ['geofence_alerts', 'route_history', 'eta_prediction'],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get whiteLabeling => PlanFeature(
        id: 'feature_white_label',
        name: 'White-labeling',
        description: 'Full white-labeling with custom branding',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'branding_watermark',
        sortOrder: 33,
        isHighlight: true,
        metadata: {
          'available_from': 'premium',
          'customization_options': [
            'logo',
            'colors',
            'domain',
            'email_templates'
          ],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get support247 => PlanFeature(
        id: 'feature_247_support',
        name: '24/7 Priority Support',
        description: '24/7 priority support with 4-hour response time',
        type: FeatureType.enterprise,
        isIncluded: false,
        icon: 'support_agent',
        sortOrder: 34,
        isHighlight: false,
        metadata: {
          'available_from': 'premium',
          'response_time': '4h',
          'availability': '24/7',
          'channels': ['email', 'chat', 'phone', 'video_call'],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  // Custom Features (For custom plans)
  static PlanFeature get sapIntegration => PlanFeature(
        id: 'feature_sap_integration',
        name: 'SAP Integration',
        description: 'Integration with SAP ERP system',
        type: FeatureType.custom,
        isIncluded: false,
        icon: 'integration_instructions',
        sortOrder: 40,
        isHighlight: true,
        metadata: {
          'plan_type': 'custom',
          'integration_type': 'sap',
          'complexity': 'high',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get oracleIntegration => PlanFeature(
        id: 'feature_oracle_integration',
        name: 'Oracle ERP Integration',
        description: 'Integration with Oracle ERP system',
        type: FeatureType.custom,
        isIncluded: false,
        icon: 'integration_instructions',
        sortOrder: 41,
        isHighlight: true,
        metadata: {
          'plan_type': 'custom',
          'integration_type': 'oracle',
          'complexity': 'high',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get dedicatedInfrastructure => PlanFeature(
        id: 'feature_dedicated_infra',
        name: 'Dedicated Infrastructure',
        description: 'Dedicated infrastructure with SLA guarantees',
        type: FeatureType.custom,
        isIncluded: false,
        icon: 'cloud',
        sortOrder: 42,
        isHighlight: true,
        metadata: {
          'plan_type': 'custom',
          'infrastructure_type': 'dedicated',
          'sla': '99.9%',
          'deployment_options': ['private_cloud', 'on_premise'],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlanFeature get customDevelopment => PlanFeature(
        id: 'feature_custom_dev',
        name: 'Custom Development',
        description: 'Custom feature development and integration',
        type: FeatureType.custom,
        isIncluded: false,
        icon: 'code',
        sortOrder: 43,
        isHighlight: true,
        metadata: {
          'plan_type': 'custom',
          'development_type': 'custom',
          'scope': 'negotiable',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Get all predefined features
  static List<PlanFeature> get allFeatures => [
        basicQrScanning,
        manualVerification,
        emailSupport,
        mobileAppAccess,
        basicReports,
        zohoIntegration,
        basicApiAccess,
        advancedQrCustomization,
        batchCodeGeneration,
        chatSupport,
        gpsAttendance,
        salaryManagement,
        bonusCalculation,
        advancedZohoIntegration,
        prioritySupport,
        multiCompanyControl,
        fullApiAccess,
        gpsRealTimeTracking,
        whiteLabeling,
        support247,
        sapIntegration,
        oracleIntegration,
        dedicatedInfrastructure,
        customDevelopment,
      ];

  /// Get features by plan type
  static List<PlanFeature> getFeaturesByPlanType(PlanType planType) {
    switch (planType) {
      case PlanType.free:
        return [
          basicQrScanning,
          manualVerification,
          emailSupport,
          mobileAppAccess,
          basicReports,
        ];
      case PlanType.basic:
        return [
          basicQrScanning,
          manualVerification,
          emailSupport,
          mobileAppAccess,
          basicReports,
          zohoIntegration,
          basicApiAccess,
          advancedQrCustomization,
          batchCodeGeneration,
          chatSupport,
        ];
      case PlanType.standard:
        return [
          basicQrScanning,
          manualVerification,
          emailSupport,
          mobileAppAccess,
          basicReports,
          zohoIntegration,
          basicApiAccess,
          advancedQrCustomization,
          batchCodeGeneration,
          chatSupport,
          gpsAttendance,
          salaryManagement,
          bonusCalculation,
          advancedZohoIntegration,
          prioritySupport,
        ];
      case PlanType.premium:
        return [
          basicQrScanning,
          manualVerification,
          emailSupport,
          mobileAppAccess,
          basicReports,
          zohoIntegration,
          basicApiAccess,
          advancedQrCustomization,
          batchCodeGeneration,
          chatSupport,
          gpsAttendance,
          salaryManagement,
          bonusCalculation,
          advancedZohoIntegration,
          prioritySupport,
          multiCompanyControl,
          fullApiAccess,
          gpsRealTimeTracking,
          whiteLabeling,
          support247,
        ];
      case PlanType.custom:
        return allFeatures; // Custom plans can include any feature
    }
  }

  /// Get highlight features for a plan type
  static List<PlanFeature> getHighlightFeatures(PlanType planType) {
    return getFeaturesByPlanType(
      planType,
    ).where((feature) => feature.isHighlight).toList();
  }
}
