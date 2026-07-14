// NEXATRACE — COMPONENT REGISTRY
// ===============================
// Declares which physical part types (SeatPartType) exist,
// their default spatial footprints, and the mapping from
// UI canvas ComponentType to physical SeatPartType.
//
// 100 % pure Dart.

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';

/// Physical part categories known to the layout validator.
enum SeatPartType {
  standardSeat,
  businessSeat,
  foldingSeat,
  sleeperLower,
  sleeperUpper,
  driverCabin,
  aisle,
  exitDoor,
}

/// Spatial footprint for a single part instance.
class PartSpec extends Equatable {
  final SeatPartType type;
  final FeetInches length; // along the bus (front-to-back)
  final FeetInches width; // across the bus (left-to-right)
  final FeetInches height;

  const PartSpec({
    required this.type,
    required this.length,
    required this.width,
    this.height = FeetInches.zero,
  });

  /// Returns sensible defaults for each part type.
  factory PartSpec.defaultFor(SeatPartType type) {
    return switch (type) {
      SeatPartType.standardSeat => PartSpec(
        type: type,
        length: const FeetInches(feet: 2, inches: 6),
        width: const FeetInches(feet: 1, inches: 6),
      ),
      SeatPartType.businessSeat => PartSpec(
        type: type,
        length: const FeetInches(feet: 3, inches: 0),
        width: const FeetInches(feet: 2, inches: 0),
      ),
      SeatPartType.foldingSeat => PartSpec(
        type: type,
        length: const FeetInches(feet: 1, inches: 6),
        width: const FeetInches(feet: 1, inches: 0),
      ),
      SeatPartType.sleeperLower => PartSpec(
        type: type,
        length: const FeetInches(feet: 6, inches: 0),
        width: const FeetInches(feet: 2, inches: 0),
      ),
      SeatPartType.sleeperUpper => PartSpec(
        type: type,
        length: const FeetInches(feet: 6, inches: 0),
        width: const FeetInches(feet: 2, inches: 0),
      ),
      SeatPartType.driverCabin => PartSpec(
        type: type,
        length: const FeetInches(feet: 3, inches: 0),
        width: const FeetInches(feet: 4, inches: 0),
      ),
      SeatPartType.aisle => PartSpec(
        type: type,
        length: const FeetInches(feet: 1, inches: 0),
        width: const FeetInches(feet: 1, inches: 6),
      ),
      SeatPartType.exitDoor => PartSpec(
        type: type,
        length: const FeetInches(feet: 2, inches: 0),
        width: const FeetInches(feet: 2, inches: 6),
      ),
    };
  }

  @override
  List<Object?> get props => [type, length, width, height];
}

/// Central registry of parts configured for the current layout.
class ComponentRegistry extends Equatable {
  final Map<SeatPartType, PartSpec> parts;
  final FeetInches aisleWidth;
  final FeetInches interSeatGap;

  const ComponentRegistry({
    this.parts = const {},
    this.aisleWidth = const FeetInches(feet: 1, inches: 6),
    this.interSeatGap = const FeetInches(feet: 1, inches: 0),
  });

  /// Returns the largest length among all registered parts (conservative
  /// fail‑safe for length validation).
  FeetInches get maxPartLength {
    if (parts.isEmpty) return const FeetInches(feet: 2, inches: 6);
    return parts.values.map((p) => p.length).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the largest width among all registered seat parts.
  FeetInches get maxPartWidth {
    if (parts.isEmpty) return const FeetInches(feet: 1, inches: 6);
    return parts.values.map((p) => p.width).reduce((a, b) => a > b ? a : b);
  }

  ComponentRegistry copyWith({
    Map<SeatPartType, PartSpec>? parts,
    FeetInches? aisleWidth,
    FeetInches? interSeatGap,
  }) => ComponentRegistry(
    parts: parts ?? this.parts,
    aisleWidth: aisleWidth ?? this.aisleWidth,
    interSeatGap: interSeatGap ?? this.interSeatGap,
  );

  @override
  List<Object?> get props => [parts, aisleWidth, interSeatGap];
}

/// Maps a UI canvas [ComponentType] to its physical [SeatPartType].
/// Returns null for structural / non‑seat types not in the registry.
SeatPartType? fromComponentType(ComponentType type) {
  return switch (type) {
    ComponentType.seat => SeatPartType.standardSeat,
    ComponentType.businessClassSeat => SeatPartType.businessSeat,
    ComponentType.foldingSeat => SeatPartType.foldingSeat,
    ComponentType.sleeperLower => SeatPartType.sleeperLower,
    ComponentType.sleeperUpper => SeatPartType.sleeperUpper,
    ComponentType.driverCabin => SeatPartType.driverCabin,
    ComponentType.aisle => SeatPartType.aisle,
    ComponentType.exitDoor => SeatPartType.exitDoor,
    _ => null,
  };
}
