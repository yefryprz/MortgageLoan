import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/models/compound_interest_model.dart';

void main() {
  group('CompoundInterest Model', () {
    test('toMap and properties serialize correctly', () {
      final now = DateTime.now();
      final compound = CompoundInterest(
        id: 1,
        principal: 50000,
        rate: 7.0,
        years: 5,
        result: 70127.59,
        date: now,
      );

      final map = compound.toMap();
      expect(map['id'], equals(1));
      expect(map['principal'], equals(50000.0));
      expect(map['rate'], equals(7.0));
      expect(map['years'], equals(5));
      expect(map['result'], equals(70127.59));
      expect(map['date'], equals(now.toIso8601String()));
    });
  });
}
