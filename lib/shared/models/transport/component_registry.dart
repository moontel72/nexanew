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
  businessReverseSeat,
  sleeperLower,
  sleeperUpper,
  reverseSeat,
  foldingSeat,
  table,
  driverSeat,
}

/// Driver seat position — which side of the bus the steering wheel is on.
enum DriverPosition { left, center, right }

/// Spatial footprint for a single part instance.
class PartSpec extends Equatable {
  final SeatPartType type;
  final FeetInches length;
  final FeetInches width;
  final DriverPosition driverPosition;

  const PartSpec({
    required this.type,
    required this.length,
    required this.width,
    this.driverPosition = DriverPosition.right,
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
        SeatPartType.businessReverseSeat => kDefaultBusinessSeatLength,
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
        SeatPartType.businessReverseSeat => kDefaultBusinessSeatWidth,
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
  List<Object?> get props => [type, length, width, driverPosition];

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'length_ft': length.feet,
    'length_in': length.inches,
    'width_ft': width.feet,
    'width_in': width.inches,
    'driver_position': driverPosition.name,
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
      driverPosition: DriverPosition.values.firstWhere(
        (e) => e.name == json['driver_position'],
        orElse: () => DriverPosition.right,
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
  final FeetInches faceToFaceGap;

  const ComponentRegistry({
    this.parts = const {},
    this.aisleWidth = kDefaultAisleWidth,
    this.interSeatGap = kDefaultInterSeatGap,
    this.initialGap = FeetInches.zero,
    this.faceToFaceGap = FeetInches.zero,
  });

  /// Returns the largest length among all registered parts.
  /// Excludes driver seat — it occupies a separate row and must not
  /// inflate passenger row length/width calculations.
  FeetInches get maxPartLength {
    final seatParts = parts.entries
        .where((e) => e.key != SeatPartType.driverSeat)
        .map((e) => e.value.length)
        .toList();
    if (seatParts.isEmpty) return kDefaultSeatLength;
    return seatParts.reduce((a, b) => a > b ? a : b);
  }

  /// Returns the largest width among all registered seat parts.
  /// Excludes driver seat — its width is irrelevant for row width.
  FeetInches get maxPartWidth {
    final seatParts = parts.entries
        .where((e) => e.key != SeatPartType.driverSeat)
        .map((e) => e.value.width)
        .toList();
    if (seatParts.isEmpty) return kDefaultSeatWidth;
    return seatParts.reduce((a, b) => a > b ? a : b);
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
    FeetInches? faceToFaceGap,
  }) => ComponentRegistry(
    parts: parts ?? this.parts,
    aisleWidth: aisleWidth ?? this.aisleWidth,
    interSeatGap: interSeatGap ?? this.interSeatGap,
    initialGap: initialGap ?? this.initialGap,
    faceToFaceGap: faceToFaceGap ?? this.faceToFaceGap,
  );

  @override
  List<Object?> get props => [
    parts,
    aisleWidth,
    interSeatGap,
    initialGap,
    faceToFaceGap,
  ];

  Map<String, dynamic> toJson() => {
    'parts': parts.map((k, v) => MapEntry(k.name, v.toJson())),
    'aisle_width_ft': aisleWidth.feet,
    'aisle_width_in': aisleWidth.inches,
    'inter_seat_gap_ft': interSeatGap.feet,
    'inter_seat_gap_in': interSeatGap.inches,
    'initial_gap_ft': initialGap.feet,
    'initial_gap_in': initialGap.inches,
    'face_to_face_gap_ft': faceToFaceGap.feet,
    'face_to_face_gap_in': faceToFaceGap.inches,
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
      faceToFaceGap: FeetInches.normalize(
        _parseInt(json['face_to_face_gap_ft'], 0),
        _parseInt(json['face_to_face_gap_in'], 0),
      ),
    );
  }
}

/// Maps a UI canvas [ComponentType] to its physical [SeatPartType].
/// Returns null for structural types not in the user registry.
///
/// When [isReverseFacing] is true, reverse seat types are returned
/// so the registry can store distinct dimensions for reverse-facing seats.
SeatPartType? fromComponentType(
  ComponentType type, {
  bool isReverseFacing = false,
}) {
  if (isReverseFacing) {
    return switch (type) {
      ComponentType.seat => SeatPartType.reverseSeat,
      ComponentType.businessClassSeat => SeatPartType.businessReverseSeat,
      _ => null,
    };
  }
  return switch (type) {
    ComponentType.seat => SeatPartType.standardSeat,
    ComponentType.businessClassSeat => SeatPartType.businessSeat,
    ComponentType.sleeperLower => SeatPartType.sleeperLower,
    ComponentType.sleeperUpper => SeatPartType.sleeperUpper,
    ComponentType.foldingSeat => SeatPartType.foldingSeat,
    ComponentType.restaurantTable => SeatPartType.table,
    ComponentType.driverCabin => SeatPartType.driverSeat,
    _ => null,
  };
}
