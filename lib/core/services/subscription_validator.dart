// Subscription Validator for NexaTrace System
// This service validates subscription limits for code generation

import '../errors/app_exceptions.dart';

class SubscriptionValidator {
  // Validate code generation against subscription limits
  static ValidationResult validateCodeGeneration(
    String planName,
    int currentUsage,
    int requestedCount,
    Map<String, int> planLimits,
  ) {
    // Get the limit for the specific code type
    final codeTypeLimit = planLimits['max_codes'] ?? 0;

    if (currentUsage + requestedCount > codeTypeLimit) {
      return ValidationResult.error(
        CodeLimitExceededException(planName, codeTypeLimit, requestedCount),
      );
    }

    return ValidationResult.success();
  }

  // Validate user creation against subscription limits
  static ValidationResult validateUserCreation(
    String planName,
    int currentUsers,
    int maxUsersAllowed,
  ) {
    if (currentUsers >= maxUsersAllowed) {
      return ValidationResult.error(
        SubscriptionException('User limit exceeded for $planName plan'),
      );
    }

    return ValidationResult.success();
  }

  // Validate product creation against subscription limits
  static ValidationResult validateProductCreation(
    String planName,
    int currentProducts,
    int maxProductsAllowed,
  ) {
    if (currentProducts >= maxProductsAllowed) {
      return ValidationResult.error(
        SubscriptionException('Product limit exceeded for $planName plan'),
      );
    }

    return ValidationResult.success();
  }

  // Validate factory creation against subscription limits
  static ValidationResult validateFactoryCreation(
    String planName,
    int currentFactories,
    int maxFactoriesAllowed,
  ) {
    if (currentFactories >= maxFactoriesAllowed) {
      return ValidationResult.error(
        SubscriptionException('Factory limit exceeded for $planName plan'),
      );
    }

    return ValidationResult.success();
  }

  // Validate storage usage against subscription limits
  static ValidationResult validateStorageUsage(
    String planName,
    double currentStorageMB,
    double maxStorageMB,
    double additionalStorageMB,
  ) {
    if (currentStorageMB + additionalStorageMB > maxStorageMB) {
      return ValidationResult.error(
        SubscriptionException('Storage limit exceeded for $planName plan'),
      );
    }

    return ValidationResult.success();
  }

  // Check if subscription is active
  static ValidationResult validateSubscriptionActive(
    String planName,
    bool isActive,
    DateTime? expiresAt,
  ) {
    if (!isActive) {
      return ValidationResult.error(
        PlanNotActiveException(planName),
      );
    }

    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      return ValidationResult.error(
        SubscriptionException('Subscription has expired'),
      );
    }

    return ValidationResult.success();
  }

  // Validate all subscription limits at once
  static Map<String, ValidationResult> validateAllLimits({
    required String planName,
    required Map<String, int> currentUsage,
    required Map<String, int> requested,
    required Map<String, int> planLimits,
    required bool isSubscriptionActive,
    DateTime? subscriptionExpiresAt,
  }) {
    final results = <String, ValidationResult>{};

    // Validate subscription status
    results['subscription'] = validateSubscriptionActive(
      planName,
      isSubscriptionActive,
      subscriptionExpiresAt,
    );

    // Validate code generation
    if (requested.containsKey('codes')) {
      results['codes'] = validateCodeGeneration(
        planName,
        currentUsage['codes'] ?? 0,
        requested['codes']!,
        planLimits,
      );
    }

    // Validate user creation
    if (requested.containsKey('users')) {
      results['users'] = validateUserCreation(
        planName,
        currentUsage['users'] ?? 0,
        planLimits['max_users'] ?? 0,
      );
    }

    // Validate product creation
    if (requested.containsKey('products')) {
      results['products'] = validateProductCreation(
        planName,
        currentUsage['products'] ?? 0,
        planLimits['max_products'] ?? 0,
      );
    }

    // Validate factory creation
    if (requested.containsKey('factories')) {
      results['factories'] = validateFactoryCreation(
        planName,
        currentUsage['factories'] ?? 0,
        planLimits['max_factories'] ?? 0,
      );
    }

    return results;
  }

  // Check if all validations passed
  static bool allValidationsPassed(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }

  // Get all validation errors
  static List<AppException> getValidationErrors(
    Map<String, ValidationResult> results,
  ) {
    return results.values
        .where((result) => !result.isValid)
        .map((result) => result.error!)
        .toList();
  }
}

// Validation result class to replace Either
class ValidationResult {
  final bool isValid;
  final AppException? error;

  const ValidationResult._({
    required this.isValid,
    this.error,
  });

  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.error(AppException error) {
    return ValidationResult._(isValid: false, error: error);
  }

  // Helper method to throw error if validation failed
  void throwIfError() {
    if (!isValid && error != null) {
      throw error!;
    }
  }

  // Helper method to get error message
  String? get errorMessage => error?.message;
}
