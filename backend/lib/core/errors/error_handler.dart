// Error Handler for NexaTrace System
// This file handles application errors and exceptions

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_exceptions.dart';
import 'error_logger.dart';

class ErrorHandler {
  // Handle API errors
  static void handleApiError(dynamic error, BuildContext context) {
    if (error is UnauthorizedException) {
      showPersistentError(
        context,
        title: 'Session Expired',
        message: 'Please login again.',
      );
      // TODO: Navigate to login screen
    } else if (error is NetworkException) {
      showPersistentError(
        context,
        title: 'Network Error',
        message: 'Please check your internet connection.',
      );
    } else if (error is ServerException) {
      showPersistentError(
        context,
        title: 'Server Error',
        message: 'Something went wrong on our end. Please try again later.',
      );
    } else if (error is ValidationException) {
      showPersistentError(
        context,
        title: 'Validation Error',
        message: error.formattedErrors,
      );
    } else if (error is RecordNotFoundException) {
      showPersistentError(
        context,
        title: 'Not Found',
        message: error.message,
      );
    } else if (error is CodeLimitExceededException) {
      showPersistentError(
        context,
        title: 'Limit Exceeded',
        message: error.message,
      );
    } else if (error is PlanNotActiveException) {
      showPersistentError(
        context,
        title: 'Subscription Issue',
        message: error.message,
      );
    } else if (error is CodeGenerationException) {
      showPersistentError(
        context,
        title: 'Code Generation Error',
        message: error.message,
      );
    } else {
      showPersistentError(
        context,
        title: 'Error',
        message: 'An unexpected error occurred.',
      );
    }
  }

  // Show error dialog
  static void _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    showPersistentError(context, title: 'Error', message: message);
  }

  // Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle form validation errors
  static void handleFormErrors(
    Map<String, String> errors,
    BuildContext context,
  ) {
    if (errors.isNotEmpty) {
      final firstError = errors.values.first;
      showErrorSnackbar(context, firstError);
    }
  }

  static void showPersistentError(
    BuildContext context, {
    required String title,
    required String message,
    String? copyText,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(message),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: copyText ?? '$title\n\n$message'),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error copied to clipboard')),
                );
              }
            },
            child: const Text('Copy Error'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  // Log error for debugging
  static void logError(dynamic error, StackTrace stackTrace, {String? tag}) {
    final errorTag = tag ?? 'AppError';
    ErrorLogger.error('[$errorTag] Error', error, stackTrace);
    // TODO: Integrate with error logging service (Sentry, Firebase Crashlytics, etc.)
  }

  // Check if error is network related
  static bool isNetworkError(dynamic error) {
    return error is NetworkException ||
        error is TimeoutException ||
        error.toString().contains('network') ||
        error.toString().contains('socket') ||
        error.toString().contains('connection');
  }

  // Check if error is authentication related
  static bool isAuthError(dynamic error) {
    return error is UnauthorizedException ||
        error.toString().contains('unauthorized') ||
        error.toString().contains('authentication') ||
        error.toString().contains('token');
  }

  // Check if error is validation related
  static bool isValidationError(dynamic error) {
    return error is ValidationException ||
        error.toString().contains('validation') ||
        error.toString().contains('invalid');
  }

  // Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is String) {
      return error;
    } else if (error is Map<String, dynamic>) {
      return error['message']?.toString() ?? 'An error occurred';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Handle error with retry option
  static Future<void> handleErrorWithRetry(
    BuildContext context,
    dynamic error,
    VoidCallback retryCallback,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(getUserFriendlyMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              retryCallback();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Handle subscription limit error
  static void handleSubscriptionLimitError(
    BuildContext context,
    String planType,
    int limit,
  ) {
    _showErrorDialog(
      context,
      'Subscription Limit Reached',
      'Your $planType plan allows only $limit codes. Please upgrade your plan to generate more codes.',
    );
  }

  // Handle code generation error
  static void handleCodeGenerationError(
    BuildContext context,
    String codeType,
    String error,
  ) {
    _showErrorDialog(
      context,
      'Failed to Generate $codeType Codes',
      'Error: $error. Please try again with different parameters.',
    );
  }

  // Handle product linking error
  static void handleProductLinkingError(BuildContext context, String error) {
    _showErrorDialog(
      context,
      'Failed to Link Codes',
      'Error: $error. Please make sure the product and codes are valid.',
    );
  }

  // Handle publish error
  static void handlePublishError(BuildContext context, String error) {
    _showErrorDialog(
      context,
      'Failed to Publish Codes',
      'Error: $error. Please try again.',
    );
  }
}
