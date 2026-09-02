import 'package:hive/hive.dart';

class AppDataRepository {
  static const String boxName = 'app_data';

  Future<Box<dynamic>> _openBox() async {
    return await Hive.openBox(boxName);
  }

  Future<T?> getValue<T>(String key) async {
    final box = await _openBox();
    return box.get(key) as T?;
  }

  Future<void> setValue<T>(String key, T value) async {
    final box = await _openBox();
    await box.put(key, value);
  }
}
