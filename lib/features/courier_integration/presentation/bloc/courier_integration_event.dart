part of 'courier_integration_bloc.dart';

/// Events for Courier Integration BLoC
abstract class CourierIntegrationEvent extends Equatable {
  const CourierIntegrationEvent();

  @override
  List<Object?> get props => [];
}

/// Load available courier services
class LoadCourierServices extends CourierIntegrationEvent {
  const LoadCourierServices();
}

/// Load shipment by ID
class LoadShipmentById extends CourierIntegrationEvent {
  final String shipmentId;

  const LoadShipmentById(this.shipmentId);

  @override
  List<Object?> get props => [shipmentId];
}

/// Create a new shipment
class CreateShipment extends CourierIntegrationEvent {
  final String courierServiceId;
  final String senderName;
  final String senderPhone;
  final String senderAddress;
  final String senderCity;
  final String senderCountry;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final String recipientCity;
  final String recipientCountry;
  final double weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final String? description;
  final double? declaredValue;
  final String? paymentMethod;
  final bool isCashOnDelivery;
  final double? codAmount;
  final String? instructions;
  final List<String>? itemTypes;

  const CreateShipment({
    required this.courierServiceId,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.senderCity,
    required this.senderCountry,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.recipientCity,
    required this.recipientCountry,
    required this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.description,
    this.declaredValue,
    this.paymentMethod,
    this.isCashOnDelivery = false,
    this.codAmount,
    this.instructions,
    this.itemTypes,
  });

  @override
  List<Object?> get props => [
        courierServiceId,
        senderName,
        senderPhone,
        senderAddress,
        senderCity,
        senderCountry,
        recipientName,
        recipientPhone,
        recipientAddress,
        recipientCity,
        recipientCountry,
        weightKg,
        lengthCm,
        widthCm,
        heightCm,
        description,
        declaredValue,
        paymentMethod,
        isCashOnDelivery,
        codAmount,
        instructions,
        itemTypes,
      ];
}

/// Create bulk shipments
class CreateBulkShipments extends CourierIntegrationEvent {
  final List<Map<String, dynamic>> shipments;

  const CreateBulkShipments({
    required this.shipments,
  });

  @override
  List<Object?> get props => [shipments];
}

/// Get shipping label
class GetShippingLabel extends CourierIntegrationEvent {
  final String shipmentId;
  final String format; // pdf, png, etc.

  const GetShippingLabel({
    required this.shipmentId,
    this.format = 'pdf',
  });

  @override
  List<Object?> get props => [shipmentId, format];
}

/// Calculate shipping rate
class CalculateShippingRate extends CourierIntegrationEvent {
  final String courierServiceId;
  final String fromCity;
  final String toCity;
  final double weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? declaredValue;
  final bool isCashOnDelivery;
  final double? codAmount;

  const CalculateShippingRate({
    required this.courierServiceId,
    required this.fromCity,
    required this.toCity,
    required this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.declaredValue,
    this.isCashOnDelivery = false,
    this.codAmount,
  });

  @override
  List<Object?> get props => [
        courierServiceId,
        fromCity,
        toCity,
        weightKg,
        lengthCm,
        widthCm,
        heightCm,
        declaredValue,
        isCashOnDelivery,
        codAmount,
      ];
}

/// Track shipment
class TrackShipment extends CourierIntegrationEvent {
  final String trackingNumber;
  final String courierServiceId;

  const TrackShipment({
    required this.trackingNumber,
    required this.courierServiceId,
  });

  @override
  List<Object?> get props => [trackingNumber, courierServiceId];
}

/// Schedule pickup
class SchedulePickup extends CourierIntegrationEvent {
  final String courierServiceId;
  final DateTime pickupDate;
  final TimeOfDay pickupTime;
  final String pickupAddress;
  final String pickupCity;
  final String pickupCountry;
  final String contactName;
  final String contactPhone;
  final int numberOfPackages;
  final double totalWeight;
  final String? instructions;

  const SchedulePickup({
    required this.courierServiceId,
    required this.pickupDate,
    required this.pickupTime,
    required this.pickupAddress,
    required this.pickupCity,
    required this.pickupCountry,
    required this.contactName,
    required this.contactPhone,
    required this.numberOfPackages,
    required this.totalWeight,
    this.instructions,
  });

  @override
  List<Object?> get props => [
        courierServiceId,
        pickupDate,
        pickupTime,
        pickupAddress,
        pickupCity,
        pickupCountry,
        contactName,
        contactPhone,
        numberOfPackages,
        totalWeight,
        instructions,
      ];
}

/// Cancel shipment
class CancelShipment extends CourierIntegrationEvent {
  final String shipmentId;
  final String reason;

  const CancelShipment({
    required this.shipmentId,
    required this.reason,
  });

  @override
  List<Object?> get props => [shipmentId, reason];
}

/// Load shipment history
class LoadShipmentHistory extends CourierIntegrationEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String? courierServiceId;

  const LoadShipmentHistory({
    this.startDate,
    this.endDate,
    this.status,
    this.courierServiceId,
  });

  @override
  List<Object?> get props => [startDate, endDate, status, courierServiceId];
}

/// Search shipments
class SearchShipments extends CourierIntegrationEvent {
  final String query;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  const SearchShipments({
    required this.query,
    this.startDate,
    this.endDate,
    this.status,
  });

  @override
  List<Object?> get props => [query, startDate, endDate, status];
}

/// Filter shipments
class FilterShipments extends CourierIntegrationEvent {
  final String? status;
  final DateTime? date;
  final String? courierServiceId;
  final String? city;

  const FilterShipments({
    this.status,
    this.date,
    this.courierServiceId,
    this.city,
  });

  @override
  List<Object?> get props => [status, date, courierServiceId, city];
}

/// Refresh shipments
class RefreshShipments extends CourierIntegrationEvent {
  const RefreshShipments();
}

/// Clear errors
class ClearErrors extends CourierIntegrationEvent {
  const ClearErrors();
}

/// Update shipment status
class UpdateShipmentStatus extends CourierIntegrationEvent {
  final String shipmentId;
  final ShipmentStatus status;
  final String? notes;

  const UpdateShipmentStatus({
    required this.shipmentId,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [shipmentId, status, notes];
}

/// Generate manifest
class GenerateManifest extends CourierIntegrationEvent {
  final List<String> shipmentIds;
  final DateTime manifestDate;

  const GenerateManifest({
    required this.shipmentIds,
    required this.manifestDate,
  });

  @override
  List<Object?> get props => [shipmentIds, manifestDate];
}

/// Load courier rates
class LoadCourierRates extends CourierIntegrationEvent {
  final String courierServiceId;

  const LoadCourierRates(this.courierServiceId);

  @override
  List<Object?> get props => [courierServiceId];
}

/// Create return shipment
class CreateReturnShipment extends CourierIntegrationEvent {
  final String originalShipmentId;
  final String reason;
  final String? instructions;

  const CreateReturnShipment({
    required this.originalShipmentId,
    required this.reason,
    this.instructions,
  });

  @override
  List<Object?> get props => [originalShipmentId, reason, instructions];
}

/// Load pickup requests
class LoadPickupRequests extends CourierIntegrationEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  const LoadPickupRequests({
    this.startDate,
    this.endDate,
    this.status,
  });

  @override
  List<Object?> get props => [startDate, endDate, status];
}

/// Cancel pickup request
class CancelPickupRequest extends CourierIntegrationEvent {
  final String pickupRequestId;
  final String reason;

  const CancelPickupRequest({
    required this.pickupRequestId,
    required this.reason,
  });

  @override
  List<Object?> get props => [pickupRequestId, reason];
}

/// Update pickup request
class UpdatePickupRequest extends CourierIntegrationEvent {
  final String pickupRequestId;
  final DateTime? pickupDate;
  final TimeOfDay? pickupTime;
  final String? instructions;

  const UpdatePickupRequest({
    required this.pickupRequestId,
    this.pickupDate,
    this.pickupTime,
    this.instructions,
  });

  @override
  List<Object?> get props =>
      [pickupRequestId, pickupDate, pickupTime, instructions];
}

/// Load tracking events
class LoadTrackingEvents extends CourierIntegrationEvent {
  final String trackingNumber;
  final String courierServiceId;

  const LoadTrackingEvents({
    required this.trackingNumber,
    required this.courierServiceId,
  });

  @override
  List<Object?> get props => [trackingNumber, courierServiceId];
}

/// Sync with courier API
class SyncWithCourierApi extends CourierIntegrationEvent {
  final String courierServiceId;
  final List<String>? shipmentIds;

  const SyncWithCourierApi({
    required this.courierServiceId,
    this.shipmentIds,
  });

  @override
  List<Object?> get props => [courierServiceId, shipmentIds];
}

/// Export shipments
class ExportShipments extends CourierIntegrationEvent {
  final List<String> shipmentIds;
  final String format; // csv, excel, pdf

  const ExportShipments({
    required this.shipmentIds,
    this.format = 'csv',
  });

  @override
  List<Object?> get props => [shipmentIds, format];
}

/// Load courier service statistics
class LoadCourierStatistics extends CourierIntegrationEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadCourierStatistics({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Test courier connection
class TestCourierConnection extends CourierIntegrationEvent {
  final String courierServiceId;

  const TestCourierConnection(this.courierServiceId);

  @override
  List<Object?> get props => [courierServiceId];
}
