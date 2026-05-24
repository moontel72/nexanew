// Subscription Gate State — UI-facing subscription tier snapshot.
//
// Exposes the user's active plan name, feature flags, and quota usage so
// any widget can read `context.watch<SubscriptionGateCubit>().state` and
// gate UI (lock buttons, show upsell sheets, hide features).
//
// Maps directly to the backend `subscriptions` table (Step 8) plus the
// `plan_limits` payload returned from `/api/v1/{panel}/subscription`.

import 'package:equatable/equatable.dart';

/// Canonical plan tier names (aligned with backend `plans.name`).
enum PlanTier { free, basic, pro, enterprise, custom }

PlanTier _tierFromName(String? name) {
  switch (name?.toLowerCase()) {
    case 'free':
      return PlanTier.free;
    case 'basic':
      return PlanTier.basic;
    case 'pro':
      return PlanTier.pro;
    case 'enterprise':
      return PlanTier.enterprise;
    default:
      return PlanTier.custom;
  }
}

class SubscriptionGateState extends Equatable {
  /// Plan display name (e.g. "Pro", "Enterprise").
  final String planName;

  /// Canonical tier enum.
  final PlanTier tier;

  /// Whether the subscription is active (not suspended/expired).
  final bool isActive;

  /// Expiry date (null = perpetual).
  final DateTime? expiresAt;

  /// Hard quota limits keyed by resource (codes, users, products, factories,
  /// storage_mb, api_calls).  Mirrors backend `plan_limits` JSON.
  final Map<String, int> limits;

  /// Current usage counters for the same keys as [limits].
  final Map<String, int> usage;

  /// Boolean feature flags from `plans.features` (e.g. `bulk_codes`,
  /// `freight_auction`, `voucher_system`).
  final Map<String, bool> features;

  const SubscriptionGateState({
    this.planName = 'Free',
    this.tier = PlanTier.free,
    this.isActive = true,
    this.expiresAt,
    this.limits = const {},
    this.usage = const {},
    this.features = const {},
  });

  factory SubscriptionGateState.fromJson(Map<String, dynamic> json) {
    final name = json['plan_name']?.toString() ?? 'Free';
    final rawLimits = (json['limits'] as Map?) ?? const {};
    final rawUsage = (json['usage'] as Map?) ?? const {};
    final rawFeatures = (json['features'] as Map?) ?? const {};
    return SubscriptionGateState(
      planName: name,
      tier: _tierFromName(name),
      isActive: json['is_active'] == true,
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      limits: rawLimits.map(
        (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
      ),
      usage: rawUsage.map(
        (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
      ),
      features: rawFeatures.map((k, v) => MapEntry(k.toString(), v == true)),
    );
  }

  /// Whether the plan is expired or suspended.
  bool get isExpired =>
      !isActive || (expiresAt != null && expiresAt!.isBefore(DateTime.now()));

  /// Whether a named feature is enabled for the active plan.
  bool hasFeature(String featureKey) =>
      isActive && (features[featureKey] ?? false);

  /// Remaining quota for a resource (clamped to >= 0).
  /// Returns -1 if the resource has no defined limit (unlimited).
  int remaining(String resourceKey) {
    final cap = limits[resourceKey];
    if (cap == null) return -1; // unlimited
    final used = usage[resourceKey] ?? 0;
    final r = cap - used;
    return r < 0 ? 0 : r;
  }

  /// Whether [count] additional units of [resourceKey] would exceed the cap.
  bool wouldExceed(String resourceKey, int count) {
    final cap = limits[resourceKey];
    if (cap == null) return false; // unlimited
    return ((usage[resourceKey] ?? 0) + count) > cap;
  }

  /// Tier ordering helper — true if this plan is at least [minTier].
  bool isAtLeast(PlanTier minTier) => tier.index >= minTier.index;

  SubscriptionGateState copyWith({
    String? planName,
    PlanTier? tier,
    bool? isActive,
    DateTime? expiresAt,
    Map<String, int>? limits,
    Map<String, int>? usage,
    Map<String, bool>? features,
  }) => SubscriptionGateState(
    planName: planName ?? this.planName,
    tier: tier ?? this.tier,
    isActive: isActive ?? this.isActive,
    expiresAt: expiresAt ?? this.expiresAt,
    limits: limits ?? this.limits,
    usage: usage ?? this.usage,
    features: features ?? this.features,
  );

  @override
  List<Object?> get props => [
    planName,
    tier,
    isActive,
    expiresAt,
    limits,
    usage,
    features,
  ];
}
