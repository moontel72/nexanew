import 'package:equatable/equatable.dart';

enum TruckStatus {
  inactive,
  available,
  onTrip,
  maintenance,
}

class Truck extends Equatable {
  final String id;
  final String ownerId;
  final String registrationNumber;
  final String? model;
  final String? type;
  final TruckStatus status;
  final double? capacity;
  final String? capacityUnit;

  const Truck({
    required this.id,
    required this.ownerId,
    required this.registrationNumber,
    this.model,
    this.type,
    this.capacity,
    this.capacityUnit,
    this.status = TruckStatus.available,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        registrationNumber,
        model,
        type,
        capacity,
        capacityUnit,
        status,
      ];
}
