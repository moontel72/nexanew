import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/models/order/cart_item_model.dart';
import 'package:nexatrace_system/shared/models/order/order_model.dart';

class ResellerOrderRemoteDatasource {
  final ApiService _api;

  ResellerOrderRemoteDatasource({required ApiService apiService})
      : _api = apiService;

  /// Place a new order with the factory.
  /// Payload includes tenant_id, factory_id, and reseller_id for multi-vendor routing.
  Future<OrderModel> placeOrder({
    required String tenantId,
    required String factoryId,
    required String resellerId,
    required List<CartItemModel> items,
  }) async {
    final res = await _api.post(
      ApiEndpoints.placeOrder,
      body: {
        'tenant_id': tenantId,
        'factory_id': factoryId,
        'reseller_id': resellerId,
        'items': items
            .map((e) => {
                  'product_id': e.productId,
                  'tenant_id': e.tenantId,
                  'factory_id': e.factoryId,
                  'quantity': e.quantity,
                  'unit_price': e.unitPrice,
                })
            .toList(),
      },
    );

    if (res is Map) {
      final data = res['data'] ?? res;
      return OrderModel.fromJson((data as Map).cast<String, dynamic>());
    }
    throw Exception('Invalid order response from server');
  }

  /// Fetch paginated order history for a reseller, optionally filtered by factory.
  Future<List<OrderModel>> fetchOrderHistory({
    required String resellerId,
    String? tenantId,
    String? factoryId,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.get(
      ApiEndpoints.orderHistory,
      queryParameters: {
        'reseller_id': resellerId,
        if (tenantId != null && tenantId.isNotEmpty) 'tenant_id': tenantId,
        if (factoryId != null && factoryId.isNotEmpty) 'factory_id': factoryId,
        'page': page,
        'limit': limit,
      },
    );

    if (res is Map) {
      final data = res['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((m) => OrderModel.fromJson(m.cast<String, dynamic>()))
            .toList();
      }
    }
    return [];
  }

  /// Fetch a single order's full detail.
  Future<OrderModel> fetchOrderDetail(String orderId) async {
    final url = ApiEndpoints.getOrderDetailsUrl(orderId);
    final res = await _api.get(url);

    if (res is Map) {
      final data = res['data'] ?? res;
      return OrderModel.fromJson((data as Map).cast<String, dynamic>());
    }
    throw Exception('Failed to fetch order detail');
  }
}
