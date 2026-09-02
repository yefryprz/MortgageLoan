import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/models/loan_model.dart';

void main() {
  group('Loan Model', () {
    test('toMap and constructor work predictably', () {
      final now = DateTime.now();
      final loan = Loan(
        id: 1,
        amount: 250000,
        payment: 1500,
        rate: 6.5,
        term: 30,
        totalInterest: 100000,
        date: now,
      );

      final map = loan.toMap();
      expect(map['id'], equals(1));
      expect(map['amount'], equals(250000.0));
      expect(map['payment'], equals(1500.0));
      expect(map['rate'], equals(6.5));
      expect(map['term'], equals(30));
      expect(map['totalInterest'], equals(100000.0));
      expect(map['date'], equals(now.toIso8601String()));
    });
  });
}
