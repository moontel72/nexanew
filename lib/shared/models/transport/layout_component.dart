// NEXATRACE — LAYOUT COMPONENT MODEL
// ====================================
// Component-based seat layout architecture (v2).
//
// Each component occupies a position on the canvas grid with explicit
// span_rows × span_cols. Multi-cell objects (sleeper berths, lavatories)
// are a single entity — not split into individual cells.
//
// Section 14E: Seat Layout Designer — Component Architecture.

import 'dart:convert';

/// Component types for the modular seat layout canvas.
enum ComponentType {
  seat, // Standard passenger seat (1×1)
  sleeperLower, // Lower sleeper berth (1×3 or 1×4)
  sleeperUpper, // Upper sleeper berth (1×3 or 1×4)
  foldingSeat, // Folding aisle seat — Coaster 2-in-1 rule (1×1)
  aisle, // Empty aisle space — walkway strip (1×1)
  exitDoor, // Exit / front door (1×1)
  driverCabin, // Driver cockpit (2×1)
  emergency, // Emergency exit (1×1)
  lavatory, // Washroom block (2×2)
  restaurantTable, // Restaurant-style dining module (2×2, 4 seats + table)
  businessClassSeat, // Luxury business class seat (2×1, premium wide)
  empty, // Unoccupied canvas cell
}

/// Booking mode determines how the booking engine treats the component.
enum BookingMode {
  standard, // Always bookable at flat price
  conditional, // Bookable only when occupied (folding seat)
  berth, // Sleeper pricing tier
  premium, // Business class premium tier
  none, // Not bookable (structural)
}

/// Immutable data class for a single layout component.
class LayoutComponent {
  final String id;
  final ComponentType type;
  final int originRow;
  final int originCol;
  final int spanRows;
  final int spanCols;
  String? seatId;
  int? seatNumber;
  bool bookable;
  BookingMode bookingMode;
  String? genderRestriction;
  String?
  customLabel; // Override sticker number set by owner (freezes auto-numbering)
  Map<String, dynamic> meta;

  LayoutComponent({
    required this.id,
    required this.type,
    required this.originRow,
    required this.originCol,
    this.spanRows = 1,
    this.spanCols = 1,
    this.seatId,
    this.seatNumber,
    this.bookable = true,
    this.bookingMode = BookingMode.standard,
    this.genderRestriction,
    this.customLabel,
    Map<String, dynamic>? meta,
  }) : meta = meta ?? {};

  /// Whether this component occupies more than 1 cell.
  bool get isMultiCell => spanRows > 1 || spanCols > 1;

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

  /// Whether this component has custom painter sub-layout.
  bool get hasCustomRender => switch (type) {
    ComponentType.restaurantTable || ComponentType.businessClassSeat => true,
    _ => false,
  };

  /// Whether this component can be edited/moved by the user.
  bool get isEditable => switch (type) {
    ComponentType.aisle ||
    ComponentType.exitDoor ||
    ComponentType.driverCabin ||
    ComponentType.restaurantTable => false,
    _ => true,
  };

  /// Check if a grid cell at (row, col) falls within this component's footprint.
  bool occupies(int row, int col) =>
      row >= originRow &&
      row < originRow + spanRows &&
      col >= originCol &&
      col < originCol + spanCols;

  /// Get the effective display label (custom override or auto-generated).
  String? get displayLabel => customLabel ?? seatId;

  /// Clone with optional overrides.
  LayoutComponent copyWith({
    String? id,
    ComponentType? type,
    int? originRow,
    int? originCol,
    int? spanRows,
    int? spanCols,
    String? seatId,
    int? seatNumber,
    bool? bookable,
    BookingMode? bookingMode,
    String? genderRestriction,
    String? customLabel,
    Map<String, dynamic>? meta,
  }) => LayoutComponent(
    id: id ?? this.id,
    type: type ?? this.type,
    originRow: originRow ?? this.originRow,
    originCol: originCol ?? this.originCol,
    spanRows: spanRows ?? this.spanRows,
    spanCols: spanCols ?? this.spanCols,
    seatId: seatId ?? this.seatId,
    seatNumber: seatNumber ?? this.seatNumber,
    bookable: bookable ?? this.bookable,
    bookingMode: bookingMode ?? this.bookingMode,
    genderRestriction: genderRestriction ?? this.genderRestriction,
    customLabel: customLabel ?? this.customLabel,
    meta: meta ?? Map<String, dynamic>.from(this.meta),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'origin_row': originRow,
    'origin_col': originCol,
    'span_rows': spanRows,
    'span_cols': spanCols,
    'seat_id': seatId,
    'seat_number': seatNumber,
    'bookable': bookable,
    'booking_mode': bookingMode.name,
    'gender_restriction': genderRestriction,
    if (customLabel != null) 'custom_label': customLabel,
    'meta': meta,
  };

  factory LayoutComponent.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? 'empty');
    final bp = json['booking_mode'] as String?;
    return LayoutComponent(
      id: (json['id'] as String?) ?? '',
      type: ComponentType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => ComponentType.empty,
      ),
      originRow: (json['origin_row'] as int?) ?? (json['row'] as int?) ?? 1,
      originCol: (json['origin_col'] as int?) ?? (json['col'] as int?) ?? 1,
      spanRows: (json['span_rows'] as int?) ?? 1,
      spanCols: (json['span_cols'] as int?) ?? 1,
      seatId: json['seat_id'] as String?,
      seatNumber: json['seat_number'] as int?,
      bookable: (json['bookable'] as bool?) ?? true,
      bookingMode: bp != null
          ? BookingMode.values.firstWhere(
              (e) => e.name == bp,
              orElse: () => BookingMode.standard,
            )
          : BookingMode.standard,
      genderRestriction: json['gender_restriction'] as String?,
      customLabel: json['custom_label'] as String?,
      meta: (json['meta'] as Map<String, dynamic>?) ?? {},
    );
  }

  @override
  String toString() =>
      'LayoutComponent(id=$id, type=${type.name}, @($originRow,$originCol) '
      '${spanRows}×${spanCols}, label=$seatId)';
}

/// A structural strip that spans multiple rows in a fixed column.
/// Used for aisle strips and driver cockpit zones.
class StructuralStrip {
  final String type; // 'aisle' | 'driver_cockpit'
  final int col;
  final int fromRow;
  final int toRow;
  final int? originRow;
  final int? originCol;
  final int? spanCols;

  const StructuralStrip({
    required this.type,
    required this.col,
    required this.fromRow,
    required this.toRow,
    this.originRow,
    this.originCol,
    this.spanCols,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'col': col,
    'from_row': fromRow,
    'to_row': toRow,
    if (originRow != null) 'origin_row': originRow,
    if (originCol != null) 'origin_col': originCol,
    if (spanCols != null) 'span_cols': spanCols,
  };

  factory StructuralStrip.fromJson(Map<String, dynamic> json) =>
      StructuralStrip(
        type: json['type'] as String,
        col: json['col'] as int,
        fromRow: json['from_row'] as int,
        toRow: json['to_row'] as int,
        originRow: json['origin_row'] as int?,
        originCol: json['origin_col'] as int?,
        spanCols: json['span_cols'] as int?,
      );
}
