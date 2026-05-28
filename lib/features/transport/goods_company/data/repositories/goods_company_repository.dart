import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:trace_odd/shared/models/transport/goods_company_model.dart';

abstract class GoodsCompanyRepository {
  // Company registration and management
  Future<Either<String, GoodsCompanyModel>> registerCompany({
    required String companyName,
    required String ownerName,
    required String phone,
    required String email,
    required String cnic,
    required String address,
    required GoodsCompanyPlanType planType,
    double? initialBalance,
  });

  Future<Either<String, GoodsCompanyModel>> getCompany(String companyId);
  Future<Either<String, GoodsCompanyModel>> getCompanyByUserId(String userId);
  Future<Either<String, GoodsCompanyModel>> getCompanyByPhone(String phone);
  Future<Either<String, GoodsCompanyModel>> updateCompany(
      String companyId, Map<String, dynamic> updates);
  Future<Either<String, bool>> deleteCompany(String companyId);

  // Verification and status management
  Future<Either<String, GoodsCompanyModel>> verifyCompany(
    String companyId, {
    required VerificationStatus status,
    String? notes,
  });

  Future<Either<String, GoodsCompanyModel>> updateCompanyStatus(
    String companyId, {
    required GoodsCompanyStatus status,
    String? reason,
  });

  // Subscription management
  Future<Either<String, GoodsCompanySubscription>> createSubscription({
    required String companyId,
    required GoodsCompanyPlanType planType,
    required double amount,
    required String paymentMethod,
    required String paymentReference,
    bool isAutoRenew = false,
  });

  Future<Either<String, GoodsCompanySubscription>> getActiveSubscription(
      String companyId);
  Future<Either<String, List<GoodsCompanySubscription>>> getSubscriptionHistory(
      String companyId);
  Future<Either<String, bool>> cancelSubscription(
    String subscriptionId, {
    required String reason,
  });

  Future<Either<String, bool>> renewSubscription(
    String subscriptionId, {
    required String paymentReference,
  });

  // Commission management
  Future<Either<String, CommissionStructureModel>> setCommissionStructure({
    required String companyId,
    required double minPercentage,
    required double maxPercentage,
    bool isDynamic = true,
    Map<String, double>? dynamicRates,
    bool includeTax = false,
    bool includeInsurance = false,
    String? notes,
  });

  Future<Either<String, CommissionStructureModel>> getCommissionStructure(
      String companyId);
  Future<Either<String, CommissionStructureModel>> updateCommissionStructure(
    String structureId, {
    double? minPercentage,
    double? maxPercentage,
    bool? isDynamic,
    Map<String, double>? dynamicRates,
    bool? includeTax,
    bool? includeInsurance,
    String? notes,
  });

  // Fleet management
  Future<Either<String, bool>> addTruckToFleet({
    required String companyId,
    required String truckId,
    required String registrationNumber,
    required String truckType,
    double? capacityTons,
    int? lengthFeet,
  });

  Future<Either<String, bool>> removeTruckFromFleet(
    String companyId,
    String truckId, {
    String? reason,
  });

  Future<Either<String, List<Map<String, dynamic>>>> getFleet(
    String companyId, {
    String? status,
    String? truckType,
    int? limit,
    int? offset,
  });

  Future<Either<String, Map<String, dynamic>>> getFleetStats(String companyId);

  // Factory connections
  Future<Either<String, bool>> connectToFactory({
    required String companyId,
    required String factoryId,
    double? agreedCommission,
    String? notes,
  });

  Future<Either<String, bool>> disconnectFromFactory(
    String companyId,
    String factoryId, {
    String? reason,
  });

  Future<Either<String, List<Map<String, dynamic>>>> getConnectedFactories(
    String companyId, {
    bool? activeOnly,
    int? limit,
    int? offset,
  });

  // Load and trip management
  Future<Either<String, String>> postLoad({
    required String companyId,
    required String originCity,
    required String destinationCity,
    required String cargoType,
    required double weightTons,
    required String truckType,
    required double expectedPrice,
    DateTime? preferredDate,
    String? specialRequirements,
  });

  Future<Either<String, List<Map<String, dynamic>>>> getCompanyLoads(
    String companyId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  Future<Either<String, Map<String, dynamic>>> getLoadStats(String companyId);

  // Bidding management
  Future<Either<String, String>> placeBid({
    required String companyId,
    required String loadId,
    required double amount,
    required String truckId,
    double? commissionPercentage,
    DateTime? estimatedDeliveryDate,
    String? notes,
  });

  Future<Either<String, List<Map<String, dynamic>>>> getCompanyBids(
    String companyId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  Future<Either<String, Map<String, dynamic>>> getBidStats(String companyId);

  // Trip management
  Future<Either<String, Map<String, dynamic>>> createTripFromBid({
    required String companyId,
    required String bidId,
    required String loadId,
    required String truckId,
    required String driverId,
    required double totalAmount,
    double? commissionPercentage,
    Map<String, dynamic>? contractTerms,
  });

  Future<Either<String, List<Map<String, dynamic>>>> getCompanyTrips(
    String companyId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  Future<Either<String, Map<String, dynamic>>> getTripStats(String companyId);

  // Earnings and financials
  Future<Either<String, Map<String, dynamic>>> getEarningsSummary(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<String, List<Map<String, dynamic>>>> getEarningsBreakdown(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy, // day, week, month, trip_type
    int? limit,
    int? offset,
  });

  Future<Either<String, double>> getTotalRevenue(String companyId);
  Future<Either<String, double>> getTotalCommissionEarned(String companyId);
  Future<Either<String, double>> getPendingPayments(String companyId);

  // Settings management
  Future<Either<String, GoodsCompanySettings>> getSettings(String companyId);
  Future<Either<String, GoodsCompanySettings>> updateSettings(
    String companyId,
    Map<String, dynamic> updates,
  );

  // API usage management
  Future<Either<String, bool>> recordApiCall(String companyId);
  Future<Either<String, Map<String, dynamic>>> getApiUsage(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<String, bool>> resetApiUsage(String companyId);

  // Search and discovery
  Future<Either<String, List<GoodsCompanyModel>>> searchCompanies({
    String? query,
    String? city,
    GoodsCompanyPlanType? planType,
    double? minRating,
    bool? verifiedOnly,
    int? limit,
    int? offset,
  });

  Future<Either<String, List<GoodsCompanyModel>>> getNearbyCompanies({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int limit = 20,
  });

  // Rating and reviews
  Future<Either<String, bool>> rateCompany({
    required String raterId,
    required String companyId,
    required double rating,
    required String comment,
    required String tripId,
  });

  Future<Either<String, Map<String, dynamic>>> getCompanyRating(
      String companyId);
  Future<Either<String, List<Map<String, dynamic>>>> getCompanyReviews(
    String companyId, {
    int? limit,
    int? offset,
  });

  // Analytics and reporting
  Future<Either<String, Map<String, dynamic>>> getAnalyticsDashboard(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<String, Map<String, dynamic>>> generateReport({
    required String companyId,
    required String reportType, // monthly, quarterly, yearly, custom
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metrics,
  });

  // Validation and checks
  Future<Either<String, bool>> canPostLoad(String companyId);
  Future<Either<String, bool>> canPlaceBid(String companyId);
  Future<Either<String, bool>> canCreateTrip(String companyId);
  Future<Either<String, bool>> hasSufficientBalance(String companyId);
  Future<Either<String, double>> getRequiredMinimumBalance(String companyId);

  // Batch operations
  Future<Either<String, Map<String, dynamic>>> batchUpdateCompanies(
      Map<String, Map<String, dynamic>> updates);
  Future<Either<String, Map<String, double>>> getBalancesForCompanies(
      List<String> companyIds);

  // Audit and logs
  Future<Either<String, List<Map<String, dynamic>>>> getAuditLogs(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int? limit,
    int? offset,
  });

  // Support and help
  Future<Either<String, String>> requestSupport({
    required String companyId,
    required String subject,
    required String message,
    List<String>? attachments,
    String? priority, // low, medium, high, urgent
  });

  Future<Either<String, List<Map<String, dynamic>>>> getSupportTickets(
    String companyId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });
}
