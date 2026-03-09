class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  _CacheEntry({required this.data, required this.timestamp});
}

class CacheService {
  static final CacheService _instance = CacheService._();

  factory CacheService() {
    return _instance;
  }

  CacheService._();

  final Map<String, _CacheEntry<dynamic>> _cache = {};

  // Default TTL: 24 hours
  T? get<T>(String key, {Duration ttl = const Duration(hours: 24)}) {
    final entry = _cache[key];
    if (entry != null) {
      if (DateTime.now().difference(entry.timestamp) < ttl) {
        return entry.data as T?;
      } else {
        _cache.remove(key); // Expired
      }
    }
    return null;
  }

  void set<T>(String key, T data) {
    _cache[key] = _CacheEntry(data: data, timestamp: DateTime.now());
  }

  void clear(String key) {
    _cache.remove(key);
  }

  void clearAll() {
    _cache.clear();
  }
}
