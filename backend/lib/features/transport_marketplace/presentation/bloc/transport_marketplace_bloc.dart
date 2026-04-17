import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/bid.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/document.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/load.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/marketplace_statistics.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/message.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/rating.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/route.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/shipment.dart';
import 'package:nexatrace_system/features/transport_marketplace/domain/entities/truck.dart';

part 'transport_marketplace_event.dart';
part 'transport_marketplace_state.dart';

class TransportMarketplaceBloc
    extends Bloc<TransportMarketplaceEvent, TransportMarketplaceState> {
  TransportMarketplaceBloc() : super(const TransportMarketplaceInitial()) {
    on<LoadAvailableLoads>(_onLoadAvailableLoads);
    on<LoadMyLoads>(_onLoadMyLoads);
    on<PostLoad>(_onPostLoad);
    on<LoadLoadDetails>(_onLoadLoadDetails);
    on<UpdateLoadStatus>(_onUpdateLoadStatus);
    on<DeleteLoad>(_onDeleteLoad);
    on<LoadAvailableTrucks>(_onLoadAvailableTrucks);
    on<LoadMyTrucks>(_onLoadMyTrucks);
    on<RegisterTruck>(_onRegisterTruck);
    on<UpdateTruckStatus>(_onUpdateTruckStatus);
    on<PlaceBid>(_onPlaceBid);
    on<LoadMyBids>(_onLoadMyBids);
    on<LoadBidsForLoad>(_onLoadBidsForLoad);
    on<AcceptBid>(_onAcceptBid);
    on<RejectBid>(_onRejectBid);
    on<CancelBid>(_onCancelBid);
    on<CreateShipmentFromBid>(_onCreateShipmentFromBid);
    on<LoadMyShipments>(_onLoadMyShipments);
    on<UpdateShipmentStatus>(_onUpdateShipmentStatus);
    on<UploadDocument>(_onUploadDocument);
    on<LoadUserRating>(_onLoadUserRating);
    on<SubmitRating>(_onSubmitRating);
  }

  Future<void> _onLoadAvailableLoads(
    LoadAvailableLoads event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AvailableLoadsLoaded(
        loads: const [],
        filters: {
          'type': event.filterByType,
          'origin': event.filterByOrigin,
          'destination': event.filterByDestination,
          'date': event.filterByDate?.toIso8601String(),
          'min_weight': event.minWeight,
          'max_weight': event.maxWeight,
        },
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyLoads(
    LoadMyLoads event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const MyLoadsLoaded(loads: []));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onPostLoad(
    PostLoad event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 500));

      final load = Load(
        id: 'load_${DateTime.now().millisecondsSinceEpoch}',
        shipperId: 'shipper',
        companyId: 'company',
        type: _parseLoadType(event.loadType),
        status: LoadStatus.posted,
        origin: event.origin,
        originCity: event.origin,
        originState: '',
        originCountry: '',
        originPostalCode: '',
        destination: event.destination,
        destinationCity: event.destination,
        destinationState: '',
        destinationCountry: '',
        destinationPostalCode: '',
        weight: event.weight,
        weightUnit: _parseWeightUnit(event.weightUnit),
        dimensions: event.dimensions,
        commodityType: event.commodityType,
        specialRequirements: event.specialRequirements,
        requiredDocuments: event.documents,
        pickupDate: event.pickupDate,
        deliveryDate: event.deliveryDate,
        budget: event.budget,
        currency: 'USD',
        paymentMethod: PaymentMethod.cash,
        contactName: event.contactName ?? 'Contact',
        contactPhone: event.contactPhone ?? '',
        contactEmail: event.contactEmail ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      emit(LoadPosted(load: load, message: 'Load posted successfully'));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadLoadDetails(
    LoadLoadDetails event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));

      emit(LoadDetailLoaded(
        load: Load(
          id: event.loadId,
          shipperId: 'shipper',
          companyId: 'company',
          type: LoadType.general,
          status: LoadStatus.posted,
          origin: '',
          originCity: '',
          originState: '',
          originCountry: '',
          originPostalCode: '',
          destination: '',
          destinationCity: '',
          destinationState: '',
          destinationCountry: '',
          destinationPostalCode: '',
          weight: 0,
          weightUnit: WeightUnit.kg,
          pickupDate: DateTime.now(),
          deliveryDate: DateTime.now(),
          budget: 0,
          currency: 'USD',
          paymentMethod: PaymentMethod.cash,
          contactName: 'Contact',
          contactPhone: '',
          contactEmail: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        bids: const [],
        relatedShipments: const [],
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onUpdateLoadStatus(
    UpdateLoadStatus event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));

      emit(LoadStatusUpdated(
        load: Load(
          id: event.loadId,
          shipperId: 'shipper',
          companyId: 'company',
          type: LoadType.general,
          status: event.status,
          origin: '',
          originCity: '',
          originState: '',
          originCountry: '',
          originPostalCode: '',
          destination: '',
          destinationCity: '',
          destinationState: '',
          destinationCountry: '',
          destinationPostalCode: '',
          weight: 0,
          weightUnit: WeightUnit.kg,
          pickupDate: DateTime.now(),
          deliveryDate: DateTime.now(),
          budget: 0,
          currency: 'USD',
          paymentMethod: PaymentMethod.cash,
          contactName: 'Contact',
          contactPhone: '',
          contactEmail: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onDeleteLoad(
    DeleteLoad event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(LoadDeleted(loadId: event.loadId, message: 'Load deleted successfully'));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadAvailableTrucks(
    LoadAvailableTrucks event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(AvailableTrucksLoaded(
        trucks: const [],
        filters: {
          'type': event.filterByType,
          'location': event.filterByLocation,
          'min_capacity': event.minCapacity,
          'max_capacity': event.maxCapacity,
        },
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyTrucks(
    LoadMyTrucks event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const MyTrucksLoaded(trucks: []));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onRegisterTruck(
    RegisterTruck event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(TruckRegistered(
        truck: Truck(
          id: 'truck_${DateTime.now().millisecondsSinceEpoch}',
          ownerId: 'owner',
          registrationNumber: event.registrationNumber,
        ),
        message: 'Truck registered successfully',
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTruckStatus(
    UpdateTruckStatus event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(TruckStatusUpdated(
        truck: Truck(
          id: event.truckId,
          ownerId: 'owner',
          registrationNumber: '',
          status: event.status,
        ),
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onPlaceBid(
    PlaceBid event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(BidPlaced(
        bid: Bid(
          id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
          loadId: event.loadId,
          bidderId: 'bidder',
          amount: event.amount,
          status: BidStatus.pending,
          notes: event.notes,
          createdAt: DateTime.now(),
        ),
        loadId: event.loadId,
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onAcceptBid(
    AcceptBid event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(BidAccepted(
        bid: Bid(
          id: event.bidId,
          loadId: event.loadId,
          bidderId: 'bidder',
          amount: 0,
          status: BidStatus.accepted,
          createdAt: DateTime.now(),
        ),
        loadId: event.loadId,
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onRejectBid(
    RejectBid event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(BidRejected(bidId: event.bidId, reason: event.reason));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyBids(
    LoadMyBids event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const MyBidsLoaded(bids: []));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadBidsForLoad(
    LoadBidsForLoad event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(BidsForLoadLoaded(bids: const [], loadId: event.loadId));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onCancelBid(
    CancelBid event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(BidCancelled(bidId: event.bidId, reason: event.reason));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onCreateShipmentFromBid(
    CreateShipmentFromBid event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(ShipmentCreated(
        shipment: Shipment(
          id: 'shipment_${DateTime.now().millisecondsSinceEpoch}',
          loadId: event.loadId,
          shipperId: 'shipper',
          transporterId: 'transporter',
          status: ShipmentStatus.created,
        ),
        loadId: event.loadId,
        bidId: event.bidId,
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyShipments(
    LoadMyShipments event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(MyShipmentsLoaded(shipments: const [], role: event.role));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onUpdateShipmentStatus(
    UpdateShipmentStatus event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(ShipmentStatusUpdated(
        shipment: Shipment(
          id: event.shipmentId,
          loadId: '',
          shipperId: 'shipper',
          transporterId: 'transporter',
          status: event.status,
        ),
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(DocumentUploaded(
        document: Document(
          id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
          ownerId: event.entityId,
          name: event.documentType,
          type: event.documentType,
          url: event.filePath,
          uploadedAt: DateTime.now(),
        ),
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserRating(
    LoadUserRating event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(UserRatingLoaded(
        rating: Rating(
          id: 'rating_${DateTime.now().millisecondsSinceEpoch}',
          fromUserId: 'system',
          toUserId: event.userId,
          stars: 0,
          createdAt: DateTime.now(),
        ),
        userId: event.userId,
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<TransportMarketplaceState> emit,
  ) async {
    try {
      emit(const TransportMarketplaceLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(RatingSubmitted(
        shipmentId: event.shipmentId,
        ratedUserId: event.ratedUserId,
        rating: event.rating,
      ));
    } catch (e) {
      emit(TransportMarketplaceError(message: e.toString()));
    }
  }

  WeightUnit _parseWeightUnit(String value) {
    switch (value.toLowerCase()) {
      case 'ton':
      case 'tons':
        return WeightUnit.ton;
      case 'lb':
      case 'lbs':
        return WeightUnit.lb;
      case 'kg':
      case 'kgs':
      default:
        return WeightUnit.kg;
    }
  }

  LoadType _parseLoadType(String value) {
    switch (value.toLowerCase()) {
      case 'fulltruckload':
      case 'full_truck_load':
      case 'ftl':
        return LoadType.fullTruckLoad;
      case 'lessthantruckload':
      case 'less_than_truck_load':
      case 'ltl':
        return LoadType.lessThanTruckLoad;
      case 'refrigerated':
        return LoadType.refrigerated;
      case 'hazardous':
        return LoadType.hazardous;
      case 'oversized':
        return LoadType.oversized;
      case 'bulk':
        return LoadType.bulk;
      case 'container':
        return LoadType.container;
      case 'partload':
      case 'part_load':
        return LoadType.partLoad;
      case 'general':
      default:
        return LoadType.general;
    }
  }
}
