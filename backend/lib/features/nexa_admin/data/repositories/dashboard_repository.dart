// Dashboard Repository for NexaTrace System
// Simplified version to fix compilation errors

import 'package:nexatrace_system/core/config/api_config.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/shared/models/dashboard/dashboard_models.dart';

/// Dashboard Repository
class DashboardRepository {
  final ApiClient apiClient;

  DashboardRepository({
    required this.apiClient,
  });

  /// Get complete dashboard data
  Future<DashboardData> getDashboardData() async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard',
      );

      return DashboardData.fromApi(
        (response['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    } catch (error) {
      if (error is NetworkException) {
        throw NetworkException('Failed to fetch dashboard data: Network error');
      } else {
        throw Exception('Failed to fetch dashboard data: ${error.toString()}');
      }
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/statistics',
      );

      return response['data'];
    } catch (error) {
      throw Exception('Failed to fetch statistics: ${error.toString()}');
    }
  }

  /// Get revenue data for time period
  Future<List<Map<String, dynamic>>> getRevenueData({
    String period = 'monthly',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'period': period,
      };

      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/revenue',
        queryParams: queryParameters,
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (error) {
      throw Exception('Failed to fetch revenue data: ${error.toString()}');
    }
  }

  /// Get usage data for time period
  Future<List<Map<String, dynamic>>> getUsageData({
    String period = 'monthly',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'period': period,
      };

      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/usage',
        queryParams: queryParameters,
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (error) {
      throw Exception('Failed to fetch usage data: ${error.toString()}');
    }
  }

  /// Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/activities',
        queryParams: {'limit': limit},
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (error) {
      throw Exception('Failed to fetch recent activities: ${error.toString()}');
    }
  }

  /// Get top companies by usage
  Future<List<Map<String, dynamic>>> getTopCompanies({
    int limit = 10,
    String sortBy = 'usage',
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/top-companies',
        queryParams: {
          'limit': limit,
          'sort_by': sortBy,
        },
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (error) {
      throw Exception('Failed to fetch top companies: ${error.toString()}');
    }
  }

  /// Get system health status
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/system-health',
      );

      return response['data'];
    } catch (error) {
      throw Exception('Failed to fetch system health: ${error.toString()}');
    }
  }

  /// Get audit logs
  Future<Map<String, dynamic>> getAuditLogs({
    int page = 1,
    int limit = 20,
    String? action,
    String? entityType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (action != null) queryParameters['action'] = action;
      if (entityType != null) queryParameters['entity_type'] = entityType;
      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/audit-logs',
        queryParams: queryParameters,
      );

      return response;
    } catch (error) {
      throw Exception('Failed to fetch audit logs: ${error.toString()}');
    }
  }

  /// Get subscription analytics
  Future<Map<String, dynamic>> getSubscriptionAnalytics({
    String period = 'monthly',
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/subscription-analytics',
        queryParams: {'period': period},
      );

      return response['data'];
    } catch (error) {
      throw Exception(
          'Failed to fetch subscription analytics: ${error.toString()}');
    }
  }

  /// Get code generation analytics
  Future<Map<String, dynamic>> getCodeGenerationAnalytics({
    String period = 'monthly',
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/code-analytics',
        queryParams: {'period': period},
      );

      return response['data'];
    } catch (error) {
      throw Exception('Failed to fetch code analytics: ${error.toString()}');
    }
  }

  /// Get user growth data
  Future<List<Map<String, dynamic>>> getUserGrowthData({
    String period = 'monthly',
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/user-growth',
        queryParams: {'period': period},
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (error) {
      throw Exception('Failed to fetch user growth data: ${error.toString()}');
    }
  }

  /// Export dashboard data
  Future<String> exportDashboardData({
    String format = 'csv',
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'format': format,
      };

      if (reportType != null) queryParameters['report_type'] = reportType;
      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/export',
        queryParams: queryParameters,
      );

      return response['data']['download_url'];
    } catch (error) {
      throw Exception('Failed to export dashboard data: ${error.toString()}');
    }
  }

  /// Get real-time metrics
  Future<Map<String, dynamic>> getRealtimeMetrics() async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/realtime-metrics',
      );

      return response['data'];
    } catch (error) {
      throw Exception('Failed to fetch real-time metrics: ${error.toString()}');
    }
  }

  /// Get alerts and notifications
  Future<List<Map<String, dynamic>>> getAlerts({
    String? severity,
    bool? resolved,
    int limit = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
      };

      if (severity != null) queryParameters['severity'] = severity;
      if (resolved != null) queryParameters['resolved'] = resolved;

      final response = await apiClient.get(
        '${ApiConfig.apiBaseUrl}/admin/dashboard/alerts',
        queryParams: queryParameters,
      );

      return List<Map<String, dynamic>>.from(response['data']);
    } catch (error) {
      throw Exception('Failed to fetch alerts: ${error.toString()}');
    }
  }
}
