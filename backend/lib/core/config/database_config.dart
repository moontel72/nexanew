// Database Configuration for NexaTrace System
// This file contains database connection settings and configuration

class DatabaseConfig {
  // PostgreSQL Database Configuration
  static const String host = '135.181.46.27';
  static const int port = 5444;
  static const String database = 'nexasystem_db';
  static const String username = 'nexa_app';
  static const String password = 'NexaAppPassword123!';

  // Connection Pool Settings
  static const int minConnections = 2;
  static const int maxConnections = 10;
  static const int connectionTimeout = 30; // seconds
  static const int idleTimeout = 300; // seconds

  // Local Database (Hive) Configuration
  static const String localDbName = 'nexatrace_local';
  static const int localDbVersion = 1;
  static const List<String> localBoxes = [
    'user_preferences',
    'cached_codes',
    'offline_scans',
    'sync_queue',
  ];

  // Cache Settings
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCachedRecords = 10000;
  static const bool enableQueryCache = true;

  // Sync Settings
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);

  // Backup Settings
  static const Duration backupInterval = Duration(hours: 24);
  static const int maxBackupFiles = 7;
  static const String backupDirectory = 'nexatrace_backups';

  // Performance Settings
  static const int batchSize = 1000;
  static const bool enableCompression = true;
  static const bool enableEncryption = true;

  // Connection String
  static String get connectionString =>
      'postgresql://$username:$password@$host:$port/$database';

  // Test Connection String (for development)
  static String get testConnectionString =>
      'postgresql://postgres:awan1972@135.181.46.27:5444/nexasystem_db';

  // Check if using production database
  static bool get isProduction => host != '135.181.46.27';

  // Get appropriate connection string based on environment
  static String getConnectionString({bool useTest = false}) {
    return useTest ? testConnectionString : connectionString;
  }
}

class DatabaseApiEndpoints {
  static const String baseUrl = 'http://135.181.46.27:8090/api/v1';

  // Database operations
  static const String health = '$baseUrl/database/health';
  static const String backup = '$baseUrl/database/backup';
  static const String restore = '$baseUrl/database/restore';
  static const String stats = '$baseUrl/database/stats';

  // Data endpoints
  static const String codes = '$baseUrl/codes';
  static const String products = '$baseUrl/products';
  static const String companies = '$baseUrl/companies';
  static const String users = '$baseUrl/users';
}

class DatabaseTables {
  static const String companies = 'companies';
  static const String factoryUsers = 'factory_users';
  static const String subscriptionPlans = 'subscription_plans';
  static const String bundleCodes = 'bundle_codes';
  static const String cartonCodes = 'carton_codes';
  static const String packetCodes = 'packet_codes';
  static const String unitCodes = 'unit_codes';
  static const String products = 'products';
  static const String productTypes = 'product_types';
  static const String batches = 'batches';
  static const String codeScans = 'code_scans';
  static const String fakeReports = 'fake_reports';
  static const String auditLogs = 'audit_logs';
}

class DatabaseColumns {
  // Common columns
  static const String id = 'id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String deletedAt = 'deleted_at';
  static const String createdBy = 'created_by';
  static const String updatedBy = 'updated_by';

  // Company table columns
  static const String companyName = 'company_name';
  static const String companyEmail = 'company_email';
  static const String companyPhone = 'company_phone';
  static const String companyAddress = 'company_address';
  static const String companyLogo = 'company_logo';
  static const String subscriptionPlanId = 'subscription_plan_id';
  static const String subscriptionStatus = 'subscription_status';
  static const String subscriptionExpiresAt = 'subscription_expires_at';
  static const String maxUsers = 'max_users';
  static const String maxProducts = 'max_products';
  static const String maxCodesPerMonth = 'max_codes_per_month';
  static const String currentMonthlyCodes = 'current_monthly_codes';
  static const String isActive = 'is_active';
  static const String verificationStatus = 'verification_status';
  static const String kycDocuments = 'kyc_documents';

  // Factory user columns
  static const String userId = 'user_id';
  static const String factoryId = 'factory_id';
  static const String role = 'role';
  static const String permissions = 'permissions';
  static const String lastLoginAt = 'last_login_at';
  static const String loginCount = 'login_count';

  // Subscription plan columns
  static const String planName = 'plan_name';
  static const String planDescription = 'plan_description';
  static const String monthlyPrice = 'monthly_price';
  static const String yearlyPrice = 'yearly_price';
  static const String maxUsersAllowed = 'max_users_allowed';
  static const String maxProductsAllowed = 'max_products_allowed';
  static const String maxCodesPerMonthAllowed = 'max_codes_per_month_allowed';
  static const String features = 'features';
  static const String isCustom = 'is_custom';
  static const String isActivePlan = 'is_active';

  // Code tables columns
  static const String code = 'code';
  static const String codeType = 'code_type';
  static const String batchId = 'batch_id';
  static const String productId = 'product_id';
  static const String companyId = 'company_id';
  static const String status = 'status';
  static const String generatedAt = 'generated_at';
  static const String activatedAt = 'activated_at';
  static const String scannedAt = 'scanned_at';
  static const String parentCodeId = 'parent_code_id';
  static const String hierarchyLevel = 'hierarchy_level';
  static const String qrCodeData = 'qr_code_data';
  static const String serialNumber = 'serial_number';

  // Product columns
  static const String productName = 'product_name';
  static const String productDescription = 'product_description';
  static const String productImage = 'product_image';
  static const String productTypeId = 'product_type_id';
  static const String sku = 'sku';
  static const String batchSize = 'batch_size';
  static const String unitPrice = 'unit_price';
  static const String manufacturingDate = 'manufacturing_date';
  static const String expiryDate = 'expiry_date';

  // Scan columns
  static const String scanId = 'scan_id';
  static const String scannedBy = 'scanned_by';
  static const String scanLocation = 'scan_location';
  static const String scanDevice = 'scan_device';
  static const String scanResult = 'scan_result';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String ipAddress = 'ip_address';

  // Audit log columns
  static const String action = 'action';
  static const String entityType = 'entity_type';
  static const String entityId = 'entity_id';
  static const String oldValues = 'old_values';
  static const String newValues = 'new_values';
  static const String ip = 'ip';
  static const String userAgent = 'user_agent';
}

class DatabaseIndexes {
  static const String idxCompaniesEmail = 'idx_companies_email';
  static const String idxCompaniesSubscription = 'idx_companies_subscription';
  static const String idxCodesCode = 'idx_codes_code';
  static const String idxCodesCompany = 'idx_codes_company';
  static const String idxCodesProduct = 'idx_codes_product';
  static const String idxScansCode = 'idx_scans_code';
  static const String idxScansDate = 'idx_scans_date';
  static const String idxProductsCompany = 'idx_products_company';
  static const String idxUsersEmail = 'idx_users_email';
  static const String idxUsersCompany = 'idx_users_company';
}

class DatabaseConstraints {
  static const String fkCodesCompany = 'fk_codes_company';
  static const String fkCodesProduct = 'fk_codes_product';
  static const String fkUsersCompany = 'fk_users_company';
  static const String fkProductsCompany = 'fk_products_company';
  static const String fkScansCode = 'fk_scans_code';
  static const String fkScansUser = 'fk_scans_user';
  static const String fkCompanySubscription = 'fk_company_subscription';
}

class DatabaseQueries {
  // Common queries
  static const String selectAll = 'SELECT * FROM ';
  static const String selectCount = 'SELECT COUNT(*) FROM ';
  static const String selectById = 'SELECT * FROM {table} WHERE id = ?';

  // Company queries
  static const String selectCompaniesByStatus =
      'SELECT * FROM ${DatabaseTables.companies} WHERE ${DatabaseColumns.subscriptionStatus} = ?';

  // Code queries
  static const String selectCodesByCompany =
      'SELECT * FROM {code_table} WHERE ${DatabaseColumns.companyId} = ?';

  // Scan statistics
  static const String selectScanStats =
      'SELECT COUNT(*) as total_scans, DATE(${DatabaseColumns.scannedAt}) as scan_date '
      'FROM ${DatabaseTables.codeScans} '
      'WHERE ${DatabaseColumns.companyId} = ? '
      'GROUP BY DATE(${DatabaseColumns.scannedAt}) '
      'ORDER BY scan_date DESC';
}
