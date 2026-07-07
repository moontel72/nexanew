// Route Editor Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_editor_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/route_map_editor_painter.dart';

class RouteEditorScreen extends StatelessWidget {
  final String? routeId;
  final String carrierCompanyId;
  const RouteEditorScreen({
    super.key,
    this.routeId,
    required this.carrierCompanyId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteEditorBloc()
        ..add(
          InitRouteEditor(routeId: routeId, carrierCompanyId: carrierCompanyId),
        ),
      child: const _EditorView(),
    );
  }
}

class _EditorView extends StatelessWidget {
  const _EditorView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteEditorBloc, RouteEditorState>(
      builder: (ctx, state) {
        final bloc = ctx.read<RouteEditorBloc>();
        if (state.loading)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B2838),
            title: Text(
              state.routeId.isNotEmpty ? 'Edit Route' : 'New Route',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: state.saving ? null : () => _doSave(bloc, state),
                child: state.saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Color(0xFF00B4D8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic fields
                _field(
                  'Route Code',
                  state.code,
                  (v) => bloc.add(UpdateField('code', v)),
                ),
                const Gap(10),
                _field(
                  'Route Name',
                  state.name,
                  (v) => bloc.add(UpdateField('name', v)),
                ),
                const Gap(10),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Origin',
                        state.origin,
                        (v) => bloc.add(UpdateField('origin', v)),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _field(
                        'Destination',
                        state.destination,
                        (v) => bloc.add(UpdateField('destination', v)),
                      ),
                    ),
                  ],
                ),
                const Gap(16),

                // Map canvas for waypoints
                const Text(
                  'Waypoints (tap to add)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x20FFFFFF)),
                  ),
                  child: GestureDetector(
                    onTapUp: (d) {
                      final renderBox = context.findRenderObject() as RenderBox;
                      final local = renderBox.globalToLocal(d.globalPosition);
                      final w = renderBox.size.width;
                      final h = renderBox.size.height;
                      bloc.add(
                        AddWaypoint(
                          31.5 + (local.dy / h - 0.5) * 3,
                          73.0 + (local.dx / w - 0.5) * 3,
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: RouteMapEditorPainter(
                            waypoints: state.waypoints
                                .map(
                                  (w) => Map<String, dynamic>.from({
                                    'lat': w.lat,
                                    'lng': w.lng,
                                    'station_name': w.label,
                                  }),
                                )
                                .toList(),
                          ),
                        ),
                        ...state.waypoints.asMap().entries.map(
                          (e) => Positioned(
                            left: ((e.value.lng - 71.5) / 3 * 300 + 140).clamp(
                              20,
                              280,
                            ),
                            top: ((e.value.lat - 30.0) / 3 * 300 + 140).clamp(
                              20,
                              280,
                            ),
                            child: GestureDetector(
                              onTap: () => bloc.add(RemoveWaypoint(e.value.id)),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00B4D8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '×',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(8),
                Wrap(
                  spacing: 6,
                  children: state.waypoints
                      .map(
                        (w) => Chip(
                          label: Text(
                            w.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: const Color(0xFF1B2838),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          onDeleted: () => bloc.add(RemoveWaypoint(w.id)),
                        ),
                      )
                      .toList(),
                ),

                // Vouchers
                if (state.dropdownsReady && state.vouchers.isNotEmpty) ...[
                  const Gap(16),
                  const Text(
                    'Vouchers',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(6),
                  Wrap(
                    spacing: 6,
                    children: state.vouchers.map((v) {
                      final id = v['id']?.toString() ?? '';
                      final selected = state.voucherIds.contains(id);
                      return FilterChip(
                        label: Text(
                          v['title']?.toString() ??
                              v['code']?.toString() ??
                              'Voucher',
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        selected: selected,
                        selectedColor: const Color(0xFF3B82F6),
                        backgroundColor: const Color(0xFF1B2838),
                        onSelected: (_) => bloc.add(ToggleVoucher(id)),
                      );
                    }).toList(),
                  ),
                ],

                // Bonuses
                if (state.dropdownsReady && state.bonuses.isNotEmpty) ...[
                  const Gap(12),
                  const Text(
                    'Staff Bonuses',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(6),
                  Wrap(
                    spacing: 6,
                    children: state.bonuses.map((b) {
                      final id = b['id']?.toString() ?? '';
                      final selected = state.bonusIds.contains(id);
                      return FilterChip(
                        label: Text(
                          b['bonus_name']?.toString() ??
                              b['name']?.toString() ??
                              'Bonus',
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        selected: selected,
                        selectedColor: const Color(0xFFF59E0B),
                        backgroundColor: const Color(0xFF1B2838),
                        onSelected: (_) => bloc.add(ToggleBonus(id)),
                      );
                    }).toList(),
                  ),
                ],

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _doSave(RouteEditorBloc bloc, RouteEditorState state) {
    bloc.add(
      SaveRoute(
        code: state.code,
        name: state.name,
        origin: state.origin,
        destination: state.destination,
        carrierCompanyId: state.carrierCompanyId,
        waypoints: state.waypoints
            .map((w) => {'lat': w.lat, 'lng': w.lng, 'label': w.label})
            .toList(),
        voucherIds: state.voucherIds.toList(),
        bonusIds: state.bonusIds.toList(),
      ),
    );
  }

  static Widget _field(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    final ctrl = TextEditingController(text: value);
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0x30FFFFFF)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00B4D8)),
        ),
        filled: true,
        fillColor: const Color(0xFF1B2838),
      ),
      onChanged: onChanged,
    );
  }
}
