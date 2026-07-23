// NEXATRACE — LAYOUT VALIDATION STATE
// ====================================

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/shared/models/transport/layout_validation_result.dart';

class LayoutValidationState extends Equatable {
  final BusDimensions dimensions;
  final ComponentRegistry registry;
  final int rows;
  final int leftSeats;
  final int rightSeats;
  final ValidationResult? lastResult;
  final FeetInches predictedLength;
  final FeetInches predictedWidth;

  /// Defaults to a 20′ Coaster — the mid-range South Asian vehicle.
  /// Users MUST adjust dimensions to match their actual bus interior
  /// via the "Physical Dimensions" section on the config screen.
  const LayoutValidationState({
    this.dimensions = const BusDimensions(
      length: FeetInches(feet: 20, inches: 0),
      width: FeetInches(feet: 6, inches: 6),
      height: FeetInches(feet: 5, inches: 6),
    ),
    this.registry = const ComponentRegistry(),
    this.rows = 14,
    this.leftSeats = 2,
    this.rightSeats = 2,
    this.lastResult,
    this.predictedLength = FeetInches.zero,
    this.predictedWidth = FeetInches.zero,
  });

  LayoutValidationState copyWith({
    BusDimensions? dimensions,
    ComponentRegistry? registry,
    int? rows,
    int? leftSeats,
    int? rightSeats,
    ValidationResult? lastResult,
    FeetInches? predictedLength,
    FeetInches? predictedWidth,
  }) => LayoutValidationState(
    dimensions: dimensions ?? this.dimensions,
    registry: registry ?? this.registry,
    rows: rows ?? this.rows,
    leftSeats: leftSeats ?? this.leftSeats,
    rightSeats: rightSeats ?? this.rightSeats,
    lastResult: lastResult ?? this.lastResult,
    predictedLength: predictedLength ?? this.predictedLength,
    predictedWidth: predictedWidth ?? this.predictedWidth,
  );

  @override
  List<Object?> get props => [
    dimensions,
    registry,
    rows,
    leftSeats,
    rightSeats,
    lastResult,
    predictedLength,
    predictedWidth,
  ];
}
