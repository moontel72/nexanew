import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:nexatrace_system/features/reseller/data/datasources/reseller_local_datasource.dart';

class ResellerSessionRepository {
  final ResellerLocalDatasource _local;
  final Uuid _uuid = const Uuid();

  ResellerSessionRepository(SharedPreferences prefs) : _local = ResellerLocalDatasource(prefs);

  bool isAuthenticated() {
    final token = _local.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final resellerId = _uuid.v4();
    final token = 'RES-TOKEN-${_uuid.v4()}';
    await _local.setSession(resellerId: resellerId, token: token);
  }

  Future<void> logout() async {
    await _local.clearSession();
  }
}

