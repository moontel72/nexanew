import 'package:trace_odd/shared/models/wallet/wallet_model.dart';

class SubscriptionFeatureResult {
  final bool allowed;
  final String message;
  final int currentUsage;
  final int limit;
  final String requiredPlan;
  final Map<String, dynamic> limits;
  final Map<String, dynamic> usage;

  const SubscriptionFeatureResult({
    required this.allowed,
    required this.message,
    required this.currentUsage,
    required this.limit,
    required this.requiredPlan,
    required this.limits,
    required this.usage,
  });
}

class SubscriptionService {
  Future<SubscriptionFeatureResult> canUseFeature({
    required String userId,
    required UserType userType,
    required String feature,
  }) async {
    return const SubscriptionFeatureResult(
      allowed: true,
      message: 'Allowed',
      currentUsage: 0,
      limit: 0,
      requiredPlan: '',
      limits: <String, dynamic>{},
      usage: <String, dynamic>{},
    );
  }
}
