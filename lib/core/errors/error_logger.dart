// Error Logger for NexaTrace System
// This file handles logging and tracking of errors throughout the application

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ErrorLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  // Log debug messages
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  // Log info messages
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Log warning messages
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Log error messages
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // In production, you might want to send errors to a remote server
    if (!kDebugMode) {
      _sendToRemoteServer(message, error, stackTrace);
    }
  }

  // Log fatal errors
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // Always send fatal errors to remote server
    _sendToRemoteServer(message, error, stackTrace);
  }

  // Log API errors
  static void apiError(
    String endpoint,
    int statusCode,
    String responseBody, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message = 'API Error: $endpoint - Status: $statusCode';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    // Log response body for debugging
    _logger.d('Response Body: $responseBody');

    if (!kDebugMode) {
      _sendApiErrorToRemoteServer(
          endpoint, statusCode, responseBody, error, stackTrace);
    }
  }

  // Log code generation errors
  static void codeGenerationError(
    String codeType,
    int batchSize,
    String errorMessage, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message =
        'Code Generation Error - Type: $codeType, Batch: $batchSize';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    _logger.d('Error Details: $errorMessage');

    if (!kDebugMode) {
      _sendCodeGenerationErrorToRemoteServer(
          codeType, batchSize, errorMessage, error, stackTrace);
    }
  }

  // Log authentication errors
  static void authError(
    String operation,
    String errorMessage, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message = 'Authentication Error - Operation: $operation';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    _logger.d('Error Details: $errorMessage');

    if (!kDebugMode) {
      _sendAuthErrorToRemoteServer(operation, errorMessage, error, stackTrace);
    }
  }

  // Log database errors
  static void databaseError(
    String operation,
    String table,
    String errorMessage, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message = 'Database Error - Operation: $operation, Table: $table';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    _logger.d('Error Details: $errorMessage');

    if (!kDebugMode) {
      _sendDatabaseErrorToRemoteServer(
          operation, table, errorMessage, error, stackTrace);
    }
  }

  // Log network errors
  static void networkError(
    String operation,
    String errorMessage, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message = 'Network Error - Operation: $operation';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    _logger.d('Error Details: $errorMessage');

    if (!kDebugMode) {
      _sendNetworkErrorToRemoteServer(
          operation, errorMessage, error, stackTrace);
    }
  }

  // Log validation errors
  static void validationError(
    String formName,
    Map<String, String> errors, [
    StackTrace? stackTrace,
  ]) {
    final message = 'Validation Error - Form: $formName';
    _logger.w(
      message,
      stackTrace: stackTrace,
    );

    _logger.d('Validation Errors: $errors');

    if (!kDebugMode) {
      _sendValidationErrorToRemoteServer(formName, errors, stackTrace);
    }
  }

  // Log subscription errors
  static void subscriptionError(
    String factoryId,
    String planId,
    String errorMessage, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message = 'Subscription Error - Factory: $factoryId, Plan: $planId';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    _logger.d('Error Details: $errorMessage');

    if (!kDebugMode) {
      _sendSubscriptionErrorToRemoteServer(
          factoryId, planId, errorMessage, error, stackTrace);
    }
  }

  // Log payment errors
  static void paymentError(
    String transactionId,
    String errorMessage, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message = 'Payment Error - Transaction: $transactionId';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    _logger.d('Error Details: $errorMessage');

    if (!kDebugMode) {
      _sendPaymentErrorToRemoteServer(
          transactionId, errorMessage, error, stackTrace);
    }
  }

  // Log Rust module errors
  static void rustModuleError(
    String function,
    String errorMessage, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final message = 'Rust Module Error - Function: $function';
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    _logger.d('Error Details: $errorMessage');

    if (!kDebugMode) {
      _sendRustModuleErrorToRemoteServer(
          function, errorMessage, error, stackTrace);
    }
  }

  // Log performance metrics
  static void performanceMetric(
    String operation,
    Duration duration, [
    Map<String, dynamic>? additionalData,
  ]) {
    final message =
        'Performance Metric - Operation: $operation, Duration: ${duration.inMilliseconds}ms';
    _logger.i(message);

    if (additionalData != null) {
      _logger.d('Additional Data: $additionalData');
    }

    if (!kDebugMode && duration.inMilliseconds > 1000) {
      _sendPerformanceMetricToRemoteServer(operation, duration, additionalData);
    }
  }

  // Log user actions for analytics
  static void userAction(
    String userId,
    String action,
    Map<String, dynamic> data,
  ) {
    final message = 'User Action - User: $userId, Action: $action';
    _logger.i(message);

    _logger.d('Action Data: $data');

    if (!kDebugMode) {
      _sendUserActionToRemoteServer(userId, action, data);
    }
  }

  // Log factory activity
  static void factoryActivity(
    String factoryId,
    String activity,
    Map<String, dynamic> data,
  ) {
    final message =
        'Factory Activity - Factory: $factoryId, Activity: $activity';
    _logger.i(message);

    _logger.d('Activity Data: $data');

    if (!kDebugMode) {
      _sendFactoryActivityToRemoteServer(factoryId, activity, data);
    }
  }

  // Log code generation activity
  static void codeGenerationActivity(
    String factoryId,
    String codeType,
    int batchSize,
    Map<String, dynamic> data,
  ) {
    final message =
        'Code Generation - Factory: $factoryId, Type: $codeType, Batch: $batchSize';
    _logger.i(message);

    _logger.d('Generation Data: $data');

    if (!kDebugMode) {
      _sendCodeGenerationActivityToRemoteServer(
          factoryId, codeType, batchSize, data);
    }
  }

  // Private method to send errors to remote server
  static Future<void> _sendToRemoteServer(
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement remote error logging service
      // Example: Sentry, Firebase Crashlytics, or custom API
      // await RemoteErrorService.logError(message, error, stackTrace);
    } catch (e) {
      // If remote logging fails, log it locally
      _logger.e('Failed to send error to remote server', error: e);
    }
  }

  // Private method to send API errors to remote server
  static Future<void> _sendApiErrorToRemoteServer(
    String endpoint,
    int statusCode,
    String responseBody,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement API error logging
    } catch (e) {
      _logger.e('Failed to send API error to remote server', error: e);
    }
  }

  // Private method to send code generation errors to remote server
  static Future<void> _sendCodeGenerationErrorToRemoteServer(
    String codeType,
    int batchSize,
    String errorMessage,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement code generation error logging
    } catch (e) {
      _logger.e('Failed to send code generation error to remote server',
          error: e);
    }
  }

  // Private method to send authentication errors to remote server
  static Future<void> _sendAuthErrorToRemoteServer(
    String operation,
    String errorMessage,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement authentication error logging
    } catch (e) {
      _logger.e('Failed to send auth error to remote server', error: e);
    }
  }

  // Private method to send database errors to remote server
  static Future<void> _sendDatabaseErrorToRemoteServer(
    String operation,
    String table,
    String errorMessage,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement database error logging
    } catch (e) {
      _logger.e('Failed to send database error to remote server', error: e);
    }
  }

  // Private method to send network errors to remote server
  static Future<void> _sendNetworkErrorToRemoteServer(
    String operation,
    String errorMessage,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement network error logging
    } catch (e) {
      _logger.e('Failed to send network error to remote server', error: e);
    }
  }

  // Private method to send validation errors to remote server
  static Future<void> _sendValidationErrorToRemoteServer(
    String formName,
    Map<String, String> errors,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement validation error logging
    } catch (e) {
      _logger.e('Failed to send validation error to remote server', error: e);
    }
  }

  // Private method to send subscription errors to remote server
  static Future<void> _sendSubscriptionErrorToRemoteServer(
    String factoryId,
    String planId,
    String errorMessage,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement subscription error logging
    } catch (e) {
      _logger.e('Failed to send subscription error to remote server', error: e);
    }
  }

  // Private method to send payment errors to remote server
  static Future<void> _sendPaymentErrorToRemoteServer(
    String transactionId,
    String errorMessage,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement payment error logging
    } catch (e) {
      _logger.e('Failed to send payment error to remote server', error: e);
    }
  }

  // Private method to send Rust module errors to remote server
  static Future<void> _sendRustModuleErrorToRemoteServer(
    String function,
    String errorMessage,
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    try {
      // TODO: Implement Rust module error logging
    } catch (e) {
      _logger.e('Failed to send Rust module error to remote server', error: e);
    }
  }

  // Private method to send performance metrics to remote server
  static Future<void> _sendPerformanceMetricToRemoteServer(
    String operation,
    Duration duration,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // TODO: Implement performance metric logging
    } catch (e) {
      _logger.e('Failed to send performance metric to remote server', error: e);
    }
  }

  // Private method to send user actions to remote server
  static Future<void> _sendUserActionToRemoteServer(
    String userId,
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      // TODO: Implement user action logging
    } catch (e) {
      _logger.e('Failed to send user action to remote server', error: e);
    }
  }

  // Private method to send factory activity to remote server
  static Future<void> _sendFactoryActivityToRemoteServer(
    String factoryId,
    String activity,
    Map<String, dynamic> data,
  ) async {
    try {
      // TODO: Implement factory activity logging
    } catch (e) {
      _logger.e('Failed to send factory activity to remote server', error: e);
    }
  }

  // Private method to send code generation activity to remote server
  static Future<void> _sendCodeGenerationActivityToRemoteServer(
    String factoryId,
    String codeType,
    int batchSize,
    Map<String, dynamic> data,
  ) async {
    try {
      // TODO: Implement code generation activity logging
    } catch (e) {
      _logger.e('Failed to send code generation activity to remote server',
          error: e);
    }
  }

  // Initialize error logging
  static void initialize() {
    // Set up global error handlers
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorLogger.error(
        'Flutter Error',
        details.exception,
        details.stack,
      );
    };

    // Set up platform error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorLogger.error('Platform Error', error, stack);
      return true;
    };
  }

  // Get logger instance (for direct access if needed)
  static Logger get logger => _logger;
}
