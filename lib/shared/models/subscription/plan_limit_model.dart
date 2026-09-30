class PlanLimitModel {
  final bool canContactDriversDirectly;
  final bool canContactOwnersDirectly;
  final bool canUseGoodsCompanies;
  final int maxLoadsPerMonth;

  const PlanLimitModel({
    required this.canContactDriversDirectly,
    required this.canContactOwnersDirectly,
    required this.canUseGoodsCompanies,
    required this.maxLoadsPerMonth,
  });

  factory PlanLimitModel.free() {
    return const PlanLimitModel(
      canContactDriversDirectly: false,
      canContactOwnersDirectly: false,
      canUseGoodsCompanies: false,
      maxLoadsPerMonth: 0,
    );
  }

  /// Parse the factory subscription-limits payload
  /// (`GET /api/v1/factory/subscription/limits`, MASTER-TASK-LIST.md item 9).
  ///
  /// Anything missing is treated as "not entitled" rather than assumed, so a
  /// short or unexpected response gates features off instead of on.
  factory PlanLimitModel.fromJson(Map<String, dynamic> json) {
    return PlanLimitModel(
      canContactDriversDirectly: json['can_contact_drivers_directly'] == true,
      canContactOwnersDirectly: json['can_contact_owners_directly'] == true,
      canUseGoodsCompanies: json['can_use_goods_companies'] == true,
      maxLoadsPerMonth: (json['max_loads_per_month'] as num?)?.toInt() ?? 0,
    );
  }

  /// Whether the subscription grants any transport access at all. The dashboard
  /// uses this to gate its Transport tab on the real plan.
  bool get hasTransportAccess =>
      canContactDriversDirectly || canUseGoodsCompanies;
}
