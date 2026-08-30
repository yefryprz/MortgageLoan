import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/database/ai_analysis_repository.dart';

void main() {
  group('AiAnalysisRepository', () {
    late AiAnalysisRepository repository;

    setUp(() {
      repository = AiAnalysisRepository();
    });

    test('canPerformAiAnalysis returns true unconditionally for unlimited analyses', () async {
      final canPerform = await repository.canPerformAiAnalysis();
      expect(canPerform, isTrue);
    });
  });
}
