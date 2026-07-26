// Route Editor Screen — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/loading/loading_state_widget.dart';
import 'package:trace_odd/shared/widgets/fleet/fleet_shared_widgets.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_editor_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_editor_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/routes/route_editor_state.dart';
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
            backgroundColor: AppColors.fleetBackground,
            body: LoadingState(),
          );

        return Scaffold(
          backgroundColor: AppColors.fleetBackground,
          appBar: AppBar(
            backgroundColor: AppColors.fleetCard,
            title: Text(
              state.routeId.isNotEmpty ? 'Edit Route' : 'New Route',
              style: const TextStyle(color: AppColors.textInverse),
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
                          color: AppColors.textInverse,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.fleetAccent,
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
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.fleetCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.shadowColor),
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
                            waypoints: state.waypoints,
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
                                  color: AppColors.fleetAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '×',
                                    style: TextStyle(
                                      color: AppColors.textInverse,
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
                            w.stationName,
                            style: const TextStyle(
                              color: AppColors.textInverse,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: AppColors.fleetCard,
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.error,
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
                      color: AppColors.textInverse,
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
                            color: selected
                                ? AppColors.textInverse
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.fleetInfo,
                        backgroundColor: AppColors.fleetCard,
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
                      color: AppColors.textInverse,
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
                            color: selected
                                ? AppColors.textInverse
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.fleetWarning,
                        backgroundColor: AppColors.fleetCard,
                        onSelected: (_) => bloc.add(ToggleBonus(id)),
                      );
                    }).toList(),
                  ),
                ],

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: FleetErrorView(
                      error: state.error!,
                      onRetry: () => bloc.add(
                        InitRouteEditor(
                          routeId: state.routeId.isNotEmpty
                              ? state.routeId
                              : null,
                          carrierCompanyId: state.carrierCompanyId,
                        ),
                      ),
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
            .map((w) => {'lat': w.lat, 'lng': w.lng, 'label': w.stationName})
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
      style: const TextStyle(color: AppColors.textInverse),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.fleetAccent),
        ),
        filled: true,
        fillColor: AppColors.fleetCard,
      ),
      onChanged: onChanged,
    );
  }
}
