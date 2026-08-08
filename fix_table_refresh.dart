import 'dart:io';

void main() {
  final path = 'lib/shared/bloc/layout_designer/layout_designer_bloc.dart';
  var c = File(path).readAsStringSync();

  final oldMethod = '  void _onSetRegistry(SetLayoutRegistry e, Emitter<LayoutDesignerState> emit) {\n'
      '    emit(state.copyWith(layout: state.layout.copyWith(registry: e.registry)));\n'
      '  }';

  final newMethod = '  void _onSetRegistry(SetLayoutRegistry e, Emitter<LayoutDesignerState> emit) {\n'
      '    final newReg = e.registry;\n'
      '    final tableSpec = newReg.parts[SeatPartType.table];\n'
      '    var comps = state.layout.components;\n'
      '    if (tableSpec != null) {\n'
      '      // Use smaller dim as depth (between rows), larger as span (across seats).\n'
      '      final tDepth = tableSpec.pixelWidth < tableSpec.pixelLength\n'
      '          ? tableSpec.pixelWidth\n'
      '          : tableSpec.pixelLength;\n'
      '      final tSpan = tableSpec.pixelWidth > tableSpec.pixelLength\n'
      '          ? tableSpec.pixelWidth\n'
      '          : tableSpec.pixelLength;\n'
      '      comps = comps.map((c) {\n'
      '        if (c.type == ComponentType.restaurantTable) {\n'
      '          return c.copyWith(width: tSpan, height: tDepth);\n'
      '        }\n'
      '        return c;\n'
      '      }).toList();\n'
      '    }\n'
      '    emit(state.copyWith(\n'
      '        layout: state.layout.copyWith(\n'
      '            registry: newReg, components: comps, isDirty: true)));\n'
      '  }';

  if (c.contains(oldMethod)) {
    c = c.replaceFirst(oldMethod, newMethod);
    File(path).writeAsStringSync(c);
    print('FIX OK: _onSetRegistry now refreshes table dimensions');
  } else {
    print('FIX SKIP: pattern not found');
  }
}
