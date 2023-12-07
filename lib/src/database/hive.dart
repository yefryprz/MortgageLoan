import 'package:hive/hive.dart';
import 'package:mortgageloan/src/models/Loan_model.dart';

class LoanData {
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
          term: records[index]["term"]);
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
}
