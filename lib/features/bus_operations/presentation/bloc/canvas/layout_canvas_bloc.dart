// NEXATRACE — LAYOUT CANVAS BLOC
// ===============================
// State management for the component-based seat layout designer.
//
// Events: PresetSelected, ComponentDropped, ComponentMoved,
//         ComponentResized, ComponentUpdated, ComponentDeleted,
//         DeckSwitched, PublishRequested, LayoutLoaded
//
// Section 14E: Seat Layout Designer — BLoC.

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/models/transport/layout_canvas_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'layout_canvas_event.dart';
import 'layout_canvas_state_bloc.dart';

/// The 5 built-in vehicle-class presets (mirrors backend getPresets()).
const _builtInPresets = [
  {
    'key': 'coach_54',
    'label': '54-Seat Coach (Large)',
    'rows': 14,
    'cols': 4,
    'left_cols': 2,
    'right_cols': 2,
    'driver_seats': 1,
    'has_upper_deck': false,
    'deck_type': 'single',
  },
  {
    'key': 'standard_45',
    'label': '45-Seat Standard Coach',
    'rows': 11,
    'cols': 4,
    'left_cols': 2,
    'right_cols': 2,
    'driver_seats': 1,
    'has_upper_deck': false,
    'deck_type': 'single',
  },
  {
    'key': 'coaster_34',
    'label': '34-Seat Coaster',
    'rows': 9,
    'cols': 4,
    'left_cols': 2,
    'right_cols': 2,
    'driver_seats': 1,
    'has_upper_deck': false,
    'deck_type': 'single',
  },
  {
    'key': 'hiace_13',
    'label': '13-Seat HiAce',
    'rows': 4,
    'cols': 3,
    'left_cols': 2,
    'right_cols': 1,
    'driver_seats': 1,
    'has_upper_deck': false,
    'deck_type': 'single',
  },
  {
    'key': 'sleeper_custom',
    'label': 'Custom Sleeper Coach',
    'rows': 10,
    'cols': 4,
    'left_cols': 2,
    'right_cols': 2,
    'driver_seats': 1,
    'has_upper_deck': true,
    'deck_type': 'dual',
  },
];

class LayoutCanvasBloc extends Bloc<LayoutCanvasEvent, LayoutCanvasBlocState> {
  final ApiService _api;
  final String companyId;
  final String? identityId;

  LayoutCanvasBloc({required this.companyId, this.identityId, ApiService? api})
    : _api = api ?? ApiService(),
      super(const LayoutCanvasBlocState()) {
    on<PresetSelected>(_onPresetSelected);
    on<ComponentDropped>(_onComponentDropped);
    on<ComponentMoved>(_onComponentMoved);
    on<ComponentResized>(_onComponentResized);
    on<ComponentUpdated>(_onComponentUpdated);
    on<ComponentDeleted>(_onComponentDeleted);
    on<DeckSwitched>(_onDeckSwitched);
    on<PublishRequested>(_onPublishRequested);
    on<LayoutLoaded>(_onLayoutLoaded);
    on<RenumberRequested>(_onRenumberRequested);
    on<BusinessClassZoneRequested>(_onBusinessClassZoneRequested);
  }

  // ═══════════════════════════════════════════════════════════
  // PRESET SELECTION
  // ═══════════════════════════════════════════════════════════

  void _onPresetSelected(PresetSelected event, Emitter emit) {
    // Safe fallback: guard against empty presets list to prevent
    // StateError (Bad state: No element) crash.
    if (_builtInPresets.isEmpty) {
      emit(state.copyWith(error: 'No built-in presets available.'));
      return;
    }
    final preset = _builtInPresets.firstWhere(
      (p) => p['key'] == event.presetKey,
      orElse: () => _builtInPresets.first,
    );

    final canvas = LayoutCanvasState.fromPreset(
      key: preset['key'] as String,
      label: preset['label'] as String,
      rows: preset['rows'] as int,
      cols: preset['cols'] as int,
      leftCols: preset['left_cols'] as int,
      rightCols: preset['right_cols'] as int,
      driverSeats: preset['driver_seats'] as int,
      deckLevel: state.activeDeck,
    );

    emit(
      state.copyWith(
        status: CanvasStatus.modified,
        lowerCanvas: state.activeDeck == 'lower' ? canvas : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper' ? canvas : state.upperCanvas,
        selectedPresetKey: event.presetKey,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMPONENT DROP (from palette)
  // ═══════════════════════════════════════════════════════════

  void _onComponentDropped(ComponentDropped event, Emitter emit) {
    final canvas = state.activeCanvas;
    if (canvas == null) return;

    // Build new component
    final newId =
        '${state.activeDeck}_${DateTime.now().millisecondsSinceEpoch}_${event.type.name}';

    // Determine default spans for multi-cell types
    int spanRows = 1;
    int spanCols = 1;
    BookingMode bookingMode = BookingMode.standard;
    bool bookable = true;
    FlexOverrides? pendingFlex;
    RowHeights? pendingHeights;

    switch (event.type) {
      case ComponentType.lavatory:
        spanRows = 2;
        spanCols = 2;
        bookable = false;
        bookingMode = BookingMode.none;
      case ComponentType.restaurantTable:
        spanRows = 2;
        spanCols = 2;
        bookable = false;
        bookingMode = BookingMode.none;
      case ComponentType.businessClassSeat:
        spanRows = 1;
        spanCols = 1;
        bookable = true;
        bookingMode = BookingMode.premium;
        final result = _computeBusinessFlexRow(canvas, event.originRow);
        pendingFlex = result.flex;
        pendingHeights = result.heights;
      case ComponentType.sleeperLower:
      case ComponentType.sleeperUpper:
        spanRows = 3; // default 1×3 berth
        spanCols = 1;
        bookingMode = BookingMode.berth;
      case ComponentType.foldingSeat:
        bookingMode = BookingMode.conditional;
      case ComponentType.aisle:
      case ComponentType.exitDoor:
      case ComponentType.driverCabin:
      case ComponentType.emergency:
        bookable = false;
        bookingMode = BookingMode.none;
      default:
        break;
    }

    // Collision check
    if (canvas.hasCollision(
      event.originRow,
      event.originCol,
      spanRows,
      spanCols,
    )) {
      // Don't place if collision — emit error
      emit(
        state.copyWith(
          error: 'Cannot place ${event.type.name}: cell is occupied',
        ),
      );
      return;
    }

    // Also check bounds
    if (event.originRow + spanRows - 1 > canvas.maxRows ||
        event.originCol + spanCols - 1 > canvas.maxCols) {
      emit(state.copyWith(error: 'Component exceeds canvas bounds'));
      return;
    }

    final component = LayoutComponent(
      id: newId,
      type: event.type,
      originRow: event.originRow,
      originCol: event.originCol,
      spanRows: spanRows,
      spanCols: spanCols,
      bookable: bookable,
      bookingMode: bookingMode,
    );

    // Apply any pending flex overrides before building the new canvas
    var effectiveCanvas = canvas;
    if (pendingFlex != null) {
      effectiveCanvas = effectiveCanvas.copyWith(flexOverrides: pendingFlex);
    }
    if (pendingHeights != null) {
      effectiveCanvas = effectiveCanvas.copyWith(rowHeights: pendingHeights);
    }

    final newComponents = _replaceCanvasComponents(effectiveCanvas, [
      ...effectiveCanvas.components,
      component,
    ], renumber: true);

    emit(
      state.copyWith(
        status: CanvasStatus.modified,
        lowerCanvas: state.activeDeck == 'lower'
            ? newComponents
            : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper'
            ? newComponents
            : state.upperCanvas,
        error: null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMPONENT MOVE
  // ═══════════════════════════════════════════════════════════

  void _onComponentMoved(ComponentMoved event, Emitter emit) {
    final canvas = state.activeCanvas;
    if (canvas == null) return;

    final comp = canvas.componentById(event.componentId);
    if (comp == null) return;

    // Collision check (exclude self)
    if (canvas.hasCollision(
      event.newOriginRow,
      event.newOriginCol,
      comp.spanRows,
      comp.spanCols,
      excludeId: comp.id,
    )) {
      emit(state.copyWith(error: 'Cannot move: destination is occupied'));
      return;
    }

    final updated = comp.copyWith(
      originRow: event.newOriginRow,
      originCol: event.newOriginCol,
    );

    final newComponents = _replaceComponentInList(canvas, updated);
    final newCanvas = _replaceCanvasComponents(
      canvas,
      newComponents,
      renumber: true,
    );

    emit(
      state.copyWith(
        status: CanvasStatus.modified,
        lowerCanvas: state.activeDeck == 'lower'
            ? newCanvas
            : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper'
            ? newCanvas
            : state.upperCanvas,
        error: null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMPONENT RESIZE
  // ═══════════════════════════════════════════════════════════

  void _onComponentResized(ComponentResized event, Emitter emit) {
    final canvas = state.activeCanvas;
    if (canvas == null) return;

    final comp = canvas.componentById(event.componentId);
    if (comp == null) return;

    // Collision check for the NEW size (exclude self)
    if (canvas.hasCollision(
      comp.originRow,
      comp.originCol,
      event.newSpanRows,
      event.newSpanCols,
      excludeId: comp.id,
    )) {
      emit(
        state.copyWith(
          error: 'Cannot resize: new area overlaps another component',
        ),
      );
      return;
    }

    final updated = comp.copyWith(
      spanRows: event.newSpanRows,
      spanCols: event.newSpanCols,
    );

    final newComponents = _replaceComponentInList(canvas, updated);
    final newCanvas = _replaceCanvasComponents(canvas, newComponents);

    emit(
      state.copyWith(
        status: CanvasStatus.modified,
        lowerCanvas: state.activeDeck == 'lower'
            ? newCanvas
            : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper'
            ? newCanvas
            : state.upperCanvas,
        error: null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMPONENT UPDATE (inspector property change)
  // ═══════════════════════════════════════════════════════════

  void _onComponentUpdated(ComponentUpdated event, Emitter emit) {
    var canvas = state.activeCanvas;
    if (canvas == null) return;

    // If the updated component is business class, ensure flex overrides exist
    if (event.updated.type == ComponentType.businessClassSeat) {
      final result = _computeBusinessFlexRow(canvas, event.updated.originRow);
      canvas = canvas.copyWith(
        flexOverrides: result.flex,
        rowHeights: result.heights,
      );
    }

    final newComponents = _replaceComponentInList(canvas, event.updated);
    final newCanvas = _replaceCanvasComponents(
      canvas,
      newComponents,
      renumber: true,
    );

    emit(
      state.copyWith(
        status: CanvasStatus.modified,
        lowerCanvas: state.activeDeck == 'lower'
            ? newCanvas
            : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper'
            ? newCanvas
            : state.upperCanvas,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMPONENT DELETE
  // ═══════════════════════════════════════════════════════════

  void _onComponentDeleted(ComponentDeleted event, Emitter emit) {
    final canvas = state.activeCanvas;
    if (canvas == null) return;

    final comp = canvas.componentById(event.componentId);
    if (comp == null || !comp.isEditable) return;

    final newComponents = canvas.components
        .where((c) => c.id != event.componentId)
        .toList();
    final newCanvas = _replaceCanvasComponents(
      canvas,
      newComponents,
      renumber: true,
    );

    emit(
      state.copyWith(
        status: CanvasStatus.modified,
        lowerCanvas: state.activeDeck == 'lower'
            ? newCanvas
            : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper'
            ? newCanvas
            : state.upperCanvas,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DECK SWITCH
  // ═══════════════════════════════════════════════════════════

  void _onDeckSwitched(DeckSwitched event, Emitter emit) {
    emit(state.copyWith(activeDeck: event.deck));
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH
  // ═══════════════════════════════════════════════════════════

  Future<void> _onPublishRequested(PublishRequested event, Emitter emit) async {
    final canvas = state.lowerCanvas;
    if (canvas == null) return;

    emit(state.copyWith(status: CanvasStatus.publishing));

    try {
      final snapshot = canvas.toSnapshot();

      if (state.layoutId != null) {
        await _api.post(
          '/bus-fleet/layouts/${state.layoutId}/publish',
          data: {
            'grid_snapshot': snapshot,
            'expected_version': event.expectedVersion,
            'change_description': event.changeDescription ?? 'Layout revision',
          },
        );
      } else {
        // Create new layout first
        final createRes = await _api.post(
          '/bus-fleet/layouts',
          data: {
            'vehicle_class': state.selectedPresetKey ?? 'standard_45',
            'display_name': state.displayName ?? 'Untitled Layout',
            'deck_level': state.activeDeck == 'lower' ? 0 : 1,
            'company_id': companyId,
          },
        );
        final newId = createRes['data']['id'] as String;

        await _api.post(
          '/bus-fleet/layouts/$newId/publish',
          data: {
            'grid_snapshot': snapshot,
            'expected_version': 1,
            'change_description': 'Initial layout',
          },
        );
      }

      emit(
        state.copyWith(
          status: CanvasStatus.published,
          versionNumber: state.versionNumber + 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CanvasStatus.error, error: 'Publish failed: $e'),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD EXISTING LAYOUT
  // ═══════════════════════════════════════════════════════════

  Future<void> _onLayoutLoaded(LayoutLoaded event, Emitter emit) async {
    emit(state.copyWith(status: CanvasStatus.loading));

    try {
      final res = await _api.get('/bus-fleet/layouts/${event.layoutId}');
      final data = res['data'] as Map<String, dynamic>;
      final snap = data['current_snapshot'] as Map<String, dynamic>?;

      final canvas = snap != null
          ? LayoutCanvasState.fromSnapshot(snap, layoutId: event.layoutId)
          : null;

      emit(
        state.copyWith(
          status: canvas != null ? CanvasStatus.loaded : CanvasStatus.error,
          layoutId: data['id'] as String,
          displayName: data['display_name'] as String?,
          versionNumber: (data['version_number'] as int?) ?? 1,
          lowerCanvas: canvas,
          upperCanvas: null, // upper deck loads separately if dual-deck
          selectedPresetKey: data['vehicle_class'] as String?,
          error: canvas == null ? 'No snapshot found' : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CanvasStatus.error,
          error: 'Failed to load layout: $e',
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RENUMBER
  // ═══════════════════════════════════════════════════════════

  void _onRenumberRequested(RenumberRequested event, Emitter emit) {
    final canvas = state.activeCanvas;
    if (canvas == null) return;

    final newCanvas = _replaceCanvasComponents(
      canvas,
      canvas.components,
      renumber: true,
    );

    emit(
      state.copyWith(
        lowerCanvas: state.activeDeck == 'lower'
            ? newCanvas
            : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper'
            ? newCanvas
            : state.upperCanvas,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUSINESS CLASS ZONE CONVERSION
  // ═══════════════════════════════════════════════════════════

  void _onBusinessClassZoneRequested(
    BusinessClassZoneRequested event,
    Emitter emit,
  ) {
    final canvas = state.activeCanvas;
    if (canvas == null) return;

    // Remove all existing components from the 3 target rows
    final rowStart = event.startRow;
    final rowEnd = rowStart + 2;
    final preserved = canvas.components.where((c) {
      final compRowEnd = c.originRow + c.spanRows - 1;
      return compRowEnd < rowStart || c.originRow > rowEnd;
    }).toList();

    final uuidPrefix = '${state.activeDeck}_bc_';

    // Business class: aisle 50% narrower, saved space to seats, rows 50% taller
    const double kCell = 56.0;
    final leftWidth = kCell * event.leftCols;
    final aisleWidth = kCell * 0.5; // half-width aisle
    final extraPerSeat = (kCell * 0.5) / (1 + event.rightCols);

    final bizColumnWidths = <double>[
      leftWidth + extraPerSeat,
      aisleWidth,
      for (int i = 0; i < event.rightCols; i++) kCell + extraPerSeat,
    ];

    // Store flex overrides AND row heights for these 3 rows
    final flexOverrides = FlexOverrides.from(canvas.flexOverrides ?? {});
    final heights = RowHeights.from(canvas.rowHeights ?? {});
    for (int row = rowStart; row <= rowEnd; row++) {
      flexOverrides[row] = List.from(bizColumnWidths);
      heights[row] = kCell * 1.5; // 84px — business class = 50% taller

      // Left-side business seat (occupies visual col 1, full left width)
      preserved.add(
        LayoutComponent(
          id: '${uuidPrefix}L${row}_${DateTime.now().millisecondsSinceEpoch}',
          type: ComponentType.businessClassSeat,
          originRow: row,
          originCol: 1,
          spanRows: 1,
          spanCols: 1, // 1 flex column = entire left side
          bookable: true,
          bookingMode: BookingMode.premium,
        ),
      );

      // Aisle (visual col 2)
      preserved.add(
        LayoutComponent(
          id: '${uuidPrefix}aisle_${row}',
          type: ComponentType.aisle,
          originRow: row,
          originCol: 2,
          bookable: false,
          bookingMode: BookingMode.none,
        ),
      );

      // Right-side business seats (visual cols 3, 4, ...)
      for (int r = 0; r < event.rightCols; r++) {
        preserved.add(
          LayoutComponent(
            id: '${uuidPrefix}R${row}_$r',
            type: ComponentType.businessClassSeat,
            originRow: row,
            originCol: 3 + r,
            spanRows: 1,
            spanCols: 1,
            bookable: true,
            bookingMode: BookingMode.premium,
          ),
        );
      }
    }

    final newCanvas = _replaceCanvasComponents(
      canvas.copyWith(flexOverrides: flexOverrides, rowHeights: heights),
      preserved,
      renumber: true,
    );

    emit(
      state.copyWith(
        status: CanvasStatus.modified,
        lowerCanvas: state.activeDeck == 'lower'
            ? newCanvas
            : state.lowerCanvas,
        upperCanvas: state.activeDeck == 'upper'
            ? newCanvas
            : state.upperCanvas,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FLEX ROW COMPUTATION
  // ═══════════════════════════════════════════════════════════

  /// Compute flex column widths AND row heights for a business class row.
  /// Returns a record with both updated maps.
  ({FlexOverrides flex, RowHeights heights}) _computeBusinessFlexRow(
    LayoutCanvasState canvas,
    int row,
  ) {
    const double kCell = 56.0;
    final meta = canvas.metadata;
    final leftCols =
        (meta['left_cols'] as int?) ?? ((canvas.maxCols - 1) ~/ 2).clamp(1, 3);
    final rightCols =
        (meta['right_cols'] as int?) ?? ((canvas.maxCols - 1) ~/ 2).clamp(1, 3);

    // Business class: aisle 50% narrower, saved space distributed to seats
    final leftWidth = kCell * leftCols;
    final aisleWidth = kCell * 0.5; // half-width aisle
    final extraPerSeat = (kCell * 0.5) / (1 + rightCols); // share saved space

    final bizWidths = <double>[
      leftWidth + extraPerSeat, // left panel + share
      aisleWidth,
      for (int i = 0; i < rightCols; i++) kCell + extraPerSeat,
    ];

    final flexOverrides = FlexOverrides.from(canvas.flexOverrides ?? {});
    flexOverrides[row] = bizWidths;

    // Business class rows are 50% taller than standard
    final heights = RowHeights.from(canvas.rowHeights ?? {});
    heights[row] = kCell * 1.5; // 84px

    return (flex: flexOverrides, heights: heights);
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Replace a single component in the list by ID match.
  List<LayoutComponent> _replaceComponentInList(
    LayoutCanvasState canvas,
    LayoutComponent updated,
  ) {
    return canvas.components.map((c) {
      return c.id == updated.id ? updated : c;
    }).toList();
  }

  /// Rebuild canvas state with new component list, optionally renumbering.
  LayoutCanvasState _replaceCanvasComponents(
    LayoutCanvasState canvas,
    List<LayoutComponent> components, {
    bool renumber = false,
  }) {
    List<LayoutComponent> finalComponents = List.from(components);

    if (renumber) {
      finalComponents = _serverSideRenumber(finalComponents);
    }

    return canvas.copyWith(components: finalComponents, isDirty: true);
  }

  /// Walk top-left → bottom-right, skip structural, assign monotonic numbers.
  /// Mirrors backend LayoutService::recomputeSeatNumbers().
  List<LayoutComponent> _serverSideRenumber(List<LayoutComponent> components) {
    // Sort by (row, col)
    final sorted = List<LayoutComponent>.from(components)
      ..sort((a, b) {
        final rowCmp = a.originRow.compareTo(b.originRow);
        if (rowCmp != 0) return rowCmp;
        return a.originCol.compareTo(b.originCol);
      });

    const structural = {
      ComponentType.aisle,
      ComponentType.exitDoor,
      ComponentType.driverCabin,
      ComponentType.emergency,
      ComponentType.lavatory,
      ComponentType.restaurantTable,
    };

    int seatCounter = 0;
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (final comp in sorted) {
      if (structural.contains(comp.type) || comp.type == ComponentType.empty) {
        comp.seatNumber = null;
        comp.seatId = null;
        continue;
      }

      // Skip auto-numbering for components with owner-set custom labels
      if (comp.customLabel != null) {
        continue;
      }

      seatCounter++;
      comp.seatNumber = seatCounter;

      if (comp.seatId == null || comp.seatId!.isEmpty) {
        final rowIdx = (comp.originRow - 1).clamp(0, 25);
        comp.seatId = '${letters[rowIdx]}$seatCounter';
      }
    }

    return sorted;
  }
}
