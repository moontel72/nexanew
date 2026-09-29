import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';

/// One page of the public browse API, with what the storefront needs to draw
/// page numbers (the API already returns total / total_pages).
class MpPage {
  const MpPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<Map<String, dynamic>> items;
  final int page;
  final int totalPages;
  final int total;

  static const empty = MpPage(items: [], page: 1, totalPages: 1, total: 0);
}

/// Read-only data access for the public marketplace site.
///
/// It talks to the same public endpoints the reseller app uses
/// (`/reseller/products`, `/reseller/factories`) with `requiresAuth: false` —
/// this site has no login at all (MASTER-TASK-LIST.md §4 done-ledger item #12), so it must never
/// send or expect a token.
class MarketplacePublicRepository {
  MarketplacePublicRepository({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  /// Published products across every active factory, one page at a time.
  /// [sortBy] is one of `popular` (default), `newest`, `price_asc`,
  /// `price_desc`, `name` — ordering happens server-side.
  Future<MpPage> productsPage({
    String? search,
    String? factoryId,
    String? category,
    String sortBy = 'popular',
    int page = 1,
    int limit = 12,
  }) async {
    final res = await _api.get(
      ApiEndpoints.resellerMarketplaceProducts,
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.isNotEmpty) 'category': category,
        if (factoryId != null && factoryId.isNotEmpty) 'factory_id': factoryId,
      },
      requiresAuth: false,
    );

    final map = res is Map ? res.cast<String, dynamic>() : <String, dynamic>{};
    final data = map['data'];
    final items = data is List
        ? data.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : <Map<String, dynamic>>[];

    return MpPage(
      items: items,
      page: _int(map['page'], page),
      totalPages: _int(map['total_pages'], 1),
      total: _int(map['total'], items.length),
    );
  }

  /// Convenience wrapper for callers that only want the first page's items
  /// (the storefront page lists one factory's products in full).
  Future<List<Map<String, dynamic>>> products({
    String? search,
    String? factoryId,
    int page = 1,
    int limit = 48,
  }) async {
    final result = await productsPage(
      search: search,
      factoryId: factoryId,
      page: page,
      limit: limit,
    );
    return result.items;
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

int _int(dynamic value, int fallback) {
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? fallback;
}
