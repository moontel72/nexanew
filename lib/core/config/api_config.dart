//lib/core/config/api_config.dart
// API Configuration for NexaTrace System
//
// NOTE: Base URLs are resolved at runtime via Environment.apiBaseUrl
// (same-origin on web, --dart-define override, or IP fallback). All
// endpoint fields are therefore getters, not compile-time constants.

import 'environment.dart';

class ApiConfig {
  // Base URLs — resolved from Environment at runtime.
  static String get baseUrl => Environment.apiBaseUrl;
  static const String apiVersion = 'v1';
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';

  // External product URLs — runtime-resolved so environments are
  // switchable via --dart-define without code changes.
  static String get studioUrl => Environment.studioUrl;

  // Timeout settings
  static const int connectTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds
  static const int sendTimeout = 30000; // milliseconds

  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 2);
}

class AuthEndpoints {
  static String get login => '${ApiConfig.apiBaseUrl}/auth/login';
  static String get register => '${ApiConfig.apiBaseUrl}/auth/register';
  static String get logout => '${ApiConfig.apiBaseUrl}/auth/logout';
  static String get refresh => '${ApiConfig.apiBaseUrl}/auth/refresh';
  static String get forgotPassword =>
      '${ApiConfig.apiBaseUrl}/auth/forgot-password';
  static String get resetPassword =>
      '${ApiConfig.apiBaseUrl}/auth/reset-password';
  static String get verifyEmail => '${ApiConfig.apiBaseUrl}/auth/verify-email';
  static String get profile => '${ApiConfig.apiBaseUrl}/auth/profile';
  static String get changePassword =>
      '${ApiConfig.apiBaseUrl}/auth/change-password';
}

class CompanyEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/companies';
  static String get list => '$base/list';
  static String get create => '$base/create';
  static String get update => '$base/update';
  static String get delete => '$base/delete';
  static String get details => '$base/details';
  static String get statistics => '$base/statistics';
  static String get subscription => '$base/subscription';
  static String get users => '$base/users';
}

class CodeEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/codes';
  static String get bundles => '$base/bundles';
  static String get generate => '$base/generate';
  static String get validate => '$base/validate';
  static String get track => '$base/track';
  static String get statistics => '$base/statistics';
  static String get export => '$base/export';
  static String get import => '$base/import';

  // Specific code type endpoints
  static String get bundleCodes => '$base/bundles';
  static String get cartonCodes => '$base/cartons';
  static String get packetCodes => '$base/packets';
  static String get unitCodes => '$base/units';
}

class PlanEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/plans';
  static String get list => '$base/list';
  static String get create => '$base/create';
  static String get update => '$base/update';
  static String get delete => '$base/delete';
  static String get details => '$base/details';
  static String get features => '$base/features';
  static String get pricing => '$base/pricing';
}

class SubscriptionEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/subscriptions';
  static String get list => '$base/list';
  static String get create => '$base/create';
  static String get update => '$base/update';
  static String get cancel => '$base/cancel';
  static String get renew => '$base/renew';
  static String get history => '$base/history';
  static String get invoices => '$base/invoices';
}

class UserEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/users';
  static String get list => '$base/list';
  static String get create => '$base/create';
  static String get update => '$base/update';
  static String get delete => '$base/delete';
  static String get profile => '$base/profile';
  static String get roles => '$base/roles';
  static String get permissions => '$base/permissions';
}

class FactoryEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/factories';
  static String get list => '$base/list';
  static String get create => '$base/create';
  static String get update => '$base/update';
  static String get delete => '$base/delete';
  static String get details => '$base/details';
  static String get employees => '$base/employees';
  static String get products => '$base/products';
  static String get dashboard => '$base/dashboard';

  // Additional factory endpoints
  static String get factoryContext => '$base/context';
  static String get switchFactoryContext => '$base/switch-context';
  static String get accessibleFactories => '$base/accessible';
  static String get factorySubscription => '$base/{id}/subscription';
  static String get factoryUsage => '$base/{id}/usage';
  static String get updateFactoryUsage => '$base/{id}/update-usage';
  static String get addFactoryEmployee => '$base/{id}/add-employee';
  static String get storeKeepers => '$base/store-keepers';
  static String get drivers => '$base/drivers';
}

class DeliveryEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/deliveries';
  static String get list => '$base/list';
  static String get create => '$base/create';
  static String get update => '$base/update';
  static String get track => '$base/track';
  static String get scan => '$base/scan';
  static String get verify => '$base/verify';
  static String get reports => '$base/reports';
}

class AdminEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/admin';
  static String get dashboard => '$base/dashboard';
  static String get companies => '$base/companies';
  static String get plans => '$base/plans';
  static String get subscriptions => '$base/subscriptions';
  static String get users => '$base/users';
  static String get reports => '$base/reports';
  static String get settings => '$base/settings';
  static String get auditLogs => '$base/audit-logs';
}

class NotificationEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/notifications';
  static String get list => '$base/list';
  static String get markRead => '$base/mark-read';
  static String get markAllRead => '$base/mark-all-read';
  static String get delete => '$base/delete';
  static String get settings => '$base/settings';
}

class ReportEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/reports';
  static String get usage => '$base/usage';
  static String get revenue => '$base/revenue';
  static String get codes => '$base/codes';
  static String get deliveries => '$base/deliveries';
  static String get factories => '$base/factories';
  static String get export => '$base/export';
}

class AnalyticsEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/analytics';
  static String get overview => '$base/overview';
  static String get realtime => '$base/realtime';
  static String get trends => '$base/trends';
  static String get predictions => '$base/predictions';
}

class FileEndpoints {
  static String get base => '${ApiConfig.apiBaseUrl}/files';
  static String get upload => '$base/upload';
  static String get download => '$base/download';
  static String get delete => '$base/delete';
  static String get list => '$base/list';
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
