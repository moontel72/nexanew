// Remote datasource for the factory's real plan/subscription limits.
//
// MASTER-TASK-LIST.md item 9: the factory dashboard's Transport tab used to run
// on a hardcoded `const PlanLimitModel`, so it showed the same features for every
// factory. This reads the plan the factory actually pays for.

import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';

class SubscriptionRemoteDatasource {
  final ApiService _api;

  SubscriptionRemoteDatasource({ApiService? api}) : _api = api ?? ApiService();

  /// Returns the `data` object of the limits response, or an empty map when the
  /// server sends no body. Failure (non-2xx) surfaces as a thrown exception from
  /// [ApiService.get], which the caller turns into a copyable error banner.
  Future<Map<String, dynamic>> getPlanLimits() async {
    final response = await _api.get(ApiEndpoints.factorySubscriptionLimits);

    // Eager copy, not a lazy `Map.cast`: a cast that rejects a value throws later
    // (during build) instead of here, where it belongs.
    final body = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};

    final data = body['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
