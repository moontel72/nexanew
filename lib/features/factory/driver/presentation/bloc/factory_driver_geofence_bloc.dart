import 'package:bloc/bloc.dart';
import 'package:trace_odd/features/factory/driver/domain/utils/geo_utils.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/factory_driver_geofence_event.dart';
import 'package:trace_odd/features/factory/driver/presentation/bloc/factory_driver_geofence_state.dart';

class FactoryDriverGeofenceBloc
    extends Bloc<FactoryDriverGeofenceEvent, FactoryDriverGeofenceState> {
  FactoryDriverGeofenceBloc() : super(const FactoryDriverGeofenceState()) {
    on<SetDeliveryLocation>(_onSetDeliveryLocation);
    on<SetCurrentLocation>(_onSetCurrentLocation);
    on<SetRecipientOverride>(_onSetRecipientOverride);
    on<ClearGeofenceError>(_onClearError);
  }

  void _onSetDeliveryLocation(
    SetDeliveryLocation event,
    Emitter<FactoryDriverGeofenceState> emit,
  ) {
    final next = state.copyWith(
      deliveryLat: event.deliveryLat,
      deliveryLng: event.deliveryLng,
      clearError: true,
    );
    emit(_recompute(next));
  }

  void _onSetCurrentLocation(
    SetCurrentLocation event,
    Emitter<FactoryDriverGeofenceState> emit,
  ) {
    final next = state.copyWith(
      currentLat: event.currentLat,
      currentLng: event.currentLng,
      clearError: true,
    );
    emit(_recompute(next));
  }

  void _onSetRecipientOverride(
    SetRecipientOverride event,
    Emitter<FactoryDriverGeofenceState> emit,
  ) {
    final next = state.copyWith(
      recipientOverride: event.enabled,
      clearError: true,
    );
    emit(_recompute(next));
  }

  void _onClearError(
    ClearGeofenceError event,
    Emitter<FactoryDriverGeofenceState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  FactoryDriverGeofenceState _recompute(FactoryDriverGeofenceState s) {
    final deliveryLat = s.deliveryLat;
    final deliveryLng = s.deliveryLng;
    final currentLat = s.currentLat;
    final currentLng = s.currentLng;

    if (deliveryLat == null || deliveryLng == null) {
      return s.copyWith(distanceMeters: null, scanUnlocked: s.recipientOverride);
    }
    if (currentLat == null || currentLng == null) {
      return s.copyWith(distanceMeters: null, scanUnlocked: s.recipientOverride);
    }

    final d = distanceMeters(
      fromLat: currentLat,
      fromLng: currentLng,
      toLat: deliveryLat,
      toLng: deliveryLng,
    );

    final unlocked = s.recipientOverride || d <= 100.0;
    return s.copyWith(distanceMeters: d, scanUnlocked: unlocked);
  }
}

