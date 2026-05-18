import 'package:equatable/equatable.dart';

class FactoryDriverGeofenceState extends Equatable {
  final double? deliveryLat;
  final double? deliveryLng;
  final double? currentLat;
  final double? currentLng;
  final double? distanceMeters;
  final bool recipientOverride;
  final bool scanUnlocked;
  final String? error;

  const FactoryDriverGeofenceState({
    this.deliveryLat,
    this.deliveryLng,
    this.currentLat,
    this.currentLng,
    this.distanceMeters,
    this.recipientOverride = false,
    this.scanUnlocked = false,
    this.error,
  });

  FactoryDriverGeofenceState copyWith({
    double? deliveryLat,
    double? deliveryLng,
    double? currentLat,
    double? currentLng,
    double? distanceMeters,
    bool? recipientOverride,
    bool? scanUnlocked,
    String? error,
    bool clearError = false,
  }) {
    return FactoryDriverGeofenceState(
      deliveryLat: deliveryLat ?? this.deliveryLat,
      deliveryLng: deliveryLng ?? this.deliveryLng,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      recipientOverride: recipientOverride ?? this.recipientOverride,
      scanUnlocked: scanUnlocked ?? this.scanUnlocked,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        deliveryLat,
        deliveryLng,
        currentLat,
        currentLng,
        distanceMeters,
        recipientOverride,
        scanUnlocked,
        error,
      ];
}

