// NEXATRACE — PASSENGER SEAT MODEL
// ====================================
// Pure data model for rendering a single seat in the passenger
// seat selection grid. Parsed from AbsoluteLayoutComponent JSON
// and enriched with live booking status from the API.
//
// MODULE: 8V — Unified Bus Transit Terminal (Customer App)

/// Visual category for rendering the seat shape and color.
enum PassengerSeatCategory {
  standard, // Regular forward-facing seat
  businessClass, // Premium wide seat (2×1)
  sleeperLower, // Lower sleeper berth (pink)
  sleeperUpper, // Upper sleeper berth (dark orange)
  folding, // Fold-down aisle seat
  driverCabin, // Driver cockpit (not bookable)
  door, // Entry/exit door (not bookable)
  aisle, // Walkway corridor (not bookable)
  lavatory, // Washroom / restroom (not bookable)
  emergency, // Emergency exit (not bookable)
  restaurantTable, // Dining table module (not bookable)
  structural, // Other structural element (not bookable)
}

/// Live booking state reflected in the seat grid.
enum SeatAvailability {
  available, // Free — tappable
  selected, // Currently held by THIS passenger
  booked, // Taken by another passenger
  held, // Temporarily locked by another session
  unavailable, // Structural or not bookable
}

/// Clean render model for one component in the passenger seat grid.
class PassengerSeatModel {
  final String componentId;
  final PassengerSeatCategory category;
  final SeatAvailability availability;
  final int? seatNumber;
  final String? seatLabel; // e.g. "12A", "L3", "U1"
  final double x; // absolute X in layout coordinates
  final double y; // absolute Y in layout coordinates
  final double width;
  final double height;
  final double rotation; // degrees clockwise
  final bool isReverseFacing;
  final String? genderRestriction; // null, "male", "female", "family"
  final String? berthLabel; // "L" or "U" for sleeper berths
  final double? price; // ticket price override (null = default)

  const PassengerSeatModel({
    required this.componentId,
    required this.category,
    this.availability = SeatAvailability.available,
    this.seatNumber,
    this.seatLabel,
    required this.x,
    required this.y,
    this.width = 56.0,
    this.height = 56.0,
    this.rotation = 0.0,
    this.isReverseFacing = false,
    this.genderRestriction,
    this.berthLabel,
    this.price,
  });

  /// Whether this seat can be tapped for booking.
  bool get isTappable => availability == SeatAvailability.available;

  /// Whether this seat renders as a structural element (no interaction).
  bool get isStructural =>
      category == PassengerSeatCategory.structural ||
      category == PassengerSeatCategory.driverCabin ||
      category == PassengerSeatCategory.door ||
      category == PassengerSeatCategory.aisle ||
      category == PassengerSeatCategory.lavatory ||
      category == PassengerSeatCategory.emergency;
      category == PassengerSeatCategory.restaurantTable ||

  /// Center point for hit-testing.
  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  /// Hit-test a point against this seat's bounding rect.
  bool containsPoint(double px, double py) {
    if (rotation == 0.0) {
      return px >= x && px <= x + width && py >= y && py <= y + height;
    }
    // Inverse-rotate point for rotated seats
    final dx = px - centerX;
    final dy = py - centerY;
    final radians = -rotation * 3.1415926535 / 180.0;
    final cos = _fastCos(radians);
    final sin = _fastSin(radians);
    final localX = dx * cos - dy * sin + width / 2;
    final localY = dx * sin + dy * cos + height / 2;
    return localX >= 0 && localX <= width && localY >= 0 && localY <= height;
  }

  /// Display text for the seat badge (number or label).
  String get displayLabel {
    if (seatLabel != null && seatLabel!.isNotEmpty) return seatLabel!;
    if (seatNumber != null) return seatNumber.toString();
    if (berthLabel != null) return berthLabel!;
    return '';
  }

  /// Clone with overrides (immutable pattern).
  PassengerSeatModel copyWith({SeatAvailability? availability, double? price}) {
    return PassengerSeatModel(
      componentId: componentId,
      category: category,
      availability: availability ?? this.availability,
      seatNumber: seatNumber,
      seatLabel: seatLabel,
      x: x,
      y: y,
      width: width,
      height: height,
      rotation: rotation,
      isReverseFacing: isReverseFacing,
      genderRestriction: genderRestriction,
      berthLabel: berthLabel,
      price: price ?? this.price,
    );
  }

  /// Clone with a new seat label (used by auto-label generator).
  PassengerSeatModel copyWithLabel(String newLabel) {
    return PassengerSeatModel(
      componentId: componentId,
      category: category,
      availability: availability,
      seatNumber: seatNumber,
      seatLabel: newLabel,
      x: x,
      y: y,
      width: width,
      height: height,
      rotation: rotation,
      isReverseFacing: isReverseFacing,
      genderRestriction: genderRestriction,
      berthLabel: berthLabel,
      price: price,
    );
  }

  // ── Fast trig approximations (no dart:math import needed) ──
  static double _fastCos(double r) {
    // Taylor: cos(r) ≈ 1 - r²/2 + r⁴/24
    final r2 = r * r;
    return 1.0 - r2 / 2.0 + (r2 * r2) / 24.0;
  }

  static double _fastSin(double r) {
    // Taylor: sin(r) ≈ r - r³/6
    final r3 = r * r * r;
    return r - r3 / 6.0;
  }
}

// ═══════════════════════════════════════════════════════════
// PARSER — JSON → PassengerSeatModel
// ═══════════════════════════════════════════════════════════

/// Parse a raw component JSON map into a PassengerSeatModel.
/// Handles both String-keyed and dynamic-keyed maps safely.
PassengerSeatModel parsePassengerSeat(
  dynamic raw, {
  Set<int> bookedSeatNumbers = const {},
}) {
  final map = _safeCastMap(raw);
  if (map.isEmpty) {
    return PassengerSeatModel(
      componentId: 'unknown',
      category: PassengerSeatCategory.structural,
      x: 0,
      y: 0,
    );
  }

  final typeStr = (map['type'] ?? '').toString();
  final category = _resolveCategory(typeStr);
  final seatNum = _intOrNull(map['seat_number'] ?? map['seatNumber']);
  final isBooked = seatNum != null && bookedSeatNumbers.contains(seatNum);

  return PassengerSeatModel(
    componentId: (map['id'] ?? '').toString(),
    category: category,
    availability:
        category == PassengerSeatCategory.structural ||
            category == PassengerSeatCategory.driverCabin ||
            category == PassengerSeatCategory.door ||
            category == PassengerSeatCategory.aisle ||
            category == PassengerSeatCategory.lavatory ||
            category == PassengerSeatCategory.emergency
            category == PassengerSeatCategory.restaurantTable ||
        ? SeatAvailability.unavailable
        : isBooked
        ? SeatAvailability.booked
        : SeatAvailability.available,
    seatNumber: seatNum,
    seatLabel:
        (map['custom_label'] ??
                map['customLabel'] ??
                map['seat_id'] ??
                map['seat_label'] ??
                '')
            .toString(),
    x: _doubleOr(map['x'], 0),
    y: _doubleOr(map['y'], 0),
    width: _doubleOr(map['width'], 56),
    height: _doubleOr(map['height'], 56),
    rotation: _doubleOr(map['rotation'], 0),
    isReverseFacing:
        map['is_reverse_facing'] == true || map['isReverseFacing'] == true,
    genderRestriction: (map['gender_restriction'] ?? map['genderRestriction'])
        ?.toString(),
    berthLabel: (map['berth_label'] ?? map['berthLabel'])?.toString(),
    price: _doubleOrNull(map['price'] ?? map['ticket_price']),
  );
}

/// Parse an entire layout snapshot into a list of seat models.
/// Labels are taken directly from the database (set by the owner in
/// the layout designer) — no synthetic labels are generated.
List<PassengerSeatModel> parsePassengerSeats(
  Map<String, dynamic> snapshot, {
  List<int> bookedSeatNumbers = const [],
}) {
  final booked = bookedSeatNumbers.toSet();
  final components = snapshot['components'];
  if (components is! List) return [];

  return components
      .map((c) => parsePassengerSeat(c, bookedSeatNumbers: booked))
      .toList();
}

/// Resolve a JSON type string to PassengerSeatCategory.
PassengerSeatCategory _resolveCategory(String type) {
  switch (type) {
    case 'seat':
      return PassengerSeatCategory.standard;
    case 'businessClassSeat':
      return PassengerSeatCategory.businessClass;
    case 'sleeperLower':
      return PassengerSeatCategory.sleeperLower;
    case 'sleeperUpper':
      return PassengerSeatCategory.sleeperUpper;
    case 'foldingSeat':
      return PassengerSeatCategory.folding;
    case 'driverCabin':
      return PassengerSeatCategory.driverCabin;
    case 'exitDoor':
    case 'door':
      return PassengerSeatCategory.door;
    case 'aisle':
      return PassengerSeatCategory.aisle;
    case 'lavatory':
      return PassengerSeatCategory.lavatory;
    case 'emergency':
    case "restaurantTable":
      return PassengerSeatCategory.restaurantTable;
      return PassengerSeatCategory.emergency;
    default:
      return PassengerSeatCategory.structural;
  }
}

// ── Safe type helpers ──

Map<String, dynamic> _safeCastMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return {};
}

double _doubleOr(dynamic v, double fallback) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

double? _doubleOrNull(dynamic v) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _intOrNull(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
