import 'dart:math';

class AmortizationScheduleItem {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  const AmortizationScheduleItem({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}

class LoanCalculator {
  const LoanCalculator._();

  /// Calculates monthly payment based on standard amortization formula
  static double calculateMonthlyPayment({
    required double amount,
    required double rate,
    required int termYears,
  }) {
    if (amount <= 0 || termYears <= 0) return 0.0;
    if (rate <= 0) return amount / (termYears * 12);

    final double monthlyRate = rate / 100 / 12;
    final int totalMonths = termYears * 12;

    final double factor = pow(1 + monthlyRate, totalMonths).toDouble();
    final double payment = amount * (monthlyRate * factor) / (factor - 1);
    return payment;
  }

  /// Calculates total interest paid over the life of the loan
  static double calculateTotalInterest({
    required double monthlyPayment,
    required int termYears,
    required double amount,
  }) {
    if (amount <= 0 || termYears <= 0) return 0.0;
    final double totalAmount = monthlyPayment * (termYears * 12);
    final double totalInterest = totalAmount - amount;
    return totalInterest > 0 ? totalInterest : 0.0;
  }

  /// Generates the complete amortization schedule month by month
  static List<AmortizationScheduleItem> generateAmortizationSchedule({
    required double monthlyPayment,
    required double amount,
    required double rate,
    required int termMonths,
  }) {
    final List<AmortizationScheduleItem> rows = [];
    if (amount <= 0 || termMonths <= 0) return rows;

    double balance = amount;
    double currentMonthlyPayment = monthlyPayment;
    final double monthlyRate = rate / 100 / 12;

    for (int month = 1; month <= termMonths; month++) {
      final double interest =
          double.parse((balance * monthlyRate).toStringAsFixed(2));
      double principal =
          double.parse((currentMonthlyPayment - interest).toStringAsFixed(2));

      if (balance < currentMonthlyPayment) {
        principal = balance;
        currentMonthlyPayment = principal + interest;
      }

      balance = double.parse((balance - principal).toStringAsFixed(2));
      if (balance < 0) balance = 0;

      rows.add(
        AmortizationScheduleItem(
          month: month,
          payment: currentMonthlyPayment,
          principal: principal,
          interest: interest,
          balance: balance,
        ),
      );

      if (balance <= 0) break;
    }
    return rows;
  }
}
