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
enum SeatPartType {
  standardSeat,
  businessSeat,
  sleeperLower,
  sleeperUpper,
  reverseSeat,
  foldingSeat,
  table,
  driverSeat,
}

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
        SeatPartType.sleeperLower => kDefaultSleeperLowerLength,
        SeatPartType.sleeperUpper => kDefaultSleeperUpperLength,
        SeatPartType.reverseSeat => kDefaultReverseSeatLength,
        SeatPartType.foldingSeat => kDefaultFoldSeatLength,
        SeatPartType.table => kDefaultTableLength,
        SeatPartType.driverSeat => kDefaultSeatLength,
      },
      width: switch (type) {
        SeatPartType.standardSeat => kDefaultSeatWidth,
        SeatPartType.businessSeat => kDefaultBusinessSeatWidth,
        SeatPartType.sleeperLower => kDefaultSleeperLowerWidth,
        SeatPartType.sleeperUpper => kDefaultSleeperUpperWidth,
        SeatPartType.reverseSeat => kDefaultReverseSeatWidth,
        SeatPartType.foldingSeat => kDefaultFoldSeatWidth,
        SeatPartType.table => kDefaultTableWidth,
        SeatPartType.driverSeat => kDefaultSeatWidth,
      },
    );
  }

  @override
  List<Object?> get props => [type, length, width];

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'length_ft': length.feet,
    'length_in': length.inches,
    'width_ft': width.feet,
    'width_in': width.inches,
  };

  factory PartSpec.fromJson(Map<String, dynamic> json) {
    int p(dynamic v, int fb) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fb;
      return fb;
    }

    return PartSpec(
      type: SeatPartType.values.firstWhere((e) => e.name == json['type']),
      length: FeetInches.normalize(
        p(json['length_ft'], 0),
        p(json['length_in'], 0),
      ),
      width: FeetInches.normalize(
        p(json['width_ft'], 0),
        p(json['width_in'], 0),
      ),
    );
  }
}

/// Central registry of parts configured for the current layout.
class ComponentRegistry extends Equatable {
  final Map<SeatPartType, PartSpec> parts;
  final FeetInches aisleWidth;
  final FeetInches interSeatGap;
  final FeetInches initialGap;

  const ComponentRegistry({
    this.parts = const {},
    this.aisleWidth = kDefaultAisleWidth,
    this.interSeatGap = kDefaultInterSeatGap,
    this.initialGap = FeetInches.zero,
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
      ComponentType.sideDoor => 64.0,
      ComponentType.slidingDoor => 80.0,
      ComponentType.frontDoor => 64.0,
      ComponentType.rearDoor => 64.0,
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
    FeetInches? initialGap,
  }) => ComponentRegistry(
    parts: parts ?? this.parts,
    aisleWidth: aisleWidth ?? this.aisleWidth,
    interSeatGap: interSeatGap ?? this.interSeatGap,
    initialGap: initialGap ?? this.initialGap,
  );

  @override
  List<Object?> get props => [parts, aisleWidth, interSeatGap, initialGap];

  Map<String, dynamic> toJson() => {
    'parts': parts.map((k, v) => MapEntry(k.name, v.toJson())),
    'aisle_width_ft': aisleWidth.feet,
    'aisle_width_in': aisleWidth.inches,
    'inter_seat_gap_ft': interSeatGap.feet,
    'inter_seat_gap_in': interSeatGap.inches,
    'initial_gap_ft': initialGap.feet,
    'initial_gap_in': initialGap.inches,
  };

  factory ComponentRegistry.fromJson(Map<String, dynamic> json) {
    // Helper: parse a numeric value that may arrive as int, double, or String.
    int _parseInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    final partsJson = (json['parts'] as Map<String, dynamic>?) ?? {};
    final parts = <SeatPartType, PartSpec>{};
    for (final e in partsJson.entries) {
      final type = SeatPartType.values.firstWhere(
        (t) => t.name == e.key,
        orElse: () => SeatPartType.standardSeat,
      );
      if (e.value is Map) {
        parts[type] = PartSpec.fromJson(Map<String, dynamic>.from(e.value));
      }
    }
    return ComponentRegistry(
      parts: parts,
      aisleWidth: FeetInches.normalize(
        _parseInt(json['aisle_width_ft'], 1),
        _parseInt(json['aisle_width_in'], 6),
      ),
      interSeatGap: FeetInches.normalize(
        _parseInt(json['inter_seat_gap_ft'], 1),
        _parseInt(json['inter_seat_gap_in'], 0),
      ),
      initialGap: FeetInches.normalize(
        _parseInt(json['initial_gap_ft'], 0),
        _parseInt(json['initial_gap_in'], 0),
      ),
    );
  }
}

/// Maps a UI canvas [ComponentType] to its physical [SeatPartType].
/// Returns null for structural types not in the user registry.
///
/// Note: [SeatPartType.reverseSeat] has no direct [ComponentType] mapping
/// because reversed seats use [ComponentType.seat] with an `isReverseFacing`
/// flag. Palette-dragged reversed seats currently resolve to [standardSeat]
/// dimensions. Use the registry panel to configure reverseSeat separately
/// if custom dimensions are needed.
SeatPartType? fromComponentType(ComponentType type) {
  return switch (type) {
    ComponentType.seat => SeatPartType.standardSeat,
    ComponentType.businessClassSeat => SeatPartType.businessSeat,
    ComponentType.sleeperLower => SeatPartType.sleeperLower,
    ComponentType.sleeperUpper => SeatPartType.sleeperUpper,
    ComponentType.foldingSeat => SeatPartType.foldingSeat,
    ComponentType.restaurantTable => SeatPartType.table,
    _ => null,
  };
}
