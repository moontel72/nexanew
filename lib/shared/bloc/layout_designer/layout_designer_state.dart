// Layout Designer State — wraps AbsoluteLayoutState
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';

class LayoutDesignerState extends Equatable {
  final AbsoluteLayoutState layout;
  final bool isLoading;
  final String? error;

  const LayoutDesignerState({
    this.layout = const AbsoluteLayoutState(),
    this.isLoading = false,
    this.error,
  });

  LayoutDesignerState copyWith({
    AbsoluteLayoutState? layout,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => LayoutDesignerState(
    layout: layout ?? this.layout,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );

  // ── Convenience getters (delegate to layout) ──
  AbsoluteLayoutComponent? get selectedComponent => layout.selectedComponent;

  @override
  List<Object?> get props => [layout, isLoading, error];
}
