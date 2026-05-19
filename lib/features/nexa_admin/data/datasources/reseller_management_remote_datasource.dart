import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';

class ResellerManagementRemoteDatasource {
  final ApiService _api;

  ResellerManagementRemoteDatasource({required ApiService apiService})
    : _api = apiService;

  // ── List / Search ────────────────────────────────────────────────
  Future<Map<String, dynamic>> listResellers({
    String search = '',
    String? status,
    String? city,
    String? planType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await _api.get(
      ApiEndpoints.adminResellers,
      queryParameters: {
        'search': search,
        if (status != null) 'status': status,
        if (city != null) 'city': city,
        if (planType != null) 'plan_type': planType,
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page,
        'per_page': perPage,
      },
    );
    return _asMap(res);
  }

  // ── Detail ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getResellerDetail(String id) async {
    final res = await _api.get(ApiEndpoints.adminResellerDetail(id));
    return _asMap(res, unwrapData: true);
  }

  // ── Create ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createReseller({
    required String name,
    required String businessName,
    required String registrationNo,
    required String email,
    required String phone,
    required String password,
    required String city,
    String? address,
    String? planId,
  }) async {
    final res = await _api.post(
      ApiEndpoints.adminCreateReseller,
      body: {
        'name': name,
        'business_name': businessName,
        'registration_no': registrationNo,
        'email': email,
        'phone': phone,
        'password': password,
        'city': city,
        if (address != null) 'address': address,
        if (planId != null) 'plan_id': planId,
      },
    );
    return _asMap(res, unwrapData: true);
  }

  // ── Update ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateReseller({
    required String id,
    String? name,
    String? businessName,
    String? registrationNo,
    String? email,
    String? phone,
    String? city,
    String? address,
    String? planId,
  }) async {
    final res = await _api.put(
      ApiEndpoints.adminUpdateReseller(id),
      body: {
        if (name != null) 'name': name,
        if (businessName != null) 'business_name': businessName,
        if (registrationNo != null) 'registration_no': registrationNo,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
        if (address != null) 'address': address,
        if (planId != null) 'plan_id': planId,
      },
    );
    return _asMap(res, unwrapData: true);
  }

  // ── Delete (soft) ────────────────────────────────────────────────
  Future<void> deleteReseller(String id) async {
    await _api.delete(ApiEndpoints.adminDeleteReseller(id));
  }

  // ── Status update ────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateResellerStatus({
    required String id,
    required String status,
    String? reason,
  }) async {
    final res = await _api.patch(
      ApiEndpoints.adminUpdateResellerStatus(id),
      body: {'status': status, if (reason != null) 'reason': reason},
    );
    return _asMap(res, unwrapData: true);
  }

  // ── Suspend / Unsuspend ──────────────────────────────────────────
  Future<Map<String, dynamic>> toggleSuspend({
    required String id,
    required bool suspend,
    String? reason,
  }) async {
    final res = await _api.patch(
      ApiEndpoints.adminSuspendReseller(id),
      body: {'suspend': suspend, if (reason != null) 'reason': reason},
    );
    return _asMap(res, unwrapData: true);
  }

  // ── Purchase Approval ────────────────────────────────────────────
  Future<Map<String, dynamic>> approvePurchase(String id) async {
    final res = await _api.patch(ApiEndpoints.adminApproveResellerPurchase(id));
    return _asMap(res, unwrapData: true);
  }

  Future<Map<String, dynamic>> rejectPurchase(String id) async {
    final res = await _api.patch(ApiEndpoints.adminRejectResellerPurchase(id));
    return _asMap(res, unwrapData: true);
  }

  Future<Map<String, dynamic>> viewProof(String id) async {
    final res = await _api.get(ApiEndpoints.adminViewResellerProof(id));
    return _asMap(res, unwrapData: true);
  }

  // ── Helpers ──────────────────────────────────────────────────────
  Map<String, dynamic> _asMap(dynamic res, {bool unwrapData = false}) {
    if (res is Map) {
      final data = res['data'];
      if (unwrapData && data is Map) {
        return data.cast<String, dynamic>();
      }
      return res.cast<String, dynamic>();
    }
    throw Exception('Unexpected API response');
  }
}
