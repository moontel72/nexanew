part of 'transport_marketplace_bloc.dart';

/// States for Transport Marketplace BLoC
abstract class TransportMarketplaceState extends Equatable {
  const TransportMarketplaceState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TransportMarketplaceInitial extends TransportMarketplaceState {
  const TransportMarketplaceInitial();
}

/// Loading state
class TransportMarketplaceLoading extends TransportMarketplaceState {
  const TransportMarketplaceLoading();
}

/// Available loads loaded successfully
class AvailableLoadsLoaded extends TransportMarketplaceState {
  final List<Load> loads;
  final bool hasMore;
  final int totalCount;
  final Map<String, dynamic>? filters;

  const AvailableLoadsLoaded({
    required this.loads,
    this.hasMore = false,
    this.totalCount = 0,
    this.filters,
  });

  @override
  List<Object?> get props => [loads, hasMore, totalCount, filters];
}

/// My loads loaded successfully (for shippers)
class MyLoadsLoaded extends TransportMarketplaceState {
  final List<Load> loads;
  final bool hasMore;
  final int totalCount;

  const MyLoadsLoaded({
    required this.loads,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [loads, hasMore, totalCount];
}

/// Load posted successfully
class LoadPosted extends TransportMarketplaceState {
  final Load load;
  final String? message;

  const LoadPosted({
    required this.load,
    this.message,
  });

  @override
  List<Object?> get props => [load, message];
}

/// Load details loaded successfully
class LoadDetailLoaded extends TransportMarketplaceState {
  final Load load;
  final List<Bid>? bids;
  final List<Shipment>? relatedShipments;

  const LoadDetailLoaded({
    required this.load,
    this.bids,
    this.relatedShipments,
  });

  @override
  List<Object?> get props => [load, bids, relatedShipments];
}

/// Load status updated successfully
class LoadStatusUpdated extends TransportMarketplaceState {
  final Load load;

  const LoadStatusUpdated({
    required this.load,
  });

  @override
  List<Object?> get props => [load];
}

/// Load deleted successfully
class LoadDeleted extends TransportMarketplaceState {
  final String loadId;
  final String message;

  const LoadDeleted({
    required this.loadId,
    required this.message,
  });

  @override
  List<Object?> get props => [loadId, message];
}

/// Available trucks loaded successfully
class AvailableTrucksLoaded extends TransportMarketplaceState {
  final List<Truck> trucks;
  final bool hasMore;
  final int totalCount;
  final Map<String, dynamic>? filters;

  const AvailableTrucksLoaded({
    required this.trucks,
    this.hasMore = false,
    this.totalCount = 0,
    this.filters,
  });

  @override
  List<Object?> get props => [trucks, hasMore, totalCount, filters];
}

/// My trucks loaded successfully (for transporters)
class MyTrucksLoaded extends TransportMarketplaceState {
  final List<Truck> trucks;
  final bool hasMore;
  final int totalCount;

  const MyTrucksLoaded({
    required this.trucks,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [trucks, hasMore, totalCount];
}

/// Truck registered successfully
class TruckRegistered extends TransportMarketplaceState {
  final Truck truck;
  final String? message;

  const TruckRegistered({
    required this.truck,
    this.message,
  });

  @override
  List<Object?> get props => [truck, message];
}

/// Truck status updated successfully
class TruckStatusUpdated extends TransportMarketplaceState {
  final Truck truck;

  const TruckStatusUpdated({
    required this.truck,
  });

  @override
  List<Object?> get props => [truck];
}

/// Truck location updated successfully
class TruckLocationUpdated extends TransportMarketplaceState {
  final String truckId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const TruckLocationUpdated({
    required this.truckId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [truckId, latitude, longitude, timestamp];
}

/// Bid placed successfully
class BidPlaced extends TransportMarketplaceState {
  final Bid bid;
  final String loadId;

  const BidPlaced({
    required this.bid,
    required this.loadId,
  });

  @override
  List<Object?> get props => [bid, loadId];
}

/// My bids loaded successfully (for transporters)
class MyBidsLoaded extends TransportMarketplaceState {
  final List<Bid> bids;
  final bool hasMore;
  final int totalCount;

  const MyBidsLoaded({
    required this.bids,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [bids, hasMore, totalCount];
}

/// Bids for load loaded successfully (for shippers)
class BidsForLoadLoaded extends TransportMarketplaceState {
  final List<Bid> bids;
  final String loadId;

  const BidsForLoadLoaded({
    required this.bids,
    required this.loadId,
  });

  @override
  List<Object?> get props => [bids, loadId];
}

/// Bid accepted successfully
class BidAccepted extends TransportMarketplaceState {
  final Bid bid;
  final String loadId;

  const BidAccepted({
    required this.bid,
    required this.loadId,
  });

  @override
  List<Object?> get props => [bid, loadId];
}

/// Bid rejected successfully
class BidRejected extends TransportMarketplaceState {
  final String bidId;
  final String reason;

  const BidRejected({
    required this.bidId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bidId, reason];
}

/// Bid cancelled successfully
class BidCancelled extends TransportMarketplaceState {
  final String bidId;
  final String reason;

  const BidCancelled({
    required this.bidId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bidId, reason];
}

/// Shipment created successfully
class ShipmentCreated extends TransportMarketplaceState {
  final Shipment shipment;
  final String loadId;
  final String bidId;

  const ShipmentCreated({
    required this.shipment,
    required this.loadId,
    required this.bidId,
  });

  @override
  List<Object?> get props => [shipment, loadId, bidId];
}

/// My shipments loaded successfully
class MyShipmentsLoaded extends TransportMarketplaceState {
  final List<Shipment> shipments;
  final bool hasMore;
  final int totalCount;
  final String? role; // shipper or transporter

  const MyShipmentsLoaded({
    required this.shipments,
    this.hasMore = false,
    this.totalCount = 0,
    this.role,
  });

  @override
  List<Object?> get props => [shipments, hasMore, totalCount, role];
}

/// Shipment status updated successfully
class ShipmentStatusUpdated extends TransportMarketplaceState {
  final Shipment shipment;

  const ShipmentStatusUpdated({
    required this.shipment,
  });

  @override
  List<Object?> get props => [shipment];
}

/// Escrow payment created successfully
class EscrowPaymentCreated extends TransportMarketplaceState {
  final String shipmentId;
  final double amount;
  final String paymentId;

  const EscrowPaymentCreated({
    required this.shipmentId,
    required this.amount,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [shipmentId, amount, paymentId];
}

/// Escrow payment released successfully
class EscrowPaymentReleased extends TransportMarketplaceState {
  final String shipmentId;
  final double amount;
  final String? releaseReason;

  const EscrowPaymentReleased({
    required this.shipmentId,
    required this.amount,
    this.releaseReason,
  });

  @override
  List<Object?> get props => [shipmentId, amount, releaseReason];
}

/// Escrow payment refunded successfully
class EscrowPaymentRefunded extends TransportMarketplaceState {
  final String shipmentId;
  final double amount;
  final String refundReason;

  const EscrowPaymentRefunded({
    required this.shipmentId,
    required this.amount,
    required this.refundReason,
  });

  @override
  List<Object?> get props => [shipmentId, amount, refundReason];
}

/// Rating submitted successfully
class RatingSubmitted extends TransportMarketplaceState {
  final String shipmentId;
  final String ratedUserId;
  final int rating;

  const RatingSubmitted({
    required this.shipmentId,
    required this.ratedUserId,
    required this.rating,
  });

  @override
  List<Object?> get props => [shipmentId, ratedUserId, rating];
}

/// User rating loaded successfully
class UserRatingLoaded extends TransportMarketplaceState {
  final Rating rating;
  final String userId;

  const UserRatingLoaded({
    required this.rating,
    required this.userId,
  });

  @override
  List<Object?> get props => [rating, userId];
}

/// Document uploaded successfully
class DocumentUploaded extends TransportMarketplaceState {
  final Document document;

  const DocumentUploaded({
    required this.document,
  });

  @override
  List<Object?> get props => [document];
}

/// Documents loaded successfully
class DocumentsLoaded extends TransportMarketplaceState {
  final List<Document> documents;
  final String entityType;
  final String entityId;

  const DocumentsLoaded({
    required this.documents,
    required this.entityType,
    required this.entityId,
  });

  @override
  List<Object?> get props => [documents, entityType, entityId];
}

/// Document deleted successfully
class DocumentDeleted extends TransportMarketplaceState {
  final String documentId;

  const DocumentDeleted({
    required this.documentId,
  });

  @override
  List<Object?> get props => [documentId];
}

/// Search results for loads
class LoadSearchResults extends TransportMarketplaceState {
  final List<Load> results;
  final String query;
  final Map<String, dynamic>? filters;

  const LoadSearchResults({
    required this.results,
    required this.query,
    this.filters,
  });

  @override
  List<Object?> get props => [results, query, filters];
}

/// Search results for trucks
class TruckSearchResults extends TransportMarketplaceState {
  final List<Truck> results;
  final String query;
  final Map<String, dynamic>? filters;

  const TruckSearchResults({
    required this.results,
    required this.query,
    this.filters,
  });

  @override
  List<Object?> get props => [results, query, filters];
}

/// Marketplace statistics loaded successfully
class MarketplaceStatisticsLoaded extends TransportMarketplaceState {
  final MarketplaceStatistics statistics;

  const MarketplaceStatisticsLoaded({
    required this.statistics,
  });

  @override
  List<Object?> get props => [statistics];
}

/// Route planning loaded successfully
class RoutePlanningLoaded extends TransportMarketplaceState {
  final Route route;
  final String origin;
  final String destination;

  const RoutePlanningLoaded({
    required this.route,
    required this.origin,
    required this.destination,
  });

  @override
  List<Object?> get props => [route, origin, destination];
}

/// Fleet management loaded successfully
class FleetManagementLoaded extends TransportMarketplaceState {
  final List<Truck> fleet;
  final Map<String, dynamic> statistics;

  const FleetManagementLoaded({
    required this.fleet,
    required this.statistics,
  });

  @override
  List<Object?> get props => [fleet, statistics];
}

/// Message sent successfully
class MessageSent extends TransportMarketplaceState {
  final Message message;

  const MessageSent({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Messages loaded successfully
class MessagesLoaded extends TransportMarketplaceState {
  final List<Message> messages;
  final String? userId;
  final String? relatedEntityType;
  final String? relatedEntityId;

  const MessagesLoaded({
    required this.messages,
    this.userId,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  @override
  List<Object?> get props =>
      [messages, userId, relatedEntityType, relatedEntityId];
}

/// Error state
class TransportMarketplaceError extends TransportMarketplaceState {
  final String message;
  final String? errorCode;
  final bool isNetworkError;
  final bool isServerError;
  final bool isUnauthorized;
  final bool isValidationError;
  final StackTrace? stackTrace;

  const TransportMarketplaceError({
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
class NoData extends TransportMarketplaceState {
  final String message;

  const NoData({
    this.message = 'No data available',
  });

  @override
  List<Object?> get props => [message];
}

/// No loads found state
class NoLoadsFound extends TransportMarketplaceState {
  final String message;

  const NoLoadsFound({
    this.message = 'No loads found',
  });

  @override
  List<Object?> get props => [message];
}

/// No trucks found state
class NoTrucksFound extends TransportMarketplaceState {
  final String message;

  const NoTrucksFound({
    this.message = 'No trucks found',
  });

  @override
  List<Object?> get props => [message];
}

/// No bids found state
class NoBidsFound extends TransportMarketplaceState {
  final String message;

  const NoBidsFound({
    this.message = 'No bids found',
  });

  @override
  List<Object?> get props => [message];
}

/// Refreshing state
class TransportMarketplaceRefreshing extends TransportMarketplaceState {
  final List<dynamic> currentData;
  final String dataType;

  const TransportMarketplaceRefreshing({
    required this.currentData,
    required this.dataType,
  });

  @override
  List<Object?> get props => [currentData, dataType];
}

/// Loading more state
class TransportMarketplaceLoadingMore extends TransportMarketplaceState {
  final List<dynamic> currentData;
  final String dataType;

  const TransportMarketplaceLoadingMore({
    required this.currentData,
    required this.dataType,
  });

  @override
  List<Object?> get props => [currentData, dataType];
}

/// Truck detail loaded
class TruckDetailLoaded extends TransportMarketplaceState {
  final Truck truck;
  final List<Shipment>? recentShipments;
  final Rating? rating;

  const TruckDetailLoaded({
    required this.truck,
    this.recentShipments,
    this.rating,
  });

  @override
  List<Object?> get props => [truck, recentShipments, rating];
}

/// Shipment detail loaded
class ShipmentDetailLoaded extends TransportMarketplaceState {
  final Shipment shipment;
  final Load? load;
  final Truck? truck;
  final List<Document>? documents;
  final List<Message>? messages;

  const ShipmentDetailLoaded({
    required this.shipment,
    this.load,
    this.truck,
    this.documents,
    this.messages,
  });

  @override
  List<Object?> get props => [shipment, load, truck, documents, messages];
}

/// User profile loaded (for marketplace)
class MarketplaceUserProfileLoaded extends TransportMarketplaceState {
  final Map<String, dynamic> userProfile;
  final Rating rating;
  final List<Shipment>? recentShipments;

  const MarketplaceUserProfileLoaded({
    required this.userProfile,
    required this.rating,
    this.recentShipments,
  });

  @override
  List<Object?> get props => [userProfile, rating, recentShipments];
}
