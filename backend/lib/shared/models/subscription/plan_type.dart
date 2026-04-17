// File: lib/features/nexa_admin/data/models/subscription/plan_type.dart

/// Plan Type Enumeration
/// Defines the different types of subscription plans available in NexaTrace
enum PlanType {
  /// Free trial/forever free plan for startups and testing
  free,

  /// Basic plan for small businesses
  basic,

  /// Standard plan for medium businesses
  standard,

  /// Premium plan for large enterprises
  premium,

  /// Custom plan for enterprise plus with negotiated terms
  custom,
}

/// Billing Cycle Enumeration
/// Defines the different billing cycles available for subscription plans
enum BillingCycle {
  /// Monthly billing cycle
  monthly,

  /// Quarterly billing cycle
  quarterly,

  /// Yearly billing cycle (with discount)
  yearly,

  /// One-time payment
  oneTime,
}

/// Plan Status Enumeration
/// Defines the status of a subscription plan
enum PlanStatus {
  /// Plan is active and available for subscription
  active,

  /// Plan is inactive and not available for new subscriptions
  inactive,

  /// Plan is archived and cannot be used
  archived,
}

/// Feature Type Enumeration
/// Defines the type of feature in a plan
enum FeatureType {
  /// Core feature that is essential
  core,

  /// Advanced feature for higher tiers
  advanced,

  /// Enterprise feature for premium/custom plans
  enterprise,

  /// Custom feature for negotiated plans
  custom,
}

/// Extension methods for PlanType enum
extension PlanTypeExtension on PlanType {
  /// Get the display name of the plan type
  String get displayName {
    switch (this) {
      case PlanType.free:
        return 'Free Plan';
      case PlanType.basic:
        return 'Basic Plan';
      case PlanType.standard:
        return 'Standard Plan';
      case PlanType.premium:
        return 'Premium Plan';
      case PlanType.custom:
        return 'Custom Plan';
    }
  }

  /// Get the description of the plan type
  String get description {
    switch (this) {
      case PlanType.free:
        return 'Free trial/forever free plan for startups and testing';
      case PlanType.basic:
        return 'Basic plan for small businesses';
      case PlanType.standard:
        return 'Standard plan for medium businesses';
      case PlanType.premium:
        return 'Premium plan for large enterprises';
      case PlanType.custom:
        return 'Custom plan for enterprise plus with negotiated terms';
    }
  }

  /// Get the color code for the plan type
  String get colorCode {
    switch (this) {
      case PlanType.free:
        return '#4CAF50'; // Green
      case PlanType.basic:
        return '#2196F3'; // Blue
      case PlanType.standard:
        return '#FF9800'; // Orange
      case PlanType.premium:
        return '#9C27B0'; // Purple
      case PlanType.custom:
        return '#FF5722'; // Deep Orange
    }
  }
}

/// Extension methods for BillingCycle enum
extension BillingCycleExtension on BillingCycle {
  /// Get the display name of the billing cycle
  String get displayName {
    switch (this) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
      case BillingCycle.oneTime:
        return 'One Time';
    }
  }

  /// Get the discount percentage for the billing cycle
  double get discountPercentage {
    switch (this) {
      case BillingCycle.monthly:
        return 0.0;
      case BillingCycle.quarterly:
        return 5.0;
      case BillingCycle.yearly:
        return 15.0;
      case BillingCycle.oneTime:
        return 20.0;
    }
  }

  /// Get the number of months for the billing cycle
  int get months {
    switch (this) {
      case BillingCycle.monthly:
        return 1;
      case BillingCycle.quarterly:
        return 3;
      case BillingCycle.yearly:
        return 12;
      case BillingCycle.oneTime:
        return 0; // One-time payment
    }
  }
}

/// Extension methods for PlanStatus enum
extension PlanStatusExtension on PlanStatus {
  /// Get the display name of the plan status
  String get displayName {
    switch (this) {
      case PlanStatus.active:
        return 'Active';
      case PlanStatus.inactive:
        return 'Inactive';
      case PlanStatus.archived:
        return 'Archived';
    }
  }

  /// Get the color code for the plan status
  String get colorCode {
    switch (this) {
      case PlanStatus.active:
        return '#4CAF50'; // Green
      case PlanStatus.inactive:
        return '#FF9800'; // Orange
      case PlanStatus.archived:
        return '#9E9E9E'; // Grey
    }
  }
}
