// NEXATRACE — ABSOLUTE LAYOUT STATE
// ====================================
// Immutable state holder for the absolute (freeform) bus layout designer.
// Holds the complete component graph and canvas metadata.
//
// 100% isolated from the legacy grid-based LayoutCanvasState.

import 'absolute_layout_component.dart';
import 'component_registry.dart';

// ═══════════════════════════════════════════════════════════
// UNIT CONVERSION
// ═══════════════════════════════════════════════════════════
// Backward-compatible re‑export: kPixelsPerInch now lives in
// dimensional_constants.dart as the single source of truth.
export 'dimensional_constants.dart' show kPixelsPerInch;

/// Scale ratio: 1 inch = 4 logical pixels.
/// This means 48 px = 1 foot (12 inches × 4 px/inch).
/// Actual canvas dimensions are now driven by [BusDimensions]
/// and scaled dynamically per vehicle preset.
/// @Deprecated('Use kPixelsPerInch from dimensional_constants.dart')
const double kPixelsPerInch = 4.0;

/// Convert logical pixels to a human-readable feet+inches string.
/// e.g. pxToFtIn(280) → "5' 10\""
String pxToFtIn(double pixels) {
  final totalInches = (pixels / kPixelsPerInch).round();
  final feet = totalInches ~/ 12;
  final inches = totalInches % 12;
  if (feet > 0 && inches > 0) {
    return "$feet' $inches\"";
  } else if (feet > 0) {
    return "$feet'";
  } else {
    return '$inches"';
  }
}

/// Convert logical pixels to inches string.
/// e.g. pxToInches(56) → "14.0 in"
String pxToInches(double pixels) {
  return '${(pixels / kPixelsPerInch).toStringAsFixed(1)} in';
}

/// Vehicle class presets for the absolute canvas.
class AbsoluteLayoutPreset {
  final String key;
  final String label;
  final double canvasWidth;
  final double canvasHeight;
  final int leftSeats; // for auto-generating default seat rows
  final int rightSeats;
  final int driverSeats;
  final String deckType;

  const AbsoluteLayoutPreset({
    required this.key,
    required this.label,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.leftSeats,
    required this.rightSeats,
    required this.driverSeats,
    required this.deckType,
  });

  static const List<AbsoluteLayoutPreset> builtIn = [
    AbsoluteLayoutPreset(
      key: 'coach_54',
      label: '54-Seat Coach (Large)',
      canvasWidth: 280,
      canvasHeight: 896,
      leftSeats: 2,
      rightSeats: 2,
      driverSeats: 1,
      deckType: 'single',
    ),
    AbsoluteLayoutPreset(
      key: 'standard_45',
      label: '45-Seat Standard Coach',
      canvasWidth: 280,
      canvasHeight: 728,
      leftSeats: 2,
      rightSeats: 2,
      driverSeats: 1,
      deckType: 'single',
    ),
    AbsoluteLayoutPreset(
      key: 'coaster_34',
      label: '34-Seat Coaster',
      canvasWidth: 224,
      canvasHeight: 616,
      leftSeats: 2,
      rightSeats: 2,
      driverSeats: 1,
      deckType: 'single',
    ),
    AbsoluteLayoutPreset(
      key: 'hiace_13',
      label: '13-Seat HiAce',
      canvasWidth: 168,
      canvasHeight: 336,
      leftSeats: 2,
      rightSeats: 1,
      driverSeats: 1,
      deckType: 'single',
    ),
    AbsoluteLayoutPreset(
      key: 'vip_sleeper_40',
      label: '40-Seat VIP + Sleeper (5\'1" × 18\'8")',
      canvasWidth: 244,
      canvasHeight: 896,
      leftSeats: 2,
      rightSeats: 2,
      driverSeats: 1,
      deckType: 'single',
    ),
  ];
}

class AbsoluteLayoutState {
  final String? layoutId;
  final String deckLevel;
  final double canvasWidth;
  final double canvasHeight;
  final String displayName;
  final List<AbsoluteLayoutComponent> components;
  final Map<String, dynamic> metadata;
  final bool isDirty;
  final bool isSaving;
  final String? errorMessage;
  final String? selectedComponentId;
  final ComponentRegistry? registry;

  const AbsoluteLayoutState({
    this.layoutId,
    this.deckLevel = 'lower',
    this.canvasWidth = 280.0,
    this.canvasHeight = 896.0,
    this.displayName = 'Untitled Layout',
    this.components = const [],
    this.metadata = const {},
    this.isDirty = false,
    this.isSaving = false,
    this.errorMessage,
    this.selectedComponentId,
    this.registry,
  });

  /// Total number of ticketable seats.
  int get totalSeats =>
      components.where((c) => c.bookable && !c.isStructural).length;

  /// Find a component by ID.
  AbsoluteLayoutComponent? componentById(String id) {
    try {
      return components.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get the currently selected component.
  AbsoluteLayoutComponent? get selectedComponent =>
      selectedComponentId != null ? componentById(selectedComponentId!) : null;

  /// Find the topmost component at a given canvas point.
  AbsoluteLayoutComponent? componentAt(double x, double y) {
    // Iterate in reverse (topmost last) for correct z-order hit-testing
    for (int i = components.length - 1; i >= 0; i--) {
      if (components[i].containsPoint(x, y)) return components[i];
    }
    return null;
  }

  /// Check for collision between a proposed rect and existing components.
  bool hasCollision(
    double x,
    double y,
    double w,
    double h, {
    String? excludeId,
  }) {
    for (final c in components) {
      if (c.id == excludeId) continue;
      // Simple AABB collision (ignore rotation for speed)
      if (x < c.x + c.width &&
          x + w > c.x &&
          y < c.y + c.height &&
          y + h > c.y) {
        return true;
      }
    }
    return false;
  }

  /// Serialize to a publishable snapshot.
  Map<String, dynamic> toSnapshot() => {
    'canvas': {
      'canvas_width': canvasWidth,
      'canvas_height': canvasHeight,
      'deck_level': deckLevel,
    },
    'display_name': displayName,
    'components': components.map((c) => c.toJson()).toList(),
    'metadata': {...metadata, 'total_bookable_seats': totalSeats},
  };

  /// Parse from a backend snapshot.
  /// All nested casts are defensive to survive legacy / malformed snapshot data
  /// that may arrive as String, List, or other non-Map types.
  factory AbsoluteLayoutState.fromSnapshot(
    Map<String, dynamic> snap, {
    String? layoutId,
  }) {
    // ── Safe canvas extraction ──
    Map<String, dynamic>? canvas;
    final rawCanvas = snap['canvas'];
    if (rawCanvas is Map<String, dynamic>) {
      canvas = rawCanvas;
    } else if (rawCanvas is Map) {
      canvas = rawCanvas.cast<String, dynamic>();
    }

    // ── Safe metadata extraction ──
    Map<String, dynamic> metadata;
    final rawMeta = snap['metadata'];
    if (rawMeta is Map<String, dynamic>) {
      metadata = rawMeta;
    } else if (rawMeta is Map) {
      metadata = rawMeta.cast<String, dynamic>();
    } else {
      metadata = <String, dynamic>{};
    }

    // ── Safe components extraction ──
    final compsJson = snap['components'];
    final List<dynamic> compsList;
    if (compsJson is List) {
      compsList = compsJson;
    } else {
      compsList = <dynamic>[];
    }

    final components = <AbsoluteLayoutComponent>[];
    for (final j in compsList) {
      if (j is Map) {
        try {
          components.add(
            AbsoluteLayoutComponent.fromJson(
              j is Map<String, dynamic> ? j : j.cast<String, dynamic>(),
            ),
          );
        } catch (_) {
          // Skip one malformed component — don't lose the whole layout
        }
      }
    }

    return AbsoluteLayoutState(
      layoutId: layoutId,
      deckLevel: canvas?['deck_level'] as String? ?? 'lower',
      canvasWidth: (canvas?['canvas_width'] as num?)?.toDouble() ?? 280.0,
      canvasHeight: (canvas?['canvas_height'] as num?)?.toDouble() ?? 896.0,
      displayName: snap['display_name'] as String? ?? 'Untitled Layout',
      components: components,
      metadata: metadata,
    );
  }

  /// Create a copy with overrides.
  AbsoluteLayoutState copyWith({
    String? layoutId,
    String? deckLevel,
    double? canvasWidth,
    double? canvasHeight,
    String? displayName,
    List<AbsoluteLayoutComponent>? components,
    Map<String, dynamic>? metadata,
    bool? isDirty,
    bool? isSaving,
    String? errorMessage,
    String? selectedComponentId,
    ComponentRegistry? registry,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return AbsoluteLayoutState(
      layoutId: layoutId ?? this.layoutId,
      deckLevel: deckLevel ?? this.deckLevel,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      displayName: displayName ?? this.displayName,
      components: components ?? this.components,
      metadata: metadata ?? this.metadata,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedComponentId: clearSelection
          ? null
          : (selectedComponentId ?? this.selectedComponentId),
      registry: registry ?? this.registry,
    );
  }
}
