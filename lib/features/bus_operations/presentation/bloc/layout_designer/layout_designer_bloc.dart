// Layout Designer Bloc — canvas state machine
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_component.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'layout_designer_event.dart';
import 'layout_designer_state.dart';

final _uuid = Uuid();

class LayoutDesignerBloc
    extends Bloc<LayoutDesignerEvent, LayoutDesignerState> {
  final ApiService _api = ApiService();

  LayoutDesignerBloc() : super(const LayoutDesignerState()) {
    on<InitDesigner>(_onInit);
    on<ApplyPreset>(_onPreset);
    on<AddComponent>(_onAdd);
    on<SelectComponent>(_onSelect);
    on<UpdateComponent>(_onUpdate);
    on<DeleteComponent>(_onDelete);
    on<SaveLayout>(_onSave);
    on<PublishLayout>(_onPublish);
    on<UpdateCanvasSize>(_onCanvasSize);
    on<ClearDesignerError>(_onClear);
  }

  Future<void> _onInit(
    InitDesigner e,
    Emitter<LayoutDesignerState> emit,
  ) async {
    if (e.layoutId == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      final r = await _api.get('${e.apiPrefix}/absolute-layouts/${e.layoutId}');
      final d = r?['data'];
      // The layout data is stored in current_snapshot (JSON column).
      // Top-level fields (display_name, canvas_width etc.) are separate columns.
      final Map<String, dynamic> snap;
      if (d is Map) {
        final snapshot = d['current_snapshot'];
        if (snapshot is Map) {
          snap = Map<String, dynamic>.from(snapshot as Map);
          // Merge top-level fields so fromSnapshot finds display_name etc.
          snap['display_name'] ??= d['display_name']?.toString();
          snap['layout_status'] ??= d['layout_status']?.toString();
        } else {
          snap = Map<String, dynamic>.from(d as Map);
        }
      } else {
        snap = <String, dynamic>{};
      }
      emit(
        state.copyWith(
          layout: AbsoluteLayoutState.fromSnapshot(snap, layoutId: e.layoutId),
          isLoading: false,
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(isLoading: false, error: 'Failed to load layout: $ex'),
      );
    }
  }

  void _onPreset(ApplyPreset e, Emitter<LayoutDesignerState> emit) {
    final preset = e.preset;
    const double aisleW = 40.0;
    const double rowH = 56.0;
    const double topMargin = 100.0;
    const double leftMargin = 28.0;
    const double seatSpan = 48.0;

    // Calculate row count from canvas height
    final int rows = ((preset.canvasHeight - topMargin - 40) / rowH)
        .round()
        .clamp(1, 30);

    final List<AbsoluteLayoutComponent> newComponents = [];
    int seatCounter = 1;

    // Driver cabin at front center
    final driverX = (preset.canvasWidth - 80) / 2;
    newComponents.add(
      AbsoluteLayoutComponent(
        id: _uuid.v4(),
        type: ComponentType.driverCabin,
        x: driverX,
        y: 16,
        width: 80,
        height: 48,
        bookable: false,
        bookingMode: BookingMode.none,
      ),
    );

    // Generate seat rows — linear S-series numbering (S1, S2, S3...)
    for (int row = 0; row < rows; row++) {
      final y = topMargin + row * rowH;

      // Scan left-to-right: left seats, then right seats
      // Left-side seats
      for (int s = 0; s < preset.leftSeats; s++) {
        final x = leftMargin + s * seatSpan;
        newComponents.add(
          AbsoluteLayoutComponent(
            id: _uuid.v4(),
            type: ComponentType.seat,
            x: x,
            y: y,
            width: 44,
            height: 44,
            seatId: 'S$seatCounter',
            seatNumber: seatCounter,
          ),
        );
        seatCounter++;
      }

      // Right-side seats
      final rightStartX = leftMargin + preset.leftSeats * seatSpan + aisleW;
      for (int s = 0; s < preset.rightSeats; s++) {
        final x = rightStartX + s * seatSpan;
        newComponents.add(
          AbsoluteLayoutComponent(
            id: _uuid.v4(),
            type: ComponentType.seat,
            x: x,
            y: y,
            width: 44,
            height: 44,
            seatId: 'S$seatCounter',
            seatNumber: seatCounter,
          ),
        );
        seatCounter++;
      }
    }

    final layout = state.layout.copyWith(
      canvasWidth: preset.canvasWidth,
      canvasHeight: preset.canvasHeight,
      displayName: preset.label,
      components: newComponents,
      isDirty: true,
      selectedComponentId: null,
    );
    emit(state.copyWith(layout: layout));
  }

  void _onAdd(AddComponent e, Emitter<LayoutDesignerState> emit) {
    final comp = AbsoluteLayoutComponent(
      id: _uuid.v4(),
      type: e.type,
      x: e.x,
      y: e.y,
      width: e.type == ComponentType.driverCabin
          ? 48
          : e.type.name.contains('seat') || e.type.name.contains('sleeper')
          ? 44
          : 80,
      height: e.type == ComponentType.driverCabin
          ? 48
          : e.type.name.contains('seat') || e.type.name.contains('sleeper')
          ? 44
          : 100,
      seatId: e.seatId,
      seatNumber: e.seatNumber,
      berthLabel: e.berthLabel,
    );
    final newComponents = [...state.layout.components, comp];
    emit(
      state.copyWith(
        layout: state.layout.copyWith(
          components: newComponents,
          isDirty: true,
          selectedComponentId: comp.id,
        ),
      ),
    );
  }

  void _onSelect(SelectComponent e, Emitter<LayoutDesignerState> emit) {
    emit(
      state.copyWith(
        layout: state.layout.copyWith(
          selectedComponentId: e.id,
          clearSelection: e.id == null,
        ),
      ),
    );
  }

  void _onUpdate(UpdateComponent e, Emitter<LayoutDesignerState> emit) {
    final newComponents = state.layout.components
        .map((c) => c.id == e.updated.id ? e.updated : c)
        .toList();
    emit(
      state.copyWith(
        layout: state.layout.copyWith(components: newComponents, isDirty: true),
      ),
    );
  }

  void _onDelete(DeleteComponent e, Emitter<LayoutDesignerState> emit) {
    final newComponents = state.layout.components
        .where((c) => c.id != e.id)
        .toList();
    emit(
      state.copyWith(
        layout: state.layout.copyWith(
          components: newComponents,
          isDirty: true,
          selectedComponentId: null,
        ),
      ),
    );
  }

  Future<void> _onSave(SaveLayout e, Emitter<LayoutDesignerState> emit) async {
    emit(
      state.copyWith(
        layout: state.layout.copyWith(isSaving: true, errorMessage: null),
      ),
    );
    try {
      final body = state.layout.toSnapshot();
      if (state.layout.layoutId != null) {
        await _api.put(
          '${e.apiPrefix}/absolute-layouts/${state.layout.layoutId}',
          body: body,
        );
      } else {
        final r = await _api.post(
          '${e.apiPrefix}/absolute-layouts',
          body: body,
        );
        final id = r?['data']?['id']?.toString();
        if (id != null)
          emit(state.copyWith(layout: state.layout.copyWith(layoutId: id)));
      }
      emit(
        state.copyWith(
          layout: state.layout.copyWith(isSaving: false, isDirty: false),
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(
          layout: state.layout.copyWith(
            isSaving: false,
            errorMessage: 'Save failed: $ex',
          ),
        ),
      );
    }
  }

  Future<void> _onPublish(
    PublishLayout e,
    Emitter<LayoutDesignerState> emit,
  ) async {
    if (state.layout.layoutId == null) {
      emit(state.copyWith(error: 'Save layout before publishing'));
      return;
    }
    emit(state.copyWith(layout: state.layout.copyWith(isSaving: true)));
    try {
      await _api.post(
        '${e.apiPrefix}/absolute-layouts/${state.layout.layoutId}/publish',
      );
      emit(
        state.copyWith(
          layout: state.layout.copyWith(isSaving: false, isDirty: false),
        ),
      );
    } catch (ex) {
      emit(
        state.copyWith(
          layout: state.layout.copyWith(
            isSaving: false,
            errorMessage: 'Publish failed: $ex',
          ),
        ),
      );
    }
  }

  void _onCanvasSize(UpdateCanvasSize e, Emitter<LayoutDesignerState> emit) {
    emit(
      state.copyWith(
        layout: state.layout.copyWith(
          canvasWidth: e.width,
          canvasHeight: e.height,
          isDirty: true,
        ),
      ),
    );
  }

  void _onClear(ClearDesignerError e, Emitter<LayoutDesignerState> emit) {
    emit(state.copyWith(error: null, clearError: true));
  }
}
