// App Exceptions for NexaTrace System
// This file defines custom exceptions used throughout the application

// Base exception class
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
}

class NoInternetException extends NetworkException {
  const NoInternetException([StackTrace? stackTrace])
      : super('No internet connection', stackTrace);
}

class TimeoutException extends NetworkException {
  const TimeoutException([StackTrace? stackTrace])
      : super('Request timed out', stackTrace);
}

class ServerException extends NetworkException {
  final int statusCode;
  final dynamic responseData;

  const ServerException(
    String message,
    this.statusCode,
    this.responseData, [
    StackTrace? stackTrace,
  ]) : super(message, stackTrace);
}

class LockedException extends NetworkException {
  final String invoiceId;

  const LockedException({
    required String message,
    required this.invoiceId,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

class RedirectException extends NetworkException {
  final String? location;
  final String? originalMethod;

  const RedirectException(
    String message, {
    this.location,
    this.originalMethod,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.stackTrace]);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([StackTrace? stackTrace])
      : super('Invalid email or password', stackTrace);
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException([StackTrace? stackTrace])
      : super('Session expired. Please login again', stackTrace);
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException([String? message, StackTrace? stackTrace])
      : super(message ?? 'Unauthorized access', stackTrace);
}

// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String> errors;

  const ValidationException(this.errors, [StackTrace? stackTrace])
      : super('Validation failed', stackTrace);

  String get formattedErrors {
    return errors.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}

// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.stackTrace]);
}

class RecordNotFoundException extends DatabaseException {
  const RecordNotFoundException(String recordType, [StackTrace? stackTrace])
      : super('$recordType not found', stackTrace);
}

class DuplicateRecordException extends DatabaseException {
  const DuplicateRecordException(String recordType, [StackTrace? stackTrace])
      : super('$recordType already exists', stackTrace);
}

// Code generation exceptions
class CodeGenerationException extends AppException {
  const CodeGenerationException(super.message, [super.stackTrace]);
}

class CodeLimitExceededException extends CodeGenerationException {
  final String planName;
  final int limit;
  final int requested;

  const CodeLimitExceededException(
    this.planName,
    this.limit,
    this.requested, [
    StackTrace? stackTrace,
  ]) : super(
          'Code generation limit exceeded for $planName plan. '
          'Limit: $limit, Requested: $requested',
          stackTrace,
        );
}

class InvalidCodeFormatException extends CodeGenerationException {
  const InvalidCodeFormatException(String format, [StackTrace? stackTrace])
      : super('Invalid code format: $format', stackTrace);
}

// Subscription exceptions
class SubscriptionException extends AppException {
  const SubscriptionException(super.message, [super.stackTrace]);
}

class PlanNotActiveException extends SubscriptionException {
  const PlanNotActiveException(String planName, [StackTrace? stackTrace])
      : super('$planName plan is not active', stackTrace);
}

class PaymentRequiredException extends SubscriptionException {
  const PaymentRequiredException([StackTrace? stackTrace])
      : super('Payment required to continue', stackTrace);
}

// Factory exceptions
class FactoryException extends AppException {
  const FactoryException(super.message, [super.stackTrace]);
}

class FactoryNotFoundException extends FactoryException {
  const FactoryNotFoundException(String factoryId, [StackTrace? stackTrace])
      : super('Factory with ID $factoryId not found', stackTrace);
}

class FactorySuspendedException extends FactoryException {
  const FactorySuspendedException(String factoryName, [StackTrace? stackTrace])
      : super('$factoryName factory is suspended', stackTrace);
}

// Product exceptions
class ProductException extends AppException {
  const ProductException(super.message, [super.stackTrace]);
}

class ProductNotFoundException extends ProductException {
  const ProductNotFoundException(String productId, [StackTrace? stackTrace])
      : super('Product with ID $productId not found', stackTrace);
}

class ProductAlreadyLinkedException extends ProductException {
  const ProductAlreadyLinkedException(
    String productId, [
    StackTrace? stackTrace,
  ]) : super('Product with ID $productId already has linked codes', stackTrace);
}

// Code exceptions
class CodeException extends AppException {
  const CodeException(super.message, [super.stackTrace]);
}

class CodeNotFoundException extends CodeException {
  const CodeNotFoundException(String code, [StackTrace? stackTrace])
      : super('Code $code not found', stackTrace);
}

class CodeAlreadyPublishedException extends CodeException {
  const CodeAlreadyPublishedException(String code, [StackTrace? stackTrace])
      : super(
          'Code $code is already published and cannot be modified',
          stackTrace,
        );
}

class CodeNotLinkedException extends CodeException {
  const CodeNotLinkedException(String code, [StackTrace? stackTrace])
      : super('Code $code is not linked to any product', stackTrace);
}

// Employee exceptions
class EmployeeException extends AppException {
  const EmployeeException(super.message, [super.stackTrace]);
}

class EmployeeNotFoundException extends EmployeeException {
  const EmployeeNotFoundException(String employeeId, [StackTrace? stackTrace])
      : super('Employee with ID $employeeId not found', stackTrace);
}

class InvalidEmployeeRoleException extends EmployeeException {
  const InvalidEmployeeRoleException(String role, [StackTrace? stackTrace])
      : super('Invalid employee role: $role', stackTrace);
}

// Delivery exceptions
class DeliveryException extends AppException {
  const DeliveryException(super.message, [super.stackTrace]);
}

class DeliveryNotFoundException extends DeliveryException {
  const DeliveryNotFoundException(String deliveryId, [StackTrace? stackTrace])
      : super('Delivery with ID $deliveryId not found', stackTrace);
}

class DeliveryAlreadyCompletedException extends DeliveryException {
  const DeliveryAlreadyCompletedException(
    String deliveryId, [
    StackTrace? stackTrace,
  ]) : super('Delivery with ID $deliveryId is already completed', stackTrace);
}

// File exceptions
class FileException extends AppException {
  const FileException(super.message, [super.stackTrace]);
}

class FileNotFoundException extends FileException {
  const FileNotFoundException(String fileName, [StackTrace? stackTrace])
      : super('File $fileName not found', stackTrace);
}

class FileSizeExceededException extends FileException {
  final int maxSize;

  const FileSizeExceededException(this.maxSize, [StackTrace? stackTrace])
      : super('File size exceeds maximum limit of ${maxSize}MB', stackTrace);
}

// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException(super.message, [super.stackTrace]);
}

class MissingConfigurationException extends ConfigurationException {
  const MissingConfigurationException(
    String configKey, [
    StackTrace? stackTrace,
  ]) : super('Missing configuration: $configKey', stackTrace);
}

// Helper function to convert exceptions to user-friendly messages
String getExceptionMessage(Exception exception) {
  if (exception is AppException) {
    return exception.message;
  } else if (exception is FormatException) {
    return 'Invalid data format';
  } else if (exception is ArgumentError) {
    return 'Invalid argument provided';
  } else if (exception is StateError) {
    return 'Application state error';
  } else {
    return 'An unexpected error occurred';
  }
}

// Helper function to check exception type
bool isNetworkException(Exception exception) {
  return exception is NetworkException ||
      exception is NoInternetException ||
      exception is TimeoutException ||
      exception is ServerException;
}

bool isAuthException(Exception exception) {
  return exception is AuthException ||
      exception is InvalidCredentialsException ||
      exception is TokenExpiredException ||
      exception is UnauthorizedException;
}

bool isValidationException(Exception exception) {
  return exception is ValidationException;
}

bool isCodeGenerationException(Exception exception) {
  return exception is CodeGenerationException ||
      exception is CodeLimitExceededException ||
      exception is InvalidCodeFormatException;
}
