//lib/core/constants/api_endpoints.dart
// API Endpoints for NexaTrace System
// This file defines all API endpoints used in the application
// Version: 2.0 - Comprehensive structure with all endpoints
// Includes backward compatibility for existing code

class ApiEndpoints {
  // Base URL - should be loaded from environment variables
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://135.181.46.27/api/v1',
  );

  // ==================== AUTHENTICATION ENDPOINTS ====================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String changePassword = '/auth/change-password';
  static const String profile = '/auth/profile';

  // ==================== USER ENDPOINTS ====================
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String userPreferences = '/user/preferences';
  static const String userNotifications = '/user/notifications';

  // ==================== ADMIN ENDPOINTS ====================
  // Dashboard
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStats = '/admin/dashboard/stats';
  static const String adminFilters = '/admin/dashboard/filters';

  // Factory Management (Nexa Admin)
  static const String adminFactories = '/admin/companies';
  static const String adminCompanies = adminFactories;
  static const String adminRegisterFactory = '/admin/companies';
  static const String adminApproveFactory = '/admin/companies/{id}/approve';
  static const String adminSuspendFactory = '/admin/companies/{id}/suspend';
  static const String adminFactoryDetails = '/admin/companies/{id}';
  static const String adminCompanyDetails = adminFactoryDetails;
  static const String adminFactoryStats = '/admin/companies/statistics';
  static const String adminCompanyStats = adminFactoryStats;
  static const String adminFactoryPlans = '/admin/plans';
  static const String adminFactorySubscriptions = '/admin/subscriptions';
  static const String adminFactoryExport = '/admin/companies/export';
  static const String adminUpdateFactoryStatus = '/admin/companies/{id}/status';
  static const String adminUpdateVerificationStatus =
      '/admin/companies/{id}/verification-status';
  static const String adminAssignPlan = '/admin/companies/{id}/assign-plan';
  static const String adminUploadDocument = '/admin/companies/{id}/documents';
  static const String adminDeleteDocument =
      '/admin/companies/{id}/documents/{document}';
  static const String adminSendWelcomeEmail =
      '/admin/companies/{id}/send-welcome-email';
  static const String adminResetCompanyPassword =
      '/admin/companies/{id}/reset-password';

  // Plan Management
  static const String adminPlans = '/admin/plans';
  static const String adminPlanDetails = '/admin/plans/{id}';
  static const String adminPlanLimits = '/admin/plans/limits';
  static const String adminUpdatePlan = '/admin/plans/{id}';
  static const String adminPlanStatistics = '/admin/plans/statistics';
  static const String adminPlanFeatures = '/admin/plans/features';
  static const String adminPlanExport = '/admin/plans/export';
  static const String adminDuplicatePlan = '/admin/plans/{id}/duplicate';

  // Payment Management
  static const String adminPayments = '/admin/payments';
  static const String adminPaymentDetails = '/admin/payments/{id}';
  static const String adminPaymentHistory = '/admin/payments/history';
  static const String adminInvoice = '/admin/payments/invoice/{id}';

  // User Management
  static const String adminUsers = '/admin/users';
  static const String adminUserDetails = '/admin/users/{id}';
  static const String adminCreateUser = '/admin/users';
  static const String adminUpdateUser = '/admin/users/{id}';

  // Subscription Management
  static const String adminSubscriptions = '/admin/subscriptions';
  static const String adminSubscriptionDetails = '/admin/subscriptions/{id}';
  static const String adminUpdateSubscription = '/admin/subscriptions/{id}';

  // Billing Management
  static const String adminBillingInvoices = '/admin/billing/invoices';
  static const String adminBillingSubscriptions =
      '/admin/billing/subscriptions';
  static const String adminBillingTransactions = '/admin/billing/transactions';

  // Reports
  static const String adminReportsUsage = '/admin/reports/usage';
  static const String adminReportsRevenue = '/admin/reports/revenue';
  static const String adminReportsAuditLogs = '/admin/reports/audit-logs';

  // Settings
  static const String adminSettingsSystem = '/admin/settings/system';
  static const String adminSettingsEmailTemplates =
      '/admin/settings/email-templates';
  static const String adminSettingsApiKeys = '/admin/settings/api-keys';

  // ==================== ADMIN TRANSPORT ENDPOINTS ====================
  static const String adminTransportWalletStats =
      '/admin/transport/wallet/stats';
  static const String adminTransportMarketplaceStats =
      '/admin/transport/marketplace/stats';
  static const String adminTransportDriversStats =
      '/admin/transport/drivers/stats';

  // Transport fraud stats (documented in PROJECT_MASTER.md)
  static const String transportFraudStats = '/transport/fraud/stats';

  // ==================== CODE GENERATION ENDPOINTS ====================
  // General Code Endpoints
  static const String generateCodes = '/codes/generate';
  static const String validateCodes = '/codes/validate';
  static const String downloadCodes = '/codes/download';

  // Bundle Codes
  static const String bundleCodes = '/codes/bundle';
  static const String generateBundleCodes = '/codes/bundle/generate';
  static const String bundleCodesList = '/codes/bundle/list';
  static const String bundleCodeDetails = '/codes/bundle/{id}';
  static const String deleteBundleCodes = '/codes/bundle/delete';
  static const String downloadBundleCodes = '/codes/bundle/download';
  static const String linkBundleCodes = '/codes/bundle/link';
  static const String publishBundleCodes = '/codes/bundle/publish';

  // Carton Codes
  static const String cartonCodes = '/codes/carton';
  static const String generateCartonCodes = '/codes/carton/generate';
  static const String cartonCodesList = '/codes/carton/list';
  static const String cartonCodeDetails = '/codes/carton/{id}';
  static const String deleteCartonCodes = '/codes/carton/delete';
  static const String downloadCartonCodes = '/codes/carton/download';
  static const String linkCartonCodes = '/codes/carton/link';
  static const String publishCartonCodes = '/codes/carton/publish';
  static const String cartonBatches = '/codes/carton/batches';
  static const String deleteCartonBatch = '/codes/carton/batch/delete';

  // Carton Code Format-specific endpoints
  // POST /v1/codes/carton/{format}/generate -- generate codes for specific format
  // GET /v1/codes/carton/{format}/list -- list codes for specific format
  static String generateCartonCodesByFormat(String format) =>
      '/codes/carton/$format/generate';
  static String listCartonCodesByFormat(String format) =>
      '/codes/carton/$format/list';

  // Packet Codes
  static const String packetCodes = '/codes/packet';
  static const String generatePacketCodes = '/codes/packet/generate';
  static const String packetCodesList = '/codes/packet/list';
  static const String packetCodeDetails = '/codes/packet/{id}';
  static const String deletePacketCodes = '/codes/packet/delete';
  static const String downloadPacketCodes = '/codes/packet/download';
  static const String linkPacketCodes = '/codes/packet/link';
  static const String publishPacketCodes = '/codes/packet/publish';

  // Unit Codes (Authentication Codes)
  static const String unitCodes = '/codes/unit';
  static const String generateUnitCodes = '/codes/unit/generate';
  static const String unitCodesList = '/codes/unit/list';
  static const String unitCodeDetails = '/codes/unit/{id}';
  static const String linkUnitCodes = '/codes/unit/link';
  static const String publishUnitCodes = '/codes/unit/publish';
  static const String deleteUnitCodes = '/codes/unit/delete';
  static const String downloadUnitCodes = '/codes/unit/download';

  // ==================== PRODUCT ENDPOINTS ====================
  static const String factoryAuth = '/factory/auth';
  static const String factoryLogin = '/factory/auth/login';
  static const String factoryLogout = '/factory/auth/logout';
  static const String factoryProfile = '/factory/auth/profile';

  static const String products = '/factory/products';
  static const String createProduct = '/factory/products';
  static const String productDetails = '/factory/products/{id}';
  static const String updateProduct = '/factory/products/{id}';
  static const String deleteProduct = '/factory/products/{id}';
  static const String productTypes = '/factory/products/types';
  static const String productCategories = '/factory/products/categories';
  static const String linkCodesToProduct = '/factory/products/{id}/link-codes';
  static const String productCodes = '/factory/products/{id}/codes';
  static const String publishProductCodes =
      '/factory/products/{id}/publish-codes';

  // ==================== STORE KEEPER ENDPOINTS ====================
  static const String storeKeeperDashboard = '/store/dashboard';
  static const String createBundle = '/store/bundles';
  static const String createCarton = '/store/cartons';
  static const String createPacket = '/store/packets';
  static const String scanCodes = '/store/scan';
  static const String inventory = '/store/inventory';
  static const String updateInventory = '/store/inventory/update';
  static const String bundleDetails = '/store/bundles/{id}';
  static const String cartonDetails = '/store/cartons/{id}';
  static const String packetDetails = '/store/packets/{id}';

  // ==================== DRIVER ENDPOINTS ====================
  static const String driverDashboard = '/driver/dashboard';
  static const String assignedDeliveries = '/driver/deliveries';
  static const String acceptDelivery = '/driver/deliveries/accept';
  static const String startDelivery = '/driver/deliveries/start';
  static const String completeDelivery = '/driver/deliveries/complete';
  static const String updateLocation = '/driver/location';
  static const String deliveryDetails = '/driver/deliveries/{id}';
  static const String deliveryHistory = '/driver/history';
  static const String trackDelivery = '/driver/deliveries/{id}/track';

  // ==================== RESELLER ENDPOINTS ====================
  static const String resellerDashboard = '/reseller/dashboard';
  static const String browseProducts = '/reseller/products';
  static const String placeOrder = '/reseller/orders';
  static const String orderHistory = '/reseller/orders/history';
  static const String orderDetails = '/reseller/orders/{id}';
  static const String receiveDelivery = '/reseller/receive';
  static const String forwardToShop = '/reseller/forward';
  static const String availableFactories = '/reseller/factories';

  // ==================== SHOP ENDPOINTS ====================
  static const String shopDashboard = '/shop/dashboard';
  static const String browseSuppliers = '/shop/suppliers';
  static const String purchaseOrder = '/shop/purchases';
  static const String purchaseHistory = '/shop/purchases/history';
  static const String verifyProduct = '/shop/verify';
  static const String verificationResult = '/shop/verify/result';
  static const String shopInventory = '/shop/inventory';

  // ==================== CUSTOMER ENDPOINTS ====================
  static const String customerDashboard = '/customer/dashboard';
  static const String scanProduct = '/customer/scan';
  static const String verifyAuthenticity = '/customer/verify';
  static const String productDetailsCustomer = '/customer/product/{id}';
  static const String reportFake = '/customer/report';
  static const String scanHistory = '/customer/history';

  // ==================== MULTI-TENANT ENDPOINTS ====================
  static const String switchContext = '/tenant/switch';
  static const String currentContext = '/tenant/current';
  static const String accessibleTenants = '/tenant/accessible';
  static const String tenantDetails = '/tenant/{id}';
  static const String tenantSettings = '/tenant/settings';
  static const String tenantUsage = '/tenant/usage';
  static const String tenantLimits = '/tenant/limits';
  static const String factoryContext = '/factories/context';
  static const String switchFactoryContext = '/factories/switch-context';
  static const String accessibleFactories = '/factories/accessible';

  // ==================== DASHBOARD & ANALYTICS ENDPOINTS ====================
  static const String factoryDashboard = '/factory/dashboard';
  static const String analytics = '/analytics';
  static const String reports = '/reports';
  static const String usageStats = '/stats/usage';
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsRealtime = '/analytics/realtime';
  static const String analyticsTrends = '/analytics/trends';
  static const String analyticsPredictions = '/analytics/predictions';

  // ==================== FILE MANAGEMENT ENDPOINTS ====================
  static const String fileUpload = '/files/upload';
  static const String fileDownload = '/files/download';
  static const String fileDelete = '/files/delete';
  static const String fileList = '/files/list';

  // ==================== NOTIFICATION ENDPOINTS ====================
  static const String notificationsList = '/notifications/list';
  static const String notificationsMarkRead = '/notifications/mark-read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static const String notificationsDelete = '/notifications/delete';
  static const String notificationsSettings = '/notifications/settings';

  // ==================== HEALTH CHECK ENDPOINTS ====================
  static const String healthCheck = '/health';
  static const String databaseHealth = '/database/health';
  static const String databaseBackup = '/database/backup';
  static const String databaseRestore = '/database/restore';
  static const String databaseStats = '/database/stats';

  // ==================== BACKWARD COMPATIBILITY CONSTANTS ====================
  // These constants are kept for backward compatibility with existing code

  // Factory endpoints (legacy)
  static const String factories = adminFactories;
  static const String factoryById = adminFactoryDetails;
  static const String factorySubscription = '/factories/{id}/subscription';
  static const String factoryUsage = '/factories/{id}/usage';
  static const String updateFactoryUsage = '/factories/{id}/update-usage';
  static const String employees = '/factories/{id}/employees';
  static const String addFactoryEmployee = '/factories/{id}/add-employee';
  static const String removeFactoryEmployee = '/factories/{id}/remove-employee';

  // Employee endpoints (legacy)
  static const String storeKeepers = '/employees/store-keepers';
  static const String drivers = '/employees/drivers';

  // Subscription and billing endpoints (legacy)
  static const String plans = adminPlans;
  static const String subscriptions = adminSubscriptions;
  static const String payments = adminPayments;

  // Universal app endpoints (legacy)
  static const String resellerOrders = '/reseller/orders';
  static const String shopPurchases = '/shop/purchases';
  static const String customerVerification = '/customer/verify';

  // Delivery and tracking endpoints (legacy)
  static const String legacyDeliveries = '/deliveries';
  static const String legacyTrackDelivery = '/deliveries/{id}/track';

  // Reports and analytics (legacy)
  static const String legacyReports = '/reports';
  static const String legacyAnalytics = '/analytics';

  // ==================== HELPER METHODS ====================

  // Helper method to build full URLs
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }

  // Helper to build URL with path parameters
  static String buildUrl(String endpoint, Map<String, String> params) {
    String url = baseUrl + endpoint;
    params.forEach((key, value) {
      url = url.replaceFirst('{$key}', value);
    });
    return url;
  }

  // Helper to get admin factory details URL
  static String getAdminFactoryDetailsUrl(String factoryId) {
    return getFullUrl(adminFactoryDetails.replaceFirst('{id}', factoryId));
  }

  // Helper to get admin plan details URL
  static String getAdminPlanDetailsUrl(String planId) {
    return getFullUrl(adminPlanDetails.replaceFirst('{id}', planId));
  }

  // Helper to get product details URL
  static String getProductDetailsUrl(String productId) {
    return getFullUrl(productDetails.replaceFirst('{id}', productId));
  }

  // Helper to get bundle code details URL
  static String getBundleCodeDetailsUrl(String codeId) {
    return getFullUrl(bundleCodeDetails.replaceFirst('{id}', codeId));
  }

  // Helper to get carton code details URL
  static String getCartonCodeDetailsUrl(String codeId) {
    return getFullUrl(cartonCodeDetails.replaceFirst('{id}', codeId));
  }

  // Helper to get packet code details URL
  static String getPacketCodeDetailsUrl(String codeId) {
    return getFullUrl(packetCodeDetails.replaceFirst('{id}', codeId));
  }

  // Helper to get unit code details URL
  static String getUnitCodeDetailsUrl(String codeId) {
    return getFullUrl(unitCodeDetails.replaceFirst('{id}', codeId));
  }

  // Helper to get delivery details URL
  static String getDeliveryDetailsUrl(String deliveryId) {
    return getFullUrl(deliveryDetails.replaceFirst('{id}', deliveryId));
  }

  // Helper to get order details URL
  static String getOrderDetailsUrl(String orderId) {
    return getFullUrl(orderDetails.replaceFirst('{id}', orderId));
  }

  // Helper to get customer product details URL
  static String getCustomerProductDetailsUrl(String productId) {
    return getFullUrl(productDetailsCustomer.replaceFirst('{id}', productId));
  }

  // Helper to get tenant details URL
  static String getTenantDetailsUrl(String tenantId) {
    return getFullUrl(tenantDetails.replaceFirst('{id}', tenantId));
  }

  // Helper to get invoice URL
  static String getInvoiceUrl(String invoiceId) {
    return getFullUrl(adminInvoice.replaceFirst('{id}', invoiceId));
  }

  // Helper to get payment details URL
  static String getPaymentDetailsUrl(String paymentId) {
    return getFullUrl(adminPaymentDetails.replaceFirst('{id}', paymentId));
  }

  // Helper to get user details URL
  static String getUserDetailsUrl(String userId) {
    return getFullUrl(adminUserDetails.replaceFirst('{id}', userId));
  }

  // Helper to get subscription details URL
  static String getSubscriptionDetailsUrl(String subscriptionId) {
    return getFullUrl(
      adminSubscriptionDetails.replaceFirst('{id}', subscriptionId),
    );
  }

  // Helper to get document delete URL
  static String getDocumentDeleteUrl(String factoryId, String documentId) {
    return getFullUrl(
      adminDeleteDocument
          .replaceFirst('{id}', factoryId)
          .replaceFirst('{document}', documentId),
    );
  }
}
