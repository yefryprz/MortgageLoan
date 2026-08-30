import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/utils/loan_simulation_calculator.dart';

void main() {
  group('LoanSimulationCalculator', () {
    test('calculateMonthlyPayment matches financial formula', () {
      final payment = LoanSimulationCalculator.calculateMonthlyPayment(
        360000,
        5.5,
        30,
      );

      // Principal: 360,000, 5.5% 30yr = ~2044.04
      expect(payment, closeTo(2044.04, 0.5));
    });

    test('simulateLoan without extras returns full duration and standard interest', () {
      final result = LoanSimulationCalculator.simulateLoan(
        principal: 360000,
        annualRate: 5.5,
        years: 30,
      );

      expect(result.monthsSaved, equals(0.0));
      expect(result.totalInterest, greaterThan(300000));
    });

    test('simulateLoan with monthly extra reduces interest and saves months', () {
      final baseResult = LoanSimulationCalculator.simulateLoan(
        principal: 360000,
        annualRate: 5.5,
        years: 30,
      );

      final extraResult = LoanSimulationCalculator.simulateLoan(
        principal: 360000,
        annualRate: 5.5,
        years: 30,
        monthlyExtra: 500,
      );

      expect(extraResult.totalInterest, lessThan(baseResult.totalInterest));
      expect(extraResult.monthsSaved, greaterThan(0));
    });
  });
}
