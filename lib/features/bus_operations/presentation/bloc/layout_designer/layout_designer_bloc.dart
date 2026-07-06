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
      Map<String, dynamic> snap = {};
      if (d is Map<String, dynamic>) snap = d;
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
    final layout = state.layout.copyWith(
      canvasWidth: e.preset.canvasWidth,
      canvasHeight: e.preset.canvasHeight,
      components: [],
      isDirty: true,
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
          : e.type.name.contains('seat')
          ? 44
          : 80,
      height: e.type == ComponentType.driverCabin
          ? 48
          : e.type.name.contains('seat')
          ? 44
          : 100,
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
      state.copyWith(layout: state.layout.copyWith(selectedComponentId: e.id)),
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
