import 'package:hive/hive.dart';

class AdRepository {
  static const String boxName = 'ads';

  Future<Box<dynamic>> _openBox() async {
    return await Hive.openBox(boxName);
  }

  Future<void> incrementAdCount(String key) async {
    final db = await _openBox();
    final int records = (db.get(key) as int?) ?? 0;
    await db.put(key, records + 1);
  }

  Future<int> getAdCount(String key) async {
    final db = await _openBox();
    final int counter = (db.get(key) as int?) ?? 0;
    return counter;
  }

  Future<void> resetAdCount(String key) async {
    final db = await _openBox();
    await db.delete(key);
  }
}
