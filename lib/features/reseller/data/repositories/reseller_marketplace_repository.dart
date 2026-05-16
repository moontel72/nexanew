import 'package:nexatrace_system/features/reseller/data/datasources/reseller_marketplace_remote_datasource.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_marketplace_product_model.dart';

class ResellerMarketplaceRepository {
  final ResellerMarketplaceRemoteDatasource _remote;

  ResellerMarketplaceRepository({required ResellerMarketplaceRemoteDatasource remote})
      : _remote = remote;

  Future<List<Map<String, dynamic>>> getFactories({String? tenantId}) {
    return _remote.listFactories(tenantId: tenantId);
  }

  Future<List<ResellerMarketplaceProductModel>> getProducts({
    required String tenantId,
    required String factoryId,
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
}

