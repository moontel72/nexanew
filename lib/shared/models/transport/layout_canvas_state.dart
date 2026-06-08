// NEXATRACE — LAYOUT CANVAS STATE
// =================================
// Immutable state holder for the seat layout designer canvas.
// Holds the complete component graph, structural strips, and metadata
// for a single deck level.

import 'layout_component.dart';

class LayoutCanvasState {
  final String? layoutId;
  final String deckLevel; // 'lower' | 'upper'
  final int maxRows;
  final int maxCols; // total visual columns including aisle
  final int seatCols; // ticketable column count (excludes structural)
  final List<LayoutComponent> components;
  final List<StructuralStrip> structuralStrips;
  final Map<String, dynamic> metadata;
  final bool isDirty;

  const LayoutCanvasState({
    this.layoutId,
    this.deckLevel = 'lower',
    this.maxRows = 14,
    this.maxCols = 7,
    this.seatCols = 4,
    this.components = const [],
    this.structuralStrips = const [],
    this.metadata = const {},
    this.isDirty = false,
  });

  /// Total number of ticketable seats.
  int get totalSeats =>
      components.where((c) => c.bookable && !c.isStructural).length;

  /// Count of sleeper berths (lower + upper).
  int get sleeperBerths => components
      .where(
        (c) =>
            c.type == ComponentType.sleeperLower ||
            c.type == ComponentType.sleeperUpper,
      )
      .length;

  /// Count of conditional (folding) seats.
  int get conditionalSeats =>
      components.where((c) => c.bookingMode == BookingMode.conditional).length;

  /// Find a component by ID.
  LayoutComponent? componentById(String id) {
    try {
      return components.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find the component occupying a specific grid cell.
  LayoutComponent? componentAt(int row, int col) {
    for (final c in components) {
      if (c.occupies(row, col)) return c;
    }
    return null;
  }

  /// Check if a grid cell is occupied.
  bool isOccupied(int row, int col) => componentAt(row, col) != null;

  /// Check if a rectangular region has any collision.
  bool hasCollision(
    int originRow,
    int originCol,
    int spanRows,
    int spanCols, {
    String? excludeId,
  }) {
    for (int r = originRow; r < originRow + spanRows; r++) {
      for (int c = originCol; c < originCol + spanCols; c++) {
        final occupant = componentAt(r, c);
        if (occupant != null && occupant.id != excludeId) return true;
      }
    }
    return false;
  }

  /// Convert components to a publishable snapshot (v2 format).
  Map<String, dynamic> toSnapshot() => {
    'canvas': {'max_rows': maxRows, 'max_cols': maxCols, 'seat_cols': seatCols},
    'components': components.map((c) => c.toJson()).toList(),
    'structural_strips': structuralStrips.map((s) => s.toJson()).toList(),
    'metadata': {
      ...metadata,
      'total_bookable_seats': totalSeats,
      'total_berths': sleeperBerths,
      'total_conditional_seats': conditionalSeats,
    },
  };

  /// Parse from a backend snapshot (handles both v1 grid and v2 component formats).
  factory LayoutCanvasState.fromSnapshot(
    Map<String, dynamic> snap, {
    String? layoutId,
    String deckLevel = 'lower',
  }) {
    final canvas = snap['canvas'] as Map<String, dynamic>?;
    final componentsJson = snap['components'] as List<dynamic>?;
    final gridJson = snap['grid'] as List<dynamic>?;
    final stripsJson = snap['structural_strips'] as List<dynamic>?;
    final meta = (snap['metadata'] as Map<String, dynamic>?) ?? {};

    List<LayoutComponent> components;

    if (componentsJson != null && componentsJson.isNotEmpty) {
      // v2 component-based format
      components = componentsJson
          .whereType<Map<String, dynamic>>()
          .map((j) => LayoutComponent.fromJson(j))
          .toList();
    } else if (gridJson != null && gridJson.isNotEmpty) {
      // v1 legacy grid format — convert to components
      components = gridJson
          .whereType<Map<String, dynamic>>()
          .map((j) => LayoutComponent.fromJson(j))
          .toList();
    } else {
      components = [];
    }

    final strips = (stripsJson ?? [])
        .whereType<Map<String, dynamic>>()
        .map((j) => StructuralStrip.fromJson(j))
        .toList();

    return LayoutCanvasState(
      layoutId: layoutId,
      deckLevel: deckLevel,
      maxRows: canvas?['max_rows'] as int? ?? (snap['rows'] as int?) ?? 14,
      maxCols:
          canvas?['max_cols'] as int? ??
          (snap['total_visual_cols'] as int?) ??
          (snap['cols'] as int?) ??
          7,
      seatCols:
          canvas?['seat_cols'] as int? ?? (snap['seat_cols'] as int?) ?? 4,
      components: components,
      structuralStrips: strips,
      metadata: meta,
    );
  }

  /// Create a fresh canvas from a preset definition.
  factory LayoutCanvasState.fromPreset({
    required String key,
    required String label,
    required int rows,
    required int cols, // ticketable cols (excludes aisle)
    required int leftCols,
    required int rightCols,
    required int driverSeats,
    String deckLevel = 'lower',
  }) {
    final totalVisualCols = leftCols + 1 + rightCols;
    final components = <LayoutComponent>[];
    int seatCounter = 0;
    final uuidPrefix = '${deckLevel}_';

    // Build row by row, left to right
    for (int row = 1; row <= rows; row++) {
      // Left seats
      for (int l = 1; l <= leftCols; l++) {
        seatCounter++;
        final label = _computeSeatLabel(row, seatCounter, leftCols, rightCols);
        components.add(
          LayoutComponent(
            id: '$uuidPrefix${row}_${l}',
            type: ComponentType.seat,
            originRow: row,
            originCol: l,
            seatId: label,
            seatNumber: seatCounter,
            bookable: true,
          ),
        );
      }

      // Aisle column (single structural strip — NOT double)
      // Note: we add ONE aisle cell per row at the correct visual column
      final aisleCol = leftCols + 1;
      components.add(
        LayoutComponent(
          id: '$uuidPrefix${row}_aisle',
          type: ComponentType.aisle,
          originRow: row,
          originCol: aisleCol,
          bookable: false,
          bookingMode: BookingMode.none,
        ),
      );
    }

    // Driver seats (row 0)
    for (int d = 0; d < driverSeats; d++) {
      components.add(
        LayoutComponent(
          id: '${uuidPrefix}driver_$d',
          type: ComponentType.driverCabin,
          originRow: 0,
          originCol: d + 1,
          seatId: d == 0 ? 'DRV' : 'CO-DRV',
          bookable: false,
          bookingMode: BookingMode.none,
        ),
      );
    }

    // Structural strips
    final strips = <StructuralStrip>[
      StructuralStrip(
        type: 'aisle',
        col: leftCols + 1,
        fromRow: 1,
        toRow: rows,
      ),
      if (driverSeats > 0)
        StructuralStrip(
          type: 'driver_cockpit',
          col: 1,
          fromRow: 0,
          toRow: 0,
          originRow: 0,
          originCol: 1,
          spanCols: driverSeats,
        ),
    ];

    return LayoutCanvasState(
      deckLevel: deckLevel,
      maxRows: rows,
      maxCols: totalVisualCols,
      seatCols: cols,
      components: components,
      structuralStrips: strips,
      metadata: {
        'preset_key': key,
        'preset_label': label,
        'left_cols': leftCols,
        'right_cols': rightCols,
        'driver_seats': driverSeats,
      },
    );
  }

  /// Compute seat label using aisle-exclusion rule.
  /// Row letter + sequential position within row (skipping aisle).
  static String _computeSeatLabel(
    int row,
    int seatIndex,
    int leftCols,
    int rightCols,
  ) {
    final ticketablePerRow = leftCols + rightCols;
    final positionInRow = ((seatIndex - 1) % ticketablePerRow) + 1;
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rowLetter = letters[row - 1 >= 0 && row - 1 < 26 ? row - 1 : 0];
    return '$rowLetter$positionInRow';
  }

  LayoutCanvasState copyWith({
    String? layoutId,
    String? deckLevel,
    int? maxRows,
    int? maxCols,
    int? seatCols,
    List<LayoutComponent>? components,
    List<StructuralStrip>? structuralStrips,
    Map<String, dynamic>? metadata,
    bool? isDirty,
  }) => LayoutCanvasState(
    layoutId: layoutId ?? this.layoutId,
    deckLevel: deckLevel ?? this.deckLevel,
    maxRows: maxRows ?? this.maxRows,
    maxCols: maxCols ?? this.maxCols,
    seatCols: seatCols ?? this.seatCols,
    components: components ?? this.components,
    structuralStrips: structuralStrips ?? this.structuralStrips,
    metadata: metadata ?? this.metadata,
    isDirty: isDirty ?? this.isDirty,
  );
}
