part of 'courier_integration_bloc.dart';

/// States for Courier Integration BLoC
abstract class CourierIntegrationState extends Equatable {
  const CourierIntegrationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CourierIntegrationInitial extends CourierIntegrationState {
  const CourierIntegrationInitial();
}

/// Loading state
class CourierIntegrationLoading extends CourierIntegrationState {
  const CourierIntegrationLoading();
}

/// Courier services loaded successfully
class CourierServicesLoaded extends CourierIntegrationState {
  final List<CourierService> services;
  final CourierService? selectedService;

  const CourierServicesLoaded({
    required this.services,
    this.selectedService,
  });

  @override
  List<Object?> get props => [services, selectedService];
}

/// Shipment created successfully
class ShipmentCreated extends CourierIntegrationState {
  final Shipment shipment;
  final String? labelUrl;
  final String? trackingNumber;

  const ShipmentCreated({
    required this.shipment,
    this.labelUrl,
    this.trackingNumber,
  });

  @override
  List<Object?> get props => [shipment, labelUrl, trackingNumber];
}

/// Bulk shipments created successfully
class BulkShipmentsCreated extends CourierIntegrationState {
  final List<Shipment> shipments;
  final String? manifestUrl;

  const BulkShipmentsCreated({
    required this.shipments,
    this.manifestUrl,
  });

  @override
  List<Object?> get props => [shipments, manifestUrl];
}

/// Shipping label generated successfully
class ShippingLabelGenerated extends CourierIntegrationState {
  final String shipmentId;
  final String labelUrl;
  final String format;

  const ShippingLabelGenerated({
    required this.shipmentId,
    required this.labelUrl,
    required this.format,
  });

  @override
  List<Object?> get props => [shipmentId, labelUrl, format];
}

/// Shipping rate calculated successfully
class ShippingRateCalculated extends CourierIntegrationState {
  final ShippingRate rate;
  final String courierServiceId;

  const ShippingRateCalculated({
    required this.rate,
    required this.courierServiceId,
  });

  @override
  List<Object?> get props => [rate, courierServiceId];
}

/// Shipment tracked successfully
class ShipmentTracked extends CourierIntegrationState {
  final Shipment shipment;
  final List<TrackingEvent> trackingEvents;
  final String trackingNumber;

  const ShipmentTracked({
    required this.shipment,
    required this.trackingEvents,
    required this.trackingNumber,
  });

  @override
  List<Object?> get props => [shipment, trackingEvents, trackingNumber];
}

/// Pickup scheduled successfully
class PickupScheduled extends CourierIntegrationState {
  final PickupRequest pickupRequest;
  final String confirmationNumber;

  const PickupScheduled({
    required this.pickupRequest,
    required this.confirmationNumber,
  });

  @override
  List<Object?> get props => [pickupRequest, confirmationNumber];
}

/// Shipment cancelled successfully
class ShipmentCancelled extends CourierIntegrationState {
  final String shipmentId;
  final String reason;

  const ShipmentCancelled({
    required this.shipmentId,
    required this.reason,
  });

  @override
  List<Object?> get props => [shipmentId, reason];
}

/// Shipment history loaded successfully
class ShipmentHistoryLoaded extends CourierIntegrationState {
  final List<Shipment> shipments;
  final bool hasMore;
  final int totalCount;

  const ShipmentHistoryLoaded({
    required this.shipments,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [shipments, hasMore, totalCount];
}

/// Search results state
class SearchResults extends CourierIntegrationState {
  final List<Shipment> results;
  final String query;

  const SearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

/// Filter results state
class FilterResults extends CourierIntegrationState {
  final List<Shipment> results;
  final Map<String, dynamic> filters;

  const FilterResults({
    required this.results,
    required this.filters,
  });

  @override
  List<Object?> get props => [results, filters];
}

/// Manifest generated successfully
class ManifestGenerated extends CourierIntegrationState {
  final String manifestUrl;
  final DateTime manifestDate;
  final int shipmentCount;

  const ManifestGenerated({
    required this.manifestUrl,
    required this.manifestDate,
    required this.shipmentCount,
  });

  @override
  List<Object?> get props => [manifestUrl, manifestDate, shipmentCount];
}

/// Courier rates loaded successfully
class CourierRatesLoaded extends CourierIntegrationState {
  final List<ShippingRate> rates;
  final String courierServiceId;

  const CourierRatesLoaded({
    required this.rates,
    required this.courierServiceId,
  });

  @override
  List<Object?> get props => [rates, courierServiceId];
}

/// Return shipment created successfully
class ReturnShipmentCreated extends CourierIntegrationState {
  final Shipment returnShipment;
  final String originalShipmentId;

  const ReturnShipmentCreated({
    required this.returnShipment,
    required this.originalShipmentId,
  });

  @override
  List<Object?> get props => [returnShipment, originalShipmentId];
}

/// Pickup requests loaded successfully
class PickupRequestsLoaded extends CourierIntegrationState {
  final List<PickupRequest> pickupRequests;
  final bool hasMore;
  final int totalCount;

  const PickupRequestsLoaded({
    required this.pickupRequests,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [pickupRequests, hasMore, totalCount];
}

/// Pickup request cancelled successfully
class PickupRequestCancelled extends CourierIntegrationState {
  final String pickupRequestId;
  final String reason;

  const PickupRequestCancelled({
    required this.pickupRequestId,
    required this.reason,
  });

  @override
  List<Object?> get props => [pickupRequestId, reason];
}

/// Pickup request updated successfully
class PickupRequestUpdated extends CourierIntegrationState {
  final PickupRequest pickupRequest;

  const PickupRequestUpdated({
    required this.pickupRequest,
  });

  @override
  List<Object?> get props => [pickupRequest];
}

/// Tracking events loaded successfully
class TrackingEventsLoaded extends CourierIntegrationState {
  final List<TrackingEvent> events;
  final String trackingNumber;

  const TrackingEventsLoaded({
    required this.events,
    required this.trackingNumber,
  });

  @override
  List<Object?> get props => [events, trackingNumber];
}

/// Courier API sync completed
class CourierApiSynced extends CourierIntegrationState {
  final String courierServiceId;
  final int updatedShipments;
  final int newShipments;

  const CourierApiSynced({
    required this.courierServiceId,
    required this.updatedShipments,
    required this.newShipments,
  });

  @override
  List<Object?> get props => [courierServiceId, updatedShipments, newShipments];
}

/// Shipments exported successfully
class ShipmentsExported extends CourierIntegrationState {
  final String exportUrl;
  final String format;
  final int shipmentCount;

  const ShipmentsExported({
    required this.exportUrl,
    required this.format,
    required this.shipmentCount,
  });

  @override
  List<Object?> get props => [exportUrl, format, shipmentCount];
}

/// Courier statistics loaded successfully
class CourierStatisticsLoaded extends CourierIntegrationState {
  final CourierStatistics statistics;

  const CourierStatisticsLoaded({
    required this.statistics,
  });

  @override
  List<Object?> get props => [statistics];
}

/// Courier connection tested successfully
class CourierConnectionTested extends CourierIntegrationState {
  final String courierServiceId;
  final bool isConnected;
  final String? message;

  const CourierConnectionTested({
    required this.courierServiceId,
    required this.isConnected,
    this.message,
  });

  @override
  List<Object?> get props => [courierServiceId, isConnected, message];
}

/// Error state
class CourierIntegrationError extends CourierIntegrationState {
  final String message;
  final String? errorCode;
  final bool isNetworkError;
  final bool isServerError;
  final bool isUnauthorized;
  final bool isValidationError;
  final StackTrace? stackTrace;

  const CourierIntegrationError({
    required this.message,
    this.errorCode,
    this.isNetworkError = false,
    this.isServerError = false,
    this.isUnauthorized = false,
    this.isValidationError = false,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [
        message,
        errorCode,
        isNetworkError,
        isServerError,
        isUnauthorized,
        isValidationError,
        stackTrace,
      ];
}

/// No data state
class NoData extends CourierIntegrationState {
  final String message;

  const NoData({
    this.message = 'No data available',
  });

  @override
  List<Object?> get props => [message];
}

/// No shipments state
class NoShipments extends CourierIntegrationState {
  final String message;

  const NoShipments({
    this.message = 'No shipments found',
  });

  @override
  List<Object?> get props => [message];
}

/// Refreshing state
class CourierIntegrationRefreshing extends CourierIntegrationState {
  final List<Shipment> currentShipments;

  const CourierIntegrationRefreshing({
    required this.currentShipments,
  });

  @override
  List<Object?> get props => [currentShipments];
}

/// Loading more state
class CourierIntegrationLoadingMore extends CourierIntegrationState {
  final List<Shipment> currentShipments;

  const CourierIntegrationLoadingMore({
    required this.currentShipments,
  });

  @override
  List<Object?> get props => [currentShipments];
}

/// Shipment detail loaded
class ShipmentDetailLoaded extends CourierIntegrationState {
  final Shipment shipment;
  final List<TrackingEvent>? trackingEvents;
  final List<Shipment>? relatedShipments;

  const ShipmentDetailLoaded({
    required this.shipment,
    this.trackingEvents,
    this.relatedShipments,
  });

  @override
  List<Object?> get props => [shipment, trackingEvents, relatedShipments];
}

/// Shipment status updated
class ShipmentStatusUpdated extends CourierIntegrationState {
  final Shipment shipment;

  const ShipmentStatusUpdated({
    required this.shipment,
  });

  @override
  List<Object?> get props => [shipment];
}

/// Pickup request detail loaded
class PickupRequestDetailLoaded extends CourierIntegrationState {
  final PickupRequest pickupRequest;
  final List<Shipment>? associatedShipments;

  const PickupRequestDetailLoaded({
    required this.pickupRequest,
    this.associatedShipments,
  });

  @override
  List<Object?> get props => [pickupRequest, associatedShipments];
}
