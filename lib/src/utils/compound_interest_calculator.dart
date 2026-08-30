class CompoundBreakdownItem {
  final int year;
  final double startBalance;
  final double interest;
  final double endBalance;

  const CompoundBreakdownItem({
    required this.year,
    required this.startBalance,
    required this.interest,
    required this.endBalance,
  });

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'startBalance': startBalance,
      'interest': interest,
      'endBalance': endBalance,
    };
  }

  factory CompoundBreakdownItem.fromMap(Map<String, dynamic> map) {
    return CompoundBreakdownItem(
      year: map['year'] as int,
      startBalance: (map['startBalance'] as num).toDouble(),
      interest: (map['interest'] as num).toDouble(),
      endBalance: (map['endBalance'] as num).toDouble(),
    );
  }
}

class CompoundInterestCalculator {
  const CompoundInterestCalculator._();

  /// Calculates total compound balance after [years] at annual rate [rate]%
  static double calculateFinalAmount({
    required double principal,
    required double rate,
    required int years,
  }) {
    if (principal <= 0 || years <= 0) return 0.0;
    double amount = principal;
    for (int year = 1; year <= years; year++) {
      final double interest = amount * (rate / 100);
      amount += interest;
    }
    return amount;
  }

  /// Generates the year-by-year breakdown of compound growth
  static List<CompoundBreakdownItem> generateYearlyBreakdown({
    required double principal,
    required double rate,
    required int years,
  }) {
    if (principal <= 0 || years <= 0) return [];

    final List<CompoundBreakdownItem> yearlyDetails = [];
    double amount = principal;

    for (int year = 1; year <= years; year++) {
      final double interest = amount * (rate / 100);
      final double newAmount = amount + interest;

      yearlyDetails.add(
        CompoundBreakdownItem(
          year: year,
          startBalance: amount,
          interest: interest,
          endBalance: newAmount,
        ),
      );

      amount = newAmount;
    }

    return yearlyDetails;
  }
}
