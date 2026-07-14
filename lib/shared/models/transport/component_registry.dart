// NEXATRACE — COMPONENT REGISTRY
// ===============================
// Declares which physical part types (SeatPartType) exist,
// their default spatial footprints, and the mapping from
// UI canvas ComponentType to physical SeatPartType.
//
// 100 % pure Dart.

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/dimensional_constants.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';

/// Physical part categories known to the layout validator.
/// Structural types (driver cabin, aisle, exit door) are NOT
/// user‑configurable and are excluded from this enum.
enum SeatPartType { standardSeat, businessSeat, sleeper }

/// Spatial footprint for a single part instance.
class PartSpec extends Equatable {
  final SeatPartType type;
  final FeetInches length;
  final FeetInches width;

  const PartSpec({
    required this.type,
    required this.length,
    required this.width,
  });

  double get pixelLength => length.toPixels;
  double get pixelWidth => width.toPixels;

  /// Returns sensible defaults from [dimensional_constants.dart].
  factory PartSpec.defaultFor(SeatPartType type) {
    return PartSpec(
      type: type,
      length: switch (type) {
        SeatPartType.standardSeat => kDefaultSeatLength,
        SeatPartType.businessSeat => kDefaultBusinessSeatLength,
        SeatPartType.sleeper => kDefaultSleeperLength,
      },
      width: switch (type) {
        SeatPartType.standardSeat => kDefaultSeatWidth,
        SeatPartType.businessSeat => kDefaultBusinessSeatWidth,
        SeatPartType.sleeper => kDefaultSleeperWidth,
      },
    );
  }

  @override
  List<Object?> get props => [type, length, width];
}

/// Central registry of parts configured for the current layout.
class ComponentRegistry extends Equatable {
  final Map<SeatPartType, PartSpec> parts;
  final FeetInches aisleWidth;
  final FeetInches interSeatGap;

  const ComponentRegistry({
    this.parts = const {},
    this.aisleWidth = kDefaultAisleWidth,
    this.interSeatGap = kDefaultInterSeatGap,
  });

  /// Returns the largest length among all registered parts.
  FeetInches get maxPartLength {
    if (parts.isEmpty) return kDefaultSeatLength;
    return parts.values.map((p) => p.length).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the largest width among all registered seat parts.
  FeetInches get maxPartWidth {
    if (parts.isEmpty) return kDefaultSeatWidth;
    return parts.values.map((p) => p.width).reduce((a, b) => a > b ? a : b);
  }

  /// Pixel fallback for structural / non‑configurable component types.
  double pixelFallbackFor(ComponentType type) {
    return switch (type) {
      ComponentType.driverCabin => 80.0,
      ComponentType.exitDoor => 64.0,
      ComponentType.aisle => 48.0,
      ComponentType.emergency => 64.0,
      ComponentType.lavatory => 96.0,
      ComponentType.restaurantTable => 96.0,
      _ => 44.0,
    };
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
/// Returns null for structural types not in the user registry.
SeatPartType? fromComponentType(ComponentType type) {
  return switch (type) {
    ComponentType.seat => SeatPartType.standardSeat,
    ComponentType.businessClassSeat => SeatPartType.businessSeat,
    ComponentType.sleeperLower ||
    ComponentType.sleeperUpper => SeatPartType.sleeper,
    _ => null,
  };
}
