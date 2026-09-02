import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
      cacheService.clearAll();
    });

    test('stores and retrieves cached values', () {
      cacheService.set('test_key', 'test_value');
      final value = cacheService.get<String>('test_key');
      expect(value, equals('test_value'));
    });

    test('returns null for missing or expired keys', () {
      expect(cacheService.get<String>('non_existent'), isNull);

      cacheService.set('short_lived', 'expires_soon');
      final value = cacheService.get<String>(
        'short_lived',
        ttl: const Duration(milliseconds: -1),
      );
      expect(value, isNull);
    });

    test('clears specific key and all keys', () {
      cacheService.set('key1', 'val1');
      cacheService.set('key2', 'val2');

      cacheService.clear('key1');
      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), equals('val2'));

      cacheService.clearAll();
      expect(cacheService.get<String>('key2'), isNull);
    });
  });
}
