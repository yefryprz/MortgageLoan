import 'package:hive/hive.dart';
import 'package:mortgageloan/src/models/compound_interest_model.dart';

class CompoundInterestRepository {
  static const String boxName = 'compound_interest';

  Future<Box<dynamic>> _openBox() async {
    return await Hive.openBox(boxName);
  }

  Future<void> save(CompoundInterest calculation) async {
    final box = await _openBox();
    calculation.id = box.length + 1;
    await box.put(calculation.id, calculation.toMap());
  }

  Future<List<CompoundInterest>> getHistory() async {
    final box = await _openBox();
    final records = box.values.toList();
    return List.generate(records.length, (index) {
      final record = records[index] as Map<dynamic, dynamic>;
      return CompoundInterest(
        id: record['id'] as int?,
        principal: (record['principal'] as num?)?.toDouble(),
        rate: (record['rate'] as num?)?.toDouble(),
        years: record['years'] as int?,
        result: (record['result'] as num?)?.toDouble(),
        date: record['date'] != null
            ? DateTime.tryParse(record['date'] as String)
            : null,
      );
    }).reversed.toList();
  }

  Future<void> delete(int? id) async {
    if (id == null) return;
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> deleteAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
