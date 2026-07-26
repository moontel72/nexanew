// NEXATRACE — ABSOLUTE LAYOUT DESIGNER SCREEN (BLoC-driven)
// Canvas math preserved — state management migrated to LayoutDesignerBloc.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/models/transport/absolute_layout_state.dart';
import 'package:trace_odd/shared/models/transport/layout_component.dart';
import 'package:trace_odd/shared/widgets/layout_designer/absolute_canvas_grid.dart';
import 'package:trace_odd/shared/widgets/layout_designer/absolute_component_palette.dart';
import 'package:trace_odd/shared/widgets/layout_designer/absolute_inspector_panel.dart';
import 'package:trace_odd/shared/models/transport/bus_dimensions.dart';
import 'package:trace_odd/shared/models/transport/component_registry.dart';
import 'package:trace_odd/shared/models/transport/dimensional_constants.dart';
import 'package:trace_odd/shared/widgets/layout_designer/bus_config_setup_screen.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_designer_bloc.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_designer_event.dart';
import 'package:trace_odd/shared/bloc/layout_designer/layout_designer_state.dart';

enum _CanvasTool { select, placeComponent }

class AbsoluteLayoutDesignerScreen extends StatelessWidget {
  final String companyId, companyName, apiPrefix;
  final String? layoutId;
  final BusConfig? config;
  final bool cloneFromTemplate;
  final BusDimensions? busDimensions;
  final ComponentRegistry? registry;

  const AbsoluteLayoutDesignerScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    this.layoutId,
    this.config,
    this.apiPrefix = '/bus-owner',
    this.cloneFromTemplate = false,
    this.busDimensions,
    this.registry,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => LayoutDesignerBloc()
      ..add(
        InitDesigner(
          apiPrefix: apiPrefix,
          layoutId: layoutId,
          cloneFromTemplate: cloneFromTemplate,
        ),
      ),
    child: _DesignerBody(
      companyId: companyId,
      companyName: companyName,
      layoutId: layoutId,
      config: config,
      apiPrefix: apiPrefix,
      cloneFromTemplate: cloneFromTemplate,
      busDimensions: busDimensions,
      registry: registry,
    ),
  );
}

class _DesignerBody extends StatefulWidget {
  final String companyId, companyName, apiPrefix;
  final String? layoutId;
  final BusConfig? config;
  final bool cloneFromTemplate;
  final BusDimensions? busDimensions;
  final ComponentRegistry? registry;
  const _DesignerBody({
    required this.companyId,
    required this.companyName,
    this.layoutId,
    this.config,
    required this.apiPrefix,
    this.cloneFromTemplate = false,
    this.busDimensions,
    this.registry,
  });

  @override
  State<_DesignerBody> createState() => _DesignerBodyState();
}

class _DesignerBodyState extends State<_DesignerBody> {
  final TransformationController _transformCtrl = TransformationController();
  _CanvasTool _tool = _CanvasTool.select;
  ComponentType? _placingType;
  bool _placingIsReverse = false;
  double _placingWidth = 56.0;
  double _placingHeight = 56.0;
  bool _wasSaving = false;
  bool _wasPublishing = false;
  StreamSubscription? _loadSub;

  @override
  void initState() {
    super.initState();
    // Auto-generate seat layout for NEW vehicles (no layoutId)
    // OR when cloning a preset template — the config carries the
    // vehicle identity (plate + maker) that must override the
    // template's display_name.
    if (widget.config != null &&
        (widget.layoutId == null || widget.cloneFromTemplate)) {
      _initFromConfig(widget.config!);
    }
    // ── Apply config name + registry AFTER server load completes ──
    // InitDesigner loads the old snapshot asynchronously.  We must
    // overwrite with the user's latest values from the setup screen
    // only AFTER that load finishes (isLoading → false).
    if (widget.config != null || widget.registry != null) {
      bool loadStarted = false;
      _loadSub = _bloc.stream.listen((s) {
        if (s.isLoading) loadStarted = true;
        if (!s.isLoading && loadStarted && mounted) {
          _loadSub?.cancel();
          _applyConfigData();
        }
      });
    }
    // Post-frame: verify the canvas size matches BusDimensions.
    if (widget.busDimensions != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final actualH = _state.canvasHeight;
        final expectedH = widget.busDimensions!.lengthPx;
        if ((actualH - expectedH).abs() > 1.0) {
          debugPrint(
            'MISMATCH: canvasHeight=$actualH expected=$expectedH '
            '(${pxToFtIn(actualH)} vs ${pxToFtIn(expectedH)}) — fixing!',
          );
          _bloc.add(
            UpdateCanvasSize(
              width: widget.busDimensions!.widthPx,
              height: expectedH,
            ),
          );
        } else {
          debugPrint('CANVAS_OK: ${pxToFtIn(actualH)} matches BusDimensions');
        }
      });
    }
  }

  @override
  void dispose() {
    _loadSub?.cancel();
    _transformCtrl.dispose();
    super.dispose();
  }

  // ── Helpers to read from BLoC ──
  LayoutDesignerBloc get _bloc => context.read<LayoutDesignerBloc>();
  AbsoluteLayoutState get _state => _bloc.state.layout;

  /// Apply vehicle name + registry + dimensions + front partition
  /// from the config screen AFTER InitDesigner has loaded the saved
  /// snapshot from the server.
  void _applyConfigData() {
    final cfg = widget.config;
    if (cfg != null) {
      final name = cfg.maker.isNotEmpty
          ? '${cfg.numberPlate} | ${cfg.maker}'
          : cfg.numberPlate;
      if (name.isNotEmpty) {
        _bloc.add(SetLayoutDisplayName(name));
      }
      // Front partition
      _bloc.add(SetLayoutMetadata('front_partition_px', cfg.frontPartitionPx));
      // For edit mode: clear old components and regenerate the seat
      // grid from the config screen's updated row/seat distribution.
      if (widget.layoutId != null) {
        _bloc.add(const ClearComponents());
        _initFromConfig(cfg);
      }
    }
    if (widget.registry != null) {
      _bloc.add(SetLayoutRegistry(widget.registry!));
    }
    // Canvas dimensions (bus inside length/width)
    if (widget.busDimensions != null) {
      _bloc.add(
        UpdateCanvasSize(
          width: widget.busDimensions!.widthPx,
          height: widget.busDimensions!.lengthPx,
        ),
      );
    }
  }

  void _initFromConfig(BusConfig config) {
    final bloc = _bloc;
    final leftSeats = config.leftSeats;
    final rightSeats = config.rightSeats;
    final rows = config.rowCount;

    // Use physics‑based dimensions when available.
    final registry = widget.registry;
    // Dispatch registry to BloC so _onAdd / _onPreset read it later.
    if (registry != null) {
      bloc.add(SetLayoutRegistry(registry));
    }
    // Determine component type from registry (first registered part wins).
    ComponentType activeType = ComponentType.seat;
    SeatPartType? activePartType = SeatPartType.standardSeat;
    if (registry != null && registry.parts.isNotEmpty) {
      activePartType = registry.parts.keys.first;
      activeType = switch (activePartType) {
        SeatPartType.sleeperLower => ComponentType.sleeperLower,
        SeatPartType.sleeperUpper => ComponentType.sleeperUpper,
        SeatPartType.businessSeat => ComponentType.businessClassSeat,
        SeatPartType.foldingSeat => ComponentType.foldingSeat,
        SeatPartType.table => ComponentType.restaurantTable,
        _ => ComponentType.seat,
      };
    }
    // Berth stacking: lower (aisle half) + upper (window half) share
    // same floor column, each at 50% of registered width.
    final bool hasBothBerths =
        registry != null &&
        registry.parts.containsKey(SeatPartType.sleeperLower) &&
        registry.parts.containsKey(SeatPartType.sleeperUpper);

    final defaultSpec = PartSpec.defaultFor(activePartType!);
    final activeSpec = registry?.parts[activePartType];
    final double seatLen = activeSpec?.pixelLength ?? defaultSpec.pixelLength;
    final double fullWidth = activeSpec?.pixelWidth ?? defaultSpec.pixelWidth;
    final double gapPx = (registry?.interSeatGap.toPixels ?? 0) > 0
        ? registry!.interSeatGap.toPixels
        : kDefaultInterSeatGap.toPixels;
    final double rowH = seatLen + gapPx;
    final double seatSpan = fullWidth;
    final double halfWidth = hasBothBerths ? fullWidth / 2 : fullWidth;
    final double aisleW = (registry?.aisleWidth.toPixels ?? 0) > 0
        ? registry!.aisleWidth.toPixels
        : kDefaultAisleWidth.toPixels;
    const double topMargin = 100.0;
    // Auto-calculate side margins so layout fills bus width evenly.
    // Cap at 7" (28px) max to avoid excessive gaps on large buses.
    double leftMargin;

    final double canvasH;
    final double canvasW;
    // Use config's authoritative dimensions first (always set from config screen),
    // then fall back to widget.busDimensions, then old expand-to-fit behaviour.
    final bd = widget.busDimensions;
    final double authoritativeLenPx = config.busLengthPx;
    final double authoritativeWidPx = config.busWidthPx;
    if (authoritativeLenPx > 0 && authoritativeWidPx > 0) {
      canvasH = authoritativeLenPx;
      canvasW = authoritativeWidPx;
      final totalUsedW = leftSeats * seatSpan + aisleW + rightSeats * seatSpan;
      final remainingW = canvasW - totalUsedW;
      leftMargin = (remainingW / 2).floorToDouble().clamp(0.0, 28.0);
    } else if (bd != null) {
      canvasH = bd.lengthPx;
      canvasW = bd.widthPx;
      final totalUsedW = leftSeats * seatSpan + aisleW + rightSeats * seatSpan;
      final remainingW = canvasW - totalUsedW;
      leftMargin = (remainingW / 2).floorToDouble().clamp(0.0, 28.0);
    } else {
      leftMargin = 8.0;
      canvasH = topMargin + rows * rowH + 40;
      canvasW =
          leftMargin +
          leftSeats * seatSpan +
          aisleW +
          rightSeats * seatSpan +
          leftMargin;
    }

    final vehicleName = config.maker.isNotEmpty
        ? '${config.numberPlate} | ${config.maker}'
        : config.numberPlate;
    if (vehicleName.isNotEmpty) {
      bloc.add(SetLayoutDisplayName(vehicleName));
    }

    bloc.add(
      UpdateCanvasSize(
        width: canvasW > 200 ? canvasW : 280,
        height: canvasH > 200 ? canvasH : 896,
      ),
    );

    // Persist front partition for reliable round-trip detection.
    bloc.add(SetLayoutMetadata('front_partition_px', config.frontPartitionPx));

    bloc.add(
      AddComponent(
        type: ComponentType.driverCabin,
        x: (canvasW - 80) / 2,
        y: 16,
      ),
    );

    int counter = 1;
    // Authoritative boundary from config (always set), falling back to widget.
    final frontPx = config.frontPartitionPx;
    final busLenPx = config.busLengthPx > 0
        ? config.busLengthPx
        : (widget.busDimensions?.lengthPx ?? double.infinity);
    // When partition is enabled, it REPLACES the default top margin
    // (not adds to it). Keep 40px minimum for the ruler strip.
    final effectiveTop = frontPx > 0
        ? (frontPx < 40 ? 40.0 : frontPx)
        : topMargin;
    for (int row = 0; row < rows; row++) {
      final y = effectiveTop + row * rowH;

      if (y + seatLen > busLenPx) break; // stop at bus boundary
      for (int s = 0; s < leftSeats; s++) {
        final x = leftMargin + s * seatSpan;
        if (hasBothBerths) {
          bloc.add(
            AddComponent(
              type: ComponentType.sleeperUpper,
              x: x,
              y: y,
              width: halfWidth,
              height: seatLen,
              berthLabel: 'U$counter',
            ),
          );
          bloc.add(
            AddComponent(
              type: ComponentType.sleeperLower,
              x: x + halfWidth,
              y: y,
              width: halfWidth,
              height: seatLen,
              berthLabel: 'L$counter',
            ),
          );
        } else if (activeType == ComponentType.sleeperLower ||
            activeType == ComponentType.sleeperUpper) {
          bloc.add(
            AddComponent(
              type: activeType,
              x: x,
              y: y,
              width: seatSpan,
              height: seatLen,
              berthLabel: activeType == ComponentType.sleeperLower
                  ? 'L$counter'
                  : 'U$counter',
            ),
          );
        } else {
          bloc.add(
            AddComponent(
              type: activeType,
              x: x,
              y: y,
              seatId: 'S$counter',
              seatNumber: counter,
            ),
          );
        }
        counter++;
      }

      final rightStartX = leftMargin + leftSeats * seatSpan + aisleW;
      for (int s = 0; s < rightSeats; s++) {
        final x = rightStartX + s * seatSpan;
        if (hasBothBerths) {
          bloc.add(
            AddComponent(
              type: ComponentType.sleeperLower,
              x: x,
              y: y,
              width: halfWidth,
              height: seatLen,
              berthLabel: 'L$counter',
            ),
          );
          bloc.add(
            AddComponent(
              type: ComponentType.sleeperUpper,
              x: x + halfWidth,
              y: y,
              width: halfWidth,
              height: seatLen,
              berthLabel: 'U$counter',
            ),
          );
        } else if (activeType == ComponentType.sleeperLower ||
            activeType == ComponentType.sleeperUpper) {
          bloc.add(
            AddComponent(
              type: activeType,
              x: x,
              y: y,
              width: seatSpan,
              height: seatLen,
              berthLabel: activeType == ComponentType.sleeperLower
                  ? 'L$counter'
                  : 'U$counter',
            ),
          );
        } else {
          bloc.add(
            AddComponent(
              type: activeType,
              x: x,
              y: y,
              seatId: 'S$counter',
              seatNumber: counter,
            ),
          );
        }
        counter++;
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
    return BlocListener<LayoutDesignerBloc, LayoutDesignerState>(
      listener: (ctx, state) {
        // Show success when save/publish completes (isSaving: true→false, no error)
        if (_wasSaving &&
            !state.layout.isSaving &&
            state.layout.errorMessage == null &&
            state.layout.layoutId != null) {
          final msg = _wasPublishing
              ? '✓ Published successfully!'
              : '✓ Saved successfully!';
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(msg, style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF16A34A),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        _wasSaving = state.layout.isSaving;
      },
      child: BlocBuilder<LayoutDesignerBloc, LayoutDesignerState>(
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
                            _placingIsReverse = isReverse;
                            _placingWidth = defW;
                            _placingHeight = defH;
                          });
                          _bloc.add(const SelectComponent(null));
                        },
                      ),
                      Expanded(child: _buildCanvas()),
                    ],
                  ),
                ),
                _statusBar(),
              ],
            ),
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
            Gap(8),
            ElevatedButton.icon(
              onPressed: _state.isSaving
                  ? null
                  : () {
                      _wasPublishing = false;
                      _bloc.add(SaveLayout(apiPrefix: widget.apiPrefix));
                    },
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
                  : () {
                      _wasPublishing = true;
                      _bloc.add(PublishLayout(apiPrefix: widget.apiPrefix));
                    },
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
            _bloc.add(
              AddComponent(
                type: _placingType!,
                x: x,
                y: y,
                isReverseFacing: _placingIsReverse,
                width: _placingWidth,
                height: _placingHeight,
              ),
            );
            setState(() {
              _tool = _CanvasTool.select;
              _placingType = null;
              _placingIsReverse = false;
            });
          }
        },
        onCanvasTap: (x, y) {
          if (_tool == _CanvasTool.placeComponent && _placingType != null) {
            _bloc.add(
              AddComponent(
                type: _placingType!,
                x: x,
                y: y,
                isReverseFacing: _placingIsReverse,
                width: _placingWidth,
                height: _placingHeight,
              ),
            );
            setState(() {
              _tool = _CanvasTool.select;
              _placingType = null;
              _placingIsReverse = false;
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
