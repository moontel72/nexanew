part of 'transport_marketplace_bloc.dart';

/// Events for Transport Marketplace BLoC
abstract class TransportMarketplaceEvent extends Equatable {
  const TransportMarketplaceEvent();

  @override
  List<Object?> get props => [];
}

/// Load available loads (for transporters)
class LoadAvailableLoads extends TransportMarketplaceEvent {
  final String? filterByType;
  final String? filterByOrigin;
  final String? filterByDestination;
  final DateTime? filterByDate;
  final double? minWeight;
  final double? maxWeight;

  const LoadAvailableLoads({
    this.filterByType,
    this.filterByOrigin,
    this.filterByDestination,
    this.filterByDate,
    this.minWeight,
    this.maxWeight,
  });

  @override
  List<Object?> get props => [
        filterByType,
        filterByOrigin,
        filterByDestination,
        filterByDate,
        minWeight,
        maxWeight,
      ];
}

/// Load my loads (for shippers)
class LoadMyLoads extends TransportMarketplaceEvent {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMyLoads({
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

/// Post a new load (for shippers)
class PostLoad extends TransportMarketplaceEvent {
  final String loadType;
  final String origin;
  final String destination;
  final DateTime pickupDate;
  final DateTime deliveryDate;
  final double weight;
  final String weightUnit;
  final String? dimensions;
  final String? commodityType;
  final String? specialRequirements;
  final double budget;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final List<String>? documents;

  const PostLoad({
    required this.loadType,
    required this.origin,
    required this.destination,
    required this.pickupDate,
    required this.deliveryDate,
    required this.weight,
    required this.weightUnit,
    this.dimensions,
    this.commodityType,
    this.specialRequirements,
    required this.budget,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.documents,
  });

  @override
  List<Object?> get props => [
        loadType,
        origin,
        destination,
        pickupDate,
        deliveryDate,
        weight,
        weightUnit,
        dimensions,
        commodityType,
        specialRequirements,
        budget,
        contactName,
        contactPhone,
        contactEmail,
        documents,
      ];
}

/// Load load details by ID
class LoadLoadDetails extends TransportMarketplaceEvent {
  final String loadId;

  const LoadLoadDetails(this.loadId);

  @override
  List<Object?> get props => [loadId];
}

/// Update load status
class UpdateLoadStatus extends TransportMarketplaceEvent {
  final String loadId;
  final LoadStatus status;
  final String? reason;

  const UpdateLoadStatus({
    required this.loadId,
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [loadId, status, reason];
}

/// Delete load
class DeleteLoad extends TransportMarketplaceEvent {
  final String loadId;
  final String reason;

  const DeleteLoad({
    required this.loadId,
    required this.reason,
  });

  @override
  List<Object?> get props => [loadId, reason];
}

/// Load available trucks (for shippers)
class LoadAvailableTrucks extends TransportMarketplaceEvent {
  final String? filterByType;
  final String? filterByLocation;
  final double? minCapacity;
  final double? maxCapacity;
  final DateTime? availableFrom;
  final DateTime? availableTo;

  const LoadAvailableTrucks({
    this.filterByType,
    this.filterByLocation,
    this.minCapacity,
    this.maxCapacity,
    this.availableFrom,
    this.availableTo,
  });

  @override
  List<Object?> get props => [
        filterByType,
        filterByLocation,
        minCapacity,
        maxCapacity,
        availableFrom,
        availableTo,
      ];
}

/// Load my trucks (for transporters)
class LoadMyTrucks extends TransportMarketplaceEvent {
  final String? status;

  const LoadMyTrucks({
    this.status,
  });

  @override
  List<Object?> get props => [status];
}

/// Register a new truck
class RegisterTruck extends TransportMarketplaceEvent {
  final String truckType;
  final String registrationNumber;
  final double capacity;
  final String capacityUnit;
  final String? dimensions;
  final String? features;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final String? fitnessCertificateNumber;
  final DateTime? fitnessExpiry;
  final String? driverName;
  final String? driverPhone;
  final String? driverLicenseNumber;
  final String? currentLocation;
  final bool isAvailable;

  const RegisterTruck({
    required this.truckType,
    required this.registrationNumber,
    required this.capacity,
    required this.capacityUnit,
    this.dimensions,
    this.features,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.fitnessCertificateNumber,
    this.fitnessExpiry,
    this.driverName,
    this.driverPhone,
    this.driverLicenseNumber,
    this.currentLocation,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        truckType,
        registrationNumber,
        capacity,
        capacityUnit,
        dimensions,
        features,
        insuranceNumber,
        insuranceExpiry,
        fitnessCertificateNumber,
        fitnessExpiry,
        driverName,
        driverPhone,
        driverLicenseNumber,
        currentLocation,
        isAvailable,
      ];
}

/// Update truck status
class UpdateTruckStatus extends TransportMarketplaceEvent {
  final String truckId;
  final TruckStatus status;
  final String? location;
  final bool? isAvailable;

  const UpdateTruckStatus({
    required this.truckId,
    required this.status,
    this.location,
    this.isAvailable,
  });

  @override
  List<Object?> get props => [truckId, status, location, isAvailable];
}

/// Place a bid on a load
class PlaceBid extends TransportMarketplaceEvent {
  final String loadId;
  final double amount;
  final String? notes;
  final DateTime? proposedPickupDate;
  final DateTime? proposedDeliveryDate;
  final String? truckId;

  const PlaceBid({
    required this.loadId,
    required this.amount,
    this.notes,
    this.proposedPickupDate,
    this.proposedDeliveryDate,
    this.truckId,
  });

  @override
  List<Object?> get props => [
        loadId,
        amount,
        notes,
        proposedPickupDate,
        proposedDeliveryDate,
        truckId,
      ];
}

/// Load my bids (for transporters)
class LoadMyBids extends TransportMarketplaceEvent {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMyBids({
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

/// Load bids for a load (for shippers)
class LoadBidsForLoad extends TransportMarketplaceEvent {
  final String loadId;
  final String? sortBy; // amount, rating, etc.

  const LoadBidsForLoad({
    required this.loadId,
    this.sortBy,
  });

  @override
  List<Object?> get props => [loadId, sortBy];
}

/// Accept a bid
class AcceptBid extends TransportMarketplaceEvent {
  final String bidId;
  final String loadId;

  const AcceptBid({
    required this.bidId,
    required this.loadId,
  });

  @override
  List<Object?> get props => [bidId, loadId];
}

/// Reject a bid
class RejectBid extends TransportMarketplaceEvent {
  final String bidId;
  final String reason;

  const RejectBid({
    required this.bidId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bidId, reason];
}

/// Cancel a bid
class CancelBid extends TransportMarketplaceEvent {
  final String bidId;
  final String reason;

  const CancelBid({
    required this.bidId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bidId, reason];
}

/// Create shipment from accepted bid
class CreateShipmentFromBid extends TransportMarketplaceEvent {
  final String bidId;
  final String loadId;
  final String? contractTerms;
  final List<String>? documents;

  const CreateShipmentFromBid({
    required this.bidId,
    required this.loadId,
    this.contractTerms,
    this.documents,
  });

  @override
  List<Object?> get props => [bidId, loadId, contractTerms, documents];
}

/// Load my shipments
class LoadMyShipments extends TransportMarketplaceEvent {
  final String? status;
  final String? role; // shipper or transporter
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMyShipments({
    this.status,
    this.role,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, role, startDate, endDate];
}

/// Update shipment status
class UpdateShipmentStatus extends TransportMarketplaceEvent {
  final String shipmentId;
  final ShipmentStatus status;
  final String? location;
  final String? notes;
  final List<String>? proofImages;

  const UpdateShipmentStatus({
    required this.shipmentId,
    required this.status,
    this.location,
    this.notes,
    this.proofImages,
  });

  @override
  List<Object?> get props => [shipmentId, status, location, notes, proofImages];
}

/// Create escrow payment
class CreateEscrowPayment extends TransportMarketplaceEvent {
  final String shipmentId;
  final double amount;
  final String paymentMethod;
  final String? notes;

  const CreateEscrowPayment({
    required this.shipmentId,
    required this.amount,
    required this.paymentMethod,
    this.notes,
  });

  @override
  List<Object?> get props => [shipmentId, amount, paymentMethod, notes];
}

/// Release escrow payment
class ReleaseEscrowPayment extends TransportMarketplaceEvent {
  final String shipmentId;
  final String? releaseReason;

  const ReleaseEscrowPayment({
    required this.shipmentId,
    this.releaseReason,
  });

  @override
  List<Object?> get props => [shipmentId, releaseReason];
}

/// Refund escrow payment
class RefundEscrowPayment extends TransportMarketplaceEvent {
  final String shipmentId;
  final String refundReason;

  const RefundEscrowPayment({
    required this.shipmentId,
    required this.refundReason,
  });

  @override
  List<Object?> get props => [shipmentId, refundReason];
}

/// Submit rating
class SubmitRating extends TransportMarketplaceEvent {
  final String shipmentId;
  final String ratedUserId;
  final int rating;
  final String? comments;
  final String role; // shipper or transporter

  const SubmitRating({
    required this.shipmentId,
    required this.ratedUserId,
    required this.rating,
    this.comments,
    required this.role,
  });

  @override
  List<Object?> get props => [shipmentId, ratedUserId, rating, comments, role];
}

/// Load user rating
class LoadUserRating extends TransportMarketplaceEvent {
  final String userId;

  const LoadUserRating(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Upload document
class UploadDocument extends TransportMarketplaceEvent {
  final String entityType; // load, truck, shipment, etc.
  final String entityId;
  final String documentType;
  final String filePath;
  final String? description;

  const UploadDocument({
    required this.entityType,
    required this.entityId,
    required this.documentType,
    required this.filePath,
    this.description,
  });

  @override
  List<Object?> get props => [
        entityType,
        entityId,
        documentType,
        filePath,
        description,
      ];
}

/// Load documents
class LoadDocuments extends TransportMarketplaceEvent {
  final String entityType;
  final String entityId;
  final String? documentType;

  const LoadDocuments({
    required this.entityType,
    required this.entityId,
    this.documentType,
  });

  @override
  List<Object?> get props => [entityType, entityId, documentType];
}

/// Delete document
class DeleteDocument extends TransportMarketplaceEvent {
  final String documentId;

  const DeleteDocument(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// Search loads
class SearchLoads extends TransportMarketplaceEvent {
  final String query;
  final String? origin;
  final String? destination;
  final DateTime? date;
  final String? loadType;

  const SearchLoads({
    required this.query,
    this.origin,
    this.destination,
    this.date,
    this.loadType,
  });

  @override
  List<Object?> get props => [query, origin, destination, date, loadType];
}

/// Search trucks
class SearchTrucks extends TransportMarketplaceEvent {
  final String query;
  final String? location;
  final String? truckType;
  final double? minCapacity;
  final double? maxCapacity;

  const SearchTrucks({
    required this.query,
    this.location,
    this.truckType,
    this.minCapacity,
    this.maxCapacity,
  });

  @override
  List<Object?> get props =>
      [query, location, truckType, minCapacity, maxCapacity];
}

/// Filter loads
class FilterLoads extends TransportMarketplaceEvent {
  final Map<String, dynamic> filters;

  const FilterLoads({
    required this.filters,
  });

  @override
  List<Object?> get props => [filters];
}

/// Filter trucks
class FilterTrucks extends TransportMarketplaceEvent {
  final Map<String, dynamic> filters;

  const FilterTrucks({
    required this.filters,
  });

  @override
  List<Object?> get props => [filters];
}

/// Refresh data
class RefreshData extends TransportMarketplaceEvent {
  final String dataType; // loads, trucks, bids, shipments

  const RefreshData(this.dataType);

  @override
  List<Object?> get props => [dataType];
}

/// Clear errors
class ClearErrors extends TransportMarketplaceEvent {
  const ClearErrors();
}

/// Load marketplace statistics
class LoadMarketplaceStatistics extends TransportMarketplaceEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userRole; // shipper, transporter, or null for all

  const LoadMarketplaceStatistics({
    this.startDate,
    this.endDate,
    this.userRole,
  });

  @override
  List<Object?> get props => [startDate, endDate, userRole];
}

/// Load route planning
class LoadRoutePlanning extends TransportMarketplaceEvent {
  final String origin;
  final String destination;
  final List<String>? waypoints;
  final String? optimizationCriteria; // fastest, shortest, cheapest

  const LoadRoutePlanning({
    required this.origin,
    required this.destination,
    this.waypoints,
    this.optimizationCriteria,
  });

  @override
  List<Object?> get props =>
      [origin, destination, waypoints, optimizationCriteria];
}

/// Update truck location
class UpdateTruckLocation extends TransportMarketplaceEvent {
  final String truckId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;

  const UpdateTruckLocation({
    required this.truckId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
  });

  @override
  List<Object?> get props => [truckId, latitude, longitude, accuracy, speed];
}

/// Load fleet management (for transporters with multiple trucks)
class LoadFleetManagement extends TransportMarketplaceEvent {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadFleetManagement({
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

/// Send message to user
class SendMessageToUser extends TransportMarketplaceEvent {
  final String recipientId;
  final String message;
  final String? relatedEntityType;
  final String? relatedEntityId;

  const SendMessageToUser({
    required this.recipientId,
    required this.message,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  @override
  List<Object?> get props =>
      [recipientId, message, relatedEntityType, relatedEntityId];
}

/// Load messages
class LoadMessages extends TransportMarketplaceEvent {
  final String? userId;
  final String? relatedEntityType;
  final String? relatedEntityId;

  const LoadMessages({
    this.userId,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  @override
  List<Object?> get props => [userId, relatedEntityType, relatedEntityId];
}
