//lib/core/services/multi_tenant_service.dart
// Multi Tenant Service for NexaTrace System
// This service handles multi-tenancy and factory data isolation

import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/user_roles.dart';
import '../errors/app_exceptions.dart';
import '../errors/error_logger.dart';

class MultiTenantService {
  final Dio _dio;
  final String? _authToken;

  MultiTenantService({required Dio dio, String? authToken})
    : _dio = dio,
      _authToken = authToken;

  // Get current factory context
  Future<Map<String, dynamic>> getCurrentFactoryContext() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.factoryContext,
        options: Options(headers: _getHeaders()),
      );

      return response.data['data'];
    } catch (error) {
      ErrorLogger.error('Failed to get factory context', error);
      throw _handleError(error);
    }
  }

  // Switch factory context
  Future<void> switchFactoryContext(String factoryId) async {
    try {
      await _dio.post(
        ApiEndpoints.switchFactoryContext,
        data: {'factory_id': factoryId},
        options: Options(headers: _getHeaders()),
      );
    } catch (error) {
      ErrorLogger.error('Failed to switch factory context', error);
      throw _handleError(error);
    }
  }

  // Get all accessible factories for current user
  Future<List<Map<String, dynamic>>> getAccessibleFactories() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.accessibleFactories,
        options: Options(headers: _getHeaders()),
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (error) {
      ErrorLogger.error('Failed to get accessible factories', error);
      throw _handleError(error);
    }
  }

  // Check if user has access to factory
  Future<bool> hasFactoryAccess(String factoryId) async {
    try {
      final factories = await getAccessibleFactories();
      return factories.any((factory) => factory['id'] == factoryId);
    } catch (error) {
      ErrorLogger.error('Failed to check factory access', error);
      return false;
    }
  }

  // Get factory subscription limits
  Future<Map<String, dynamic>> getFactorySubscriptionLimits(
    String factoryId,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.factorySubscription.replaceFirst('{id}', factoryId),
        options: Options(headers: _getHeaders()),
      );

      return response.data['data'];
    } catch (error) {
      ErrorLogger.error('Failed to get factory subscription limits', error);
      throw _handleError(error);
    }
  }

  // Get factory usage statistics
  Future<Map<String, dynamic>> getFactoryUsageStatistics(
    String factoryId,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.factoryUsage.replaceFirst('{id}', factoryId),
        options: Options(headers: _getHeaders()),
      );

      return response.data['data'];
    } catch (error) {
      ErrorLogger.error('Failed to get factory usage statistics', error);
      throw _handleError(error);
    }
  }

  // Check code generation limits
  Future<bool> canGenerateCodes(
    String factoryId,
    String codeType,
    int quantity,
  ) async {
    try {
      final limits = await getFactorySubscriptionLimits(factoryId);
      final usage = await getFactoryUsageStatistics(factoryId);

      final codeTypeKey = '${codeType}_codes';
      final limit = limits[codeTypeKey] as int? ?? 0;
      final used = usage[codeTypeKey] as int? ?? 0;

      return used + quantity <= limit;
    } catch (error) {
      ErrorLogger.error('Failed to check code generation limits', error);
      throw _handleError(error);
    }
  }

  // Get remaining code quota
  Future<int> getRemainingCodeQuota(String factoryId, String codeType) async {
    try {
      final limits = await getFactorySubscriptionLimits(factoryId);
      final usage = await getFactoryUsageStatistics(factoryId);

      final codeTypeKey = '${codeType}_codes';
      final limit = limits[codeTypeKey] as int? ?? 0;
      final used = usage[codeTypeKey] as int? ?? 0;

      return limit - used;
    } catch (error) {
      ErrorLogger.error('Failed to get remaining code quota', error);
      throw _handleError(error);
    }
  }

  // Update factory usage
  Future<void> updateFactoryUsage(
    String factoryId,
    String codeType,
    int quantity,
  ) async {
    try {
      await _dio.post(
        ApiEndpoints.updateFactoryUsage.replaceFirst('{id}', factoryId),
        data: {
          'factory_id': factoryId,
          'code_type': codeType,
          'quantity': quantity,
        },
        options: Options(headers: _getHeaders()),
      );
    } catch (error) {
      ErrorLogger.error('Failed to update factory usage', error);
      throw _handleError(error);
    }
  }

  // Get factory employees
  Future<List<Map<String, dynamic>>> getFactoryEmployees(
    String factoryId,
    String? role,
  ) async {
    try {
      String endpoint;
      if (role == UserRoles.storeKeeper) {
        endpoint = ApiEndpoints.storeKeepers;
      } else if (role == UserRoles.driver) {
        endpoint = ApiEndpoints.drivers;
      } else {
        endpoint = ApiEndpoints.employees.replaceFirst('{id}', factoryId);
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: role != null ? {'role': role} : null,
        options: Options(headers: _getHeaders()),
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (error) {
      ErrorLogger.error('Failed to get factory employees', error);
      throw _handleError(error);
    }
  }

  // Add employee to factory
  Future<void> addEmployeeToFactory(
    String factoryId,
    Map<String, dynamic> employeeData,
  ) async {
    try {
      await _dio.post(
        ApiEndpoints.addFactoryEmployee.replaceFirst('{id}', factoryId),
        data: {'factory_id': factoryId, ...employeeData},
        options: Options(headers: _getHeaders()),
      );
    } catch (error) {
      ErrorLogger.error('Failed to add employee to factory', error);
      throw _handleError(error);
    }
  }

  // Remove employee from factory
  Future<void> removeEmployeeFromFactory(
    String factoryId,
    String employeeId,
  ) async {
    try {
      await _dio.delete(
        ApiEndpoints.removeFactoryEmployee.replaceFirst('{id}', factoryId),
        data: {'factory_id': factoryId, 'employee_id': employeeId},
        options: Options(headers: _getHeaders()),
      );
    } catch (error) {
      ErrorLogger.error('Failed to remove employee from factory', error);
      throw _handleError(error);
    }
  }

  // Get factory products
  Future<List<Map<String, dynamic>>> getFactoryProducts(
    String factoryId, {
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.products.replaceFirst('{id}', factoryId),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        options: Options(headers: _getHeaders()),
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (error) {
      ErrorLogger.error('Failed to get factory products', error);
      throw _handleError(error);
    }
  }

  // Get factory codes
  Future<List<Map<String, dynamic>>> getFactoryCodes(
    String factoryId,
    String codeType, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String endpoint;
      switch (codeType) {
        case 'bundle':
          endpoint = ApiEndpoints.bundleCodes;
          break;
        case 'carton':
          endpoint = ApiEndpoints.cartonCodes;
          break;
        case 'packet':
          endpoint = ApiEndpoints.packetCodes;
          break;
        case 'unit':
          endpoint = ApiEndpoints.unitCodes;
          break;
        default:
          throw ArgumentError('Invalid code type: $codeType');
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'factory_id': factoryId,
          if (status != null && status.isNotEmpty) 'status': status,
          'page': page,
          'limit': limit,
        },
        options: Options(headers: _getHeaders()),
      );

      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (error) {
      ErrorLogger.error('Failed to get factory codes', error);
      throw _handleError(error);
    }
  }

  // Validate factory access for operation
  Future<void> validateFactoryAccess(String factoryId, String operation) async {
    final hasAccess = await hasFactoryAccess(factoryId);
    if (!hasAccess) {
      throw UnauthorizedException(
        'You do not have access to factory $factoryId for operation: $operation',
      );
    }
  }

  // Get factory dashboard data
  Future<Map<String, dynamic>> getFactoryDashboardData(String factoryId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.factoryDashboard.replaceFirst('{id}', factoryId),
        options: Options(headers: _getHeaders()),
      );

      return response.data['data'];
    } catch (error) {
      ErrorLogger.error('Failed to get factory dashboard data', error);
      throw _handleError(error);
    }
  }

  // Private helper methods
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException();
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          if (statusCode == 401) {
            return UnauthorizedException();
          } else if (statusCode == 403) {
            return UnauthorizedException('Access forbidden');
          } else if (statusCode == 404) {
            return FactoryNotFoundException('Factory not found');
          } else if (statusCode == 422) {
            return ValidationException(
              Map<String, String>.from(responseData['errors'] ?? {}),
            );
          } else {
            return ServerException(
              'Server error: $statusCode',
              statusCode ?? 500,
              responseData ?? 'No response data',
            );
          }
        case DioExceptionType.cancel:
          return NetworkException('Request cancelled');
        case DioExceptionType.unknown:
          if (error.error?.toString().contains('SocketException') == true) {
            return NoInternetException();
          }
          return NetworkException('Network error: ${error.message}');
        default:
          return NetworkException('Network error: ${error.message}');
      }
    }

    return NetworkException('Unexpected error: $error');
  }
}
