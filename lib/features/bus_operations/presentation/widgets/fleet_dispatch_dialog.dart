// Fleet Dispatch Dialog — BLoC-driven (Wave 6)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/presentation/bloc/dispatch/fleet_dispatch_bloc.dart';

const _shifts = ['morning', 'evening', 'night', 'special'];

class FleetDispatchDialog extends StatelessWidget {
  final String apiPrefix;
  final String? busCompanyId;
  final VoidCallback? onSaved;

  const FleetDispatchDialog({
    super.key,
    required this.apiPrefix,
    this.busCompanyId,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String apiPrefix,
    String? busCompanyId,
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => FleetDispatchBloc()
          ..add(InitDispatch(apiPrefix: apiPrefix, busCompanyId: busCompanyId)),
        child: FleetDispatchDialog(
          apiPrefix: apiPrefix,
          busCompanyId: busCompanyId,
          onSaved: onSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetDispatchBloc, DispatchState>(
      builder: (ctx, state) {
        final bloc = ctx.read<FleetDispatchBloc>();
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
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
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment, color: Colors.white, size: 22),
                    const Gap(10),
                    const Expanded(
                      child: Text(
                        'Fleet Dispatch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
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
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          const Text(
                            'Date Range',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                              color: Colors.white,
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
                              color: Colors.white,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: state.selectedReturn,
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF1E293B),
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
                              child: Text(
                                state.error!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          if (state.success != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                state.success!,
                                style: const TextStyle(color: Colors.green),
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
                                bloc.add(const SaveDispatch());
                                if (onSaved != null) onSaved!();
                                Navigator.pop(ctx, true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4D8),
                        ),
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
                                'Assign',
                                style: TextStyle(color: Colors.white),
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
            color: Colors.white,
          ),
        ),
        const Gap(4),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF00B4D8), size: 20),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: const Color(0xFF1E293B),
          ),
          hint: Text(
            'Select $label',
            style: const TextStyle(color: Colors.white38),
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
                    style: const TextStyle(color: Colors.white),
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
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
