// Fleet Dispatch Dialog — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/widgets/loading/loading_state_widget.dart';
import 'package:trace_odd/shared/widgets/fleet/fleet_shared_widgets.dart';

import 'package:trace_odd/features/bus_operations/presentation/bloc/dispatch/fleet_dispatch_bloc.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/dispatch/fleet_dispatch_event.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/dispatch/fleet_dispatch_state.dart';

const _shifts = ['morning', 'evening', 'night', 'special'];

class FleetDispatchDialog extends StatelessWidget {
  final String apiPrefix;
  final String? busCompanyId;
  final String? assignmentId;
  final VoidCallback? onSaved;

  const FleetDispatchDialog({
    super.key,
    required this.apiPrefix,
    this.busCompanyId,
    this.assignmentId,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String apiPrefix,
    String? busCompanyId,
    String? assignmentId,
    Map<String, dynamic>? initialData,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) {
          final bloc = FleetDispatchBloc()
            ..add(
              InitDispatch(apiPrefix: apiPrefix, busCompanyId: busCompanyId),
            );
          // Pre-populate fields when editing
          if (assignmentId != null && initialData != null) {
            _prefillFromData(bloc, initialData);
          }
          return bloc;
        },
        child: FleetDispatchDialog(
          apiPrefix: apiPrefix,
          busCompanyId: busCompanyId,
          assignmentId: assignmentId,
          onSaved: onSaved,
        ),
      ),
    );
  }

  static void _prefillFromData(
    FleetDispatchBloc bloc,
    Map<String, dynamic> data,
  ) {
    if (data['vehicle_id'] != null)
      bloc.add(SetDispatchField('vehicle', data['vehicle_id']));
    if (data['route_id'] != null)
      bloc.add(SetDispatchField('route', data['route_id']));
    if (data['driver_id'] != null)
      bloc.add(SetDispatchField('driver', data['driver_id']));
    if (data['conductor_id'] != null)
      bloc.add(SetDispatchField('conductor', data['conductor_id']));
    if (data['relief_driver_id'] != null)
      bloc.add(SetDispatchField('reliefDriver', data['relief_driver_id']));
    if (data['relief_conductor_id'] != null)
      bloc.add(
        SetDispatchField('reliefConductor', data['relief_conductor_id']),
      );
    if (data['shift'] != null)
      bloc.add(SetDispatchField('shift', data['shift']));
    if (data['return_type'] != null)
      bloc.add(SetDispatchField('return', data['return_type']));
    if (data['date_from'] != null)
      bloc.add(
        SetDispatchField('dateFrom', DateTime.tryParse(data['date_from'])),
      );
    if (data['date_to'] != null)
      bloc.add(SetDispatchField('dateTo', DateTime.tryParse(data['date_to'])));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetDispatchBloc, DispatchState>(
      builder: (ctx, state) {
        final bloc = ctx.read<FleetDispatchBloc>();
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.fleetSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.fleetSurfaceLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment,
                      color: AppColors.textInverse,
                      size: 22,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        assignmentId != null
                            ? 'Edit Assignment'
                            : 'Fleet Dispatch',
                        style: const TextStyle(
                          color: AppColors.textInverse,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: state.loading
                    ? const LoadingState()
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          const Text(
                            'Date Range',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textInverse,
                            ),
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Expanded(
                                child: _dateBtn(
                                  ctx,
                                  'From',
                                  state.dateFrom,
                                  (d) =>
                                      bloc.add(SetDispatchField('dateFrom', d)),
                                ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: _dateBtn(
                                  ctx,
                                  'To',
                                  state.dateTo,
                                  (d) =>
                                      bloc.add(SetDispatchField('dateTo', d)),
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),

                          // Shift selector
                          const Text(
                            'Shift',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textInverse,
                            ),
                          ),
                          const Gap(8),
                          SegmentedButton<String>(
                            segments: _shifts
                                .map(
                                  (s) =>
                                      ButtonSegment(value: s, label: Text(s)),
                                )
                                .toList(),
                            selected: {state.shift},
                            onSelectionChanged: (s) =>
                                bloc.add(SetDispatchField('shift', s.first)),
                          ),
                          const Gap(16),

                          // Vehicle dropdown
                          _dropdown(
                            'Vehicle',
                            Icons.directions_bus,
                            state.selectedVehicle,
                            state.vehicles,
                            (v) => bloc.add(SetDispatchField('vehicle', v)),
                          ),
                          const Gap(10),

                          // Route dropdown
                          _dropdown(
                            'Route',
                            Icons.route,
                            state.selectedRoute,
                            state.routes,
                            (v) {
                              bloc.add(SetDispatchField('route', v));
                              if (v != null)
                                bloc.add(
                                  InitDispatch(
                                    apiPrefix: state.apiPrefix,
                                    busCompanyId: busCompanyId,
                                    routeId: v,
                                  ),
                                );
                            },
                          ),
                          const Gap(10),

                          // Driver
                          _dropdown(
                            'Primary Driver *',
                            Icons.person,
                            state.selectedDriver,
                            state.drivers,
                            (v) => bloc.add(SetDispatchField('driver', v)),
                          ),
                          const Gap(10),

                          // Relief Driver
                          _dropdown(
                            'Relief Driver',
                            Icons.airline_seat_recline_normal,
                            state.selectedReliefDriver,
                            state.drivers,
                            (v) =>
                                bloc.add(SetDispatchField('reliefDriver', v)),
                          ),
                          const Gap(10),

                          // Conductor
                          _dropdown(
                            'Primary Conductor',
                            Icons.person_outline,
                            state.selectedConductor,
                            state.conductors,
                            (v) => bloc.add(SetDispatchField('conductor', v)),
                          ),
                          const Gap(10),

                          // Relief Conductor
                          _dropdown(
                            'Relief Conductor',
                            Icons.airline_seat_recline_extra,
                            state.selectedReliefConductor,
                            state.conductors,
                            (v) => bloc.add(
                              SetDispatchField('reliefConductor', v),
                            ),
                          ),
                          const Gap(10),

                          // Return type
                          const Text(
                            'Return Type',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textInverse,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: state.selectedReturn,
                            dropdownColor: AppColors.fleetSurfaceLight,
                            style: const TextStyle(
                              color: AppColors.textInverse,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: AppColors.fleetSurfaceLight,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'one_way',
                                child: Text('One Way'),
                              ),
                              DropdownMenuItem(
                                value: 'round_trip',
                                child: Text('Round Trip'),
                              ),
                            ],
                            onChanged: (v) => bloc.add(
                              SetDispatchField('return', v ?? 'one_way'),
                            ),
                          ),

                          if (state.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: FleetErrorView(
                                error: state.error!,
                                onRetry: () => bloc.add(
                                  InitDispatch(
                                    apiPrefix: state.apiPrefix,
                                    busCompanyId: busCompanyId,
                                    routeId: state.selectedRoute,
                                  ),
                                ),
                              ),
                            ),
                          if (state.success != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.fleetSuccess.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.fleetSuccess,
                                      size: 18,
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        state.success!,
                                        style: const TextStyle(
                                          color: AppColors.fleetSuccess,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => bloc.add(const ResetDispatch()),
                        child: const Text('Reset'),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.saving
                            ? null
                            : () {
                                if (assignmentId != null) {
                                  bloc.add(UpdateDispatch(assignmentId!));
                                } else {
                                  bloc.add(const SaveDispatch());
                                }
                                if (onSaved != null) onSaved!();
                                Navigator.pop(ctx, true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.fleetAccent,
                        ),
                        child: state.saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textInverse,
                                ),
                              )
                            : Text(
                                assignmentId != null ? 'Update' : 'Assign',
                                style: const TextStyle(
                                  color: AppColors.textInverse,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dropdown(
    String label,
    IconData icon,
    String? value,
    List<Map<String, dynamic>> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textInverse,
          ),
        ),
        const Gap(4),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: AppColors.fleetSurfaceLight,
          style: const TextStyle(color: AppColors.textInverse),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.fleetAccent, size: 20),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.fleetSurfaceLight,
          ),
          hint: Text(
            'Select $label',
            style: const TextStyle(color: AppColors.textTertiary),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item['id']?.toString(),
                  child: Text(
                    item['name']?.toString() ??
                        item['plate_number']?.toString() ??
                        item['id']?.toString() ??
                        '—',
                    style: const TextStyle(color: AppColors.textInverse),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dateBtn(
    BuildContext ctx,
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged,
  ) {
    return OutlinedButton(
      onPressed: () async {
        final d = await showDatePicker(
          context: ctx,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) onChanged(d);
      },
      child: Text(
        value != null ? '${value.day}/${value.month}/${value.year}' : label,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
