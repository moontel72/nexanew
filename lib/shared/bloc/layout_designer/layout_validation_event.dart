// NEXATRACE — LAYOUT VALIDATION EVENTS
// ======================================

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';

sealed class LayoutValidationEvent extends Equatable {
  const LayoutValidationEvent();

  @override
  List<Object?> get props => [];
}

class DimensionsChanged extends LayoutValidationEvent {
  final BusDimensions dimensions;
  const DimensionsChanged(this.dimensions);

  @override
  List<Object?> get props => [dimensions];
}

class RegistryChanged extends LayoutValidationEvent {
  final ComponentRegistry registry;
  const RegistryChanged(this.registry);

  @override
  List<Object?> get props => [registry];
}

class SeatMatrixChanged extends LayoutValidationEvent {
  final int rows;
  final int leftSeats;
  final int rightSeats;
  const SeatMatrixChanged({
    required this.rows,
    required this.leftSeats,
    required this.rightSeats,
  });

  @override
  List<Object?> get props => [rows, leftSeats, rightSeats];
}
