import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/reseller/data/datasources/reseller_local_datasource.dart';

class ResellerSessionRepository {
  final ResellerLocalDatasource _local;

  ResellerSessionRepository(SharedPreferences prefs)
    : _local = ResellerLocalDatasource(prefs);

  bool isAuthenticated() {
    final token = _local.getToken();
    return token != null && token.isNotEmpty;
  }

  String? getResellerId() => _local.getResellerId();
  String? getToken() => _local.getToken();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Call real backend login endpoint
    final res = await ApiService().post(
      '/reseller/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    final data = (res is Map)
        ? (res['data'] ?? res)
        : throw Exception('Invalid response');
    final resellerId = data['resellerId']?.toString();
    final token = data['token']?.toString();
    final name = data['name']?.toString();
    final businessName = data['businessName']?.toString();
    final purchaseApproved = data['purchaseApproved'] == true;

    if (resellerId == null || token == null) {
      throw Exception('Login failed: Invalid server response');
    }

    await _local.setSession(resellerId: resellerId, token: token);
    await _local.setProfile(
      name: name,
      businessName: businessName,
      purchaseApproved: purchaseApproved,
    );

    return {'resellerId': resellerId, 'token': token, 'name': name};
  }

  Future<void> logout() async {
    await _local.clearSession();
  }
}
