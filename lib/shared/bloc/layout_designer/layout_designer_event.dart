// NEXATRACE — LAYOUT DESIGNER EVENTS
// ====================================

import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';

abstract class LayoutDesignerEvent extends Equatable {
  const LayoutDesignerEvent();
  @override
  List<Object?> get props => [];
}

class InitDesigner extends LayoutDesignerEvent {
  final String apiPrefix;
  final String? layoutId;
  final bool cloneFromTemplate;
  const InitDesigner({
    required this.apiPrefix,
    this.layoutId,
    this.cloneFromTemplate = false,
  });
  @override
  List<Object?> get props => [apiPrefix, layoutId, cloneFromTemplate];
}

class ApplyPreset extends LayoutDesignerEvent {
  final AbsoluteLayoutPreset preset;
  const ApplyPreset(this.preset);
  @override
  List<Object?> get props => [preset];
}

class AddComponent extends LayoutDesignerEvent {
  final ComponentType type;
  final double x, y;
  final String? seatId;
  final int? seatNumber;
  final String? berthLabel;
  final double? width;
  final double? height;
  final bool isReverseFacing;
  const AddComponent({
    required this.type,
    required this.x,
    required this.y,
    this.seatId,
    this.seatNumber,
    this.berthLabel,
    this.width,
    this.height,
    this.isReverseFacing = false,
  });
  @override
  List<Object?> get props => [
    type,
    x,
    y,
    seatId,
    seatNumber,
    berthLabel,
    width,
    height,
    isReverseFacing,
  ];
}

class SelectComponent extends LayoutDesignerEvent {
  final String? id;
  const SelectComponent(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateComponent extends LayoutDesignerEvent {
  final AbsoluteLayoutComponent updated;
  const UpdateComponent(this.updated);
  @override
  List<Object?> get props => [updated];
}

class DeleteComponent extends LayoutDesignerEvent {
  final String id;
  const DeleteComponent(this.id);
  @override
  List<Object?> get props => [id];
}

class SaveLayout extends LayoutDesignerEvent {
  final String apiPrefix;
  const SaveLayout({required this.apiPrefix});
  @override
  List<Object?> get props => [apiPrefix];
}

class PublishLayout extends LayoutDesignerEvent {
  final String apiPrefix;
  const PublishLayout({required this.apiPrefix});
  @override
  List<Object?> get props => [apiPrefix];
}

class UpdateCanvasSize extends LayoutDesignerEvent {
  final double width, height;
  const UpdateCanvasSize({required this.width, required this.height});
  @override
  List<Object?> get props => [width, height];
}

class ClearDesignerError extends LayoutDesignerEvent {
  const ClearDesignerError();
}

class SetLayoutDisplayName extends LayoutDesignerEvent {
  final String name;
  const SetLayoutDisplayName(this.name);
  @override
  List<Object?> get props => [name];
}

class SetLayoutRegistry extends LayoutDesignerEvent {
  final ComponentRegistry registry;
  const SetLayoutRegistry(this.registry);
  @override
  List<Object?> get props => [registry];
}

class SetLayoutMetadata extends LayoutDesignerEvent {
  final String key;
  final dynamic value;
  const SetLayoutMetadata(this.key, this.value);
  @override
  List<Object?> get props => [key, value];
}
