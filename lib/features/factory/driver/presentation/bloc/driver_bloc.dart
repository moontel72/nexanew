import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexatrace_system/features/factory/driver/domain/repositories/driver_repository.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/trip.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/expense.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/factory_driver.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/proof_of_delivery.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/chat_message.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/dispute.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/driver_earnings.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/earning_transaction.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/vehicle_maintenance.dart';

part 'driver_event.dart';
part 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRepository _repository;

  DriverBloc({required DriverRepository repository})
    : _repository = repository,
      super(const DriverInitial()) {
    // ── Profile ────────────────────────────────────────
    on<LoadDriverProfile>(_onLoadDriverProfile);

    // ── Trips ──────────────────────────────────────────
    on<LoadTrips>(_onLoadTrips);
    on<LoadTripById>(_onLoadTripById);
    on<UpdateTripStatus>(_onUpdateTripStatus);

    // ── Geofence / Scan eligibility ────────────────────
    on<CheckScanEligibility>(_onCheckScanEligibility);

    // ── Scanning ───────────────────────────────────────
    on<ScanPickup>(_onScanPickup);
    on<ScanDelivery>(_onScanDelivery);

    // ── Proof of Delivery ──────────────────────────────
    on<SubmitProofOfDelivery>(_onSubmitProofOfDelivery);

    // ── Expenses ───────────────────────────────────────
    on<SubmitExpense>(_onSubmitExpense);
    on<LoadTripExpenses>(_onLoadTripExpenses);

    // ── Earnings ───────────────────────────────────────
    on<LoadEarnings>(_onLoadEarnings);
    on<LoadPaymentHistory>(_onLoadPaymentHistory);

    // ── Vehicle info & maintenance ─────────────────────
    on<LoadVehicleInfo>(_onLoadVehicleInfo);
    on<UpdateMeterReadings>(_onUpdateMeterReadings);
    on<AddMaintenanceLog>(_onAddMaintenanceLog);
    on<LoadMaintenanceLogs>(_onLoadMaintenanceLogs);

    // ── Chat / Messages ────────────────────────────────
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);

    // ── Disputes ───────────────────────────────────────
    on<LoadDisputes>(_onLoadDisputes);
    on<SubmitCounterEvidence>(_onSubmitCounterEvidence);
    on<SubmitDisputeEvidence>(_onSubmitDisputeEvidence);

    // ── GPS & Location ─────────────────────────────────
    on<CheckFakeGps>(_onCheckFakeGps);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);

    // ── KPIs ───────────────────────────────────────────
    on<LoadDriverKpis>(_onLoadDriverKpis);

    // ── Offline Sync ───────────────────────────────────
    on<SyncOfflineData>(_onSyncOfflineData);

    // ── Compliance ─────────────────────────────────────
    on<CheckCompliance>(_onCheckCompliance);

    // ── Chat Conversations List ────────────────────────
    on<LoadConversations>(_onLoadConversations);

    // ── Performance (alias for LoadDriverKpis) ──────────
    on<LoadPerformance>(_onLoadPerformance);

    // ── Expenses (all) ──────────────────────────────────
    on<LoadExpenses>(_onLoadExpenses);

    // ── Compliance (alias for CheckCompliance) ──────────
    on<LoadCompliance>(_onLoadCompliance);

    // ── Document Upload ─────────────────────────────────
    on<UploadDocument>(_onUploadDocument);

    // ── Utility ────────────────────────────────────────
    on<ClearError>(_onClearError);
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  Future<void> _onLoadDriverProfile(
    LoadDriverProfile event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading driver profile'));
    try {
      final driver = await _repository.getDriverProfile();
      emit(DriverProfileLoaded(driver));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Trips
  // ---------------------------------------------------------------------------

  Future<void> _onLoadTrips(LoadTrips event, Emitter<DriverState> emit) async {
    emit(const DriverLoading(action: 'Loading trips'));
    try {
      final trips = await _repository.getTrips(status: event.statusFilter);
      emit(TripsLoaded(trips: trips));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onLoadTripById(
    LoadTripById event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading trip details'));
    try {
      final trip = await _repository.getTripById(event.tripId);
      emit(TripDetailLoaded(trip));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTripStatus(
    UpdateTripStatus event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Updating trip status'));
    try {
      final trip = await _repository.updateTripStatus(
        tripId: event.tripId,
        status: event.status,
        lat: event.lat,
        lng: event.lng,
      );
      emit(TripStatusUpdated(trip));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Geofence / Scan eligibility
  // ---------------------------------------------------------------------------

  Future<void> _onCheckScanEligibility(
    CheckScanEligibility event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Checking scan eligibility'));
    try {
      final isEligible = await _repository.checkDeliveryScanEligibility(
        tripId: event.tripId,
        lat: event.lat,
        lng: event.lng,
      );
      emit(
        ScanEligibilityResult(
          isEligible: isEligible,
          reason: isEligible ? null : 'Outside allowed geofence',
        ),
      );
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Scanning
  // ---------------------------------------------------------------------------

  Future<void> _onScanPickup(
    ScanPickup event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Scanning pickup'));
    try {
      final trip = await _repository.scanPickup(
        tripId: event.tripId,
        code: event.code,
        lat: event.lat,
        lng: event.lng,
      );
      emit(ScanCompleted(trip: trip, scanType: 'pickup'));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onScanDelivery(
    ScanDelivery event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Scanning delivery'));
    try {
      final trip = await _repository.scanDelivery(
        tripId: event.tripId,
        code: event.code,
        lat: event.lat,
        lng: event.lng,
      );
      emit(ScanCompleted(trip: trip, scanType: 'delivery'));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Proof of Delivery
  // ---------------------------------------------------------------------------

  Future<void> _onSubmitProofOfDelivery(
    SubmitProofOfDelivery event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Submitting proof of delivery'));
    try {
      final pod = await _repository.submitProofOfDelivery(
        tripId: event.tripId,
        type: event.verificationType,
        pin: event.pin,
        recipientPhotoPath: event.recipientPhotoPath,
        documentPhotoPath: event.documentPhotoPath,
        signaturePath: event.signaturePath,
        recipientName: event.recipientName,
        debriefPhotoPaths: event.debriefPhotoPaths,
        damageNotes: event.damageNotes,
      );
      emit(ProofOfDeliverySubmitted(pod));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------

  Future<void> _onSubmitExpense(
    SubmitExpense event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Submitting expense'));
    try {
      final expense = await _repository.submitExpense(
        tripId: event.tripId ?? '',
        type: event.type,
        amount: event.amount,
        receiptPath: event.receiptPath ?? '',
        notes: event.notes ?? '',
      );
      emit(ExpenseSubmitted(expense));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onLoadTripExpenses(
    LoadTripExpenses event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading trip expenses'));
    try {
      final expenses = await _repository.getTripExpenses(event.tripId);
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Earnings
  // ---------------------------------------------------------------------------

  Future<void> _onLoadEarnings(
    LoadEarnings event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading earnings'));
    try {
      final earnings = await _repository.getEarnings(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(EarningsLoaded(earnings));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onLoadPaymentHistory(
    LoadPaymentHistory event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading payment history'));
    try {
      final transactions = await _repository.getPaymentHistory(
        startDate: event.startDate,
        endDate: event.endDate,
        page: event.page ?? 1,
      );
      emit(
        PaymentHistoryLoaded(transactions: transactions, page: event.page ?? 1),
      );
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Vehicle info & maintenance
  // ---------------------------------------------------------------------------

  Future<void> _onLoadVehicleInfo(
    LoadVehicleInfo event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading vehicle info'));
    try {
      final driver = await _repository.getDriverProfile();
      emit(VehicleInfoLoaded(driver));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMeterReadings(
    UpdateMeterReadings event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Updating meter readings'));
    try {
      // updateTripStatus also persists meter-related fields on the backend
      final trip = await _repository.updateTripStatus(
        tripId: event.tripId,
        status: TripStatus.inTransit,
        lat: 0.0,
        lng: 0.0,
      );
      emit(MeterReadingsUpdated(trip));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onAddMaintenanceLog(
    AddMaintenanceLog event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Adding maintenance log'));
    try {
      final log = await _repository.addMaintenanceLog(
        vehicleId: event.vehicleId,
        type: event.type,
        serviceDate: event.serviceDate,
        nextServiceDate: event.nextServiceDate ?? event.serviceDate,
        mileage: event.mileage,
        notes: event.notes ?? '',
      );
      emit(MaintenanceLogAdded(log));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onLoadMaintenanceLogs(
    LoadMaintenanceLogs event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading maintenance logs'));
    try {
      final logs = await _repository.getMaintenanceLogs(event.vehicleId);
      emit(MaintenanceLogsLoaded(logs));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Chat / Messages
  // ---------------------------------------------------------------------------

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading messages'));
    try {
      final messages = await _repository.getMessages(
        event.chatId,
        page: event.page ?? 1,
      );
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Sending message'));
    try {
      final message = await _repository.sendMessage(
        chatId: event.chatId,
        message: event.message,
        attachmentPath: event.attachmentPath,
      );
      emit(MessageSent(message));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Disputes
  // ---------------------------------------------------------------------------

  Future<void> _onLoadDisputes(
    LoadDisputes event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading disputes'));
    try {
      final disputes = await _repository.getDisputes();
      emit(DisputesLoaded(disputes));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onSubmitCounterEvidence(
    SubmitCounterEvidence event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Submitting counter-evidence'));
    try {
      final dispute = await _repository.submitCounterEvidence(
        disputeId: event.disputeId,
        evidence: event.evidence,
      );
      emit(CounterEvidenceSubmitted(dispute));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  /// Alias for SubmitCounterEvidence - used by disputes screen
  Future<void> _onSubmitDisputeEvidence(
    SubmitDisputeEvidence event,
    Emitter<DriverState> emit,
  ) async {
    await _onSubmitCounterEvidence(
      SubmitCounterEvidence(
        disputeId: event.disputeId,
        counterEvidence: event.counterEvidence,
      ),
      emit,
    );
  }

  // ---------------------------------------------------------------------------
  // GPS & Location
  // ---------------------------------------------------------------------------

  Future<void> _onCheckFakeGps(
    CheckFakeGps event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Checking fake GPS'));
    try {
      final isSpoofing = await _repository.checkFakeGps();
      emit(FakeGpsCheckResult(isSpoofingDetected: isSpoofing));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Updating location'));
    try {
      await _repository.updateLocation(
        tripId: event.tripId,
        lat: event.lat,
        lng: event.lng,
      );
      emit(const DriverLocationUpdated());
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // KPIs
  // ---------------------------------------------------------------------------

  Future<void> _onLoadDriverKpis(
    LoadDriverKpis event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading KPIs'));
    try {
      final kpis = await _repository.getDriverKpis();
      emit(DriverKpisLoaded(kpis));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Offline Sync
  // ---------------------------------------------------------------------------

  Future<void> _onSyncOfflineData(
    SyncOfflineData event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Syncing offline data'));
    try {
      await _repository.syncOfflineData(event.pendingActions);
      emit(OfflineSyncCompleted(syncedCount: event.pendingActions.length));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Compliance
  // ---------------------------------------------------------------------------

  Future<void> _onCheckCompliance(
    CheckCompliance event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Checking compliance'));
    try {
      final driver = await _repository.getDriverProfile();
      final expiringDocs = <String>[];

      if (driver.isLicenseExpired || driver.isLicenseExpiringSoon) {
        expiringDocs.add('license');
      }
      if (driver.isInsuranceExpired) {
        expiringDocs.add('insurance');
      }
      if (driver.registrationExpiry != null &&
          driver.registrationExpiry!.difference(DateTime.now()).inDays <= 30) {
        expiringDocs.add('registration');
      }

      final hasExpiredDocs =
          driver.isLicenseExpired ||
          driver.isInsuranceExpired ||
          (driver.registrationExpiry != null &&
              driver.registrationExpiry!.isBefore(DateTime.now()));

      emit(
        ComplianceChecked(
          hasExpiredDocs: hasExpiredDocs,
          expiringDocs: expiringDocs,
        ),
      );
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Chat Conversations List
  // ---------------------------------------------------------------------------

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading conversations'));
    try {
      // Conversations are loaded via messages with admin/customer
      final messages = await _repository.getMessages('admin');
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Performance (alias)
  // ---------------------------------------------------------------------------

  Future<void> _onLoadPerformance(
    LoadPerformance event,
    Emitter<DriverState> emit,
  ) async {
    // Delegate to the KPIs handler
    await _onLoadDriverKpis(const LoadDriverKpis(), emit);
  }

  // ---------------------------------------------------------------------------
  // Expenses (all - loads trip expenses)
  // ---------------------------------------------------------------------------

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Loading expenses'));
    try {
      if (event.tripId != null) {
        final expenses = await _repository.getTripExpenses(event.tripId!);
        emit(ExpensesLoaded(expenses));
      } else {
        // Load expenses for all trips - for now emit empty
        emit(const ExpensesLoaded([]));
      }
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Compliance (alias)
  // ---------------------------------------------------------------------------

  Future<void> _onLoadCompliance(
    LoadCompliance event,
    Emitter<DriverState> emit,
  ) async {
    await _onCheckCompliance(const CheckCompliance(), emit);
  }

  // ---------------------------------------------------------------------------
  // Document Upload
  // ---------------------------------------------------------------------------

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverLoading(action: 'Uploading document'));
    try {
      // Document upload handled by repository
      // For now emit a compliance re-check
      await _onCheckCompliance(const CheckCompliance(), emit);
    } catch (e) {
      emit(DriverError(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  Future<void> _onClearError(
    ClearError event,
    Emitter<DriverState> emit,
  ) async {
    emit(const DriverInitial());
  }
}
