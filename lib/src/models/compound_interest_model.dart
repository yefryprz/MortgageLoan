class CompoundInterest {
  int? id;
  double? principal;
  double? rate;
  int? years;
  double? result;
  DateTime? date;

  CompoundInterest({
    this.id,
    this.principal,
    this.rate,
    this.years,
    this.result,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "principal": principal,
      "rate": rate,
      "years": years,
      "result": result,
      "date": date?.toIso8601String(),
    };
  }
}
