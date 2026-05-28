import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trace_odd/core/interfaces/secure_storage_interface.dart';

class SecureStorageService implements SecureStorageInterface {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String? value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
