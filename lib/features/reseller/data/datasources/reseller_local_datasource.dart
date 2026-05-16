import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_employee_model.dart';
import 'package:nexatrace_system/shared/models/reseller/reseller_shop_model.dart';
import 'package:nexatrace_system/shared/models/wallet/wallet_model.dart';

class ResellerLocalDatasource {
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  ResellerLocalDatasource(this._prefs);

  static const _kResellerId = 'reseller_current_user_id';
  static const _kToken = 'reseller_auth_token';
  static const _kShops = 'reseller_shops';
  static const _kEmployees = 'reseller_employees';
  static const _kWallet = 'reseller_wallet';
  static const _kDeviceId = 'reseller_device_id';

  String? getToken() => _prefs.getString(_kToken);

  String? getResellerId() => _prefs.getString(_kResellerId);

  Future<void> setSession({
    required String resellerId,
    required String token,
  }) async {
    await _prefs.setString(_kResellerId, resellerId);
    await _prefs.setString(_kToken, token);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_kResellerId);
    await _prefs.remove(_kToken);
  }

  Future<String> getOrCreateDeviceId() async {
    final existing = _prefs.getString(_kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _uuid.v4();
    await _prefs.setString(_kDeviceId, id);
    return id;
  }

  List<ResellerShopModel> listShops(String resellerId) {
    final raw = _prefs.getString(_kShops);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => ResellerShopModel.fromJson(m.cast<String, dynamic>()))
        .where((s) => s.resellerId == resellerId)
        .toList();
  }

  Future<ResellerShopModel> createShop({
    required String resellerId,
    required String name,
  }) async {
    final now = DateTime.now();
    final shop = ResellerShopModel(
      id: _uuid.v4(),
      resellerId: resellerId,
      name: name,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final all = _readShopList();
    all.add(shop.toJson());
    await _prefs.setString(_kShops, jsonEncode(all));
    return shop;
  }

  Future<int> deleteShop({
    required String resellerId,
    required String shopId,
  }) async {
    final all = _readShopList();
    final before = all.length;
    all.removeWhere((m) {
      final map = (m as Map).cast<String, dynamic>();
      return map['resellerId'] == resellerId && map['id'] == shopId;
    });
    await _prefs.setString(_kShops, jsonEncode(all));

    final employees = _readEmployeeList();
    employees.removeWhere((m) {
      final map = (m as Map).cast<String, dynamic>();
      return map['resellerId'] == resellerId && map['shopId'] == shopId;
    });
    await _prefs.setString(_kEmployees, jsonEncode(employees));

    return before - all.length;
  }

  List<ResellerEmployeeModel> listEmployees({
    required String resellerId,
    String? shopId,
  }) {
    final raw = _prefs.getString(_kEmployees);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => ResellerEmployeeModel.fromJson(m.cast<String, dynamic>()))
        .where((e) => e.resellerId == resellerId)
        .where((e) => shopId == null ? true : e.shopId == shopId)
        .toList();
  }

  Future<ResellerEmployeeModel> createEmployee({
    required String resellerId,
    required String shopId,
    required String name,
    required ResellerEmployeeRole role,
  }) async {
    final now = DateTime.now();
    final employee = ResellerEmployeeModel(
      id: _uuid.v4(),
      resellerId: resellerId,
      shopId: shopId,
      name: name,
      role: role,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final employees = _readEmployeeList();
    employees.add(employee.toJson());
    await _prefs.setString(_kEmployees, jsonEncode(employees));
    return employee;
  }

  Future<int> deleteEmployee({
    required String resellerId,
    required String employeeId,
  }) async {
    final employees = _readEmployeeList();
    final before = employees.length;
    employees.removeWhere((m) {
      final map = (m as Map).cast<String, dynamic>();
      return map['resellerId'] == resellerId && map['id'] == employeeId;
    });
    await _prefs.setString(_kEmployees, jsonEncode(employees));
    return before - employees.length;
  }

  WalletModel getOrCreateWallet(String resellerId) {
    final raw = _prefs.getString(_kWallet);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final wallet = WalletModel.fromJson(decoded.cast<String, dynamic>());
        if (wallet.userId == resellerId) return wallet;
      }
    }

    final now = DateTime.now();
    final wallet = WalletModel(
      id: _uuid.v4(),
      userId: resellerId,
      userType: UserType.reseller,
      balance: 0.0,
      minimumBalance: 500.0,
      lastUpdated: now,
      createdAt: now,
      currency: 'PKR',
    );
    _prefs.setString(_kWallet, jsonEncode(wallet.toJson()));
    return wallet;
  }

  Future<WalletModel> updateWallet(WalletModel wallet) async {
    await _prefs.setString(_kWallet, jsonEncode(wallet.toJson()));
    return wallet;
  }

  List<dynamic> _readShopList() {
    final raw = _prefs.getString(_kShops);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded;
    return [];
  }

  List<dynamic> _readEmployeeList() {
    final raw = _prefs.getString(_kEmployees);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded;
    return [];
  }
}

