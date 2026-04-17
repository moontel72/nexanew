import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:nexatrace_system/features/courier_integration/domain/entities/courier_service.dart';
import 'package:nexatrace_system/features/courier_integration/domain/entities/courier_statistics.dart';
import 'package:nexatrace_system/features/courier_integration/domain/entities/pickup_request.dart';
import 'package:nexatrace_system/features/courier_integration/domain/entities/shipment.dart';
import 'package:nexatrace_system/features/courier_integration/domain/entities/shipping_rate.dart';
import 'package:nexatrace_system/features/courier_integration/domain/entities/tracking_event_entity.dart';

part 'courier_integration_event.dart';
part 'courier_integration_state.dart';

class CourierIntegrationBloc
    extends Bloc<CourierIntegrationEvent, CourierIntegrationState> {
  CourierIntegrationBloc() : super(const CourierIntegrationInitial()) {
    on<CourierIntegrationEvent>(_onAnyEvent);
  }

  Future<void> _onAnyEvent(
    CourierIntegrationEvent event,
    Emitter<CourierIntegrationState> emit,
  ) async {
    emit(const CourierIntegrationLoading());
    emit(const CourierIntegrationError(
      message: 'Courier Integration not implemented yet.',
    ));
  }
}

