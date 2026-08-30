import 'package:hive/hive.dart';
import 'package:mortgageloan/src/models/loan_model.dart';

class LoanRepository {
  static const String boxName = 'loan';

  Future<Box<dynamic>> _openBox() async {
    return await Hive.openBox(boxName);
  }

  Future<void> insertRecord(Loan loan) async {
    final db = await _openBox();
    final int id = db.length + 1;
    loan.id = id;
    await db.put(id, loan.toMap());
  }

  Future<List<Loan>> selectRecords() async {
    final db = await _openBox();
    final records = db.values.toList();
    return List.generate(records.length, (index) {
      final record = records[index] as Map<dynamic, dynamic>;
      return Loan(
        id: record['id'] as int?,
        amount: (record['amount'] as num?)?.toDouble(),
        payment: (record['payment'] as num?)?.toDouble(),
        rate: (record['rate'] as num?)?.toDouble(),
        term: record['term'] as int?,
        totalInterest: (record['totalInterest'] as num?)?.toDouble() ?? 0.0,
        date: record['date'] != null ? DateTime.tryParse(record['date'] as String) : null,
      );
    });
  }

  Future<void> deleteRecord(int? id) async {
    if (id == null) return;
    final db = await _openBox();
    await db.delete(id);
  }

  Future<void> deleteAllRecords() async {
    final db = await _openBox();
    await db.clear();
  }
}
