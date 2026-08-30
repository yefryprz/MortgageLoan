import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class AiAnalysisRepository {
  static const String analysisBoxName = 'ai_analysis';
  static const String usageBoxName = 'ai_usage';

  Future<Box<dynamic>> _openAnalysisBox() async {
    return await Hive.openBox(analysisBoxName);
  }

  Future<Box<dynamic>> _openUsageBox() async {
    return await Hive.openBox(usageBoxName);
  }

  Future<void> saveAiAnalysis(
    Map<String, dynamic> responseJson,
    Map<String, dynamic> loanData,
  ) async {
    final box = await _openAnalysisBox();
    final int id = box.length + 1;
    await box.put(id, {
      'id': id,
      'date': DateTime.now().toIso8601String(),
      'response': responseJson,
      'loanData': loanData,
    });
  }

  Future<List<Map<String, dynamic>>> getAiAnalysisHistory() async {
    final box = await _openAnalysisBox();
    return box.values
        .cast<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
        .reversed
        .toList();
  }

  Future<void> deleteAiAnalysis(int id) async {
    final box = await _openAnalysisBox();
    await box.delete(id);
  }

  Future<void> deleteAllAiAnalysis() async {
    final box = await _openAnalysisBox();
    await box.clear();
  }

  Future<bool> canPerformAiAnalysis() async {
    final box = await _openUsageBox();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final int count = box.get(today) as int? ?? 0;
    return count < 1;
  }

  Future<void> incrementAiAnalysisCount() async {
    final box = await _openUsageBox();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final int count = box.get(today) as int? ?? 0;
    await box.put(today, count + 1);
  }

  Future<int> getRemainingAiAnalyses() async {
    final box = await _openUsageBox();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final int count = box.get(today) as int? ?? 0;
    return (1 - count).clamp(0, 1);
  }
}
