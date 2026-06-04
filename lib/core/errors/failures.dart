// File: lib/core/errors/failures.dart
// File: lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';
import 'package:trace_odd/core/errors/app_exceptions.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.stackTrace});

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  bool get stringify => true;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.stackTrace});
}

/// Server-related failures (5xx errors)
class ServerFailure extends Failure {
  final int statusCode;
  final Map<String, dynamic>? responseData;

  const ServerFailure(
    super.message, {
    this.statusCode = 500,
    this.responseData,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, statusCode, responseData, stackTrace];
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.stackTrace});
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, {super.stackTrace});
}

/// Invalid credentials failure
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(super.message, {super.stackTrace});
}

/// Account suspended failure
class AccountSuspendedFailure extends Failure {
  final DateTime? suspensionEnd;

  const AccountSuspendedFailure(
    super.message, {
    this.suspensionEnd,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, suspensionEnd, stackTrace];
}

/// Account locked failure
class AccountLockedFailure extends Failure {
  final DateTime? unlockTime;

  const AccountLockedFailure(
    super.message, {
    this.unlockTime,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, unlockTime, stackTrace];
}

/// Validation failures (form validation, input validation)
class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure(
    super.message, {
    required this.errors,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, errors, stackTrace];
}

/// Data parsing failures
class DataParsingFailure extends Failure {
  final dynamic data;

  const DataParsingFailure(super.message, {this.data, super.stackTrace});

  @override
  List<Object?> get props => [message, data, stackTrace];
}

/// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.stackTrace});
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.stackTrace});
}

/// File system failures
class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message, {super.stackTrace});
}

/// API rate limit failure
class RateLimitFailure extends Failure {
  final Duration retryAfter;

  const RateLimitFailure(
    super.message, {
    required this.retryAfter,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, retryAfter, stackTrace];
}

/// Timeout failure
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.stackTrace});
}

/// Not found failure
class NotFoundFailure extends Failure {
  final String resourceType;
  final String? resourceId;

  const NotFoundFailure(
    super.message, {
    required this.resourceType,
    this.resourceId,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, resourceType, resourceId, stackTrace];
}

/// Conflict failure (e.g., duplicate resource)
class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.stackTrace});
}

/// Payment failure
class PaymentFailure extends Failure {
  final String? paymentMethodId;
  final String? transactionId;

  const PaymentFailure(
    super.message, {
    this.paymentMethodId,
    this.transactionId,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [
    message,
    paymentMethodId,
    transactionId,
    stackTrace,
  ];
}

/// Subscription failure
class SubscriptionFailure extends Failure {
  final String? subscriptionId;

  const SubscriptionFailure(
    super.message, {
    this.subscriptionId,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, subscriptionId, stackTrace];
}

/// Feature not available failure
class FeatureNotAvailableFailure extends Failure {
  final String featureName;
  final String? requiredPlan;

  const FeatureNotAvailableFailure(
    super.message, {
    required this.featureName,
    this.requiredPlan,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, featureName, requiredPlan, stackTrace];
}

/// Unknown failure (catch-all for unexpected errors)
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.stackTrace});
}

/// Helper function to convert exceptions to failures
Failure mapExceptionToFailure(dynamic exception, StackTrace stackTrace) {
  if (exception is Failure) {
    return exception;
  }

  if (exception is ValidationException) {
    return ValidationFailure(
      exception.message,
      errors: exception.errors.map((key, value) => MapEntry(key, [value])),
      stackTrace: stackTrace,
    );
  }

  final errorMessage = exception.toString().toLowerCase();

  // Map common exception patterns to appropriate failures
  if (errorMessage.contains('network') ||
      errorMessage.contains('socket') ||
      errorMessage.contains('connection')) {
    return NetworkFailure('Network error: $exception', stackTrace: stackTrace);
  } else if (errorMessage.contains('timeout') ||
      errorMessage.contains('timed out')) {
    return TimeoutFailure(
      'Request timed out: $exception',
      stackTrace: stackTrace,
    );
  } else if (errorMessage.contains('404') ||
      errorMessage.contains('not found')) {
    // Try to extract resource type from the message
    String resourceType = 'resource';
    String? resourceId;

    // Simple extraction logic - you can enhance this based on your error format
    if (errorMessage.contains('factory')) {
      resourceType = 'factory';
      // Try to extract ID if present
      final idMatch = RegExp(
        r'[a-f0-9]{8,}|factory[_\s]?(\d+)',
      ).firstMatch(errorMessage);
      if (idMatch != null) {
        resourceId = idMatch.group(0);
      }
    } else if (errorMessage.contains('product')) {
      resourceType = 'product';
    } else if (errorMessage.contains('code') ||
        errorMessage.contains('barcode')) {
      resourceType = 'code';
    } else if (errorMessage.contains('user')) {
      resourceType = 'user';
    }

    return NotFoundFailure(
      'Resource not found: $exception',
      resourceType: resourceType,
      resourceId: resourceId,
      stackTrace: stackTrace,
    );
  } else if (errorMessage.contains('401') ||
      errorMessage.contains('unauthorized')) {
    return AuthenticationFailure(
      'Authentication failed: $exception',
      stackTrace: stackTrace,
    );
  } else if (errorMessage.contains('403') ||
      errorMessage.contains('forbidden')) {
    return AuthorizationFailure(
      'Access denied: $exception',
      stackTrace: stackTrace,
    );
  } else if (errorMessage.contains('409') ||
      errorMessage.contains('conflict')) {
    return ConflictFailure(
      'Conflict error: $exception',
      stackTrace: stackTrace,
    );
  } else if (errorMessage.contains('422') ||
      errorMessage.contains('validation') ||
      errorMessage.contains('invalid')) {
    // For validation failures, try to extract errors from the exception if possible
    Map<String, List<String>> errors = {};

    // Check if the exception has a 'errors' field (common in Dio responses)
    if (exception is Map && exception.containsKey('errors')) {
      try {
        final errorData = exception['errors'];
        if (errorData is Map) {
          errorData.forEach((key, value) {
            if (value is List) {
              errors[key.toString()] = value.map((e) => e.toString()).toList();
            } else if (value is String) {
              errors[key.toString()] = [value];
            } else {
              errors[key.toString()] = [value.toString()];
            }
          });
        }
      } catch (e) {
        // If extraction fails, just use a default error message
      }
    }

    // If no structured errors found, create a default one
    if (errors.isEmpty) {
      errors = {
        'general': ['Validation error occurred'],
      };
    }

    return ValidationFailure(
      'Validation error: $exception',
      errors: errors,
      stackTrace: stackTrace,
    );
  } else if (errorMessage.contains('429') ||
      errorMessage.contains('rate limit')) {
    // Try to extract retry-after information
    Duration retryAfter = const Duration(minutes: 1);

    if (exception is Map && exception.containsKey('retryAfter')) {
      try {
        final seconds = int.tryParse(exception['retryAfter'].toString());
        if (seconds != null) {
          retryAfter = Duration(seconds: seconds);
        }
      } catch (e) {
        // Keep default
      }
    }

    return RateLimitFailure(
      'Rate limit exceeded: $exception',
      retryAfter: retryAfter,
      stackTrace: stackTrace,
    );
  } else if (errorMessage.contains('500') ||
      errorMessage.contains('server error')) {
    // Surface the actual server error message, not the wrapper class name
    if (exception is ServerException) {
      return ServerFailure(
        exception.message,
        statusCode: exception.statusCode,
        stackTrace: stackTrace,
      );
    }
    return ServerFailure('Server error: $exception', stackTrace: stackTrace);
  }

  return UnknownFailure('Unexpected error: $exception', stackTrace: stackTrace);
}
