// NEXATRACE — ABSOLUTE LAYOUT COMPONENT MODEL
// ==============================================
// Freeform pixel-based component model for the Absolute Canvas Engine.
// Components carry X, Y, Width, Height, and Rotation (degrees) instead
// of grid row/column integer coordinates.
//
// 100% isolated from the legacy grid-based LayoutComponent.
// Uses the shared ComponentType enum (imported, not modified).

import 'package:flutter/material.dart';

import 'layout_component.dart'; // ComponentType, BookingMode

/// Absolute-positioning component for the freeform bus layout canvas.
class AbsoluteLayoutComponent {
  final String id;
  final ComponentType type;
  double x; // left edge in logical pixels
  double y; // top edge in logical pixels
  double width; // width in logical pixels
  double height; // height in logical pixels
  double rotation; // degrees clockwise (0-360)
  String? seatId;
  int? seatNumber;
  String? berthLabel; // e.g., "L1", "U2" — auto‑assigned for sleeper berths
  bool
  isReverseFacing; // true = reverse-facing seat (Type‑2), false = forward (Type‑1)
  bool bookable;
  BookingMode bookingMode;
  String? genderRestriction;
  String? customLabel; // Override sticker number (freezes auto-numbering)
  Map<String, dynamic> meta;

  AbsoluteLayoutComponent({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.width = 56.0,
    this.height = 56.0,
    this.rotation = 0.0,
    this.seatId,
    this.seatNumber,
    this.berthLabel,
    this.isReverseFacing = false,
    this.bookable = true,
    this.bookingMode = BookingMode.standard,
    this.genderRestriction,
    this.customLabel,
    Map<String, dynamic>? meta,
  }) : meta = meta ?? {};

  /// Center point (for rotation pivot).
  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  /// Bounding rect for hit-testing.
  bool containsPoint(double px, double py) {
    // For rotated hit-test: transform point into component-local space
    if (rotation == 0.0) {
      return px >= x && px <= x + width && py >= y && py <= y + height;
    }
    // Inverse-rotate the point around the component center
    final dx = px - centerX;
    final dy = py - centerY;
    final radians = -rotation * 3.1415926535 / 180.0;
    final cos = _cos(radians);
    final sin = _sin(radians);
    final localX = dx * cos - dy * sin + width / 2;
    final localY = dx * sin + dy * cos + height / 2;
    return localX >= 0 && localX <= width && localY >= 0 && localY <= height;
  }

  /// Whether this component is structural (not ticketable).
  bool get isStructural => switch (type) {
    ComponentType.aisle ||
    ComponentType.exitDoor ||
    ComponentType.driverCabin ||
    ComponentType.emergency ||
    ComponentType.lavatory ||
    ComponentType.restaurantTable ||
    ComponentType.empty => true,
    _ => false,
  };

  /// Whether this component can be edited/moved by the user.
  /// All components are deletable — structural components like doors
  /// and driver cabins are still interactive for selection/delete.
  bool get isEditable => true;

  /// Whether this component lies within the canvas bounds.
  /// Uses a 2 px tolerance so seats flush with the canvas edge
  /// are not clipped due to floating-point rounding.
  static const double _eps = 2.0;
  bool isWithinBounds(double canvasW, double canvasH) =>
      x >= -_eps &&
      y >= -_eps &&
      x + width <= canvasW + _eps &&
      y + height <= canvasH + _eps;

  /// Default icon for this component type.
  IconData get defaultIcon => switch (type) {
    ComponentType.seat => Icons.event_seat,
    ComponentType.sleeperLower => Icons.airline_seat_flat,
    ComponentType.sleeperUpper => Icons.airline_seat_flat_angled,
    ComponentType.foldingSeat => Icons.chair_alt,
    ComponentType.exitDoor => Icons.door_front_door,
    ComponentType.driverCabin => Icons.settings_accessibility,
    ComponentType.emergency => Icons.warning_amber_rounded,
    ComponentType.lavatory => Icons.wc,
    ComponentType.restaurantTable => Icons.table_restaurant,
    ComponentType.businessClassSeat => Icons.airline_seat_flat_angled,
    _ => Icons.grid_view,
  };

  /// Display name for the type.
  String get typeLabel => switch (type) {
    ComponentType.seat => 'Seat',
    ComponentType.sleeperLower => 'Sleeper (Lower)',
    ComponentType.sleeperUpper => 'Sleeper (Upper)',
    ComponentType.foldingSeat => 'Folding Seat',
    ComponentType.exitDoor => 'Exit Door',
    ComponentType.driverCabin => 'Driver Cabin',
    ComponentType.emergency => 'Emergency Exit',
    ComponentType.lavatory => 'Lavatory',
    ComponentType.restaurantTable => 'Restaurant Table',
    ComponentType.businessClassSeat => 'Business Class',
    _ => 'Unknown',
  };

  /// Default color per type.
  Color get defaultColor => switch (type) {
    ComponentType.seat => const Color(0xFF7C3AED),
    ComponentType.sleeperLower => const Color(0xFFDB2777),
    ComponentType.sleeperUpper => const Color(0xFFF97316),
    ComponentType.foldingSeat => const Color(0xFF06B6D4),
    ComponentType.exitDoor => const Color(0xFFEF4444),
    ComponentType.driverCabin => const Color(0xFF1E293B),
    ComponentType.emergency => const Color(0xFFDC2626),
    ComponentType.lavatory => const Color(0xFF6366F1),
    ComponentType.restaurantTable => const Color(0xFF059669),
    ComponentType.businessClassSeat => const Color(0xFFD97706),
    _ => const Color(0xFF1A2533),
  };

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'rotation': rotation,
    if (seatId != null) 'seat_id': seatId,
    if (seatNumber != null) 'seat_number': seatNumber,
    if (berthLabel != null) 'berth_label': berthLabel,
    'is_reverse_facing': isReverseFacing,
    'bookable': bookable,
    'booking_mode': bookingMode.name,
    if (genderRestriction != null) 'gender_restriction': genderRestriction,
    if (customLabel != null) 'custom_label': customLabel,
    'meta': meta,
  };

  /// Deserialize from JSON.
  factory AbsoluteLayoutComponent.fromJson(Map<String, dynamic> json) {
    return AbsoluteLayoutComponent(
      id: json['id'] as String,
      type: ComponentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ComponentType.seat,
      ),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? 56.0,
      height: (json['height'] as num?)?.toDouble() ?? 56.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      seatId: json['seat_id'] as String?,
      seatNumber: json['seat_number'] as int?,
      berthLabel: json['berth_label'] as String?,
      isReverseFacing: json['is_reverse_facing'] as bool? ?? false,
      bookable: json['bookable'] as bool? ?? true,
      bookingMode: BookingMode.values.firstWhere(
        (e) => e.name == (json['booking_mode'] as String?),
        orElse: () => BookingMode.standard,
      ),
      genderRestriction: json['gender_restriction'] as String?,
      customLabel: json['custom_label'] as String?,
      meta: _safeCastMap(json['meta']),
    );
  }

  /// Create a copy with optional field overrides.
  AbsoluteLayoutComponent copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    String? seatId,
    int? seatNumber,
    String? berthLabel,
    bool? isReverseFacing,
    bool? bookable,
    BookingMode? bookingMode,
    String? genderRestriction,
    String? customLabel,
    Map<String, dynamic>? meta,
  }) => AbsoluteLayoutComponent(
    id: id,
    type: type,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    rotation: rotation ?? this.rotation,
    seatId: seatId ?? this.seatId,
    seatNumber: seatNumber ?? this.seatNumber,
    berthLabel: berthLabel ?? this.berthLabel,
    isReverseFacing: isReverseFacing ?? this.isReverseFacing,
    bookable: bookable ?? this.bookable,
    bookingMode: bookingMode ?? this.bookingMode,
    genderRestriction: genderRestriction ?? this.genderRestriction,
    customLabel: customLabel ?? this.customLabel,
    meta: meta ?? this.meta,
  );
}

/// Safely cast a dynamic value to Map<String, dynamic>.
/// Returns an empty map for null, List, String, or any non-Map type
/// to avoid the "type 'X' is not a subtype of Map<String, dynamic>?" crash.
Map<String, dynamic> _safeCastMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return <String, dynamic>{};
}

// Tiny inline trig helpers to avoid a math import for hit-testing.
double _cos(double r) {
  double x = 1.0, term = 1.0;
  for (int i = 1; i <= 10; i++) {
    term *= -r * r / ((2 * i - 1) * (2 * i));
    x += term;
  }
  return x;
}

double _sin(double r) {
  double x = r, term = r;
  for (int i = 1; i <= 10; i++) {
    term *= -r * r / ((2 * i) * (2 * i + 1));
    x += term;
  }
  return x;
}
