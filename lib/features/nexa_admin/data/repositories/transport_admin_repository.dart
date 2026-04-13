import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/shared/models/transport/admin_transport_stats.dart';

class TransportAdminRepository {
  final ApiClient apiClient;

  TransportAdminRepository({required this.apiClient});

  Future<WalletAdminStats> getWalletStats() async {
    final res = await apiClient.get(ApiEndpoints.adminTransportWalletStats);
    final data = (res is Map ? (res['data'] as Map?) : null) ?? const {};
    return WalletAdminStats.fromApi(data.cast<String, dynamic>());
  }

  Future<MarketplaceAdminStats> getMarketplaceStats() async {
    final res = await apiClient.get(ApiEndpoints.adminTransportMarketplaceStats);
    final data = (res is Map ? (res['data'] as Map?) : null) ?? const {};
    return MarketplaceAdminStats.fromApi(data.cast<String, dynamic>());
  }

  Future<DriversAdminStats> getDriversStats() async {
    final res = await apiClient.get(ApiEndpoints.adminTransportDriversStats);
    final data = (res is Map ? (res['data'] as Map?) : null) ?? const {};
    return DriversAdminStats.fromApi(data.cast<String, dynamic>());
  }

  Future<FraudAdminStats> getFraudStats() async {
    final res = await apiClient.get(ApiEndpoints.transportFraudStats);
    final data = (res is Map ? (res['data'] as Map?) : null) ?? const {};
    return FraudAdminStats.fromApi(data.cast<String, dynamic>());
  }
}

