part of 'company_management_bloc.dart';

/// State for company management BLoC
@freezed
abstract class CompanyManagementState with _$CompanyManagementState {
  /// Initial state - no data loaded
  const factory CompanyManagementState.initial() = _Initial;

  /// Loading state - data is being fetched
  const factory CompanyManagementState.loading() = _Loading;

  /// Loaded state - companies data is available
  const factory CompanyManagementState.loaded({
    required List<Company> companies,
    required int total,
    required int page,
    required int perPage,
    required int totalPages,
    required String search,
    String? status,
    String? verificationStatus,
    String? country,
    String? planType,
    required String sortBy,
    required String sortOrder,
    required CompanyStatistics? statistics,
    required CompanyFilterOptions filterOptions,
  }) = _Loaded;

  /// Company detail loaded state
  const factory CompanyManagementState.companyDetailLoaded({
    required Company company,
    required CompanyUsageStats usageStats,
    required List<SubscriptionPlan> availablePlans,
    required CompanyFilterOptions filterOptions,
  }) = _CompanyDetailLoaded;

  /// Company created state
  const factory CompanyManagementState.companyCreated({
    required Company company,
    required String message,
  }) = _CompanyCreated;

  /// Company updated state
  const factory CompanyManagementState.companyUpdated({
    required Company company,
    required String message,
  }) = _CompanyUpdated;

  /// Company deleted state
  const factory CompanyManagementState.companyDeleted({
    required String companyId,
    required String message,
  }) = _CompanyDeleted;

  /// Company status updated state
  const factory CompanyManagementState.companyStatusUpdated({
    required String companyId,
    required String status,
    required String message,
  }) = _CompanyStatusUpdated;

  /// Verification status updated state
  const factory CompanyManagementState.verificationStatusUpdated({
    required String companyId,
    required String verificationStatus,
    required String message,
  }) = _VerificationStatusUpdated;

  /// Plan assigned state
  const factory CompanyManagementState.planAssigned({
    required String companyId,
    required SubscriptionPlan plan,
    required String message,
  }) = _PlanAssigned;

  /// Document uploaded state
  const factory CompanyManagementState.documentUploaded({
    required String companyId,
    required CompanyDocument document,
    required String message,
  }) = _DocumentUploaded;

  /// Document deleted state
  const factory CompanyManagementState.documentDeleted({
    required String companyId,
    required String documentId,
    required String message,
  }) = _DocumentDeleted;

  /// Exporting state - companies are being exported
  const factory CompanyManagementState.exporting() = _Exporting;

  /// Exported state - companies export completed
  const factory CompanyManagementState.exported({
    required String filePath,
    required String message,
  }) = _Exported;

  /// Welcome email sent state
  const factory CompanyManagementState.welcomeEmailSent({
    required String companyId,
    required String message,
  }) = _WelcomeEmailSent;

  /// Password reset state
  const factory CompanyManagementState.passwordReset({
    required String companyId,
    required String message,
  }) = _PasswordReset;

  /// Error state - operation failed
  const factory CompanyManagementState.error({
    required String message,
    @Default(false) bool isNetworkError,
    @Default(false) bool isServerError,
    @Default(false) bool isValidationError,
    StackTrace? stackTrace,
  }) = _Error;
}

/// Company filter options
class CompanyFilterOptions extends Equatable {
  final List<String> statusOptions;
  final List<String> verificationStatusOptions;
  final List<String> countryOptions;
  final List<String> planTypeOptions;
  final List<String> companyTypeOptions;
  final List<String> industryTypeOptions;

  const CompanyFilterOptions({
    required this.statusOptions,
    required this.verificationStatusOptions,
    required this.countryOptions,
    required this.planTypeOptions,
    required this.companyTypeOptions,
    required this.industryTypeOptions,
  });

  /// Default filter options
  factory CompanyFilterOptions.defaultOptions() {
    return CompanyFilterOptions(
      statusOptions: const ['active', 'pending', 'suspended', 'terminated'],
      verificationStatusOptions: const [
        'notSubmitted',
        'pending',
        'verified',
        'rejected',
      ],
      countryOptions: const [
        'United States',
        'India',
        'United Kingdom',
        'Germany',
        'France',
        'Japan',
        'China',
        'Australia',
        'Canada',
        'UAE',
      ],
      planTypeOptions: const ['free', 'basic', 'standard', 'premium', 'custom'],
      companyTypeOptions: const [
        'manufacturing',
        'distributor',
        'retailer',
        'wholesaler',
        'importer',
        'exporter',
        'other',
      ],
      industryTypeOptions: const [
        'food_beverage',
        'pharmaceutical',
        'electronics',
        'textile',
        'automotive',
        'chemical',
        'cosmetics',
        'agriculture',
        'other',
      ],
    );
  }

  /// Create CompanyFilterOptions from JSON
  factory CompanyFilterOptions.fromJson(Map<String, dynamic> json) {
    final data = json['filter_options'] as Map<String, dynamic>? ?? {};

    return CompanyFilterOptions(
      statusOptions: List<String>.from(data['status_options'] as List? ?? []),
      verificationStatusOptions: List<String>.from(
        data['verification_status_options'] as List? ?? [],
      ),
      countryOptions: List<String>.from(data['country_options'] as List? ?? []),
      planTypeOptions: List<String>.from(
        data['plan_type_options'] as List? ?? [],
      ),
      companyTypeOptions: List<String>.from(
        data['company_type_options'] as List? ?? [],
      ),
      industryTypeOptions: List<String>.from(
        data['industry_type_options'] as List? ?? [],
      ),
    );
  }

  /// Convert CompanyFilterOptions to JSON
  Map<String, dynamic> toJson() {
    return {
      'status_options': statusOptions,
      'verification_status_options': verificationStatusOptions,
      'country_options': countryOptions,
      'plan_type_options': planTypeOptions,
      'company_type_options': companyTypeOptions,
      'industry_type_options': industryTypeOptions,
    };
  }

  @override
  List<Object?> get props => [
    statusOptions,
    verificationStatusOptions,
    countryOptions,
    planTypeOptions,
    companyTypeOptions,
    industryTypeOptions,
  ];

  @override
  bool get stringify => true;
}
