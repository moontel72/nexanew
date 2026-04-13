import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FactoryAuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  static const _tokenKey = 'factory_auth_token';
  static const _userKey = 'factory_user';
  static const _expiryKey = 'factory_token_expiry';

  FactoryAuthRepository({
    required ApiClient apiClient,
    required SharedPreferences sharedPreferences,
  }) : _apiClient = apiClient,
       _prefs = sharedPreferences;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? companyId,
  }) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.factoryAuth}/login',
      body: {
        'email': email,
        'password': password,
        if (companyId != null && companyId.isNotEmpty) 'company_id': companyId,
      },
      requiresAuth: false,
    );

    final data = (response['data'] is Map)
        ? (response['data'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final token = (data['token'] ?? response['token'])?.toString();
    final user = (data['user'] is Map)
        ? (data['user'] as Map).cast<String, dynamic>()
        : (response['user'] is Map)
        ? (response['user'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token received');
    }

    await _apiClient.setAuthToken(token);

    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user));
    await _prefs.setString(
      _expiryKey,
      DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    );

    return {'token': token, 'user': user, 'raw': response};
  }

  Future<void> logout() async {
    await _apiClient.post('${ApiEndpoints.factoryAuth}/logout');
    await _apiClient.clearAuthToken();
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    await _prefs.remove(_expiryKey);
  }

  Future<Map<String, dynamic>> profile() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.factoryAuth}/profile',
    );
    if (response is Map && response['data'] is Map) {
      return (response['data'] as Map).cast<String, dynamic>();
    }
    return (response as Map).cast<String, dynamic>();
  }

  Future<bool> isAuthenticated() async {
    final token = _prefs.getString(_tokenKey);
    final expiryString = _prefs.getString(_expiryKey);

    if (token == null || expiryString == null) return false;

    final expiry = DateTime.tryParse(expiryString);
    if (expiry == null) return false;

    return expiry.isAfter(DateTime.now());
  }
}
