import 'package:freezed_annotation/freezed_annotation.dart';

part 'goods_company_model.freezed.dart';
part 'goods_company_model.g.dart';

enum GoodsCompanyPlanType {
  basic, // $29/month
  professional, // $79/month
  enterprise // $199/month
}

enum GoodsCompanyStatus {
  pending,
  active,
  suspended,
  terminated,
  underReview
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
  underReview
}

@freezed
abstract class GoodsCompanyModel with _$GoodsCompanyModel {
  const factory GoodsCompanyModel({
    required String id,
    required String userId,
    required String companyName,
    required String ownerName,
    required String phone,
    required String email,
    required String cnic,
    required String address,
    required GoodsCompanyPlanType planType,
    @Default(GoodsCompanyStatus.pending) GoodsCompanyStatus status,
    @Default(VerificationStatus.pending) VerificationStatus verificationStatus,
    @Default(0.0) double commissionMin,
    @Default(15.0) double commissionMax,
    @Default(false) bool autoCommissionEnabled,
    @Default(true) bool liveTrackingEnabled,
    @Default(true) bool biddingEnabled,
    @Default(false) bool autoBiddingEnabled,
    @Default(false) bool escrowEnabled,
    @Default(false) bool whatsappIntegration,
    @Default(false) bool whiteLabelEnabled,
    @Default(0) int apiCallsToday,
    @Default(1000) int apiCallsLimit,
    @Default(0) int totalTrucks,
    @Default(0) int totalFactories,
    @Default(0) int totalTrips,
    @Default(0.0) double totalRevenue,
    @Default(0.0) double rating,
    @Default(0) int ratingCount,
    String? logoUrl,
    String? website,
    String? taxNumber,
    String? bankAccountNumber,
    String? bankName,
    String? verificationNotes,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    DateTime? lastPaymentDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _GoodsCompanyModel;

  factory GoodsCompanyModel.fromJson(Map<String, dynamic> json) =>
      _$GoodsCompanyModelFromJson(json);

  const GoodsCompanyModel._();

  // Getters
  bool get isActive => status == GoodsCompanyStatus.active;
  bool get isVerified => verificationStatus == VerificationStatus.verified;
  bool get isSuspended => status == GoodsCompanyStatus.suspended;
  bool get canOperate => isActive && isVerified;
  bool get hasActiveSubscription => subscriptionEndDate == null ||
      subscriptionEndDate!.isAfter(DateTime.now());
  bool get isApiLimitExceeded => apiCallsToday >= apiCallsLimit;

  String get planName {
    switch (planType) {
      case GoodsCompanyPlanType.basic:
        return 'Basic';
      case GoodsCompanyPlanType.professional:
        return 'Professional';
      case GoodsCompanyPlanType.enterprise:
        return 'Enterprise';
    }
  }

  double get monthlyPrice {
    switch (planType) {
      case GoodsCompanyPlanType.basic:
        return 29.0;
      case GoodsCompanyPlanType.professional:
        return 79.0;
      case GoodsCompanyPlanType.enterprise:
        return 199.0;
    }
  }

  double get yearlyPrice => monthlyPrice * 12 * 0.9; // 10% discount

  int get maxTruckConnections {
    switch (planType) {
      case GoodsCompanyPlanType.basic:
        return 20;
      case GoodsCompanyPlanType.professional:
        return 50;
      case GoodsCompanyPlanType.enterprise:
        return -1; // Unlimited
    }
  }

  int get maxFactoryConnections {
    switch (planType) {
      case GoodsCompanyPlanType.basic:
        return 10;
      case GoodsCompanyPlanType.professional:
        return 25;
      case GoodsCompanyPlanType.enterprise:
        return -1; // Unlimited
    }
  }

  int get maxMonthlyTrips {
    switch (planType) {
      case GoodsCompanyPlanType.basic:
        return 50;
      case GoodsCompanyPlanType.professional:
        return 150;
      case GoodsCompanyPlanType.enterprise:
        return -1; // Unlimited
    }
  }

  String get formattedRating => rating.toStringAsFixed(1);
  String get formattedRevenue => '₹${totalRevenue.toStringAsFixed(2)}';
  String get formattedMonthlyPrice => '\$${monthlyPrice.toStringAsFixed(2)}/month';
  String get formattedYearlyPrice => '\$${yearlyPrice.toStringAsFixed(2)}/year';

  bool get canAddMoreTrucks {
    if (maxTruckConnections == -1) return true;
    return totalTrucks < maxTruckConnections;
  }

  bool get canAddMoreFactories {
    if (maxFactoryConnections == -1) return true;
    return totalFactories < maxFactoryConnections;
  }

  bool get canAcceptMoreTrips {
    if (maxMonthlyTrips == -1) return true;
    return totalTrips < maxMonthlyTrips;
  }

  double get apiUsagePercentage => (apiCallsToday / apiCallsLimit) * 100;
  String get formattedApiUsage => '$apiCallsToday/$apiCallsLimit';

  // Methods
  double calculateCommission(double tripAmount) {
    if (autoCommissionEnabled) {
      // Dynamic commission based on trip amount
      if (tripAmount <= 10000) return 15.0;
      if (tripAmount <= 50000) return 12.0;
      if (tripAmount <= 100000) return 10.0;
      return 8.0;
    }
    return commissionMin; // Use minimum commission
  }

  bool canChargeCommission(double percentage) {
    return percentage >= commissionMin && percentage <= commissionMax;
  }

  bool canMakeApiCall() {
    return apiCallsToday < apiCallsLimit;
  }

  GoodsCompanyModel incrementApiCalls() {
    return copyWith(apiCallsToday: apiCallsToday + 1);
  }

  GoodsCompanyModel resetApiCalls() {
    return copyWith(apiCallsToday: 0);
  }
}

@freezed
abstract class GoodsCompanySubscription with _$GoodsCompanySubscription {
  const factory GoodsCompanySubscription({
    required String id,
    required String companyId,
    required GoodsCompanyPlanType planType,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
    required String paymentMethod,
    required String paymentReference,
    @Default(false) bool isAutoRenew,
    @Default(false) bool isPaid,
    String? invoiceUrl,
    DateTime? paidAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    required DateTime createdAt,
  }) = _GoodsCompanySubscription;

  factory GoodsCompanySubscription.fromJson(Map<String, dynamic> json) =>
      _$GoodsCompanySubscriptionFromJson(json);

  const GoodsCompanySubscription._();

  bool get isActive => endDate.isAfter(DateTime.now()) && isPaid;
  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isCancelled => cancelledAt != null;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 0;
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

@freezed
abstract class CommissionStructureModel with _$CommissionStructureModel {
  const factory CommissionStructureModel({
    required String id,
    required String companyId,
    required double minPercentage,
    required double maxPercentage,
    @Default(true) bool isDynamic,
    Map<String, double>? dynamicRates, // tripAmount -> percentage
    @Default(false) bool includeTax,
    @Default(false) bool includeInsurance,
    String? notes,
    required DateTime effectiveFrom,
    DateTime? effectiveTo,
    required DateTime createdAt,
  }) = _CommissionStructureModel;

  factory CommissionStructureModel.fromJson(Map<String, dynamic> json) =>
      _$CommissionStructureModelFromJson(json);

  const CommissionStructureModel._();

  bool get isActive => effectiveTo == null || effectiveTo!.isAfter(DateTime.now());

  double calculateCommission(double tripAmount, {bool includeExtras = true}) {
    if (!isDynamic || dynamicRates == null) {
      return minPercentage;
    }

    // Find appropriate rate based on trip amount
    double? selectedRate;
    for (var entry in dynamicRates!.entries) {
      final amountThreshold = double.tryParse(entry.key);
      if (amountThreshold != null && tripAmount >= amountThreshold) {
        selectedRate = entry.value;
      }
    }

    return selectedRate ?? minPercentage;
  }

  bool isValidPercentage(double percentage) {
    return percentage >= minPercentage && percentage <= maxPercentage;
  }
}

@freezed
abstract class GoodsCompanySettings with _$GoodsCompanySettings {
  const factory GoodsCompanySettings({
    required String companyId,
    @Default(true) bool emailNotifications,
    @Default(true) bool smsNotifications,
    @Default(true) bool pushNotifications,
    @Default(true) bool bidNotifications,
    @Default(true) bool tripNotifications,
    @Default(true) bool paymentNotifications,
    @Default(false) bool autoAcceptBids,
    @Default(50000.0) double autoAcceptMaxAmount,
    @Default(false) bool requireDriverVerification,
    @Default(false) bool requireTruckVerification,
    @Default(true) bool showLiveTracking,
    @Default(false) bool shareLocationWithFactories,
    @Default('en') String language,
    @Default('PK') String country,
    @Default('UTC') String timezone,
    DateTime? updatedAt,
  }) = _GoodsCompanySettings;

  factory GoodsCompanySettings.fromJson(Map<String, dynamic> json) =>
      _$GoodsCompanySettingsFromJson(json);
}
