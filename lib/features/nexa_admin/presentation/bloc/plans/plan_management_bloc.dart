// File: lib/features/nexa_admin/presentation/bloc/plans/plan_management_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:trace_odd/shared/models/subscription/plan_model.dart';
import 'package:trace_odd/shared/models/subscription/plan_type.dart';
import 'package:trace_odd/shared/models/subscription/plan_feature_model.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/plan_management_repository.dart';

part 'plan_management_event.dart';
part 'plan_management_state.dart';
part 'plan_management_bloc.freezed.dart';

class PlanManagementBloc
    extends Bloc<PlanManagementEvent, PlanManagementState> {
  final PlanManagementRepository planRepository;

  PlanManagementBloc({required this.planRepository})
      : super(const PlanManagementState.initial()) {
    on<_LoadPlans>(_onLoadPlans);
    on<_LoadPlan>(_onLoadPlan);
    on<_CreatePlan>(_onCreatePlan);
    on<_UpdatePlan>(_onUpdatePlan);
    on<_UpdatePlanStatus>(_onUpdatePlanStatus);
    on<_DeletePlan>(_onDeletePlan);
    on<_DuplicatePlan>(_onDuplicatePlan);
    on<_LoadPlanStatistics>(_onLoadPlanStatistics);
    on<_LoadPlanFeatures>(_onLoadPlanFeatures);
    on<_ExportPlans>(_onExportPlans);
    on<_ClearError>(_onClearError);
    on<_Reset>(_onReset);
  }

  Future<void> _onLoadPlans(
    _LoadPlans event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      emit(const PlanManagementState.loading());

      final results = await Future.wait([
        planRepository.getPlans(
          search: event.search,
          type: event.type,
          status: event.status,
          page: event.page,
          limit: event.perPage,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
        ),
        planRepository.getPlanStatistics(),
        planRepository.getPlanFeatures(),
      ], eagerError: false);

      final response = results[0] as PlansResponse;

      PlanStatistics? statistics;
      final statsRaw = results[1];
      if (statsRaw is Map<String, dynamic> && statsRaw.isNotEmpty) {
        try {
          statistics = PlanStatistics.fromJson({'data': statsRaw});
        } catch (_) {
          statistics = null;
        }
      }

      final availableFeatures = <String, List<PlanFeature>>{};
      final featuresRaw = results[2];
      if (featuresRaw is List<Map<String, dynamic>>) {
        for (final item in featuresRaw) {
          try {
            final feature = PlanFeature.fromJson(item);
            final key = feature.type.name;
            availableFeatures.putIfAbsent(key, () => []).add(feature);
          } catch (_) {}
        }
      }

      emit(PlanManagementState.loaded(
        plans: response.plans,
        total: response.total,
        page: response.page,
        perPage: response.limit,
        totalPages: response.totalPages,
        search: event.search,
        type: event.type,
        status: event.status,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        statistics: statistics,
        availableFeatures: availableFeatures,
      ));
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onLoadPlan(
    _LoadPlan event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      emit(const PlanManagementState.loading());
      final plan = await planRepository.getPlanById(event.id);
      emit(PlanManagementState.planDetailLoaded(
        plan: plan,
        availableFeatures: {},
      ));
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onCreatePlan(
    _CreatePlan event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      emit(const PlanManagementState.loading());

      final computedPrices = _computeMonthlyAndYearlyPrice(
        price: event.price,
        billingCycle: event.billingCycle,
      );

      final limits = event.limits;
      final metadata = <String, dynamic>{
        if (event.isFeatured != null) 'is_featured': event.isFeatured,
        if (event.isPopular != null) 'is_popular': event.isPopular,
        if (event.sortOrder != null) 'sort_order': event.sortOrder,
        ...?event.metadata,
        if (limits['transport_connections_per_month'] != null)
          'transport_connections_per_month':
              limits['transport_connections_per_month'],
        if (limits['max_loads_per_month'] != null)
          'max_loads_per_month': limits['max_loads_per_month'],
      };

      final plan = await planRepository.createPlan({
        'name': event.name,
        'type': event.type,
        'description': event.description,
        'monthly_price': computedPrices.$1,
        'yearly_price': computedPrices.$2,
        'currency': event.currency,
        'status': event.status,
        'features': event.features?.map((f) => f.id).toList(),
        'monthly_unit_codes': limits['monthly_unit_codes'],
        'monthly_packet_codes': limits['monthly_packet_codes'],
        'monthly_carton_codes': limits['monthly_carton_codes'],
        'monthly_bundle_codes': limits['monthly_bundle_codes'],
        'max_stores': (limits['stores'] ?? limits['max_stores']),
        'max_drivers': (limits['drivers'] ?? limits['max_drivers']),
        'max_users': limits['max_users'],
        'metadata': metadata,
      });
      emit(PlanManagementState.planCreated(
        plan: plan,
        message: 'Plan created successfully',
      ));

      // Reload plans to reflect the new plan
      add(const PlanManagementEvent.loadPlans());
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  (double, double) _computeMonthlyAndYearlyPrice({
    required double price,
    required String billingCycle,
  }) {
    switch (billingCycle) {
      case 'monthly':
        return (price, price * 12);
      case 'quarterly':
        return (price / 3, price * 4);
      case 'yearly':
        return (price / 12, price);
      case 'one_time':
        return (price, price);
      default:
        return (price, price * 12);
    }
  }

  Future<void> _onUpdatePlan(
    _UpdatePlan event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      emit(const PlanManagementState.loading());

      final updateData = <String, dynamic>{};

      if (event.name != null) updateData['name'] = event.name;
      if (event.type != null) updateData['type'] = event.type;
      if (event.description != null) {
        updateData['description'] = event.description;
      }
      if (event.price != null) {
        final computedPrices = _computeMonthlyAndYearlyPrice(
          price: event.price!,
          billingCycle: event.billingCycle ?? 'monthly',
        );
        updateData['monthly_price'] = computedPrices.$1;
        updateData['yearly_price'] = computedPrices.$2;
      }
      if (event.billingCycle != null) {
        updateData['billing_cycle'] = event.billingCycle;
      }
      if (event.currency != null) updateData['currency'] = event.currency;
      if (event.status != null) updateData['status'] = event.status;
      final metaUpdate = <String, dynamic>{
        ...?event.metadata,
        if (event.isFeatured != null) 'is_featured': event.isFeatured,
        if (event.isPopular != null) 'is_popular': event.isPopular,
        if (event.sortOrder != null) 'sort_order': event.sortOrder,
      };

      if (event.limits != null) {
        final limits = event.limits!;
        if (limits['monthly_unit_codes'] != null) {
          updateData['monthly_unit_codes'] = limits['monthly_unit_codes'];
        }
        if (limits['monthly_packet_codes'] != null) {
          updateData['monthly_packet_codes'] = limits['monthly_packet_codes'];
        }
        if (limits['monthly_carton_codes'] != null) {
          updateData['monthly_carton_codes'] = limits['monthly_carton_codes'];
        }
        if (limits['monthly_bundle_codes'] != null) {
          updateData['monthly_bundle_codes'] = limits['monthly_bundle_codes'];
        }
        if (limits['max_stores'] != null) {
          updateData['max_stores'] = limits['max_stores'];
        }
        if (limits['max_drivers'] != null) {
          updateData['max_drivers'] = limits['max_drivers'];
        }
        if (limits['max_users'] != null) {
          updateData['max_users'] = limits['max_users'];
        }
        if (limits['transport_connections_per_month'] != null) {
          metaUpdate['transport_connections_per_month'] =
              limits['transport_connections_per_month'];
        }
        if (limits['max_loads_per_month'] != null) {
          metaUpdate['max_loads_per_month'] = limits['max_loads_per_month'];
        }
      }

      if (event.features != null) {
        updateData['features'] = event.features!.map((f) => f.id).toList();
      }

      if (metaUpdate.isNotEmpty) {
        updateData['metadata'] = metaUpdate;
      }

      final plan = await planRepository.updatePlan(event.id, updateData);
      emit(PlanManagementState.planUpdated(
        plan: plan,
        message: 'Plan updated successfully',
      ));

      // Reload plans to reflect the update
      add(const PlanManagementEvent.loadPlans());
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onUpdatePlanStatus(
    _UpdatePlanStatus event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      final current = state;
      emit(const PlanManagementState.loading());
      await planRepository.changePlanStatus(event.planId, event.status.name);
      emit(PlanManagementState.planStatusUpdated(
        planId: event.planId,
        newStatus: event.status,
        message: 'Plan status updated successfully',
      ));
      current.maybeMap(
        loaded: (s) {
          add(PlanManagementEvent.loadPlans(
            search: s.search,
            type: s.type,
            status: s.status,
            page: s.page,
            perPage: s.perPage,
            sortBy: s.sortBy,
            sortOrder: s.sortOrder,
          ));
        },
        orElse: () {
          add(const PlanManagementEvent.loadPlans());
        },
      );
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onLoadPlanStatistics(
    _LoadPlanStatistics event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      final raw = await planRepository.getPlanStatistics();
      final stats = PlanStatistics.fromJson({'data': raw});

      state.maybeMap(
        loaded: (s) {
          emit(s.copyWith(statistics: stats));
        },
        orElse: () {
          emit(PlanManagementState.loaded(
            plans: const [],
            total: 0,
            page: 1,
            perPage: 20,
            totalPages: 1,
            search: '',
            sortBy: 'created_at',
            sortOrder: 'desc',
            statistics: stats,
            availableFeatures: const {},
          ));
        },
      );
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onLoadPlanFeatures(
    _LoadPlanFeatures event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      final raw = await planRepository.getPlanFeatures();
      final features = <String, List<PlanFeature>>{};
      for (final item in raw) {
        try {
          final feature = PlanFeature.fromJson(item);
          final key = feature.type.name;
          features.putIfAbsent(key, () => []).add(feature);
        } catch (_) {}
      }

      state.maybeMap(
        loaded: (s) {
          emit(s.copyWith(availableFeatures: features));
        },
        orElse: () {
          emit(PlanManagementState.loaded(
            plans: const [],
            total: 0,
            page: 1,
            perPage: 20,
            totalPages: 1,
            search: '',
            sortBy: 'created_at',
            sortOrder: 'desc',
            statistics: null,
            availableFeatures: features,
          ));
        },
      );
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onDeletePlan(
    _DeletePlan event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      final current = state;
      emit(const PlanManagementState.loading());
      await planRepository.deletePlan(event.id);
      emit(PlanManagementState.planDeleted(
        planId: event.id,
        message: 'Plan deleted successfully',
      ));
      current.maybeMap(
        loaded: (s) {
          add(PlanManagementEvent.loadPlans(
            search: s.search,
            type: s.type,
            status: s.status,
            page: s.page,
            perPage: s.perPage,
            sortBy: s.sortBy,
            sortOrder: s.sortOrder,
          ));
        },
        orElse: () {
          add(const PlanManagementEvent.loadPlans());
        },
      );
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onDuplicatePlan(
    _DuplicatePlan event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      final current = state;
      emit(const PlanManagementState.loading());
      final plan = await planRepository.duplicatePlan(event.id);
      emit(PlanManagementState.planDuplicated(
        plan: plan,
        message: 'Plan duplicated successfully',
      ));
      current.maybeMap(
        loaded: (s) {
          add(PlanManagementEvent.loadPlans(
            search: s.search,
            type: s.type,
            status: s.status,
            page: s.page,
            perPage: s.perPage,
            sortBy: s.sortBy,
            sortOrder: s.sortOrder,
          ));
        },
        orElse: () {
          add(const PlanManagementEvent.loadPlans());
        },
      );
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  Future<void> _onExportPlans(
    _ExportPlans event,
    Emitter<PlanManagementState> emit,
  ) async {
    try {
      emit(const PlanManagementState.exporting());
      // TODO: Implement export logic
      await Future.delayed(const Duration(seconds: 1));
      emit(const PlanManagementState.exported(
        filePath: 'plans_export.csv',
        message: 'Plans exported successfully',
      ));
    } catch (error) {
      emit(PlanManagementState.error(message: error.toString()));
    }
  }

  void _onClearError(
    _ClearError event,
    Emitter<PlanManagementState> emit,
  ) {
    if (state is _Error) {
      // Logic to return to previous state or initial
    }
  }

  void _onReset(
    _Reset event,
    Emitter<PlanManagementState> emit,
  ) {
    emit(const PlanManagementState.initial());
  }
}
