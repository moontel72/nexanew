import 'dart:async';

import 'package:trace_odd/features/factory/driver/domain/entities/chat_message.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/dispute.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/driver_earnings.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/earning_transaction.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/expense.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/factory_driver.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/proof_of_delivery.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/trip.dart';
import 'package:trace_odd/features/factory/driver/domain/entities/vehicle_maintenance.dart';

/// Abstract repository defining the contract for driver-related data operations.
///
/// All methods are asynchronous and may throw [AppException] subclasses
/// which should be caught and mapped to [Failure] by the implementation.
abstract class DriverRepository {
  /// Fetches the currently authenticated driver's profile.
  Future<FactoryDriver> getDriverProfile();

  /// Retrieves trips assigned to the driver, optionally filtered by [status].
  Future<List<Trip>> getTrips({String? status});

  /// Fetches a single trip by its [tripId].
  Future<Trip> getTripById(String tripId);

  /// Updates the status of a trip with the driver's current location.
  ///
  /// Location is mandatory for all status transitions to ensure geo-verification.
  Future<Trip> updateTripStatus({
    required String tripId,
    required TripStatus status,
    required double lat,
    required double lng,
  });

  /// Checks whether the driver is within the allowed geofence (100m) to scan
  /// for delivery at the given coordinates.
  ///
  /// Returns `true` if the distance to the delivery point is <= 100 meters.
  Future<bool> checkDeliveryScanEligibility({
    required String tripId,
    required double lat,
    required double lng,
  });

  /// Scans the pickup code to confirm collection of goods.
  Future<Trip> scanPickup({
    required String tripId,
    required String code,
    required double lat,
    required double lng,
  });

  /// Scans the delivery code to confirm handover at the destination.
  Future<Trip> scanDelivery({
    required String tripId,
    required String code,
    required double lat,
    required double lng,
  });

  /// Submits proof of delivery for a completed trip.
  ///
  /// Depending on [type], different fields are required:
  /// - [VerificationType.pin]: requires [pin]
  /// - [VerificationType.photo]: requires [recipientPhotoPath], [documentPhotoPath]
  /// - [VerificationType.signature]: requires [signaturePath]
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
  });

  /// Submits an expense claim for a trip.
  ///
  /// [receiptPath] is the local file path to the receipt image.
  /// [notes] provides additional context for the expense.
  Future<Expense> submitExpense({
    required String tripId,
    required ExpenseType type,
    required double amount,
    required String receiptPath,
    String? notes,
  });

  /// Retrieves all expenses associated with the given [tripId].
  Future<List<Expense>> getTripExpenses(String tripId);

  /// Fetches the driver's earnings summary, optionally scoped to a date range.
  Future<DriverEarnings> getEarnings({DateTime? startDate, DateTime? endDate});

  /// Retrieves the driver's payment history with pagination support.
  Future<List<EarningTransaction>> getPaymentHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int perPage = 20,
  });

  /// Logs a new vehicle maintenance record.
  Future<VehicleMaintenance> addMaintenanceLog({
    required String vehicleId,
    required String type,
    required DateTime serviceDate,
    required DateTime nextServiceDate,
    double? mileage,
    String? notes,
  });

  /// Retrieves all maintenance logs for a given [vehicleId].
  Future<List<VehicleMaintenance>> getMaintenanceLogs(String vehicleId);

  /// Fetches messages for the specified [chatId], with optional pagination.
  Future<List<ChatMessage>> getMessages(String chatId, {int page = 1});

  /// Sends a message to the specified chat.
  ///
  /// [attachmentPath] is an optional local file path for an attachment.
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String message,
    String? attachmentPath,
  });

  /// Retrieves all disputes involving the current driver.
  Future<List<Dispute>> getDisputes();

  /// Submits counter-evidence for an open dispute.
  Future<Dispute> submitCounterEvidence({
    required String disputeId,
    required String evidence,
  });

  /// Checks whether the device is running fake GPS / location spoofing software.
  ///
  /// Returns `true` if spoofing is detected.
  Future<bool> checkFakeGps();

  /// Sends the driver's current location to the backend for real-time tracking.
  Future<void> updateLocation({
    required String tripId,
    required double lat,
    required double lng,
  });

  /// Retrieves the driver's key performance indicators.
  ///
  /// Returns a map containing:
  /// - `onTimePct`: on-time delivery percentage
  /// - `rating`: average rating
  /// - `scansPerDay`: average scans per day
  /// - `photoQualityScore`: photo quality assessment
  /// - `tier`: current driver tier name
  Future<Map<String, dynamic>> getDriverKpis();

  /// Synchronizes pending offline actions to the backend.
  ///
  /// Each action in [pendingActions] is a map representing a queued operation
  /// that was performed while the device was offline.
  Future<void> syncOfflineData(List<Map<String, dynamic>> pendingActions);
}
