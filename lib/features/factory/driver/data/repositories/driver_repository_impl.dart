import 'package:trace_odd/core/errors/app_exceptions.dart';
import 'package:trace_odd/features/factory/driver/data/datasources/driver_remote_datasource.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/chat_message.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/dispute.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/driver_earnings.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/earning_transaction.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/expense.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/factory_driver.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/proof_of_delivery.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/trip.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/vehicle_maintenance.dart';
import 'package:trace_odd/features/factory/driver/domain/repositories/driver_repository.dart';

/// Concrete implementation of [DriverRepository] that delegates data fetching
/// to [DriverRemoteDatasource] and maps raw JSON to domain entities.
class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDatasource _remoteDatasource;

  DriverRepositoryImpl({DriverRemoteDatasource? remoteDatasource})
    : _remoteDatasource = remoteDatasource ?? DriverRemoteDatasource();

  // ──────────────────────────────────────────────
  // Profile
  // ──────────────────────────────────────────────

  @override
  Future<FactoryDriver> getDriverProfile() async {
    try {
      final json = await _remoteDatasource.getDriverProfile();
      final driverJson = json['driver'] as Map<String, dynamic>? ?? json;
      return FactoryDriver.fromJson(driverJson);
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Trips
  // ──────────────────────────────────────────────

  @override
  Future<List<Trip>> getTrips({String? status}) async {
    try {
      final list = await _remoteDatasource.getTrips(status: status);
      return list.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Trip> getTripById(String tripId) async {
    try {
      final json = await _remoteDatasource.getTripById(tripId);
      return Trip.fromJson(json['trip'] as Map<String, dynamic>? ?? json);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Trip> updateTripStatus({
    required String tripId,
    required TripStatus status,
    required double lat,
    required double lng,
  }) async {
    try {
      final json = await _remoteDatasource.updateTripStatus(
        tripId: tripId,
        status: status.name,
        lat: lat,
        lng: lng,
      );
      return Trip.fromJson(json['trip'] as Map<String, dynamic>? ?? json);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<bool> checkDeliveryScanEligibility({
    required String tripId,
    required double lat,
    required double lng,
  }) async {
    try {
      final json = await _remoteDatasource.checkDeliveryScanEligibility(
        tripId: tripId,
        lat: lat,
        lng: lng,
      );
      return (json['eligible'] as bool?) ?? false;
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Trip> scanPickup({
    required String tripId,
    required String code,
    required double lat,
    required double lng,
  }) async {
    try {
      final json = await _remoteDatasource.scanPickup(
        tripId: tripId,
        code: code,
        lat: lat,
        lng: lng,
      );
      return Trip.fromJson(json['trip'] as Map<String, dynamic>? ?? json);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Trip> scanDelivery({
    required String tripId,
    required String code,
    required double lat,
    required double lng,
  }) async {
    try {
      final json = await _remoteDatasource.scanDelivery(
        tripId: tripId,
        code: code,
        lat: lat,
        lng: lng,
      );
      return Trip.fromJson(json['trip'] as Map<String, dynamic>? ?? json);
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Proof of Delivery
  // ──────────────────────────────────────────────

  @override
  Future<ProofOfDelivery> submitProofOfDelivery({
    required String tripId,
    required VerificationType type,
    String? pin,
    String? recipientPhotoPath,
    String? documentPhotoPath,
    String? signaturePath,
    String? recipientName,
    List<String>? debriefPhotoPaths,
    String? damageNotes,
  }) async {
    try {
      final json = await _remoteDatasource.submitProofOfDelivery(
        tripId: tripId,
        verificationType: type.name,
        pin: pin,
        recipientPhotoPath: recipientPhotoPath,
        documentPhotoPath: documentPhotoPath,
        signaturePath: signaturePath,
        recipientName: recipientName,
        debriefPhotoPaths: debriefPhotoPaths,
        damageNotes: damageNotes,
      );
      return ProofOfDelivery.fromJson(
        json['proof_of_delivery'] as Map<String, dynamic>? ?? json,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Expenses
  // ──────────────────────────────────────────────

  @override
  Future<Expense> submitExpense({
    required String tripId,
    required ExpenseType type,
    required double amount,
    required String receiptPath,
    String? notes,
  }) async {
    try {
      final json = await _remoteDatasource.submitExpense(
        tripId: tripId,
        type: type.name,
        amount: amount,
        receiptPath: receiptPath,
        notes: notes,
      );
      return Expense.fromJson(json['expense'] as Map<String, dynamic>? ?? json);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<Expense>> getTripExpenses(String tripId) async {
    try {
      final list = await _remoteDatasource.getTripExpenses(tripId);
      return list
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Earnings
  // ──────────────────────────────────────────────

  @override
  Future<DriverEarnings> getEarnings({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final json = await _remoteDatasource.getEarnings(
        startDate: startDate,
        endDate: endDate,
      );
      return DriverEarnings.fromJson(
        json['earnings'] as Map<String, dynamic>? ?? json,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<EarningTransaction>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final json = await _remoteDatasource.getPaymentHistory(
        startDate: startDate,
        endDate: endDate,
        page: page,
        perPage: perPage,
      );
      final list = (json['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => EarningTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Vehicle Maintenance
  // ──────────────────────────────────────────────

  @override
  Future<VehicleMaintenance> addMaintenanceLog({
    required String vehicleId,
    required String type,
    required DateTime serviceDate,
    required DateTime nextServiceDate,
    double? mileage,
    String? notes,
  }) async {
    try {
      final json = await _remoteDatasource.addMaintenanceLog(
        vehicleId: vehicleId,
        type: type,
        serviceDate: serviceDate,
        nextServiceDate: nextServiceDate,
        mileage: mileage,
        notes: notes,
      );
      return VehicleMaintenance.fromJson(
        json['maintenance'] as Map<String, dynamic>? ?? json,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<List<VehicleMaintenance>> getMaintenanceLogs(String vehicleId) async {
    try {
      final list = await _remoteDatasource.getMaintenanceLogs(vehicleId);
      return list
          .map((e) => VehicleMaintenance.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Chat / Messages
  // ──────────────────────────────────────────────

  @override
  Future<List<ChatMessage>> getMessages(String chatId, {int page = 1}) async {
    try {
      final list = await _remoteDatasource.getMessages(chatId, page: page);
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String message,
    String? attachmentPath,
  }) async {
    try {
      final json = await _remoteDatasource.sendMessage(
        chatId: chatId,
        message: message,
        attachmentPath: attachmentPath,
      );
      return ChatMessage.fromJson(
        json['message'] as Map<String, dynamic>? ?? json,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Disputes
  // ──────────────────────────────────────────────

  @override
  Future<List<Dispute>> getDisputes() async {
    try {
      final list = await _remoteDatasource.getDisputes();
      return list
          .map((e) => Dispute.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<Dispute> submitCounterEvidence({
    required String disputeId,
    required String evidence,
  }) async {
    try {
      final json = await _remoteDatasource.submitCounterEvidence(
        disputeId: disputeId,
        evidence: evidence,
      );
      return Dispute.fromJson(json['dispute'] as Map<String, dynamic>? ?? json);
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // GPS & Location
  // ──────────────────────────────────────────────

  @override
  Future<bool> checkFakeGps() async {
    try {
      final json = await _remoteDatasource.checkFakeGps();
      return (json['fake_gps'] as bool?) ?? false;
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> updateLocation({
    required String tripId,
    required double lat,
    required double lng,
  }) async {
    try {
      await _remoteDatasource.updateLocation(
        tripId: tripId,
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // KPIs
  // ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getDriverKpis() async {
    try {
      final json = await _remoteDatasource.getDriverKpis();
      final kpis = json['kpis'] as Map<String, dynamic>? ?? json;
      return {
        'onTimePct': (kpis['on_time_pct'] as num?)?.toDouble() ?? 0.0,
        'rating': (kpis['rating'] as num?)?.toDouble() ?? 0.0,
        'scansPerDay': (kpis['scans_per_day'] as num?)?.toDouble() ?? 0.0,
        'photoQualityScore':
            (kpis['photo_quality_score'] as num?)?.toDouble() ?? 0.0,
        'tier': kpis['tier'] as String? ?? 'bronze',
      };
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Offline Sync
  // ──────────────────────────────────────────────

  @override
  Future<void> syncOfflineData(
    List<Map<String, dynamic>> pendingActions,
  ) async {
    try {
      await _remoteDatasource.syncOfflineData(pendingActions);
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ──────────────────────────────────────────────
  // Error mapping
  // ──────────────────────────────────────────────

  /// Re-throws known [AppException] instances, wrapping unexpected errors
  /// in a [ServerException] so callers can handle them uniformly.
  Never _mapError(dynamic error) {
    if (error is AppException) throw error;
    throw ServerException(error.toString(), 0, null);
  }
}
