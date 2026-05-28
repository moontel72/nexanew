// Subscription Gate Cubit — Single source of truth for plan-tier UI gating.
//
// Reads subscription state from `/api/v1/{panel}/subscription` and exposes
// helper methods (hasFeature, wouldExceed, isAtLeast) consumed by widgets.
//
// Wire this cubit at the panel root (e.g. main.dart MultiBlocProvider) so any
// child widget can `context.watch<SubscriptionGateCubit>()` to gate features.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/bloc/subscription/subscription_gate_state.dart';

class SubscriptionGateCubit extends Cubit<SubscriptionGateState> {
  /// Optional loader injected from the API layer — returns the raw
  /// `/api/v1/{panel}/subscription` response.  When null, the cubit
  /// remains in its seeded state (useful for tests / offline).
  final Future<Map<String, dynamic>> Function()? loader;

  SubscriptionGateCubit({
    this.loader,
    SubscriptionGateState initial = const SubscriptionGateState(),
  }) : super(initial);

  /// Refresh subscription snapshot from the backend.
  Future<void> refresh() async {
    if (loader == null) return;
    try {
      final json = await loader!();
      emit(SubscriptionGateState.fromJson(json));
    } catch (_) {
      // Keep last known state on failure — UI continues with cached gates.
    }
  }

  /// Manually seed state (used after login or on offline boot).
  void seed(SubscriptionGateState state) => emit(state);

  /// Increment local usage counter (optimistic UI before backend confirms).
  void bumpUsage(String resourceKey, [int delta = 1]) {
    final current = state.usage[resourceKey] ?? 0;
    final next = Map<String, int>.from(state.usage)
      ..[resourceKey] = current + delta;
    emit(state.copyWith(usage: next));
  }

  /// Reset to default free-tier state on logout.
  void reset() => emit(const SubscriptionGateState());
}
