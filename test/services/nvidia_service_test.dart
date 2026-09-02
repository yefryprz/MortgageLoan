import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/services/nvidia_service.dart';

void main() {
  group('NvidiaService', () {
    late NvidiaService nvidiaService;

    setUp(() {
      nvidiaService = NvidiaService();
    });

    test('can instantiate NvidiaService', () {
      expect(nvidiaService, isNotNull);
    });
  });
}
