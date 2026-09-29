import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';

/// Read-only data access for the public marketplace site.
///
/// It talks to the same public endpoints the reseller app uses
/// (`/reseller/products`, `/reseller/factories`) with `requiresAuth: false` —
/// this site has no login at all (MASTER-TASK-LIST item #12), so it must never
/// send or expect a token.
class MarketplacePublicRepository {
  MarketplacePublicRepository({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  /// Published products across every active factory. Optional [factoryId]
  /// narrows it to one factory (the storefront page), [search] is free text.
  Future<List<Map<String, dynamic>>> products({
    String? search,
    String? factoryId,
    int page = 1,
    int limit = 48,
  }) async {
    final res = await _api.get(
      ApiEndpoints.resellerMarketplaceProducts,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (factoryId != null && factoryId.isNotEmpty) 'factory_id': factoryId,
      },
      requiresAuth: false,
    );

    final map = res is Map ? res.cast<String, dynamic>() : <String, dynamic>{};
    final data = map['data'];
    if (data is! List) return const [];

    return data.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }

  /// Active factories that have at least one published product.
  Future<List<Map<String, dynamic>>> factories() async {
    final res = await _api.get(
      ApiEndpoints.resellerMarketplaceFactories,
      requiresAuth: false,
    );

    final map = res is Map ? res.cast<String, dynamic>() : <String, dynamic>{};
    final data = map['data'];
    if (data is! List) return const [];

    return data.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
}
