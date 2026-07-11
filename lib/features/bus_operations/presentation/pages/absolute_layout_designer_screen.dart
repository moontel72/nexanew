// NEXATRACE — ABSOLUTE LAYOUT DESIGNER SCREEN (BLoC-driven)
// Canvas math preserved — state management migrated to LayoutDesignerBloc.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/absolute_canvas_grid.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/absolute_component_palette.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/absolute_inspector_panel.dart';
import 'package:trace_odd/features/bus_operations/presentation/pages/bus_config_setup_screen.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/layout_designer/layout_designer_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/layout_designer/layout_designer_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/layout_designer/layout_designer_state.dart';

enum _CanvasTool { select, placeComponent }

class AbsoluteLayoutDesignerScreen extends StatelessWidget {
  final String companyId, companyName, apiPrefix;
  final String? layoutId;
  final BusConfig? config;

  const AbsoluteLayoutDesignerScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    this.layoutId,
    this.config,
    this.apiPrefix = '/bus-owner',
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        LayoutDesignerBloc()
          ..add(InitDesigner(apiPrefix: apiPrefix, layoutId: layoutId)),
    child: _DesignerBody(
      companyId: companyId,
      companyName: companyName,
      layoutId: layoutId,
      config: config,
      apiPrefix: apiPrefix,
    ),
  );
}

class _DesignerBody extends StatefulWidget {
  final String companyId, companyName, apiPrefix;
  final String? layoutId;
  final BusConfig? config;
  const _DesignerBody({
    required this.companyId,
    required this.companyName,
    this.layoutId,
    this.config,
    required this.apiPrefix,
  });

  @override
  State<_DesignerBody> createState() => _DesignerBodyState();
}

class _DesignerBodyState extends State<_DesignerBody> {
  final TransformationController _transformCtrl = TransformationController();
  _CanvasTool _tool = _CanvasTool.select;
  ComponentType? _placingType;
  bool _sidebarOpen = true;

  @override
  void initState() {
    super.initState();
    // Only auto-generate seat layout for NEW vehicles (no layoutId).
    // When editing an existing layout, the API-loaded data from
    // InitDesigner is authoritative — do NOT overwrite it.
    if (widget.config != null && widget.layoutId == null) {
      _initFromConfig(widget.config!);
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  // ── Helpers to read from BLoC ──
  LayoutDesignerBloc get _bloc => context.read<LayoutDesignerBloc>();
  AbsoluteLayoutState get _state => _bloc.state.layout;

  void _initFromConfig(BusConfig config) {
    final bloc = _bloc;
    final leftSeats = config.leftSeats;
    final rightSeats = config.rightSeats;
    final rows = config.rowCount;
    const double aisleW = 40.0;
    const double rowH = 56.0;
    const double topMargin = 100.0;
    const double leftMargin = 28.0;
    const double seatSpan = 48.0;

    // Auto-size canvas to fit all rows
    final canvasH = topMargin + rows * rowH + 40;
    final canvasW =
        leftMargin +
        leftSeats * seatSpan +
        aisleW +
        rightSeats * seatSpan +
        leftMargin;
    bloc.add(
      UpdateCanvasSize(
        width: canvasW > 200 ? canvasW : 280,
        height: canvasH > 200 ? canvasH : 896,
      ),
    );

    // Place driver cabin at front center
    bloc.add(
      AddComponent(
        type: ComponentType.driverCabin,
        x: (canvasW - 80) / 2,
        y: 16,
      ),
    );

    // Generate seat rows — universal linear S-series (S1, S2, S3...)
    int seatCounter = 1;
    for (int row = 0; row < rows; row++) {
      final y = topMargin + row * rowH;

      // Left-side seats
      for (int s = 0; s < leftSeats; s++) {
        final x = leftMargin + s * seatSpan;
        bloc.add(
          AddComponent(
            type: ComponentType.seat,
            x: x,
            y: y,
            seatId: 'S$seatCounter',
            seatNumber: seatCounter,
          ),
        );
        seatCounter++;
      }

      // Right-side seats
      final rightStartX = leftMargin + leftSeats * seatSpan + aisleW;
      for (int s = 0; s < rightSeats; s++) {
        final x = rightStartX + s * seatSpan;
        bloc.add(
          AddComponent(
            type: ComponentType.seat,
            x: x,
            y: y,
            seatId: 'S$seatCounter',
            seatNumber: seatCounter,
          ),
        );
        seatCounter++;
      }
    }
  }

  void _showUnsavedDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF122442),
        title: const Text(
          'Unsaved Changes',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You have unsaved changes. Save before leaving?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context, true);
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              _bloc.add(SaveLayout(apiPrefix: widget.apiPrefix));
              if (mounted && _bloc.state.error == null)
                Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutDesignerBloc, LayoutDesignerState>(
      builder: (ctx, state) => Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: Row(
                  children: [
                    AbsoluteComponentPalette(
                      onItemSelected: (type, defW, defH, isReverse) {
                        setState(() {
                          _tool = _CanvasTool.placeComponent;
                          _placingType = type;
                        });
                        _bloc.add(const SelectComponent(null));
                      },
                    ),
                    Expanded(child: _buildCanvas()),
                    if (_sidebarOpen) _presetsSidebar(),
                  ],
                ),
              ),
              _statusBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    final cfg = widget.config;
    final title = cfg != null && cfg.numberPlate.isNotEmpty
        ? '${cfg.numberPlate}${cfg.maker.isNotEmpty ? ' | ${cfg.maker}' : ''}'
        : _state.displayName;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white70,
                size: 18,
              ),
              tooltip: 'Back',
              onPressed: () {
                if (_state.isDirty) {
                  _showUnsavedDialog();
                } else {
                  Navigator.pop(context, true);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            ),
            Gap(4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_state.isDirty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'UNSAVED',
                  style: TextStyle(
                    color: Color(0xFFF97316),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Gap(8),
            _btn(Icons.near_me, 'Select', _tool == _CanvasTool.select, () {
              setState(() {
                _tool = _CanvasTool.select;
                _placingType = null;
              });
              _bloc.add(const SelectComponent(null));
            }),
            _btn(
              Icons.add_location_alt,
              'Place',
              _tool == _CanvasTool.placeComponent,
              () {
                if (_placingType == null && mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pick a part from the left palette first'),
                      backgroundColor: Color(0xFFD97706),
                      duration: Duration(seconds: 2),
                    ),
                  );
                setState(() => _tool = _CanvasTool.placeComponent);
              },
            ),
            _btn(
              _sidebarOpen ? Icons.menu_open : Icons.menu,
              'Presets',
              _sidebarOpen,
              () => setState(() => _sidebarOpen = !_sidebarOpen),
            ),
            Gap(8),
            ElevatedButton.icon(
              onPressed: _state.isSaving
                  ? null
                  : () => _bloc.add(SaveLayout(apiPrefix: widget.apiPrefix)),
              icon: _state.isSaving
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 14),
              label: Text(
                _state.layoutId == null ? 'Save & Publish' : 'Save',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Gap(4),
            ElevatedButton.icon(
              onPressed: _state.isSaving || _state.layoutId == null
                  ? null
                  : () => _bloc.add(PublishLayout(apiPrefix: widget.apiPrefix)),
              icon: _state.isSaving
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload, size: 14),
              label: const Text(
                'Publish',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, bool active, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(left: 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF7C3AED).withOpacity(0.2) : null,
              borderRadius: BorderRadius.circular(4),
              border: active
                  ? Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: active ? const Color(0xFF7C3AED) : Colors.white54,
                ),
                Gap(3),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? const Color(0xFF7C3AED) : Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildCanvas() => Stack(
    clipBehavior: Clip.none,
    children: [
      AbsoluteCanvasGrid(
        layoutState: _state,
        transformController: _transformCtrl,
        onComponentTap: (id, x, y) {
          if (_tool == _CanvasTool.select) {
            _bloc.add(SelectComponent(id));
          } else if (_tool == _CanvasTool.placeComponent &&
              _placingType != null) {
            _bloc.add(AddComponent(type: _placingType!, x: x, y: y));
            setState(() {
              _tool = _CanvasTool.select;
              _placingType = null;
            });
          }
        },
        onCanvasTap: (x, y) {
          if (_tool == _CanvasTool.placeComponent && _placingType != null) {
            _bloc.add(AddComponent(type: _placingType!, x: x, y: y));
            setState(() {
              _tool = _CanvasTool.select;
              _placingType = null;
            });
          } else if (_tool == _CanvasTool.select) {
            _bloc.add(const SelectComponent(null));
          }
        },
        onOverlayResize: (w, h, x, y) {
          final sel = _state.selectedComponent;
          if (sel != null)
            _bloc.add(
              UpdateComponent(
                sel.copyWith(
                  x: x,
                  y: y,
                  width: w.toDouble(),
                  height: h.toDouble(),
                ),
              ),
            );
        },
        onOverlayMove: (x, y) {
          final sel = _state.selectedComponent;
          if (sel != null) _bloc.add(UpdateComponent(sel.copyWith(x: x, y: y)));
        },
        onOverlayRotate: (r) {
          final sel = _state.selectedComponent;
          if (sel != null)
            _bloc.add(UpdateComponent(sel.copyWith(rotation: r)));
        },
        onOverlayDelete: () {
          final sel = _state.selectedComponent;
          if (sel != null) _bloc.add(DeleteComponent(sel.id));
        },
        onOverlayTap: () {
          // Tapping the selected component again dismisses the overlay.
          _bloc.add(const SelectComponent(null));
        },
        onOverlayClose: () {
          // Explicit "X" close button on the transform overlay.
          _bloc.add(const SelectComponent(null));
        },
      ),
      if (_state.selectedComponent != null)
        Positioned(
          top: 8,
          right: 8,
          width: 280,
          child: AbsoluteInspectorPanel(
            component: _state.selectedComponent!,
            onApply: (u) {
              _bloc.add(UpdateComponent(u));
              _bloc.add(const SelectComponent(null));
            },
            onDelete: () =>
                _bloc.add(DeleteComponent(_state.selectedComponent!.id)),
            onClose: () => _bloc.add(const SelectComponent(null)),
          ),
        ),
      if (_tool == _CanvasTool.placeComponent && _placingType != null)
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Tap canvas to place ${_placingType!.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      if (_state.errorMessage != null)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: MaterialBanner(
            backgroundColor: const Color(0xFFDC2626),
            content: Text(
              _state.errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            actions: [
              TextButton(
                onPressed: () => _bloc.add(const ClearDesignerError()),
                child: const Text(
                  'DISMISS',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _presetsSidebar() => Container(
    width: 200,
    decoration: const BoxDecoration(
      color: Color(0xFF0A1628),
      border: Border(left: BorderSide(color: Color(0x20FFFFFF))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x20FFFFFF))),
          ),
          child: const Text(
            'PRESETS',
            style: TextStyle(
              color: Color(0x80FFFFFF),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final p in AbsoluteLayoutPreset.builtIn) _presetCard(p),
              Gap(8),
              const Divider(color: Color(0x20FFFFFF)),
              Gap(8),
              InkWell(
                onTap: () {
                  _bloc.add(ApplyPreset(AbsoluteLayoutPreset.builtIn[0]));
                  _bloc.add(const UpdateCanvasSize(width: 280, height: 896));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x30FFFFFF)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.white54,
                        size: 16,
                      ),
                      Gap(6),
                      Text(
                        'Clear Canvas',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(4),
              const Text(
                'CANVAS SIZE (ft/in)',
                style: TextStyle(
                  color: Color(0x60FFFFFF),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Gap(2),
              Text(
                'W: ${pxToFtIn(_state.canvasWidth)} · H: ${pxToFtIn(_state.canvasHeight)}',
                style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 9),
              ),
              Gap(6),
              Row(
                children: [
                  Expanded(
                    child: _SizeField(
                      label: 'Width (px)',
                      initialValue: _state.canvasWidth.toInt().toString(),
                      onChanged: (s) {
                        final v = double.tryParse(s);
                        if (v != null)
                          _bloc.add(
                            UpdateCanvasSize(
                              width: v.clamp(100, 2000),
                              height: _state.canvasHeight,
                            ),
                          );
                      },
                    ),
                  ),
                  Gap(8),
                  Expanded(
                    child: _SizeField(
                      label: 'Height (px)',
                      initialValue: _state.canvasHeight.toInt().toString(),
                      onChanged: (s) {
                        final v = double.tryParse(s);
                        if (v != null)
                          _bloc.add(
                            UpdateCanvasSize(
                              width: _state.canvasWidth,
                              height: v.clamp(100, 3000),
                            ),
                          );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _presetCard(AbsoluteLayoutPreset p) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: InkWell(
      onTap: () => _bloc.add(ApplyPreset(p)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x20FFFFFF)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(4),
            Text(
              '${pxToFtIn(p.canvasWidth)} × ${pxToFtIn(p.canvasHeight)} · ${p.leftSeats + p.rightSeats}-abreast',
              style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 10),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _statusBar() {
    final sel = _state.selectedComponent;
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        border: Border(top: BorderSide(color: Color(0x20FFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.grid_view, color: Colors.white38, size: 12),
          Gap(4),
          Text(
            '${_state.components.length} parts',
            style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
          ),
          Gap(12),
          Icon(Icons.event_seat, color: const Color(0xFF7C3AED), size: 12),
          Gap(4),
          Text(
            '${_state.totalSeats} seats',
            style: const TextStyle(color: Color(0x60FFFFFF), fontSize: 11),
          ),
          const Spacer(),
          if (sel != null) ...[
            Icon(sel.defaultIcon, color: sel.defaultColor, size: 12),
            Gap(4),
            Text(
              sel.typeLabel,
              style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 11),
            ),
            Gap(8),
          ],
          Text(
            'Canvas ${pxToFtIn(_state.canvasWidth)} × ${pxToFtIn(_state.canvasHeight)}',
            style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SizeField extends StatefulWidget {
  final String label, initialValue;
  final ValueChanged<String> onChanged;
  const _SizeField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });
  @override
  State<_SizeField> createState() => _SizeFieldState();
}

class _SizeFieldState extends State<_SizeField> {
  late final TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _ctrl,
    style: const TextStyle(color: Colors.white, fontSize: 11),
    decoration: InputDecoration(
      labelText: widget.label,
      labelStyle: const TextStyle(color: Color(0x60FFFFFF), fontSize: 10),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0x30FFFFFF)),
      ),
    ),
    keyboardType: TextInputType.number,
    onChanged: widget.onChanged,
  );
}
