import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/utils/loan_calculator.dart';

void main() {
  group('LoanCalculator', () {
    test('calculateMonthlyPayment calculates correctly for standard mortgage', () {
      final payment = LoanCalculator.calculateMonthlyPayment(
        amount: 1000000,
        rate: 10.0,
        termYears: 5,
      );

      // Expected standard payment ~21,247.04
      expect(payment, closeTo(21247.04, 0.05));
    });

    test('calculateMonthlyPayment returns 0 for 0 or negative inputs', () {
      expect(
        LoanCalculator.calculateMonthlyPayment(
          amount: 0,
          rate: 5.0,
          termYears: 10,
        ),
        equals(0.0),
      );
      expect(
        LoanCalculator.calculateMonthlyPayment(
          amount: 100000,
          rate: 5.0,
          termYears: 0,
        ),
        equals(0.0),
      );
    });

    test('calculateTotalInterest computes correctly', () {
      final monthlyPayment = LoanCalculator.calculateMonthlyPayment(
        amount: 1000000,
        rate: 10.0,
        termYears: 5,
      );
      final totalInterest = LoanCalculator.calculateTotalInterest(
        monthlyPayment: monthlyPayment,
        termYears: 5,
        amount: 1000000,
      );

      // (21247.04 * 60) - 1000000 = ~274822.69
      expect(totalInterest, closeTo(274822.69, 1.0));
    });

    test('generateAmortizationSchedule creates complete month schedule', () {
      final schedule = LoanCalculator.generateAmortizationSchedule(
        monthlyPayment: 21247.04,
        amount: 1000000,
        rate: 10.0,
        termMonths: 60,
      );

      expect(schedule.isNotEmpty, isTrue);
      expect(schedule.first.month, equals(1));
      expect(schedule.last.balance, closeTo(0.0, 1.0));
    });
  });
}
