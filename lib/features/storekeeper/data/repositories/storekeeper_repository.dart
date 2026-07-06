/// Repository for StoreKeeper Catering & Inventory operations.
library;

import 'package:trace_odd/core/services/api_service.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_category.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_item.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_issuance.dart';
import 'package:trace_odd/features/storekeeper/domain/models/catering_reconciliation.dart';
import 'package:trace_odd/features/storekeeper/domain/models/storekeeper_dashboard.dart';

class StorekeeperRepository {
  final ApiService _api;
  final String _panel; // 'bus-fleet' or 'bus-owner'
  late final String _prefix; // e.g. '/api/v1/bus-fleet/storekeeper'

  StorekeeperRepository({ApiService? api, String panel = 'bus-fleet'})
    : _api = api ?? ApiService(),
      _panel = panel {
    _prefix = '/api/v1/$_panel/storekeeper';
  }

  // ─── Dashboard ──────────────────────────────────────────────

  Future<StorekeeperDashboardData> getDashboard() async {
    final r = await _api.get('$_prefix/dashboard');
    return StorekeeperDashboardData.fromJson(r['data'] ?? {});
  }

  // ─── Categories ─────────────────────────────────────────────

  Future<List<CateringCategory>> getCategories() async {
    final r = await _api.get('$_prefix/categories');
    final list = (r['data'] as List<dynamic>?) ?? [];
    return list.map((j) => CateringCategory.fromJson(j)).toList();
  }

  Future<CateringCategory> createCategory(Map<String, dynamic> data) async {
    final r = await _api.post('$_prefix/categories', body: data);
    return CateringCategory.fromJson(r['data']);
  }

  Future<CateringCategory> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    final r = await _api.put('$_prefix/categories/$id', body: data);
    return CateringCategory.fromJson(r['data']);
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete('$_prefix/categories/$id');
  }

  // ─── Items ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getItems({
    String? categoryId,
    String? status,
    String? search,
    bool lowStock = false,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (categoryId != null) params['category_id'] = categoryId;
    if (status != null) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (lowStock) params['low_stock'] = '1';

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final r = await _api.get('$_prefix/items?$query');

    final list = (r['data'] as List<dynamic>?) ?? [];
    final items = list.map((j) => CateringItem.fromJson(j)).toList();
    final meta = r['meta'] as Map<String, dynamic>? ?? {};

    return {'items': items, 'meta': meta};
  }

  Future<CateringItem> getItem(String id) async {
    final r = await _api.get('$_prefix/items/$id');
    return CateringItem.fromJson(r['data']);
  }

  Future<CateringItem> createItem(Map<String, dynamic> data) async {
    final r = await _api.post('$_prefix/items', body: data);
    return CateringItem.fromJson(r['data']);
  }

  Future<CateringItem> updateItem(String id, Map<String, dynamic> data) async {
    final r = await _api.put('$_prefix/items/$id', body: data);
    return CateringItem.fromJson(r['data']);
  }

  Future<void> deleteItem(String id) async {
    await _api.delete('$_prefix/items/$id');
  }

  Future<int> adjustStock(String id, int adjustment, {String? reason}) async {
    final r = await _api.post(
      '$_prefix/items/$id/adjust-stock',
      body: {'adjustment': adjustment, if (reason != null) 'reason': reason},
    );
    final stock = r['data']?['stock_on_hand'] ?? 0;
    return stock is int ? stock : int.tryParse(stock.toString()) ?? 0;
  }

  // ─── Issuances ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getIssuances({
    String? status,
    String? tripId,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;
    if (tripId != null) params['trip_id'] = tripId;

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final r = await _api.get('$_prefix/issuances?$query');

    final list = (r['data'] as List<dynamic>?) ?? [];
    final issuances = list.map((j) => CateringIssuance.fromJson(j)).toList();
    final meta = r['meta'] as Map<String, dynamic>? ?? {};

    return {'issuances': issuances, 'meta': meta};
  }

  Future<CateringIssuance> getIssuance(String id) async {
    final r = await _api.get('$_prefix/issuances/$id');
    return CateringIssuance.fromJson(r['data']);
  }

  Future<CateringIssuance> createIssuance(Map<String, dynamic> data) async {
    final r = await _api.post('$_prefix/issuances', body: data);
    return CateringIssuance.fromJson(r['data']);
  }

  Future<CateringIssuance> issueItems(String issuanceId) async {
    final r = await _api.post('$_prefix/issuances/$issuanceId/issue');
    return CateringIssuance.fromJson(r['data']);
  }

  // ─── Reconciliations ────────────────────────────────────────

  Future<Map<String, dynamic>> getReconciliations({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final r = await _api.get('$_prefix/reconciliations?$query');

    final list = (r['data'] as List<dynamic>?) ?? [];
    final recs = list.map((j) => CateringReconciliation.fromJson(j)).toList();
    final meta = r['meta'] as Map<String, dynamic>? ?? {};

    return {'reconciliations': recs, 'meta': meta};
  }

  Future<CateringReconciliation> reconcile(
    String issuanceId,
    Map<String, dynamic> data,
  ) async {
    final r = await _api.post(
      '$_prefix/issuances/$issuanceId/reconcile',
      body: data,
    );
    return CateringReconciliation.fromJson(r['data']);
  }

  Future<CateringReconciliation> confirmReconciliation(
    String reconciliationId,
  ) async {
    final r = await _api.post(
      '$_prefix/reconciliations/$reconciliationId/confirm',
    );
    return CateringReconciliation.fromJson(r['data']);
  }

  // ─── Active Dispatch Assignments ───────────────────────────

  Future<List<Map<String, dynamic>>> getActiveAssignments() async {
    final r = await _api.get(
      '/api/v1/$_panel/dispatch/assignments',
      queryParams: {'status': 'active', 'limit': '50'},
    );
    final raw = r['data'];
    List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      list = (raw['data'] as List<dynamic>?) ?? [];
    } else {
      list = [];
    }
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getBundles() async {
    final r = await _api.get('/api/v1/$_panel/storekeeper/bundles');
    final data = r['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}
