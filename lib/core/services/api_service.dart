// API Service for NexaTrace System
// This service provides a higher-level abstraction over ApiClient for business logic

import 'dart:typed_data';
import 'package:trace_odd/core/services/api_client.dart';

class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return _apiClient.get(
      endpoint,
      queryParams: queryParams ?? queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _apiClient.post(
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _apiClient.put(
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _apiClient.patch(
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _apiClient.delete(
      endpoint,
      body: body ?? data,
      queryParams: queryParams ?? queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? fields,
    bool requiresAuth = true,
    Uint8List? fileBytes,
    String? fileName,
  }) {
    return _apiClient.uploadFile(
      endpoint,
      filePath,
      fieldName,
      fields: fields,
      requiresAuth: requiresAuth,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _apiClient.login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      return await _apiClient.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      return await _apiClient.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  // Company management methods
  Future<List<dynamic>> getCompanies({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      return await _apiClient.get(
        '/api/admin/companies',
        queryParams: queryParams,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCompanyById(String companyId) async {
    try {
      return await _apiClient.get('/api/admin/companies/$companyId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCompany(
    Map<String, dynamic> companyData,
  ) async {
    try {
      return await _apiClient.post('/api/admin/companies', body: companyData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCompany(
    String companyId,
    Map<String, dynamic> companyData,
  ) async {
    try {
      return await _apiClient.put(
        '/api/admin/companies/$companyId',
        body: companyData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteCompany(String companyId) async {
    try {
      return await _apiClient.delete('/api/admin/companies/$companyId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCompanyStatus(
    String companyId,
    String status,
  ) async {
    try {
      return await _apiClient.patch(
        '/api/admin/companies/$companyId/status',
        body: {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCompanyStatistics() async {
    try {
      return await _apiClient.get('/api/admin/companies/statistics');
    } catch (e) {
      rethrow;
    }
  }

  // Factory methods
  Future<List<dynamic>> getFactories() async {
    try {
      return await _apiClient.getFactories();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFactoryById(String factoryId) async {
    try {
      return await _apiClient.getFactoryById(factoryId);
    } catch (e) {
      rethrow;
    }
  }

  // Code generation methods
  Future<Map<String, dynamic>> generateBundleCodes(
    Map<String, dynamic> data,
  ) async {
    try {
      return await _apiClient.generateBundleCodes(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateCartonCodes(
    Map<String, dynamic> data,
  ) async {
    try {
      return await _apiClient.generateCartonCodes(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generatePacketCodes(
    Map<String, dynamic> data,
  ) async {
    try {
      return await _apiClient.generatePacketCodes(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateUnitCodes(
    Map<String, dynamic> data,
  ) async {
    try {
      return await _apiClient.generateUnitCodes(data);
    } catch (e) {
      rethrow;
    }
  }

  // Product methods
  Future<List<dynamic>> getProducts() async {
    try {
      return await _apiClient.getProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      return await _apiClient.createProduct(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> linkCodesToProduct(
    String productId,
    List<String> codeIds,
  ) async {
    try {
      return await _apiClient.linkCodesToProduct(productId, codeIds);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> publishProductCodes(String productId) async {
    try {
      return await _apiClient.publishProductCodes(productId);
    } catch (e) {
      rethrow;
    }
  }

  // User management methods
  Future<List<dynamic>> getUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    String? role,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }

      if (companyId != null && companyId.isNotEmpty) {
        queryParams['company_id'] = companyId;
      }

      return await _apiClient.get('/api/admin/users', queryParams: queryParams);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      return await _apiClient.post('/api/admin/users', body: userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      return await _apiClient.put('/api/admin/users/$userId', body: userData);
    } catch (e) {
      rethrow;
    }
  }

  // Subscription methods
  Future<List<dynamic>> getSubscriptions({
    int page = 1,
    int perPage = 20,
    String? status,
    String? companyId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (companyId != null && companyId.isNotEmpty) {
        queryParams['company_id'] = companyId;
      }

      return await _apiClient.get(
        '/api/admin/subscriptions',
        queryParams: queryParams,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> subscriptionData,
  ) async {
    try {
      return await _apiClient.put(
        '/api/admin/subscriptions/$subscriptionId',
        body: subscriptionData,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Clean up
  void dispose() {
    _apiClient.dispose();
  }
}
