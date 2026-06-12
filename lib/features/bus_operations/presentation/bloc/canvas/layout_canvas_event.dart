// NEXATRACE — LAYOUT CANVAS BLOC EVENTS
// ========================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';

sealed class LayoutCanvasEvent {
  const LayoutCanvasEvent();
}

/// User selected a vehicle-class preset from the sidebar.
class PresetSelected extends LayoutCanvasEvent {
  final String presetKey;
  const PresetSelected(this.presetKey);
}

/// User dropped a component from the palette onto the canvas.
class ComponentDropped extends LayoutCanvasEvent {
  final ComponentType type;
  final int originRow;
  final int originCol;
  const ComponentDropped({
    required this.type,
    required this.originRow,
    required this.originCol,
  });
}

/// User dragged an existing component to a new position.
class ComponentMoved extends LayoutCanvasEvent {
  final String componentId;
  final int newOriginRow;
  final int newOriginCol;
  const ComponentMoved({
    required this.componentId,
    required this.newOriginRow,
    required this.newOriginCol,
  });
}

/// User resized a multi-cell component.
class ComponentResized extends LayoutCanvasEvent {
  final String componentId;
  final int newSpanRows;
  final int newSpanCols;
  const ComponentResized({
    required this.componentId,
    required this.newSpanRows,
    required this.newSpanCols,
  });
}

/// User updated a component's properties via the inspector.
class ComponentUpdated extends LayoutCanvasEvent {
  final String componentId;
  final LayoutComponent updated;
  const ComponentUpdated({required this.componentId, required this.updated});
}

/// User deleted a component from the canvas.
class ComponentDeleted extends LayoutCanvasEvent {
  final String componentId;
  const ComponentDeleted(this.componentId);
}

/// User switched decks (lower / upper).
class DeckSwitched extends LayoutCanvasEvent {
  final String deck; // 'lower' | 'upper'
  const DeckSwitched(this.deck);
}

/// User requested publish.
class PublishRequested extends LayoutCanvasEvent {
  final int expectedVersion;
  final String? changeDescription;
  const PublishRequested({
    required this.expectedVersion,
    this.changeDescription,
  });
}

/// Load an existing layout from the backend.
class LayoutLoaded extends LayoutCanvasEvent {
  final String layoutId;
  const LayoutLoaded(this.layoutId);
}

/// Refresh component numbering (triggered after bulk operations).
class RenumberRequested extends LayoutCanvasEvent {
  const RenumberRequested();
}

/// Convert 3 consecutive rows into a Business Class 2+1 luxury zone.
class BusinessClassZoneRequested extends LayoutCanvasEvent {
  final int startRow;
  final int leftCols;
  final int rightCols;
  const BusinessClassZoneRequested({
    required this.startRow,
    required this.leftCols,
    required this.rightCols,
  });
}
