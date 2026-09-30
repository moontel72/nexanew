// Repository for the factory's real plan/subscription limits (item 9).

import 'package:trace_odd/features/factory/admin/data/datasources/subscription_remote_datasource.dart';
import 'package:trace_odd/shared/models/subscription/plan_limit_model.dart';

class SubscriptionRepository {
  final SubscriptionRemoteDatasource _datasource;

  SubscriptionRepository({SubscriptionRemoteDatasource? datasource})
    : _datasource = datasource ?? SubscriptionRemoteDatasource();

  Future<PlanLimitModel> getPlanLimits() async {
    final data = await _datasource.getPlanLimits();
    return PlanLimitModel.fromJson(data);
  }
}
