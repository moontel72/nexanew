// NEXATRACE — LAYOUT VALIDATION BLOC
// ===================================
// Reactive spatial coordinator that merges dimension, registry,
// and seat‑matrix changes and runs the LayoutValidator pipeline.

import 'package:bloc/bloc.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_event.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_validation_state.dart';
import 'package:trace_odd/shared/models/transport/layout_validator.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/feet_inches.dart';

class LayoutValidationBloc
    extends Bloc<LayoutValidationEvent, LayoutValidationState> {
  LayoutValidationBloc() : super(const LayoutValidationState()) {
    on<DimensionsChanged>(_onDimensions);
    on<RegistryChanged>(_onRegistry);
    on<SeatMatrixChanged>(_onMatrix);
  }

  void _onDimensions(DimensionsChanged e, Emitter<LayoutValidationState> emit) {
    emit(state.copyWith(dimensions: e.dimensions));
    _validate(emit);
  }

  void _onRegistry(RegistryChanged e, Emitter<LayoutValidationState> emit) {
    emit(state.copyWith(registry: e.registry));
    _validate(emit);
  }

  void _onMatrix(SeatMatrixChanged e, Emitter<LayoutValidationState> emit) {
    emit(
      state.copyWith(
        rows: e.rows,
        leftSeats: e.leftSeats,
        rightSeats: e.rightSeats,
      ),
    );
    _validate(emit);
  }

  /// Merge parameters and run the full validation pipeline.
  void _validate(Emitter<LayoutValidationState> emit) {
    final bool isFaceToFace =
        state.registry.parts.containsKey(SeatPartType.table) &&
        (state.registry.parts.containsKey(SeatPartType.reverseSeat) ||
            state.registry.parts.containsKey(SeatPartType.businessReverseSeat));

    final FeetInches predictedLength;
    if (isFaceToFace && state.rows > 0) {
      final pairCount = state.rows ~/ 2;
      predictedLength =
          state.registry.maxPartLength * state.rows +
          state.registry.faceToFaceGap * pairCount;
    } else {
      predictedLength = LayoutValidator.calculateRequiredLength(
        rows: state.rows,
        partLength: state.registry.maxPartLength,
        interSeatGap: state.registry.interSeatGap,
      );
    }
    final predictedWidth = LayoutValidator.calculateRequiredWidth(
      leftSeats: state.leftSeats,
      rightSeats: state.rightSeats,
      partWidth: state.registry.maxPartWidth,
      aisleWidth: state.registry.aisleWidth,
    );

    final result = LayoutValidator.validateAll(
      dimensions: state.dimensions,
      registry: state.registry,
      rows: state.rows,
      leftSeats: state.leftSeats,
      rightSeats: state.rightSeats,
    );

    emit(
      state.copyWith(
        lastResult: result,
        predictedLength: predictedLength,
        predictedWidth: predictedWidth,
      ),
    );
  }
}
