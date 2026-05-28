import 'package:trace_odd/features/reseller/data/datasources/reseller_order_remote_datasource.dart';
import 'package:trace_odd/shared/models/order/cart_item_model.dart';
import 'package:trace_odd/shared/models/order/order_model.dart';

class ResellerOrderRepository {
  final ResellerOrderRemoteDatasource _remote;

  ResellerOrderRepository({required ResellerOrderRemoteDatasource remote})
      : _remote = remote;

  Future<OrderModel> placeOrder({
    required String tenantId,
    required String factoryId,
    required String resellerId,
    required List<CartItemModel> items,
  }) {
    return _remote.placeOrder(
      tenantId: tenantId,
      factoryId: factoryId,
      resellerId: resellerId,
      items: items,
    );
  }

  Future<List<OrderModel>> fetchOrderHistory({
    required String resellerId,
    String? tenantId,
    String? factoryId,
    int page = 1,
    int limit = 20,
  }) {
    return _remote.fetchOrderHistory(
      resellerId: resellerId,
      tenantId: tenantId,
      factoryId: factoryId,
      page: page,
      limit: limit,
    );
  }

  Future<OrderModel> fetchOrderDetail(String orderId) {
    return _remote.fetchOrderDetail(orderId);
  }
}
