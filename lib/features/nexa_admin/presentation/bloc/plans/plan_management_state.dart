part of 'plan_management_bloc.dart';

/// State for plan management BLoC
@freezed
abstract class PlanManagementState with _$PlanManagementState {
  /// Initial state - no data loaded
  const factory PlanManagementState.initial() = _Initial;

  /// Loading state - data is being fetched
  const factory PlanManagementState.loading() = _Loading;

  /// Loaded state - plans data is available
  const factory PlanManagementState.loaded({
    required List<Plan> plans,
    required int total,
    required int page,
    required int perPage,
    required int totalPages,
    required String search,
    String? type,
    String? status,
    required String sortBy,
    required String sortOrder,
    required PlanStatistics? statistics,
    required Map<String, List<PlanFeature>> availableFeatures,
  }) = _Loaded;

  /// Plan detail loaded state
  const factory PlanManagementState.planDetailLoaded({
    required Plan plan,
    required Map<String, List<PlanFeature>> availableFeatures,
  }) = _PlanDetailLoaded;

  /// Plan created state
  const factory PlanManagementState.planCreated({
    required Plan plan,
    required String message,
  }) = _PlanCreated;

  /// Plan updated state
  const factory PlanManagementState.planUpdated({
    required Plan plan,
    required String message,
  }) = _PlanUpdated;

  /// Plan deleted state
  const factory PlanManagementState.planDeleted({
    required String planId,
    required String message,
  }) = _PlanDeleted;

  /// Plan duplicated state
  const factory PlanManagementState.planDuplicated({
    required Plan plan,
    required String message,
  }) = _PlanDuplicated;

  /// Plan status updated state
  const factory PlanManagementState.planStatusUpdated({
    required String planId,
    required PlanStatus newStatus,
    required String message,
  }) = _PlanStatusUpdated;

  /// Exporting state - plans are being exported
  const factory PlanManagementState.exporting() = _Exporting;

  /// Exported state - plans export completed
  const factory PlanManagementState.exported({
    required String filePath,
    required String message,
  }) = _Exported;

  /// Error state - operation failed
  const factory PlanManagementState.error({
    required String message,
    @Default(false) bool isNetworkError,
    @Default(false) bool isServerError,
    @Default(false) bool isValidationError,
    StackTrace? stackTrace,
  }) = _Error;
}

/// Plan statistics model
class PlanStatistics extends Equatable {
  final int totalPlans;
  final int activePlans;
  final int draftPlans;
  final int inactivePlans;
  final Map<String, int> planTypes;
  final int featuredPlans;
  final int popularPlans;
  final List<PlanUsage> topPlans;

  const PlanStatistics({
    required this.totalPlans,
    required this.activePlans,
    required this.draftPlans,
    required this.inactivePlans,
    required this.planTypes,
    required this.featuredPlans,
    required this.popularPlans,
    required this.topPlans,
  });

  /// Create PlanStatistics from JSON
  factory PlanStatistics.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    // Parse plan types
    final planTypesMap = <String, int>{};
    final planTypesJson = data['plan_types'] as Map<String, dynamic>? ?? {};
    planTypesJson.forEach((key, value) {
      planTypesMap[key] = value as int;
    });

    // Parse top plans
    final topPlansList = <PlanUsage>[];
    final topPlansJson = data['top_plans'] as List<dynamic>? ?? [];
    for (final planJson in topPlansJson) {
      topPlansList.add(PlanUsage.fromJson(planJson as Map<String, dynamic>));
    }

    return PlanStatistics(
      totalPlans: data['total_plans'] as int,
      activePlans: data['active_plans'] as int,
      draftPlans: data['draft_plans'] as int,
      inactivePlans: data['inactive_plans'] as int,
      planTypes: planTypesMap,
      featuredPlans: data['featured_plans'] as int,
      popularPlans: data['popular_plans'] as int,
      topPlans: topPlansList,
    );
  }

  /// Convert PlanStatistics to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_plans': totalPlans,
      'active_plans': activePlans,
      'draft_plans': draftPlans,
      'inactive_plans': inactivePlans,
      'plan_types': planTypes,
      'featured_plans': featuredPlans,
      'popular_plans': popularPlans,
      'top_plans': topPlans.map((plan) => plan.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        totalPlans,
        activePlans,
        draftPlans,
        inactivePlans,
        planTypes,
        featuredPlans,
        popularPlans,
        topPlans,
      ];

  @override
  bool get stringify => true;
}

/// Plan usage statistics
class PlanUsage extends Equatable {
  final String id;
  final String name;
  final String type;
  final int companyCount;
  final double price;

  const PlanUsage({
    required this.id,
    required this.name,
    required this.type,
    required this.companyCount,
    required this.price,
  });

  /// Create PlanUsage from JSON
  factory PlanUsage.fromJson(Map<String, dynamic> json) {
    return PlanUsage(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      companyCount: json['company_count'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Convert PlanUsage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'company_count': companyCount,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, name, type, companyCount, price];

  @override
  bool get stringify => true;
}

/// Plan filter options
class PlanFilterOptions extends Equatable {
  final List<String> statusOptions;
  final List<String> typeOptions;
  final List<String> billingCycleOptions;
  final List<String> currencyOptions;

  const PlanFilterOptions({
    required this.statusOptions,
    required this.typeOptions,
    required this.billingCycleOptions,
    required this.currencyOptions,
  });

  /// Default filter options
  factory PlanFilterOptions.defaultOptions() {
    return PlanFilterOptions(
      statusOptions: const ['active', 'inactive', 'draft'],
      typeOptions: const ['free', 'basic', 'standard', 'premium', 'custom'],
      billingCycleOptions: const ['monthly', 'quarterly', 'yearly', 'one_time'],
      currencyOptions: const ['USD', 'EUR', 'GBP', 'INR', 'AED'],
    );
  }

  @override
  List<Object?> get props => [
        statusOptions,
        typeOptions,
        billingCycleOptions,
        currencyOptions,
      ];

  @override
  bool get stringify => true;
}
