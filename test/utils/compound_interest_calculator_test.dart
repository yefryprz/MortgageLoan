import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/utils/compound_interest_calculator.dart';

void main() {
  group('CompoundInterestCalculator', () {
    test('calculateFinalAmount calculates annual compounding correctly', () {
      final finalAmount = CompoundInterestCalculator.calculateFinalAmount(
        principal: 1000000,
        rate: 5.0,
        years: 10,
      );

      // 1000000 * (1.05)^10 = 1628894.626...
      expect(finalAmount, closeTo(1628894.63, 0.1));
    });

    test('generateYearlyBreakdown generates correct breakdown count', () {
      final breakdown = CompoundInterestCalculator.generateYearlyBreakdown(
        principal: 1000000,
        rate: 5.0,
        years: 10,
      );

      expect(breakdown.length, equals(10));
      expect(breakdown.first.year, equals(1));
      expect(breakdown.first.startBalance, equals(1000000.0));
      expect(breakdown.first.interest, equals(50000.0));
      expect(breakdown.first.endBalance, equals(1050000.0));
      expect(breakdown.last.year, equals(10));
      expect(breakdown.last.endBalance, closeTo(1628894.63, 0.1));
    });

    test('returns empty or zero for invalid inputs', () {
      expect(
        CompoundInterestCalculator.calculateFinalAmount(
          principal: 0,
          rate: 5.0,
          years: 10,
        ),
        equals(0.0),
      );
      expect(
        CompoundInterestCalculator.generateYearlyBreakdown(
          principal: 1000,
          rate: 5.0,
          years: 0,
        ),
        isEmpty,
      );
    });
  });
}
