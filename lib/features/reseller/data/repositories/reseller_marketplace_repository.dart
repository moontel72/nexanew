import 'package:trace_odd/features/reseller/data/datasources/reseller_marketplace_remote_datasource.dart';
import 'package:trace_odd/shared/models/reseller/reseller_marketplace_product_model.dart';

class ResellerMarketplaceRepository {
  final ResellerMarketplaceRemoteDatasource _remote;

  ResellerMarketplaceRepository({
    required ResellerMarketplaceRemoteDatasource remote,
  }) : _remote = remote;

  Future<List<Map<String, dynamic>>> getFactories({String? tenantId}) {
    return _remote.listFactories(tenantId: tenantId);
  }

  Future<List<ResellerMarketplaceProductModel>> getProducts({
    required String tenantId,
    String? factoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) {
    return _remote.listProducts(
      tenantId: tenantId,
      factoryId: factoryId,
      search: search,
      page: page,
      limit: limit,
    );
  }

  /// Fetch products from all available factories (for "all products" mode).
  Future<List<ResellerMarketplaceProductModel>> getAllProducts({
    required String tenantId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    // First get the list of factories, then fetch products for each.
    final factories = await _remote.listFactories(tenantId: tenantId);
    if (factories.isEmpty) return [];

    final all = <ResellerMarketplaceProductModel>[];
    for (final f in factories) {
      final fid = f['id']?.toString();
      if (fid == null || fid.isEmpty) continue;
      try {
        final products = await _remote.listProducts(
          tenantId: tenantId,
          factoryId: fid,
          search: search,
          page: page,
          limit: limit,
        );
        all.addAll(products);
      } catch (_) {
        // Skip factories that fail — show what we can.
      }
    }
    return all;
  }
}
