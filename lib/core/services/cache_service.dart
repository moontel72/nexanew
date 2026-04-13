class CacheService {
  Future<void> setString(String key, String value, {Duration? ttl}) async {}

  Future<String?> getString(String key) async {
    return null;
  }

  Future<void> remove(String key) async {}
}
