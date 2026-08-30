import 'dart:math';

class LoanSimulationResult {
  final double totalInterest;
  final double monthsSaved;

  const LoanSimulationResult({
    required this.totalInterest,
    required this.monthsSaved,
  });
}

class LoanSimulationCalculator {
  const LoanSimulationCalculator._();

  static double calculateMonthlyPayment(
    double principal,
    double annualRate,
    int years,
  ) {
    if (principal <= 0 || years <= 0) return 0.0;
    if (annualRate == 0) return principal / (years * 12);
    final double r = (annualRate / 100) / 12;
    final int n = years * 12;
    final double factor = pow(1 + r, n).toDouble();
    return (principal * r * factor) / (factor - 1);
  }

  static LoanSimulationResult simulateLoan({
    required double principal,
    required double annualRate,
    required int years,
    double lumpSum = 0,
    int lumpSumMonth = 0,
    double monthlyExtra = 0,
  }) {
    if (principal <= 0 || years <= 0) {
      return const LoanSimulationResult(totalInterest: 0, monthsSaved: 0);
    }

    final double r = (annualRate / 100) / 12;
    final double standardMonthlyPayment =
        calculateMonthlyPayment(principal, annualRate, years);

    double balance = principal;
    double totalInterest = 0;
    int monthsElapsed = 0;

    for (int i = 1; i <= years * 12; i++) {
      if (balance <= 0) break;

      final double interestForMonth = balance * r;
      totalInterest += interestForMonth;

      double currentPayment = standardMonthlyPayment + monthlyExtra;

      if (i == lumpSumMonth) {
        currentPayment += lumpSum;
      }

      final double principalPayment = currentPayment - interestForMonth;
      balance -= principalPayment;
      monthsElapsed++;
    }

    final double monthsSaved = ((years * 12) - monthsElapsed).toDouble();

    return LoanSimulationResult(
      totalInterest: totalInterest,
      monthsSaved: monthsSaved > 0 ? monthsSaved : 0,
    );
  }
}
