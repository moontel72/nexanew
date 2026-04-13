import 'package:equatable/equatable.dart';

enum ShipmentStatus {
  created,
  pickupScheduled,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
}

class Shipment extends Equatable {
  final String id;
  final String loadId;
  final String shipperId;
  final String transporterId;
  final ShipmentStatus status;
  final DateTime? pickupAt;
  final DateTime? deliveredAt;

  const Shipment({
    required this.id,
    required this.loadId,
    required this.shipperId,
    required this.transporterId,
    required this.status,
    this.pickupAt,
    this.deliveredAt,
  });

  @override
  List<Object?> get props => [
        id,
        loadId,
        shipperId,
        transporterId,
        status,
        pickupAt,
        deliveredAt,
      ];
}
