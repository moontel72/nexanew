part of 'plan_management_bloc.dart';

/// Events for plan management BLoC
@freezed
abstract class PlanManagementEvent with _$PlanManagementEvent {
  /// Load all subscription plans
  const factory PlanManagementEvent.loadPlans({
    @Default('') String search,
    String? type,
    String? status,
    @Default('created_at') String sortBy,
    @Default('desc') String sortOrder,
    @Default(1) int page,
    @Default(20) int perPage,
  }) = _LoadPlans;

  /// Load a specific plan by ID
  const factory PlanManagementEvent.loadPlan(String id) = _LoadPlan;

  /// Create a new subscription plan
  const factory PlanManagementEvent.createPlan({
    required String name,
    required String type,
    String? description,
    required double price,
    required String billingCycle,
    required String currency,
    required String status,
    bool? isFeatured,
    bool? isPopular,
    int? sortOrder,
    required Map<String, dynamic> limits,
    List<PlanFeatureInput>? features,
    Map<String, dynamic>? metadata,
  }) = _CreatePlan;

  /// Update an existing plan
  const factory PlanManagementEvent.updatePlan({
    required String id,
    String? name,
    String? type,
    String? description,
    double? price,
    String? billingCycle,
    String? currency,
    String? status,
    bool? isFeatured,
    bool? isPopular,
    int? sortOrder,
    Map<String, dynamic>? limits,
    List<PlanFeatureInput>? features,
    Map<String, dynamic>? metadata,
  }) = _UpdatePlan;

  /// Update plan status
  const factory PlanManagementEvent.updatePlanStatus({
    required String planId,
    required PlanStatus status,
  }) = _UpdatePlanStatus;

  /// Delete a plan
  const factory PlanManagementEvent.deletePlan(String id) = _DeletePlan;

  /// Duplicate a plan
  const factory PlanManagementEvent.duplicatePlan(String id) = _DuplicatePlan;

  /// Load plan statistics
  const factory PlanManagementEvent.loadPlanStatistics() = _LoadPlanStatistics;

  /// Load available plan features
  const factory PlanManagementEvent.loadPlanFeatures() = _LoadPlanFeatures;

  /// Export plans to CSV
  const factory PlanManagementEvent.exportPlans({
    String? search,
    String? type,
    String? status,
  }) = _ExportPlans;

  /// Clear error state
  const factory PlanManagementEvent.clearError() = _ClearError;

  /// Reset to initial state
  const factory PlanManagementEvent.reset() = _Reset;
}

/// Input model for plan features
class PlanFeatureInput extends Equatable {
  final String id;
  final bool isEnabled;
  final int? limit;

  const PlanFeatureInput({required this.id, this.isEnabled = true, this.limit});

  /// Create PlanFeatureInput from JSON
  factory PlanFeatureInput.fromJson(Map<String, dynamic> json) {
    return PlanFeatureInput(
      id: json['id'] as String,
      isEnabled: json['is_enabled'] as bool? ?? true,
      limit: json['limit'] as int?,
    );
  }

  /// Convert PlanFeatureInput to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'is_enabled': isEnabled, 'limit': limit};
  }

  @override
  List<Object?> get props => [id, isEnabled, limit];

  @override
  bool get stringify => true;
}
