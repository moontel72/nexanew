import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nexatrace_system/core/errors/failures.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/delivery.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver_earnings.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver_statistics.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/vehicle.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/repositories/driver_delivery_repository.dart';

part 'driver_delivery_event.dart';
part 'driver_delivery_state.dart';

/// BLoC for managing driver delivery operations
class DriverDeliveryBloc
    extends Bloc<DriverDeliveryEvent, DriverDeliveryState> {
  final DriverDeliveryRepository _repository;
  Timer? _locationUpdateTimer;
  Timer? _sessionTimer;
  StreamSubscription<Delivery>? _deliveryUpdatesSubscription;

  DriverDeliveryBloc({
    required DriverDeliveryRepository repository,
  })  : _repository = repository,
        super(const DriverDeliveryInitial()) {
    // Register event handlers
    on<LoadDriverProfile>(_onLoadDriverProfile);
    on<UpdateDriverProfile>(_onUpdateDriverProfile);
    on<LoadTodayDeliveries>(_onLoadTodayDeliveries);
    on<LoadDeliveryById>(_onLoadDeliveryById);
    on<StartDelivery>(_onStartDelivery);
    on<CompleteDelivery>(_onCompleteDelivery);
    on<UpdateDeliveryLocation>(_onUpdateDeliveryLocation);
    on<MarkAttendance>(_onMarkAttendance);
    on<LoadDriverEarnings>(_onLoadDriverEarnings);
    on<LoadDeliveryStatistics>(_onLoadDeliveryStatistics);
    on<SearchDeliveries>(_onSearchDeliveries);
    on<FilterDeliveries>(_onFilterDeliveries);
    on<RefreshDeliveries>(_onRefreshDeliveries);
    on<ClearErrors>(_onClearErrors);
    on<UpdateDeliveryStatus>(_onUpdateDeliveryStatus);
    on<LoadDeliveryRoute>(_onLoadDeliveryRoute);
    on<ReportDeliveryIssue>(_onReportDeliveryIssue);
    on<LoadVehicleInfo>(_onLoadVehicleInfo);
    on<UpdateVehicleInfo>(_onUpdateVehicleInfo);
    on<LoadDriverRating>(_onLoadDriverRating);
    on<SubmitFeedback>(_onSubmitFeedback);
  }

  @override
  Future<void> close() {
    _locationUpdateTimer?.cancel();
    _sessionTimer?.cancel();
    _deliveryUpdatesSubscription?.cancel();
    return super.close();
  }

  /// Start location tracking for a delivery
  void _startLocationTracking(String deliveryId) {
    // Cancel any existing timer
    _locationUpdateTimer?.cancel();

    // Start a new timer to update location every 30 seconds
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        try {
          // Get current location (in a real app, this would come from GPS)
          // For now, we'll simulate location updates
          final currentLocation = await _repository.getCurrentLocation();

          add(UpdateDeliveryLocation(
            deliveryId: deliveryId,
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            accuracy: currentLocation.accuracy,
            speed: currentLocation.speed,
          ));
        } catch (error) {
          // Log error but don't stop tracking
          if (kDebugMode) {
            print('Location tracking error: $error');
          }
        }
      },
    );
  }

  /// Stop location tracking
  void _stopLocationTracking() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Handle loading driver profile
  Future<void> _onLoadDriverProfile(
    LoadDriverProfile event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final driver = await _repository.getDriverProfile();
      final vehicle = await _repository.getVehicleInfo();

      emit(DriverProfileLoaded(
        driver: driver,
        vehicle: vehicle,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized') ||
            failure.message.contains('Unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle updating driver profile
  Future<void> _onUpdateDriverProfile(
    UpdateDriverProfile event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final updatedDriver = await _repository.updateDriverProfile(
        name: event.name,
        phone: event.phone,
        licenseNumber: event.licenseNumber,
        vehicleType: event.vehicleType,
        vehicleNumber: event.vehicleNumber,
      );

      emit(ProfileUpdated(driver: updatedDriver));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle loading today's deliveries
  Future<void> _onLoadTodayDeliveries(
    LoadTodayDeliveries event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final deliveries = await _repository.getTodayDeliveries();
      final currentDelivery = await _repository.getCurrentDelivery();

      if (deliveries.isEmpty) {
        emit(const NoDeliveries());
      } else {
        emit(DeliveriesLoaded(
          deliveries: deliveries,
          currentDelivery: currentDelivery,
          totalCount: deliveries.length,
        ));
      }
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle loading delivery by ID
  Future<void> _onLoadDeliveryById(
    LoadDeliveryById event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final delivery = await _repository.getDeliveryById(event.deliveryId);
      final relatedDeliveries =
          await _repository.getRelatedDeliveries(event.deliveryId);

      emit(DeliveryDetailLoaded(
        delivery: delivery,
        relatedDeliveries: relatedDeliveries,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle starting a delivery
  Future<void> _onStartDelivery(
    StartDelivery event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final delivery = await _repository.startDelivery(event.deliveryId);

      // Start location tracking for this delivery
      _startLocationTracking(event.deliveryId);

      emit(DeliveryStarted(delivery: delivery));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle completing a delivery
  Future<void> _onCompleteDelivery(
    CompleteDelivery event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final result = await _repository.completeDelivery(
        deliveryId: event.deliveryId,
        proofImagePath: event.proofImagePath,
        signaturePath: event.signaturePath,
        otp: event.otp,
        notes: event.notes,
      );

      // Stop location tracking
      _stopLocationTracking();

      emit(DeliveryCompleted(
        delivery: result.delivery,
        proofUrl: result.proofUrl,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle updating delivery location
  Future<void> _onUpdateDeliveryLocation(
    UpdateDeliveryLocation event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    try {
      await _repository.updateDeliveryLocation(
        deliveryId: event.deliveryId,
        latitude: event.latitude,
        longitude: event.longitude,
        accuracy: event.accuracy,
        speed: event.speed,
      );

      emit(LocationUpdated(
        deliveryId: event.deliveryId,
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: DateTime.now(),
      ));
    } catch (error) {
      // Don't emit error for location updates to avoid disrupting UI
      if (kDebugMode) {
        print('Location update failed: $error');
      }
    }
  }

  /// Handle marking attendance
  Future<void> _onMarkAttendance(
    MarkAttendance event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final result = await _repository.markAttendance(
        latitude: event.latitude,
        longitude: event.longitude,
        notes: event.notes,
      );

      emit(AttendanceMarked(
        timestamp: result.timestamp,
        location: result.location,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle loading driver earnings
  Future<void> _onLoadDriverEarnings(
    LoadDriverEarnings event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final earnings = await _repository.getDriverEarnings(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final earningsHistory = await _repository.getEarningsHistory(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(EarningsLoaded(
        earnings: earnings,
        earningsHistory: earningsHistory,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle loading delivery statistics
  Future<void> _onLoadDeliveryStatistics(
    LoadDeliveryStatistics event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final statistics = await _repository.getDeliveryStatistics();

      emit(StatisticsLoaded(statistics: statistics));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle searching deliveries
  Future<void> _onSearchDeliveries(
    SearchDeliveries event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final results = await _repository.searchDeliveries(
        query: event.query,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
      );

      emit(SearchResults(
        results: results,
        query: event.query,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle filtering deliveries
  Future<void> _onFilterDeliveries(
    FilterDeliveries event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final results = await _repository.filterDeliveries(
        status: event.status,
        date: event.date,
        area: event.area,
      );

      emit(FilterResults(
        results: results,
        filters: {
          'status': event.status,
          'date': event.date,
          'area': event.area,
        },
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle refreshing deliveries
  Future<void> _onRefreshDeliveries(
    RefreshDeliveries event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    try {
      if (state is DeliveriesLoaded) {
        final currentState = state as DeliveriesLoaded;
        emit(DriverDeliveryRefreshing(
            currentDeliveries: currentState.deliveries));
      }

      final deliveries = await _repository.getTodayDeliveries();
      final currentDelivery = await _repository.getCurrentDelivery();

      emit(DeliveriesLoaded(
        deliveries: deliveries,
        currentDelivery: currentDelivery,
        totalCount: deliveries.length,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle clearing errors
  Future<void> _onClearErrors(
    ClearErrors event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    if (state is DriverDeliveryError) {
      emit(const DriverDeliveryInitial());
    }
  }

  /// Handle updating delivery status
  Future<void> _onUpdateDeliveryStatus(
    UpdateDeliveryStatus event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final delivery = await _repository.updateDeliveryStatus(
        deliveryId: event.deliveryId,
        status: event.status,
        reason: event.reason,
      );

      emit(DeliveryDetailLoaded(delivery: delivery));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle loading delivery route
  Future<void> _onLoadDeliveryRoute(
    LoadDeliveryRoute event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      // Get delivery route information
      await _repository.getDeliveryRoute(event.deliveryId);
      final delivery = await _repository.getDeliveryById(event.deliveryId);

      emit(DeliveryDetailLoaded(
        delivery: delivery,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle reporting delivery issue
  Future<void> _onReportDeliveryIssue(
    ReportDeliveryIssue event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      await _repository.reportDeliveryIssue(
        deliveryId: event.deliveryId,
        issueType: event.issueType,
        description: event.description,
        imagePaths: event.imagePaths,
      );

      emit(IssueReported(
        deliveryId: event.deliveryId,
        issueType: event.issueType,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle loading vehicle information
  Future<void> _onLoadVehicleInfo(
    LoadVehicleInfo event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final vehicle = await _repository.getVehicleInfo();

      emit(DriverProfileLoaded(
        driver: await _repository.getDriverProfile(),
        vehicle: vehicle,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);

      emit(DriverDeliveryError(
        message: failure.message,
        isNetworkError: failure is NetworkFailure,
        isServerError: failure is ServerFailure,
        isUnauthorized: failure.message.contains('unauthorized'),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle updating vehicle information
  Future<void> _onUpdateVehicleInfo(
    UpdateVehicleInfo event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final vehicle = await _repository.updateVehicleInfo(
        vehicleNumber: event.vehicleNumber,
        vehicleType: event.vehicleType,
        insuranceNumber: event.insuranceNumber,
        insuranceExpiry: event.insuranceExpiry,
        fitnessCertificateNumber: event.fitnessCertificateNumber,
        fitnessExpiry: event.fitnessExpiry,
      );

      final driver = await _repository.getDriverProfile();
      emit(DriverProfileLoaded(driver: driver, vehicle: vehicle));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(DriverDeliveryError(
          message: failure.message, stackTrace: stackTrace));
    }
  }

  /// Handle loading driver rating
  Future<void> _onLoadDriverRating(
    LoadDriverRating event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      final rating = await _repository.getDriverRating();
      final driver = await _repository.getDriverProfile();
      emit(DriverProfileLoaded(driver: driver.copyWith(rating: rating)));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(DriverDeliveryError(
          message: failure.message, stackTrace: stackTrace));
    }
  }

  /// Handle submitting feedback for a delivery
  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<DriverDeliveryState> emit,
  ) async {
    emit(const DriverDeliveryLoading());

    try {
      await _repository.submitFeedback(
        deliveryId: event.deliveryId,
        rating: event.rating,
        comments: event.comments,
      );
      emit(FeedbackSubmitted(
        deliveryId: event.deliveryId,
        rating: event.rating,
      ));
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error, stackTrace);
      emit(DriverDeliveryError(
          message: failure.message, stackTrace: stackTrace));
    }
  }
}
