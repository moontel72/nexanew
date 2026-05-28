// Subscription Gate Widget — Declarative UI guard for plan-tier features.
//
// Wraps any child widget and either renders it (when the gate is satisfied)
// or shows a fallback (locked badge, upsell button, or nothing).  Backed by
// [SubscriptionGateCubit] read from the widget tree.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/bloc/subscription/subscription_gate_cubit.dart';
import 'package:trace_odd/shared/bloc/subscription/subscription_gate_state.dart';

/// Renders [child] only when the subscription criteria are met.
///
/// Provide either:
///   • [feature]  — string flag from `plans.features`
///   • [minTier]  — minimum plan tier (e.g. `PlanTier.pro`)
///   • [resource] + [requiredCount] — quota check
class SubscriptionGate extends StatelessWidget {
  final Widget child;
  final Widget? lockedFallback;
  final String? feature;
  final PlanTier? minTier;
  final String? resource;
  final int requiredCount;
  final VoidCallback? onLockedTap;

  const SubscriptionGate({
    super.key,
    required this.child,
    this.lockedFallback,
    this.feature,
    this.minTier,
    this.resource,
    this.requiredCount = 1,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionGateCubit, SubscriptionGateState>(
      builder: (context, state) {
        final allowed = _isAllowed(state);
        if (allowed) return child;

        final fallback = lockedFallback ?? _DefaultLockedBadge(state: state);
        if (onLockedTap == null) return fallback;
        return GestureDetector(onTap: onLockedTap, child: fallback);
      },
    );
  }

  bool _isAllowed(SubscriptionGateState state) {
    if (state.isExpired) return false;
    if (feature != null && !state.hasFeature(feature!)) return false;
    if (minTier != null && !state.isAtLeast(minTier!)) return false;
    if (resource != null && state.wouldExceed(resource!, requiredCount)) {
      return false;
    }
    return true;
  }
}

class _DefaultLockedBadge extends StatelessWidget {
  final SubscriptionGateState state;
  const _DefaultLockedBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            state.isExpired ? 'Subscription expired' : 'Upgrade required',
            style: tt.labelSmall?.copyWith(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
