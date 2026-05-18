import 'package:equatable/equatable.dart';

sealed class FactoryDriverGeofenceEvent extends Equatable {
  const FactoryDriverGeofenceEvent();

  @override
  List<Object?> get props => [];
}

class SetDeliveryLocation extends FactoryDriverGeofenceEvent {
  final double deliveryLat;
  final double deliveryLng;

  const SetDeliveryLocation({
    required this.deliveryLat,
    required this.deliveryLng,
  });

  @override
  List<Object?> get props => [deliveryLat, deliveryLng];
}

class SetCurrentLocation extends FactoryDriverGeofenceEvent {
  final double currentLat;
  final double currentLng;

  const SetCurrentLocation({
    required this.currentLat,
    required this.currentLng,
  });

  @override
  List<Object?> get props => [currentLat, currentLng];
}

class SetRecipientOverride extends FactoryDriverGeofenceEvent {
  final bool enabled;
  const SetRecipientOverride(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ClearGeofenceError extends FactoryDriverGeofenceEvent {
  const ClearGeofenceError();
}

