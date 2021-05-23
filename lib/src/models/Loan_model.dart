class Loan {
  int id;
  double amount;
  double payment;
  double rate;
  int term;

  Loan({this.id, this.amount, this.payment, this.rate, this.term});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "amount": amount,
      "payment": payment,
      "rate": rate,
      "term": term
    };
  }
}
