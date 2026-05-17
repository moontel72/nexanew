import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_marketplace_product_model.dart';

class ResellerMarketplaceRemoteDatasource {
  final ApiService _api;

  ResellerMarketplaceRemoteDatasource({required ApiService apiService})
    : _api = apiService;

  /// Fetch list of available factories (companies with marketplace enabled).
  /// Returns an empty list on any error — never throws.
  Future<List<Map<String, dynamic>>> listFactories({String? tenantId}) async {
    try {
      final res = await _api.get(
        ApiEndpoints.availableFactories,
        queryParameters: {
          if (tenantId != null && tenantId.isNotEmpty) 'tenant_id': tenantId,
        },
      );

      if (res is Map) {
        final data = res['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((m) => m.cast<String, dynamic>())
              .toList();
        }
      }
      return [];
    } catch (_) {
      // Return empty list on any error — the BLoC/screen will show empty state
      return [];
    }
  }

  /// Fetch products for a given factory.
  /// Returns an empty list on any error — never throws.
  Future<List<ResellerMarketplaceProductModel>> listProducts({
    required String tenantId,
    required String factoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _api.get(
        ApiEndpoints.browseProducts,
        queryParameters: {
          'tenant_id': tenantId,
          'factory_id': factoryId,
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (res is Map) {
        final data = res['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map(
                (m) => ResellerMarketplaceProductModel.fromJson(
                  m.cast<String, dynamic>(),
                ),
              )
              .toList();
        }
      }
      return [];
    } catch (_) {
      // Return empty list on any error — the BLoC/screen will show empty state
      return [];
    }
  }
}
