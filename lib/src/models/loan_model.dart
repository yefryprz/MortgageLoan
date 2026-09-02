class Loan {
  int? id;
  double? amount;
  double? payment;
  double? rate;
  int? term;
  double? totalInterest;
  DateTime? date;

  Loan({
    this.id,
    this.amount,
    this.payment,
    this.rate,
    this.term,
    this.totalInterest,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "amount": amount,
      "payment": payment,
      "rate": rate,
      "term": term,
      "totalInterest": totalInterest,
      "date": date?.toIso8601String(),
    };
  }
}
