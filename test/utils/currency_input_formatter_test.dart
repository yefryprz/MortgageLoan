import 'package:flutter_test/flutter_test.dart';
import 'package:mortgageloan/src/utils/currency_input_formatter.dart';

void main() {
  group('CurrencyInputFormatter', () {
    late CurrencyInputFormatter formatter;

    setUp(() {
      formatter = CurrencyInputFormatter();
    });

    test('formats plain numbers with commas', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1000000');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('1,000,000'));
    });

    test('preserves decimal numbers correctly', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1234.56');

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('1,234.56'));
    });

    test('handles empty input gracefully', () {
      const oldValue = TextEditingValue(text: '100');
      const newValue = TextEditingValue.empty;

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals(''));
    });
  });
}
