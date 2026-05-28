// Network Exceptions — Dio interceptor error taxonomy
// Handles all backend status anomalies from the 26-step architecture.
// Reuses AppException base from lib/core/errors/app_exceptions.dart.
//
// Backend mapping:
//   403 → DriverTypeMismatchException (EnsureDriverType middleware)
//   422 → AIChatGuardViolationException (AIChatLeakFilter middleware)
//   401 → TokenExpiredException (existing)
//   423 → LockedException (existing)
//   429 → RateLimitException (existing)

import 'package:trace_odd/core/errors/app_exceptions.dart';

/// Thrown when backend returns 403 with driver.type mismatch payload.
/// Middleware: EnsureDriverType (Step 19)
/// Triggers: hard navigation to access-denied overlay, not a toast.
class DriverTypeMismatchException extends AuthException {
  /// The driver type the user actually holds (factory / truck / bus).
  final String actualDriverType;

  /// The driver type(s) the route requires.
  final String requiredDriverType;

  /// The raw error message from the backend.
  final String backendMessage;

  const DriverTypeMismatchException({
    required this.actualDriverType,
    required this.requiredDriverType,
    required this.backendMessage,
    StackTrace? stackTrace,
  }) : super(backendMessage, stackTrace);
}

/// Thrown when backend returns 422 with AI chat leak detection payload.
/// Middleware: AIChatLeakFilter (Step 25)
/// Triggers: input stream block + masked payload display.
class AIChatGuardViolationException extends ValidationException {
  /// The pattern that was detected (phone, email, handle).
  final String detectedPattern;

  /// The masked version of the payload for audit display.
  final String maskedPayload;

  /// Type of leak: phone / email / handle / raw_number.
  final String leakType;

  const AIChatGuardViolationException({
    required this.detectedPattern,
    required this.maskedPayload,
    required this.leakType,
    required Map<String, String> errors,
    StackTrace? stackTrace,
  }) : super(errors, stackTrace);
}

/// Thrown when backend returns 422 with Cup of Tea penalty.
/// Module 12M — 2 failed bids/month → Rs. 50 auto-debit.
class CupOfTeaPenaltyException extends SubscriptionException {
  /// Number of failed bids this month.
  final int failedBidCount;

  /// Penalty amount debited in PKR.
  final double penaltyAmount;

  CupOfTeaPenaltyException({
    required this.failedBidCount,
    required this.penaltyAmount,
    StackTrace? stackTrace,
  }) : super(
         'Cup of Tea charge of Rs. ${penaltyAmount.toStringAsFixed(0)} deducted. '
         'Failed bid limit ($failedBidCount) exceeded.',
         stackTrace,
       );
}

/// Thrown when backend returns 422 with anti-fraud velocity block.
/// Module 8W-C — voucher usage < 70% → cash-out blocked.
class AntiFraudVelocityException extends ValidationException {
  /// Current usage ratio as percentage (0–100).
  final double usageRatio;

  /// Minimum required ratio to unlock cash-out.
  final double requiredRatio = 70.0;

  const AntiFraudVelocityException({
    required this.usageRatio,
    required Map<String, String> errors,
    StackTrace? stackTrace,
  }) : super(errors, stackTrace);

  double get deficit => requiredRatio - usageRatio;
}
