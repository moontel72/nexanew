// Web-Safe Secure Storage — Adaptive persistence for Flutter Web on HTTP
// =======================================================================
// FlutterSecureStorage requires HTTPS (Web Crypto APIs).  On HTTP origins
// it throws "Unsupported operation: FlutterSecureStorageWeb only works in
// secure contexts".  This wrapper:
//
//   1. Tries FlutterSecureStorage first (works on mobile + HTTPS web).
//   2. Catches the secure-context error on insecure HTTP web and falls
//      back to SharedPreferences.
//
// Usage:  const WebSafeStorage();  // replaces `const FlutterSecureStorage()`

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSafeStorage {
  final FlutterSecureStorage _secure;
  SharedPreferences? _prefs;

  /// Use [WebSafeStorage()] (no const) because [_prefs] is lazily initialised.
  // ignore: prefer_const_constructors
  WebSafeStorage() : _secure = const FlutterSecureStorage();

  // ── Read ──────────────────────────────────────────────────

  Future<String?> read({required String key}) async {
    try {
      return await _secure.read(key: key);
    } catch (e) {
      if (_isWebInsecureError(e)) {
        final p = await _prefsInstance();
        return p.getString(key);
      }
      rethrow;
    }
  }

  // ── Write ─────────────────────────────────────────────────

  Future<void> write({required String key, required String? value}) async {
    try {
      await _secure.write(key: key, value: value);
    } catch (e) {
      if (_isWebInsecureError(e)) {
        final p = await _prefsInstance();
        if (value == null) {
          await p.remove(key);
        } else {
          await p.setString(key, value);
        }
        return;
      }
      rethrow;
    }
  }

  // ── Delete ────────────────────────────────────────────────

  Future<void> delete({required String key}) async {
    try {
      await _secure.delete(key: key);
    } catch (e) {
      if (_isWebInsecureError(e)) {
        final p = await _prefsInstance();
        await p.remove(key);
        return;
      }
      rethrow;
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  Future<SharedPreferences> _prefsInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns true when the error is FlutterSecureStorageWeb refusing to
  /// operate on an insecure (non-HTTPS / non-localhost) origin.
  bool _isWebInsecureError(Object e) {
    if (!kIsWeb) return false;
    final msg = e.toString();
    return msg.contains('secure contexts') ||
        msg.contains('Unsupported operation') ||
        e is UnsupportedError;
  }
}
