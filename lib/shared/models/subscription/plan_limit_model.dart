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
}
