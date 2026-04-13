//lib/features/driver_delivery/presentation/bloc/driver_delivery_event.dart
part of 'driver_delivery_bloc.dart';

/// States for Driver Delivery BLoC
abstract class DriverDeliveryState extends Equatable {
  const DriverDeliveryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DriverDeliveryInitial extends DriverDeliveryState {
  const DriverDeliveryInitial();
}

/// Loading state
class DriverDeliveryLoading extends DriverDeliveryState {
  const DriverDeliveryLoading();
}

/// Driver profile loaded successfully
class DriverProfileLoaded extends DriverDeliveryState {
  final Driver driver;
  final Vehicle? vehicle;

  const DriverProfileLoaded({
    required this.driver,
    this.vehicle,
  });

  @override
  List<Object?> get props => [driver, vehicle];
}

/// Deliveries loaded successfully
class DeliveriesLoaded extends DriverDeliveryState {
  final List<Delivery> deliveries;
  final Delivery? currentDelivery;
  final bool hasMore;
  final int totalCount;

  const DeliveriesLoaded({
    required this.deliveries,
    this.currentDelivery,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [deliveries, currentDelivery, hasMore, totalCount];
}

/// Delivery details loaded
class DeliveryDetailLoaded extends DriverDeliveryState {
  final Delivery delivery;
  final List<Delivery>? relatedDeliveries;

  const DeliveryDetailLoaded({
    required this.delivery,
    this.relatedDeliveries,
  });

  @override
  List<Object?> get props => [delivery, relatedDeliveries];
}

/// Earnings loaded successfully
class EarningsLoaded extends DriverDeliveryState {
  final DriverEarnings earnings;
  final List<DriverEarnings>? earningsHistory;

  const EarningsLoaded({
    required this.earnings,
    this.earningsHistory,
  });

  @override
  List<Object?> get props => [earnings, earningsHistory];
}

/// Statistics loaded successfully
class StatisticsLoaded extends DriverDeliveryState {
  final DriverStatistics statistics;

  const StatisticsLoaded({
    required this.statistics,
  });

  @override
  List<Object?> get props => [statistics];
}

/// Delivery started successfully
class DeliveryStarted extends DriverDeliveryState {
  final Delivery delivery;

  const DeliveryStarted({
    required this.delivery,
  });

  @override
  List<Object?> get props => [delivery];
}

/// Delivery completed successfully
class DeliveryCompleted extends DriverDeliveryState {
  final Delivery delivery;
  final String? proofUrl;

  const DeliveryCompleted({
    required this.delivery,
    this.proofUrl,
  });

  @override
  List<Object?> get props => [delivery, proofUrl];
}

/// Location updated successfully
class LocationUpdated extends DriverDeliveryState {
  final String deliveryId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationUpdated({
    required this.deliveryId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [deliveryId, latitude, longitude, timestamp];
}

/// Attendance marked successfully
class AttendanceMarked extends DriverDeliveryState {
  final DateTime timestamp;
  final String location;

  const AttendanceMarked({
    required this.timestamp,
    required this.location,
  });

  @override
  List<Object?> get props => [timestamp, location];
}

/// Profile updated successfully
class ProfileUpdated extends DriverDeliveryState {
  final Driver driver;

  const ProfileUpdated({
    required this.driver,
  });

  @override
  List<Object?> get props => [driver];
}

/// Vehicle info updated successfully
class VehicleInfoUpdated extends DriverDeliveryState {
  final Vehicle vehicle;

  const VehicleInfoUpdated({
    required this.vehicle,
  });

  @override
  List<Object?> get props => [vehicle];
}

/// Feedback submitted successfully
class FeedbackSubmitted extends DriverDeliveryState {
  final String deliveryId;
  final int rating;

  const FeedbackSubmitted({
    required this.deliveryId,
    required this.rating,
  });

  @override
  List<Object?> get props => [deliveryId, rating];
}

/// Issue reported successfully
class IssueReported extends DriverDeliveryState {
  final String deliveryId;
  final String issueType;

  const IssueReported({
    required this.deliveryId,
    required this.issueType,
  });

  @override
  List<Object?> get props => [deliveryId, issueType];
}

/// Error state
class DriverDeliveryError extends DriverDeliveryState {
  final String message;
  final String? errorCode;
  final bool isNetworkError;
  final bool isServerError;
  final bool isUnauthorized;
  final StackTrace? stackTrace;

  const DriverDeliveryError({
    required this.message,
    this.errorCode,
    this.isNetworkError = false,
    this.isServerError = false,
    this.isUnauthorized = false,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [
        message,
        errorCode,
        isNetworkError,
        isServerError,
        isUnauthorized,
        stackTrace,
      ];
}

/// No deliveries state
class NoDeliveries extends DriverDeliveryState {
  final String message;

  const NoDeliveries({
    this.message = 'No deliveries found',
  });

  @override
  List<Object?> get props => [message];
}

/// Empty state
class DriverDeliveryEmpty extends DriverDeliveryState {
  final String message;

  const DriverDeliveryEmpty({
    this.message = 'No data available',
  });

  @override
  List<Object?> get props => [message];
}

/// Refreshing state
class DriverDeliveryRefreshing extends DriverDeliveryState {
  final List<Delivery> currentDeliveries;

  const DriverDeliveryRefreshing({
    required this.currentDeliveries,
  });

  @override
  List<Object?> get props => [currentDeliveries];
}

/// Loading more state
class DriverDeliveryLoadingMore extends DriverDeliveryState {
  final List<Delivery> currentDeliveries;

  const DriverDeliveryLoadingMore({
    required this.currentDeliveries,
  });

  @override
  List<Object?> get props => [currentDeliveries];
}

/// Search results state
class SearchResults extends DriverDeliveryState {
  final List<Delivery> results;
  final String query;

  const SearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

/// Filter results state
class FilterResults extends DriverDeliveryState {
  final List<Delivery> results;
  final Map<String, dynamic> filters;

  const FilterResults({
    required this.results,
    required this.filters,
  });

  @override
  List<Object?> get props => [results, filters];
}
