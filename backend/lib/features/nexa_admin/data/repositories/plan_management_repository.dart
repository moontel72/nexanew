// Plan Management Repository for NexaTrace System
// Simplified version to fix compilation errors

import 'package:nexatrace_system/core/config/api_config.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_model.dart';
import 'package:nexatrace_system/shared/models/subscription/plan_type.dart';

/// Plan response model
class PlansResponse {
  final List<Plan> plans;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PlansResponse({
    required this.plans,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PlansResponse.fromJson(Map<String, dynamic> json) {
    // Defensive parsing for plans response
    final data = json['data'];
    List<Plan> plans = [];

    if (data is List) {
      plans = data.map((plan) {
        if (plan is Map) {
          try {
            return Plan.fromJson(Map<String, dynamic>.from(plan));
          } catch (e) {
            // Return a default plan if parsing fails
            return Plan(
              id: 'unknown',
              name: 'Unknown Plan',
              type: PlanType.basic,
              description: '',
              monthlyPrice: 0.0,
              yearlyPrice: 0.0,
              billingCycle: 'monthly',
              status: PlanStatus.active,
              features: [],
              userLimits: const UserLimits(
                storeKeepers: 1,
                drivers: 1,
                adminUsers: 1,
                activeProducts: 1,
              ),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }
        return Plan(
          id: 'unknown',
          name: 'Unknown Plan',
          type: PlanType.basic,
          description: '',
          monthlyPrice: 0.0,
          yearlyPrice: 0.0,
          billingCycle: 'monthly',
          status: PlanStatus.active,
          features: [],
          userLimits: const UserLimits(
            storeKeepers: 1,
            drivers: 1,
            adminUsers: 1,
            activeProducts: 1,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    }

    return PlansResponse(
      plans: plans,
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Plan Management Repository
class PlanManagementRepository {
  final ApiClient apiClient;

  PlanManagementRepository({required this.apiClient});

  /// Get all subscription plans
  Future<PlansResponse> getPlans({
    String search = '',
    String? type,
    String? status,
    int page = 1,
    int limit = 10,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans',
        queryParams: {
          'search': search,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
          'page': page,
          'limit': limit,
          'sort_by': sortBy,
          'sort_order': sortOrder,
        },
      );

      if (response is List) {
        final plans = response
            .whereType<Map>()
            .map((e) => Plan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return PlansResponse(
          plans: plans,
          total: plans.length,
          page: 1,
          limit: plans.length,
          totalPages: 1,
        );
      }

      if (response is Map) {
        final map = Map<String, dynamic>.from(response);
        final data = map['data'];

        if (data is List) {
          return PlansResponse.fromJson({...map, 'data': data});
        }

        if (data is Map && data['data'] is List) {
          return PlansResponse.fromJson({
            ...map,
            'data': data['data'],
            'total': map['total'] ?? data['total'] ?? 0,
            'page': map['page'] ?? data['page'] ?? 1,
            'limit': map['limit'] ?? data['limit'] ?? 10,
            'total_pages': map['total_pages'] ?? data['total_pages'] ?? 1,
          });
        }
      }

      throw Exception('Unexpected response shape for plans list');
    } catch (error) {
      if (error is NetworkException) {
        throw NetworkException('Failed to fetch plans: Network error');
      } else {
        throw Exception('Failed to fetch plans: ${error.toString()}');
      }
    }
  }

  /// Get plan by ID
  Future<Plan> getPlanById(String planId) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId',
      );

      if (response is! Map) {
        throw Exception('Invalid response format');
      }

      final data = response['data'];
      if (data is! Map) {
        throw Exception('Invalid plan data format');
      }

      return Plan.fromJson(Map<String, dynamic>.from(data));
    } catch (error) {
      if (error is NotFoundException) {
        throw Exception('Plan not found');
      } else {
        throw Exception('Failed to fetch plan: ${error.toString()}');
      }
    }
  }

  /// Create new plan
  Future<Plan> createPlan(Map<String, dynamic> planData) async {
    try {
      final response = await apiClient.post(
        '${ApiConfig.apiBaseUrl}/admin/plans',
        body: planData,
      );

      if (response is! Map) {
        throw Exception('Invalid response format');
      }

      final data = response['data'];
      if (data is! Map) {
        throw Exception('Invalid plan data format');
      }

      return Plan.fromJson(Map<String, dynamic>.from(data));
    } catch (error) {
      if (error is ValidationException) {
        rethrow;
      } else {
        throw Exception('Failed to create plan: ${error.toString()}');
      }
    }
  }

  /// Update plan
  Future<Plan> updatePlan(String planId, Map<String, dynamic> planData) async {
    try {
      final response = await apiClient.put(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId',
        body: planData,
      );

      if (response is! Map) {
        throw Exception('Invalid response format');
      }

      final data = response['data'];
      if (data is! Map) {
        throw Exception('Invalid plan data format');
      }

      return Plan.fromJson(Map<String, dynamic>.from(data));
    } catch (error) {
      if (error is ValidationException) {
        rethrow;
      } else {
        throw Exception('Failed to update plan: ${error.toString()}');
      }
    }
  }

  /// Update plan status
  Future<void> updatePlanStatus({
    required String planId,
    required String status,
  }) async {
    try {
      await apiClient.put(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/status',
        body: {'status': status},
      );
    } catch (error) {
      if (error is ValidationException) {
        rethrow;
      } else {
        throw Exception('Failed to update plan status: ${error.toString()}');
      }
    }
  }

  /// Delete plan
  Future<void> deletePlan(String planId) async {
    try {
      await apiClient.delete('${ApiConfig.apiBaseUrl}/admin/plans/$planId');
    } catch (error) {
      if (error is NotFoundException) {
        throw Exception('Plan not found');
      } else {
        throw Exception('Failed to delete plan: ${error.toString()}');
      }
    }
  }

  /// Get plan statistics
  Future<Map<String, dynamic>> getPlanStatistics() async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans/statistics',
      );

      if (response is! Map) {
        return {};
      }

      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (error) {
      throw Exception('Failed to fetch plan statistics: ${error.toString()}');
    }
  }

  /// Get plan features
  Future<List<Map<String, dynamic>>> getPlanFeatures() async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans/features',
      );

      if (response is! Map) {
        return [];
      }

      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (error) {
      throw Exception('Failed to fetch plan features: ${error.toString()}');
    }
  }

  /// Update plan features
  Future<void> updatePlanFeatures(
    String planId,
    List<Map<String, dynamic>> features,
  ) async {
    try {
      await apiClient.put(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/features',
        body: {'features': features},
      );
    } catch (error) {
      throw Exception('Failed to update plan features: ${error.toString()}');
    }
  }

  /// Get plan pricing
  Future<Map<String, dynamic>> getPlanPricing(String planId) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/pricing',
      );

      if (response is! Map) {
        return {};
      }

      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (error) {
      throw Exception('Failed to fetch plan pricing: ${error.toString()}');
    }
  }

  /// Update plan pricing
  Future<void> updatePlanPricing(
    String planId,
    Map<String, dynamic> pricing,
  ) async {
    try {
      await apiClient.put(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/pricing',
        body: pricing,
      );
    } catch (error) {
      throw Exception('Failed to update plan pricing: ${error.toString()}');
    }
  }

  /// Export plans to CSV
  Future<String> exportPlans({
    String search = '',
    String? type,
    String? status,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans/export',
        queryParams: {
          'search': search,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
          'format': 'csv',
        },
      );

      if (response is! Map) {
        throw Exception('Invalid response format');
      }

      final data = response['data'];
      if (data is! Map) {
        throw Exception('Invalid data format');
      }

      final downloadUrl = data['download_url'];
      if (downloadUrl is! String) {
        throw Exception('Invalid download URL');
      }

      return downloadUrl;
    } catch (error) {
      throw Exception('Failed to export plans: ${error.toString()}');
    }
  }

  /// Import plans from CSV
  Future<void> importPlans(String filePath) async {
    try {
      await apiClient.uploadFile(
        '${ApiConfig.apiBaseUrl}/admin/plans/import',
        filePath,
        'file',
      );
    } catch (error) {
      if (error is ValidationException) {
        rethrow;
      } else {
        throw Exception('Failed to import plans: ${error.toString()}');
      }
    }
  }

  /// Validate plan data
  Future<Map<String, dynamic>> validatePlanData(
    Map<String, dynamic> planData,
  ) async {
    try {
      final response = await apiClient.post(
        '${ApiConfig.apiBaseUrl}/admin/plans/validate',
        body: planData,
      );

      if (response is! Map) {
        return {
          'valid': false,
          'errors': ['Invalid response format'],
        };
      }

      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {
        'valid': false,
        'errors': ['Invalid data format'],
      };
    } catch (error) {
      if (error is ValidationException) {
        return {'valid': false, 'errors': error.errors};
      } else {
        throw Exception('Failed to validate plan data: ${error.toString()}');
      }
    }
  }

  /// Duplicate plan
  Future<Plan> duplicatePlan(String planId) async {
    try {
      final response = await apiClient.post(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/duplicate',
      );

      if (response is! Map) {
        throw Exception('Invalid response format');
      }

      final data = response['data'];
      if (data is! Map) {
        throw Exception('Invalid plan data format');
      }

      return Plan.fromJson(Map<String, dynamic>.from(data));
    } catch (error) {
      throw Exception('Failed to duplicate plan: ${error.toString()}');
    }
  }

  /// Change plan status
  Future<void> changePlanStatus(String planId, String status) async {
    try {
      await apiClient.put(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/status',
        body: {'status': status},
      );
    } catch (error) {
      throw Exception('Failed to change plan status: ${error.toString()}');
    }
  }

  /// Get plan usage statistics
  Future<Map<String, dynamic>> getPlanUsageStatistics(String planId) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/usage',
      );

      if (response is! Map) {
        return {};
      }

      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (error) {
      throw Exception('Failed to fetch plan usage: ${error.toString()}');
    }
  }

  /// Get companies using this plan
  Future<Map<String, dynamic>> getPlanCompanies(
    String planId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/plans/$planId/companies',
        queryParams: {'page': page, 'limit': limit},
      );

      if (response is! Map) {
        return {};
      }

      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (error) {
      throw Exception('Failed to fetch plan companies: ${error.toString()}');
    }
  }
}
