// NEXATRACE — LAYOUT CANVAS BLOC STATE
// ======================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/bus_operations/domain/models/layout_canvas_state.dart';

enum CanvasStatus {
  initial,
  loading,
  loaded,
  modified,
  publishing,
  published,
  error,
}

class LayoutCanvasBlocState {
  final CanvasStatus status;
  final LayoutCanvasState? lowerCanvas;
  final LayoutCanvasState? upperCanvas;
  final String activeDeck; // 'lower' | 'upper'
  final String? error;
  final String? layoutId;
  final String? displayName;
  final int versionNumber;
  final bool hasEditLock;
  final String? selectedPresetKey;

  const LayoutCanvasBlocState({
    this.status = CanvasStatus.initial,
    this.lowerCanvas,
    this.upperCanvas,
    this.activeDeck = 'lower',
    this.error,
    this.layoutId,
    this.displayName,
    this.versionNumber = 1,
    this.hasEditLock = false,
    this.selectedPresetKey,
  });

  /// The currently active canvas state.
  LayoutCanvasState? get activeCanvas =>
      activeDeck == 'lower' ? lowerCanvas : upperCanvas;

  /// Whether a canvas has been initialized.
  bool get isCanvasReady => activeCanvas != null;

  /// Whether there are unsaved changes.
  bool get isDirty =>
      (lowerCanvas?.isDirty ?? false) || (upperCanvas?.isDirty ?? false);

  /// Total seats across both decks.
  int get totalSeats =>
      (lowerCanvas?.totalSeats ?? 0) + (upperCanvas?.totalSeats ?? 0);

  /// Total sleeper berths across both decks.
  int get sleeperBerths =>
      (lowerCanvas?.sleeperBerths ?? 0) + (upperCanvas?.sleeperBerths ?? 0);

  /// Total bookable units across both decks.
  int get bookableUnits => totalSeats;

  LayoutCanvasBlocState copyWith({
    CanvasStatus? status,
    LayoutCanvasState? lowerCanvas,
    LayoutCanvasState? upperCanvas,
    String? activeDeck,
    String? error,
    String? layoutId,
    String? displayName,
    int? versionNumber,
    bool? hasEditLock,
    String? selectedPresetKey,
  }) => LayoutCanvasBlocState(
    status: status ?? this.status,
    lowerCanvas: lowerCanvas ?? this.lowerCanvas,
    upperCanvas: upperCanvas ?? this.upperCanvas,
    activeDeck: activeDeck ?? this.activeDeck,
    error: error,
    layoutId: layoutId ?? this.layoutId,
    displayName: displayName ?? this.displayName,
    versionNumber: versionNumber ?? this.versionNumber,
    hasEditLock: hasEditLock ?? this.hasEditLock,
    selectedPresetKey: selectedPresetKey ?? this.selectedPresetKey,
  );
}
