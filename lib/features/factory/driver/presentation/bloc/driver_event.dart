// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'driver_bloc.dart';

// ──────────────────────────────────────────────
// Base event
// ──────────────────────────────────────────────

sealed class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

// ──────────────────────────────────────────────
// Profile
// ──────────────────────────────────────────────

class LoadDriverProfile extends DriverEvent {
  const LoadDriverProfile();
}

// ──────────────────────────────────────────────
// Trips
// ──────────────────────────────────────────────

class LoadTrips extends DriverEvent {
  final String? statusFilter;

  const LoadTrips({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class LoadTripById extends DriverEvent {
  final String tripId;

  const LoadTripById(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class UpdateTripStatus extends DriverEvent {
  final String tripId;
  final TripStatus status;
  final double lat;
  final double lng;

  const UpdateTripStatus({
    required this.tripId,
    required this.status,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [tripId, status, lat, lng];
}

// ──────────────────────────────────────────────
// Geofence / Scan eligibility
// ──────────────────────────────────────────────

class CheckScanEligibility extends DriverEvent {
  final String tripId;
  final double lat;
  final double lng;

  const CheckScanEligibility({
    required this.tripId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [tripId, lat, lng];
}

// ──────────────────────────────────────────────
// Scanning
// ──────────────────────────────────────────────

class ScanPickup extends DriverEvent {
  final String tripId;
  final String code;
  final double lat;
  final double lng;

  const ScanPickup({
    required this.tripId,
    required this.code,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [tripId, code, lat, lng];
}

class ScanDelivery extends DriverEvent {
  final String tripId;
  final String code;
  final double lat;
  final double lng;

  const ScanDelivery({
    required this.tripId,
    required this.code,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [tripId, code, lat, lng];
}

// ──────────────────────────────────────────────
// Proof of Delivery
// ──────────────────────────────────────────────

class SubmitProofOfDelivery extends DriverEvent {
  final String tripId;
  final VerificationType verificationType;
  final String? pin;
  final String? recipientPhotoPath;
  final String? documentPhotoPath;
  final String? signaturePath;
  final String? recipientName;
  final List<String>? debriefPhotoPaths;
  final String? damageNotes;

  const SubmitProofOfDelivery({
    required this.tripId,
    required this.verificationType,
    this.pin,
    this.recipientPhotoPath,
    this.documentPhotoPath,
    this.signaturePath,
    this.recipientName,
    this.debriefPhotoPaths,
    this.damageNotes,
  });

  @override
  List<Object?> get props => [
    tripId,
    verificationType,
    pin,
    recipientPhotoPath,
    documentPhotoPath,
    signaturePath,
    recipientName,
    debriefPhotoPaths,
    damageNotes,
  ];
}

// ──────────────────────────────────────────────
// Expenses
// ──────────────────────────────────────────────

class SubmitExpense extends DriverEvent {
  final String? tripId;
  final ExpenseType type;
  final double amount;
  final String? receiptPath;
  final String? notes;

  const SubmitExpense({
    this.tripId,
    required this.type,
    required this.amount,
    this.receiptPath,
    this.notes,
  });

  @override
  List<Object?> get props => [tripId, type, amount, receiptPath, notes];
}

class LoadTripExpenses extends DriverEvent {
  final String tripId;

  const LoadTripExpenses(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

// ──────────────────────────────────────────────
// Earnings
// ──────────────────────────────────────────────

class LoadEarnings extends DriverEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadEarnings({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadPaymentHistory extends DriverEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? page;
  final String? typeFilter;

  const LoadPaymentHistory({
    this.startDate,
    this.endDate,
    this.page,
    this.typeFilter,
  });

  @override
  List<Object?> get props => [startDate, endDate, page, typeFilter];
}

// ──────────────────────────────────────────────
// Vehicle info & maintenance
// ──────────────────────────────────────────────

class LoadVehicleInfo extends DriverEvent {
  const LoadVehicleInfo();
}

class UpdateMeterReadings extends DriverEvent {
  final String tripId;
  final double? meterStart;
  final double? meterDelivery;
  final double? meterReturn;

  const UpdateMeterReadings({
    required this.tripId,
    this.meterStart,
    this.meterDelivery,
    this.meterReturn,
  });

  @override
  List<Object?> get props => [tripId, meterStart, meterDelivery, meterReturn];
}

class AddMaintenanceLog extends DriverEvent {
  final String vehicleId;
  final String type;
  final DateTime serviceDate;
  final DateTime? nextServiceDate;
  final double? mileage;
  final String? notes;

  const AddMaintenanceLog({
    this.vehicleId = '',
    required this.type,
    required this.serviceDate,
    this.nextServiceDate,
    this.mileage,
    this.notes,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    type,
    serviceDate,
    nextServiceDate,
    mileage,
    notes,
  ];
}

class LoadMaintenanceLogs extends DriverEvent {
  final String vehicleId;

  const LoadMaintenanceLogs(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

// ──────────────────────────────────────────────
// Chat / Messages
// ──────────────────────────────────────────────

class LoadMessages extends DriverEvent {
  final String chatId;
  final String? conversationId;
  final int? page;

  const LoadMessages({String? chatId, this.conversationId, this.page})
    : chatId = chatId ?? conversationId ?? '';

  @override
  List<Object?> get props => [chatId, conversationId, page];
}

class SendMessage extends DriverEvent {
  final String chatId;
  final String message;
  final String? text;
  final String? conversationId;
  final String? attachmentPath;

  const SendMessage({
    String? chatId,
    String? message,
    this.text,
    this.conversationId,
    this.attachmentPath,
  }) : chatId = chatId ?? conversationId ?? '',
       message = message ?? text ?? '';

  @override
  List<Object?> get props => [
    chatId,
    message,
    text,
    conversationId,
    attachmentPath,
  ];
}

// ──────────────────────────────────────────────
// Disputes
// ──────────────────────────────────────────────

class LoadDisputes extends DriverEvent {
  const LoadDisputes();
}

class SubmitCounterEvidence extends DriverEvent {
  final String disputeId;
  final String evidence;
  final String? counterEvidence;

  const SubmitCounterEvidence({
    required this.disputeId,
    String? evidence,
    this.counterEvidence,
  }) : evidence = evidence ?? counterEvidence ?? '';

  @override
  List<Object?> get props => [disputeId, evidence, counterEvidence];
}

/// Alias for SubmitCounterEvidence - used by disputes screen
class SubmitDisputeEvidence extends SubmitCounterEvidence {
  const SubmitDisputeEvidence({
    required super.disputeId,
    super.counterEvidence,
  });
}

// ──────────────────────────────────────────────
// GPS & Location
// ──────────────────────────────────────────────

class CheckFakeGps extends DriverEvent {
  const CheckFakeGps();
}

class UpdateDriverLocation extends DriverEvent {
  final String tripId;
  final double lat;
  final double lng;

  const UpdateDriverLocation({
    required this.tripId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [tripId, lat, lng];
}

// ──────────────────────────────────────────────
// KPIs
// ──────────────────────────────────────────────

class LoadDriverKpis extends DriverEvent {
  const LoadDriverKpis();
}

/// Alias for LoadDriverKpis - used by performance screen
class LoadPerformance extends DriverEvent {
  const LoadPerformance();
}

// ──────────────────────────────────────────────
// Chat conversations list
// ──────────────────────────────────────────────

class LoadConversations extends DriverEvent {
  const LoadConversations();
}

// ──────────────────────────────────────────────
// Expenses (without tripId - loads all)
// ──────────────────────────────────────────────

class LoadExpenses extends DriverEvent {
  final String? tripId;
  const LoadExpenses({this.tripId});

  @override
  List<Object?> get props => [tripId];
}

// ──────────────────────────────────────────────
// Compliance check alias
// ──────────────────────────────────────────────

class LoadCompliance extends DriverEvent {
  const LoadCompliance();
}

// ──────────────────────────────────────────────
// Document upload
// ──────────────────────────────────────────────

class UploadDocument extends DriverEvent {
  final String documentType;
  final String filePath;

  const UploadDocument({required this.documentType, required this.filePath});

  @override
  List<Object?> get props => [documentType, filePath];
}

// ──────────────────────────────────────────────
// Offline Sync
// ──────────────────────────────────────────────

class SyncOfflineData extends DriverEvent {
  final List<Map<String, dynamic>> pendingActions;

  const SyncOfflineData(this.pendingActions);

  @override
  List<Object?> get props => [pendingActions];
}

// ──────────────────────────────────────────────
// Compliance
// ──────────────────────────────────────────────

class CheckCompliance extends DriverEvent {
  const CheckCompliance();
}

// ──────────────────────────────────────────────
// Utility
// ──────────────────────────────────────────────

class ClearError extends DriverEvent {
  const ClearError();
}
