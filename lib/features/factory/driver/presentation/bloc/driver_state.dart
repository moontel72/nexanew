// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'driver_bloc.dart';

// ──────────────────────────────────────────────
// Base state
// ──────────────────────────────────────────────

sealed class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object?> get props => [];
}

// ──────────────────────────────────────────────
// Initial / loading / error scaffolding
// ──────────────────────────────────────────────

class DriverInitial extends DriverState {
  const DriverInitial();
}

class DriverLoading extends DriverState {
  /// Optional hint about what is being loaded, useful for debug logging.
  final String? action;

  const DriverLoading({this.action});

  @override
  List<Object?> get props => [action];
}

class DriverError extends DriverState {
  final String message;
  final String? code;

  /// When true the previously-emitted data state is kept so the UI can
  /// show an error banner without replacing the entire screen.
  final bool isOverlay;

  const DriverError({required this.message, this.code, this.isOverlay = false});

  @override
  List<Object?> get props => [message, code, isOverlay];
}

// ──────────────────────────────────────────────
// Profile
// ──────────────────────────────────────────────

class DriverProfileLoaded extends DriverState {
  final FactoryDriver driver;

  const DriverProfileLoaded(this.driver);

  @override
  List<Object?> get props => [driver];
}

// ──────────────────────────────────────────────
// Trips
// ──────────────────────────────────────────────

class TripsLoaded extends DriverState {
  final List<Trip> trips;
  final Trip? currentTrip;

  const TripsLoaded({required this.trips, this.currentTrip});

  @override
  List<Object?> get props => [trips, currentTrip];
}

class TripDetailLoaded extends DriverState {
  final Trip trip;

  const TripDetailLoaded(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripStatusUpdated extends DriverState {
  final Trip trip;

  const TripStatusUpdated(this.trip);

  @override
  List<Object?> get props => [trip];
}

// ──────────────────────────────────────────────
// Geofence / Scan eligibility
// ──────────────────────────────────────────────

class ScanEligibilityResult extends DriverState {
  final bool isEligible;
  final double? distanceMeters;
  final String? reason;

  const ScanEligibilityResult({
    required this.isEligible,
    this.distanceMeters,
    this.reason,
  });

  @override
  List<Object?> get props => [isEligible, distanceMeters, reason];
}

// ──────────────────────────────────────────────
// Scanning
// ──────────────────────────────────────────────

class ScanCompleted extends DriverState {
  final Trip trip;
  final String scanType; // 'pickup' or 'delivery'

  const ScanCompleted({required this.trip, required this.scanType});

  @override
  List<Object?> get props => [trip, scanType];
}

// ──────────────────────────────────────────────
// Proof of Delivery
// ──────────────────────────────────────────────

class ProofOfDeliverySubmitted extends DriverState {
  final ProofOfDelivery pod;

  const ProofOfDeliverySubmitted(this.pod);

  @override
  List<Object?> get props => [pod];
}

// ──────────────────────────────────────────────
// Expenses
// ──────────────────────────────────────────────

class ExpenseSubmitted extends DriverState {
  final Expense expense;

  const ExpenseSubmitted(this.expense);

  @override
  List<Object?> get props => [expense];
}

class ExpensesLoaded extends DriverState {
  final List<Expense> expenses;

  const ExpensesLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

// ──────────────────────────────────────────────
// Earnings
// ──────────────────────────────────────────────

class EarningsLoaded extends DriverState {
  final DriverEarnings earnings;

  const EarningsLoaded(this.earnings);

  @override
  List<Object?> get props => [earnings];
}

class PaymentHistoryLoaded extends DriverState {
  final List<EarningTransaction> transactions;
  final bool hasMore;
  final int page;

  const PaymentHistoryLoaded({
    required this.transactions,
    this.hasMore = false,
    this.page = 1,
  });

  @override
  List<Object?> get props => [transactions, hasMore, page];
}

// ──────────────────────────────────────────────
// Vehicle
// ──────────────────────────────────────────────

/// The driver profile doubles as the primary vehicle-info source.
/// [VehicleInfoLoaded] wraps the [FactoryDriver] for clarity in the UI.
class VehicleInfoLoaded extends DriverState {
  final FactoryDriver vehicle;

  const VehicleInfoLoaded(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class MeterReadingsUpdated extends DriverState {
  final Trip trip;

  const MeterReadingsUpdated(this.trip);

  @override
  List<Object?> get props => [trip];
}

class MaintenanceLogAdded extends DriverState {
  final VehicleMaintenance log;

  const MaintenanceLogAdded(this.log);

  @override
  List<Object?> get props => [log];
}

class MaintenanceLogsLoaded extends DriverState {
  final List<VehicleMaintenance> logs;

  const MaintenanceLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

// ──────────────────────────────────────────────
// Chat / Messages
// ──────────────────────────────────────────────

class MessagesLoaded extends DriverState {
  final List<ChatMessage> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageSent extends DriverState {
  final ChatMessage message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

// ──────────────────────────────────────────────
// Disputes
// ──────────────────────────────────────────────

class DisputesLoaded extends DriverState {
  final List<Dispute> disputes;

  const DisputesLoaded(this.disputes);

  @override
  List<Object?> get props => [disputes];
}

class CounterEvidenceSubmitted extends DriverState {
  final Dispute dispute;

  const CounterEvidenceSubmitted(this.dispute);

  @override
  List<Object?> get props => [dispute];
}

// ──────────────────────────────────────────────
// GPS & Location
// ──────────────────────────────────────────────

class FakeGpsCheckResult extends DriverState {
  final bool isSpoofingDetected;

  const FakeGpsCheckResult({required this.isSpoofingDetected});

  @override
  List<Object?> get props => [isSpoofingDetected];
}

class DriverLocationUpdated extends DriverState {
  const DriverLocationUpdated();
}

// ──────────────────────────────────────────────
// KPIs
// ──────────────────────────────────────────────

class DriverKpisLoaded extends DriverState {
  final Map<String, dynamic> kpis;

  const DriverKpisLoaded(this.kpis);

  /// Convenience accessors mirroring the documented KPI keys.
  double get onTimePct => (kpis['onTimePct'] as num?)?.toDouble() ?? 0.0;
  double get rating => (kpis['rating'] as num?)?.toDouble() ?? 0.0;
  double get scansPerDay => (kpis['scansPerDay'] as num?)?.toDouble() ?? 0.0;
  double get photoQualityScore =>
      (kpis['photoQualityScore'] as num?)?.toDouble() ?? 0.0;
  String get tier => kpis['tier'] as String? ?? 'bronze';

  @override
  List<Object?> get props => [kpis];
}

// ──────────────────────────────────────────────
// Offline Sync
// ──────────────────────────────────────────────

class OfflineSyncCompleted extends DriverState {
  final int syncedCount;
  final int failedCount;

  const OfflineSyncCompleted({required this.syncedCount, this.failedCount = 0});

  @override
  List<Object?> get props => [syncedCount, failedCount];
}

// ──────────────────────────────────────────────
// Compliance
// ──────────────────────────────────────────────

class ComplianceChecked extends DriverState {
  final bool hasExpiredDocs;
  final List<String> expiringDocs;

  const ComplianceChecked({
    required this.hasExpiredDocs,
    this.expiringDocs = const [],
  });

  @override
  List<Object?> get props => [hasExpiredDocs, expiringDocs];
}
