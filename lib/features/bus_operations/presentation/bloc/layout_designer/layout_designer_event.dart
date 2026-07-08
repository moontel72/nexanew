// Layout Designer Events
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';

abstract class LayoutDesignerEvent extends Equatable {
  const LayoutDesignerEvent();
  @override
  List<Object?> get props => [];
}

class InitDesigner extends LayoutDesignerEvent {
  final String apiPrefix;
  final String? layoutId;
  const InitDesigner({required this.apiPrefix, this.layoutId});
  @override
  List<Object?> get props => [apiPrefix, layoutId];
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
  const AddComponent({
    required this.type,
    required this.x,
    required this.y,
    this.seatId,
    this.seatNumber,
    this.berthLabel,
  });
  @override
  List<Object?> get props => [type, x, y, seatId, seatNumber, berthLabel];
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
