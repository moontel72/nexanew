import 'package:flutter/foundation.dart';
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
        } else {
          debugPrint(
            'MARKETPLACE WARNING [listFactories]: Unexpected response format: $res',
          );
        }
      }
      return [];
    } catch (e, st) {
      debugPrint('MARKETPLACE ERROR [listFactories]: $e\n$st');
      return [];
    }
  }

  /// Fetch products for a given factory, or all factories if factoryId is null.
  /// Returns an empty list on any error — never throws.
  Future<List<ResellerMarketplaceProductModel>> listProducts({
    required String tenantId,
    String? factoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'tenant_id': tenantId,
        'page': page,
        'limit': limit,
        if (factoryId != null && factoryId.isNotEmpty) 'factory_id': factoryId,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final res = await _api.get(
        ApiEndpoints.browseProducts,
        queryParameters: params,
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
        } else {
          debugPrint(
            'MARKETPLACE WARNING [listProducts]: Unexpected response format: $res',
          );
        }
      }
      return [];
    } catch (e, st) {
      debugPrint('MARKETPLACE ERROR [listProducts]: $e\n$st');
      return [];
    }
  }
}
