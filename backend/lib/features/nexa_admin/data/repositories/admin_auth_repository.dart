// Admin Authentication Repository for NexaTrace System
// Simplified version to fix compilation errors

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nexatrace_system/core/interfaces/secure_storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:nexatrace_system/core/config/api_config.dart';
import 'package:nexatrace_system/core/errors/app_exceptions.dart';
import 'package:nexatrace_system/core/services/api_client.dart';
import 'package:nexatrace_system/features/nexa_admin/domain/entities/admin_user.dart';

/// Authentication response model
class AuthResponse {
  final AdminUser user;
  final String token;
  final DateTime tokenExpiry;
  final bool needsPasswordChange;

  AuthResponse({
    required this.user,
    required this.token,
    required this.tokenExpiry,
    required this.needsPasswordChange,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AdminUser.fromJson(json['user']),
      token: json['token'],
      tokenExpiry: DateTime.parse(json['token_expiry']),
      needsPasswordChange: json['needs_password_change'] ?? false,
    );
  }
}

/// Authentication repository for super admin
class AdminAuthRepository {
  final ApiClient apiClient;
  final SecureStorageInterface secureStorage;

  final SharedPreferences sharedPreferences;

  AdminAuthRepository({
    required this.apiClient,
    required this.secureStorage,
    required this.sharedPreferences,
  });

  Future<String?> _readString(String key) async {
    try {
      final value = await secureStorage.read(key: key);
      if (value != null) return value;
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Secure storage read failed for $key');
      }
    }

    return sharedPreferences.getString(key);
  }

  Future<void> _writeString(String key, String value) async {
    try {
      await secureStorage.write(key: key, value: value);
      if (kIsWeb) {
        await sharedPreferences.setString(key, value);
      }
      return;
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Secure storage write failed for $key');
      }
    }

    await sharedPreferences.setString(key, value);
  }

  Future<void> _deleteKey(String key) async {
    try {
      await secureStorage.delete(key: key);
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Secure storage delete failed for $key');
      }
    }

    await sharedPreferences.remove(key);
  }

  /// Login with email and password
  Future<void> _clearLocalAuth() async {
    await apiClient.clearAuthToken();
    await _deleteKey('admin_auth_token');
    await _deleteKey('admin_user');
    await _deleteKey('admin_token_expiry');
    await _deleteKey('admin_remember_me');
    await _deleteKey('admin_refresh_token');
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
    String? twoFactorCode,
  }) async {
    try {
      final sanitizedEmail = email
          .replaceAll(RegExp(r'\s+'), '')
          .trim()
          .toLowerCase();
      if (kDebugMode) {
        debugPrint(
          'AUTH_LOGIN start emailProvided=${sanitizedEmail.isNotEmpty}',
        );
        debugPrint('AUTH_LOGIN endpoint=${ApiConfig.apiBaseUrl}/auth/login');
      }
      final response = await apiClient.post(
        '${ApiConfig.apiBaseUrl}/auth/login',
        body: {
          'email': sanitizedEmail,
          'password': password,
          'remember_me': rememberMe,
          if (twoFactorCode != null && twoFactorCode.isNotEmpty)
            'two_factor_code': twoFactorCode,
        },
        requiresAuth: false,
      );

      final authResponse = AuthResponse.fromJson(response['data']);

      await apiClient.setAuthToken(authResponse.token);

      await _writeString('admin_auth_token', authResponse.token);
      await _writeString('admin_user', jsonEncode(authResponse.user.toJson()));
      await _writeString(
        'admin_token_expiry',
        authResponse.tokenExpiry.toIso8601String(),
      );
      await _writeString('admin_remember_me', rememberMe.toString());

      if (kDebugMode) {
        debugPrint('AUTH_LOGIN success tokenSaved=true');
      }
      return authResponse;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AUTH_LOGIN error=${error.runtimeType}');
      }
      if (error is UnauthorizedException) {
        throw AuthException('Invalid email or password');
      } else if (error is NetworkException) {
        throw NetworkException('Network error occurred');
      } else {
        throw AuthException('Login failed: ${error.toString()}');
      }
    }
  }

  /// Logout current admin
  Future<void> logout([String? token]) async {
    try {
      await apiClient.logout();
    } catch (error) {
      // Even if API call fails, clear local storage
    } finally {
      await _deleteKey('admin_auth_token');
      await _deleteKey('admin_user');
      await _deleteKey('admin_token_expiry');
      await _deleteKey('admin_remember_me');
      await _deleteKey('admin_refresh_token');
    }
  }

  /// Check if admin is authenticated - PURE LOCAL CHECK, NO SIDE EFFECTS
  /// This method is called during router redirect and must be fast and safe
  Future<bool> isAuthenticated() async {
    if (kDebugMode) {
      debugPrint('AUTH_CHECK start');
    }

    try {
      final token = await _readString('admin_auth_token');
      final userJson = await _readString('admin_user');
      final expiryString = await _readString('admin_token_expiry');

      if (kDebugMode) {
        debugPrint(
          'AUTH_CHECK stored token=${token != null} user=${userJson != null} expiry=${expiryString != null}',
        );
      }

      // Missing any required data = not authenticated
      if (token == null || userJson == null || expiryString == null) {
        return false;
      }

      // Check expiry - DO NOT clear auth data here to avoid side effects
      final expiry = DateTime.tryParse(expiryString);
      if (expiry == null) {
        if (kDebugMode) {
          debugPrint('AUTH_CHECK invalid expiry format');
        }
        return false;
      }

      if (expiry.isBefore(DateTime.now())) {
        if (kDebugMode) {
          debugPrint('AUTH_CHECK token expired');
        }
        // NOTE: We do NOT call _clearLocalAuth() here to avoid side effects
        // The token will be cleared on next login attempt or explicit logout
        return false;
      }

      if (kDebugMode) {
        debugPrint('AUTH_CHECK valid session');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AUTH_CHECK exception: $e');
      }
      return false;
    }
  }

  /// Get current admin user
  Future<AdminUser?> getCurrentUser() async {
    try {
      final userJson = await _readString('admin_user');
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return AdminUser.fromJson(userMap);
    } catch (storageError) {
      // If storage fails, return null
      debugPrint('Secure storage read failed: $storageError');
      return null;
    }
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    return _readString('admin_auth_token');
  }

  Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _readString('admin_token_expiry');
    if (expiryString == null) return null;
    return DateTime.tryParse(expiryString);
  }

  Future<String?> getRefreshToken() async {
    return _readString('admin_refresh_token');
  }

  /// Refresh authentication token
  Future<AuthResponse> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    try {
      final response = await apiClient.post(
        '${ApiConfig.apiBaseUrl}/auth/refresh',
        body: {'refresh_token': refreshToken},
      );

      final authResponse = AuthResponse.fromJson(response['data']);

      await apiClient.setAuthToken(authResponse.token);
      await _writeString('admin_auth_token', authResponse.token);
      await _writeString(
        'admin_token_expiry',
        authResponse.tokenExpiry.toIso8601String(),
      );
      await _writeString('admin_user', jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } catch (error) {
      // If refresh fails, try to clear auth data
      try {
        await clearAuthData();
      } catch (clearError) {
        debugPrint('Failed to clear auth data: $clearError');
      }
      rethrow;
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        throw ValidationException({'new_password': 'Passwords do not match'});
      }

      await apiClient.post(
        '${ApiConfig.apiBaseUrl}/auth/change-password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );
    } catch (error) {
      if (error is UnauthorizedException) {
        throw AuthException('Current password is incorrect');
      } else if (error is ValidationException) {
        rethrow;
      } else {
        throw AuthException('Failed to change password');
      }
    }
  }

  /// Request password reset
  Future<void> forgotPassword({required String email}) async {
    try {
      await apiClient.post(
        '${ApiConfig.apiBaseUrl}/auth/forgot-password',
        body: {'email': email},
      );
    } catch (error) {
      // Don't throw error to avoid revealing if email exists
      // Just log and continue
    }
  }

  Future<AdminUser> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    final current = await getCurrentUser();
    if (current == null) {
      throw AuthException('No admin user found');
    }

    final updated = current.copyWith(
      name: name ?? current.name,
      email: email ?? current.email,
      phone: phone ?? current.phone,
      avatarUrl: profileImage ?? current.avatarUrl,
    );

    await _writeString('admin_user', jsonEncode(updated.toJson()));

    return updated;
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await apiClient.post(
        '${ApiConfig.apiBaseUrl}/auth/reset-password',
        body: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } catch (error) {
      if (error is ValidationException) {
        rethrow;
      } else {
        throw AuthException('Failed to reset password');
      }
    }
  }

  /// Validate current session
  Future<bool> validateSession() async {
    try {
      if (!await isAuthenticated()) {
        return false;
      }

      await apiClient.get('${ApiConfig.apiBaseUrl}/auth/validate');
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    await _deleteKey('admin_auth_token');
    await _deleteKey('admin_user');
    await _deleteKey('admin_token_expiry');
    await _deleteKey('admin_remember_me');
    await _deleteKey('admin_refresh_token');
  }
}
