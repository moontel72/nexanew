import 'package:trace_odd/features/nexa_admin/data/datasources/reseller_management_remote_datasource.dart';

class ResellerManagementRepository {
  final ResellerManagementRemoteDatasource _remote;

  ResellerManagementRepository({
    required ResellerManagementRemoteDatasource remote,
  }) : _remote = remote;

  Future<Map<String, dynamic>> listResellers({
    String search = '',
    String? status,
    String? city,
    String? planType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) => _remote.listResellers(
    search: search,
    status: status,
    city: city,
    planType: planType,
    sortBy: sortBy,
    sortOrder: sortOrder,
    page: page,
    perPage: perPage,
  );

  Future<Map<String, dynamic>> getResellerDetail(String id) =>
      _remote.getResellerDetail(id);

  Future<Map<String, dynamic>> createReseller({
    required String name,
    required String businessName,
    required String registrationNo,
    required String email,
    required String phone,
    required String password,
    required String city,
    String? address,
  }) => _remote.createReseller(
    name: name,
    businessName: businessName,
    registrationNo: registrationNo,
    email: email,
    phone: phone,
    password: password,
    city: city,
    address: address,
  );

  Future<Map<String, dynamic>> updateReseller({
    required String id,
    String? name,
    String? businessName,
    String? registrationNo,
    String? email,
    String? phone,
    String? city,
    String? address,
    bool? purchaseApproved,
  }) => _remote.updateReseller(
    id: id,
    name: name,
    businessName: businessName,
    registrationNo: registrationNo,
    email: email,
    phone: phone,
    city: city,
    address: address,
    purchaseApproved: purchaseApproved,
  );

  Future<void> deleteReseller(String id) => _remote.deleteReseller(id);

  Future<Map<String, dynamic>> updateResellerStatus({
    required String id,
    required String status,
    String? reason,
  }) => _remote.updateResellerStatus(id: id, status: status, reason: reason);

  Future<Map<String, dynamic>> toggleSuspend({
    required String id,
    required bool suspend,
    String? reason,
  }) => _remote.toggleSuspend(id: id, suspend: suspend, reason: reason);

  Future<Map<String, dynamic>> approvePurchase(String id) =>
      _remote.approvePurchase(id);

  Future<Map<String, dynamic>> rejectPurchase(String id) =>
      _remote.rejectPurchase(id);

  Future<Map<String, dynamic>> viewProof(String id) => _remote.viewProof(id);
}
