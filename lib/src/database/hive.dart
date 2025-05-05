import 'package:hive/hive.dart';
import 'package:mortgageloan/src/models/compound_interest_model.dart';
import 'package:mortgageloan/src/models/loan_model.dart';

class LoanData {
  var adKey = "adCount";

  void insertRecord(Loan? loan) async {
    final db = await Hive.openBox("loan");
    loan!.id = db.length + 1;
    db.put(loan.id, loan.toMap());
  }

  Future<List<Loan>> selectRecords() async {
    final db = await Hive.openBox("loan");
    final records = db.values.toList();
    return List.generate(records.length, (index) {
      return Loan(
          id: records[index]["id"],
          amount: records[index]["amount"],
          payment: records[index]["payment"],
          rate: records[index]["rate"],
          term: records[index]["term"],
          totalInterest: records[index]["totalInterest"] ?? 0.0);
    });
  }

  void deleteRecord(int? id) async {
    final db = await Hive.openBox("loan");
    db.delete(id);
  }

  void deleteAllRecord() async {
    final db = await Hive.openBox("loan");
    await db.clear();
  }

  void AdCountUp() async {
    final db = await Hive.openBox("ads");
    final records = db.get(adKey) ?? 0;
    await db.delete(adKey);
    db.put(adKey, records + 1);
  }

  Future<int> getAdCount() async {
    final db = await Hive.openBox("ads");
    final counter = db.get(adKey) ?? 0;
    return counter;
  }

  void resetAdCount() async {
    final db = await Hive.openBox("ads");
    db.clear();
  }

  Future<void> saveCompoundInterest(CompoundInterest calculation) async {
    final box = await Hive.openBox("compound_interest");
    calculation.id = box.length + 1;
    await box.put(calculation.id, calculation.toMap());
  }

  Future<List<CompoundInterest>> getCompoundInterestHistory() async {
    final box = await Hive.openBox("compound_interest");
    final records = box.values.toList();
    return List.generate(records.length, (index) {
      return CompoundInterest(
        id: records[index]["id"],
        principal: records[index]["principal"],
        rate: records[index]["rate"],
        years: records[index]["years"],
        result: records[index]["result"],
        date: records[index]["date"] != null
            ? DateTime.parse(records[index]["date"])
            : null,
      );
    }).reversed.toList();
  }

  Future<void> deleteCompoundInterest(int? id) async {
    if (id == null) return;
    final box = await Hive.openBox("compound_interest");
    await box.delete(id);
  }

  Future<void> deleteAllCompoundInterest() async {
    final box = await Hive.openBox("compound_interest");
    await box.clear();
  }

  Future<T?> getValue<T>(String key) async {
    final box = await Hive.openBox('app_data');
    return box.get(key) as T?;
  }

  Future<void> setValue<T>(String key, T value) async {
    final box = await Hive.openBox('app_data');
    await box.put(key, value);
  }
}
