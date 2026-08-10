//lib/core/config/api_config.dart
// API Configuration for NexaTrace System
// This file contains API endpoints and configuration

import 'environment.dart';

class ApiConfig {
  // Base URLs — resolved from Environment (override via --dart-define=API_BASE_URL=...)
  static const String baseUrl = Environment.apiBaseUrl;
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';

  // Timeout settings
  static const int connectTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds
  static const int sendTimeout = 30000; // milliseconds

  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 2);
}

class AuthEndpoints {
  static const String login = '${ApiConfig.apiBaseUrl}/auth/login';
  static const String register = '${ApiConfig.apiBaseUrl}/auth/register';
  static const String logout = '${ApiConfig.apiBaseUrl}/auth/logout';
  static const String refresh = '${ApiConfig.apiBaseUrl}/auth/refresh';
  static const String forgotPassword =
      '${ApiConfig.apiBaseUrl}/auth/forgot-password';
  static const String resetPassword =
      '${ApiConfig.apiBaseUrl}/auth/reset-password';
  static const String verifyEmail = '${ApiConfig.apiBaseUrl}/auth/verify-email';
  static const String profile = '${ApiConfig.apiBaseUrl}/auth/profile';
  static const String changePassword =
      '${ApiConfig.apiBaseUrl}/auth/change-password';
}

class CompanyEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/companies';
  static const String list = '$base/list';
  static const String create = '$base/create';
  static const String update = '$base/update';
  static const String delete = '$base/delete';
  static const String details = '$base/details';
  static const String statistics = '$base/statistics';
  static const String subscription = '$base/subscription';
  static const String users = '$base/users';
}

class CodeEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/codes';
  static const String bundles = '$base/bundles';
  static const String generate = '$base/generate';
  static const String validate = '$base/validate';
  static const String track = '$base/track';
  static const String statistics = '$base/statistics';
  static const String export = '$base/export';
  static const String import = '$base/import';

  // Specific code type endpoints
  static const String bundleCodes = '$base/bundles';
  static const String cartonCodes = '$base/cartons';
  static const String packetCodes = '$base/packets';
  static const String unitCodes = '$base/units';
}

class PlanEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/plans';
  static const String list = '$base/list';
  static const String create = '$base/create';
  static const String update = '$base/update';
  static const String delete = '$base/delete';
  static const String details = '$base/details';
  static const String features = '$base/features';
  static const String pricing = '$base/pricing';
}

class SubscriptionEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/subscriptions';
  static const String list = '$base/list';
  static const String create = '$base/create';
  static const String update = '$base/update';
  static const String cancel = '$base/cancel';
  static const String renew = '$base/renew';
  static const String history = '$base/history';
  static const String invoices = '$base/invoices';
}

class UserEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/users';
  static const String list = '$base/list';
  static const String create = '$base/create';
  static const String update = '$base/update';
  static const String delete = '$base/delete';
  static const String profile = '$base/profile';
  static const String roles = '$base/roles';
  static const String permissions = '$base/permissions';
}

class FactoryEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/factories';
  static const String list = '$base/list';
  static const String create = '$base/create';
  static const String update = '$base/update';
  static const String delete = '$base/delete';
  static const String details = '$base/details';
  static const String employees = '$base/employees';
  static const String products = '$base/products';
  static const String dashboard = '$base/dashboard';

  // Additional factory endpoints
  static const String factoryContext = '$base/context';
  static const String switchFactoryContext = '$base/switch-context';
  static const String accessibleFactories = '$base/accessible';
  static const String factorySubscription = '$base/{id}/subscription';
  static const String factoryUsage = '$base/{id}/usage';
  static const String updateFactoryUsage = '$base/{id}/update-usage';
  static const String addFactoryEmployee = '$base/{id}/add-employee';
  static const String removeFactoryEmployee = '$base/{id}/remove-employee';
  static const String storeKeepers = '$base/store-keepers';
  static const String drivers = '$base/drivers';
}

class DeliveryEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/deliveries';
  static const String list = '$base/list';
  static const String create = '$base/create';
  static const String update = '$base/update';
  static const String track = '$base/track';
  static const String scan = '$base/scan';
  static const String verify = '$base/verify';
  static const String reports = '$base/reports';
}

class AdminEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/admin';
  static const String dashboard = '$base/dashboard';
  static const String companies = '$base/companies';
  static const String plans = '$base/plans';
  static const String subscriptions = '$base/subscriptions';
  static const String users = '$base/users';
  static const String reports = '$base/reports';
  static const String settings = '$base/settings';
  static const String auditLogs = '$base/audit-logs';
}

class NotificationEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/notifications';
  static const String list = '$base/list';
  static const String markRead = '$base/mark-read';
  static const String markAllRead = '$base/mark-all-read';
  static const String delete = '$base/delete';
  static const String settings = '$base/settings';
}

class ReportEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/reports';
  static const String usage = '$base/usage';
  static const String revenue = '$base/revenue';
  static const String codes = '$base/codes';
  static const String deliveries = '$base/deliveries';
  static const String factories = '$base/factories';
  static const String export = '$base/export';
}

class AnalyticsEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/analytics';
  static const String overview = '$base/overview';
  static const String realtime = '$base/realtime';
  static const String trends = '$base/trends';
  static const String predictions = '$base/predictions';
}

class FileEndpoints {
  static const String base = '${ApiConfig.apiBaseUrl}/files';
  static const String upload = '$base/upload';
  static const String download = '$base/download';
  static const String delete = '$base/delete';
  static const String list = '$base/list';
}

class ApiEndpoints {
  static final auth = AuthEndpoints();
  static final companies = CompanyEndpoints();
  static final codes = CodeEndpoints();
  static final plans = PlanEndpoints();
  static final subscriptions = SubscriptionEndpoints();
  static final users = UserEndpoints();
  static final factories = FactoryEndpoints();
  static final deliveries = DeliveryEndpoints();
  static final admin = AdminEndpoints();
  static final notifications = NotificationEndpoints();
  static final reports = ReportEndpoints();
  static final analytics = AnalyticsEndpoints();
  static final files = FileEndpoints();
}
